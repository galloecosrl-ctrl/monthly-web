-- ============================================================================
-- AffittoMese - Schema database (MVP)
-- Da eseguire UNA VOLTA nel SQL Editor di Supabase (Dashboard > SQL Editor)
-- del NUOVO progetto Supabase dedicato ad AffittoMese (non quello di
-- ComputoAI). Rieseguirlo su un database gia' inizializzato segnala errori
-- "already exists" innocui.
--
-- Modello: i proprietari pubblicano annunci di affitto mensile (camere,
-- monolocali, appartamenti, case); gli inquilini registrati inviano
-- richieste di prenotazione; il proprietario accetta o rifiuta. I contatti
-- si scambiano solo dopo l'accettazione (l'inquilino vede i contatti del
-- proprietario; il proprietario vede quelli dell'inquilino gia' dalla
-- richiesta, per potergli rispondere).
-- ============================================================================

-- ─── TABELLE ────────────────────────────────────────────────────────────────

-- Collega gli utenti di Supabase Auth (auth.users) al loro profilo pubblico.
-- Creato automaticamente dal trigger alla registrazione.
create table public.profili (
  id         uuid primary key references auth.users (id) on delete cascade,
  email      text,
  nome       text,
  telefono   text,
  -- 'utente' per tutti; 'admin' si assegna a mano via SQL (vedi in fondo).
  ruolo      text not null default 'utente' check (ruolo in ('utente','admin')),
  creato_il  timestamptz not null default now()
);

-- Gli annunci dei proprietari.
create table public.annunci (
  id              uuid primary key default gen_random_uuid(),
  proprietario    uuid not null references auth.users (id) on delete cascade,
  titolo          text not null,
  tipologia       text not null check (tipologia in ('camera','monolocale','appartamento','casa')),
  citta           text not null,
  zona            text,
  -- Indirizzo completo: visibile SOLO al proprietario (e all'admin); al
  -- pubblico si mostrano solo citta' e zona. Si comunica dopo l'accettazione.
  indirizzo       text,
  descrizione     text,
  mq              integer,
  camere          integer,
  bagni           integer,
  posti_letto     integer,
  arredato        boolean not null default true,
  -- Elenco libero di servizi: 'wifi', 'lavatrice', 'aria condizionata', ...
  servizi         text[] not null default '{}',
  prezzo_mese     numeric(10,2) not null,
  spese_incluse   boolean not null default false,
  spese_mese      numeric(10,2),
  cauzione        numeric(10,2),
  minimo_mesi     integer not null default 1,
  disponibile_dal date,
  stato           text not null default 'bozza' check (stato in ('bozza','pubblicato','sospeso')),
  creato_il       timestamptz not null default now(),
  aggiornato_il   timestamptz not null default now()
);

create index annunci_proprietario_idx on public.annunci (proprietario);
create index annunci_ricerca_idx on public.annunci (stato, citta, tipologia, prezzo_mese);

-- Le foto degli annunci: i file vivono nel bucket Storage "foto-annunci"
-- (pubblico in lettura), qui c'e' il percorso e l'ordine di visualizzazione.
create table public.foto_annunci (
  id          bigint generated always as identity primary key,
  annuncio_id uuid not null references public.annunci (id) on delete cascade,
  percorso    text not null,
  posizione   integer not null default 0
);

create index foto_annunci_annuncio_idx on public.foto_annunci (annuncio_id);

-- Le richieste di prenotazione degli inquilini.
create table public.richieste (
  id          uuid primary key default gen_random_uuid(),
  annuncio_id uuid not null references public.annunci (id) on delete cascade,
  inquilino   uuid not null references auth.users (id) on delete cascade,
  dal         date not null,
  mesi        integer not null check (mesi >= 1),
  messaggio   text,
  stato       text not null default 'inviata' check (stato in ('inviata','accettata','rifiutata','annullata')),
  creata_il   timestamptz not null default now()
);

create index richieste_annuncio_idx on public.richieste (annuncio_id);
create index richieste_inquilino_idx on public.richieste (inquilino);

-- ─── FUNZIONI DI SUPPORTO ───────────────────────────────────────────────────
-- SECURITY DEFINER: leggono le tabelle senza passare dalle policy, per
-- evitare ricorsioni RLS nelle policy che le usano.

-- Alla registrazione di un nuovo utente in auth.users crea la riga profilo,
-- copiando l'email (serve al proprietario per rispondere alle richieste).
create function public.handle_new_user()
returns trigger
language plpgsql security definer
set search_path = public
as $$
begin
  insert into public.profili (id, email) values (new.id, new.email);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- L'utente corrente e' admin?
create function public.sono_admin()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profili
    where id = auth.uid() and ruolo = 'admin'
  );
$$;

-- L'utente corrente puo' vedere il profilo (contatti) di "persona"?
-- Si', in due casi:
--   1. sono il proprietario di un annuncio su cui "persona" ha inviato
--      una richiesta (devo poterla ricontattare);
--   2. "persona" e' il proprietario di un annuncio per cui una MIA
--      richiesta e' stata ACCETTATA (mi ha aperto i contatti accettando).
create function public.puo_vedere_profilo(persona uuid)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.richieste r
    join public.annunci a on a.id = r.annuncio_id
    where (a.proprietario = auth.uid() and r.inquilino = persona)
       or (r.inquilino = auth.uid() and a.proprietario = persona and r.stato = 'accettata')
  );
$$;

-- Tiene aggiornato aggiornato_il sugli annunci.
create function public.touch_annuncio()
returns trigger
language plpgsql
as $$
begin
  new.aggiornato_il := now();
  return new;
end;
$$;

create trigger annunci_touch
  before update on public.annunci
  for each row execute function public.touch_annuncio();

-- ─── ROW-LEVEL SECURITY ─────────────────────────────────────────────────────
-- Le garanzie di riservatezza sono imposte qui, dal database stesso,
-- qualunque cosa faccia il codice applicativo.

alter table public.profili      enable row level security;
alter table public.annunci      enable row level security;
alter table public.foto_annunci enable row level security;
alter table public.richieste    enable row level security;

-- profili: ognuno vede e modifica il proprio; i contatti degli altri solo
-- nei casi previsti da puo_vedere_profilo(); l'admin vede tutti.
create policy "profili: lettura propria o consentita"
  on public.profili for select
  to authenticated
  using (id = auth.uid() or public.puo_vedere_profilo(id) or public.sono_admin());

create policy "profili: modifica propria"
  on public.profili for update
  to authenticated
  using (id = auth.uid())
  with check ((id = auth.uid() and ruolo = 'utente') or public.sono_admin());

-- annunci: quelli pubblicati li vedono tutti, anche i non registrati.
create policy "annunci: pubblicati visibili a tutti"
  on public.annunci for select
  to anon, authenticated
  using (stato = 'pubblicato');

-- Il proprietario vede sempre i propri (anche bozze e sospesi); l'admin tutti.
create policy "annunci: lettura propria o admin"
  on public.annunci for select
  to authenticated
  using (proprietario = auth.uid() or public.sono_admin());

create policy "annunci: creazione propria"
  on public.annunci for insert
  to authenticated
  with check (proprietario = auth.uid());

create policy "annunci: modifica propria o admin"
  on public.annunci for update
  to authenticated
  using (proprietario = auth.uid() or public.sono_admin())
  with check (proprietario = auth.uid() or public.sono_admin());

create policy "annunci: cancellazione propria o admin"
  on public.annunci for delete
  to authenticated
  using (proprietario = auth.uid() or public.sono_admin());

-- foto_annunci: seguono la visibilita' dell'annuncio.
create policy "foto: visibili con l'annuncio"
  on public.foto_annunci for select
  to anon, authenticated
  using (exists (
    select 1 from public.annunci a
    where a.id = annuncio_id
      and (a.stato = 'pubblicato' or a.proprietario = auth.uid() or public.sono_admin())
  ));

create policy "foto: gestione del proprietario"
  on public.foto_annunci for all
  to authenticated
  using (exists (
    select 1 from public.annunci a
    where a.id = annuncio_id and (a.proprietario = auth.uid() or public.sono_admin())
  ))
  with check (exists (
    select 1 from public.annunci a
    where a.id = annuncio_id and (a.proprietario = auth.uid() or public.sono_admin())
  ));

-- richieste: l'inquilino crea richieste a proprio nome su annunci pubblicati
-- (non sui propri annunci).
create policy "richieste: invio dell'inquilino"
  on public.richieste for insert
  to authenticated
  with check (
    inquilino = auth.uid()
    and exists (
      select 1 from public.annunci a
      where a.id = annuncio_id and a.stato = 'pubblicato' and a.proprietario <> auth.uid()
    )
  );

-- Le vedono l'inquilino che le ha inviate e il proprietario dell'annuncio.
create policy "richieste: lettura delle parti"
  on public.richieste for select
  to authenticated
  using (
    inquilino = auth.uid()
    or exists (select 1 from public.annunci a where a.id = annuncio_id and a.proprietario = auth.uid())
    or public.sono_admin()
  );

-- L'inquilino puo' solo annullare la propria richiesta.
create policy "richieste: annullamento dell'inquilino"
  on public.richieste for update
  to authenticated
  using (inquilino = auth.uid())
  with check (inquilino = auth.uid() and stato = 'annullata');

-- Il proprietario risponde (accetta/rifiuta) alle richieste sui suoi annunci.
create policy "richieste: risposta del proprietario"
  on public.richieste for update
  to authenticated
  using (exists (select 1 from public.annunci a where a.id = annuncio_id and a.proprietario = auth.uid()))
  with check (
    exists (select 1 from public.annunci a where a.id = annuncio_id and a.proprietario = auth.uid())
    and stato in ('accettata','rifiutata')
  );

-- Nessuna policy insert/update/delete per il ruolo "anon": i non registrati
-- possono solo consultare gli annunci pubblicati. Il service_role (solo
-- server-side) bypassa RLS per definizione: mai usarlo nel browser.

-- ─── STORAGE: bucket per le foto degli annunci ──────────────────────────────
-- Bucket pubblico in lettura (le foto degli annunci sono pubbliche per
-- natura); scrittura solo nella propria cartella "<uid>/...".

insert into storage.buckets (id, name, public)
values ('foto-annunci', 'foto-annunci', true)
on conflict (id) do nothing;

create policy "foto-annunci: lettura pubblica"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'foto-annunci');

create policy "foto-annunci: caricamento nella propria cartella"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'foto-annunci'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "foto-annunci: cancellazione nella propria cartella"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'foto-annunci'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ─── NOMINA ADMIN ───────────────────────────────────────────────────────────
-- Da eseguire DOPO che l'account si e' registrato sul sito:
--
--   update public.profili set ruolo = 'admin'
--   where email = 'galloecosrl@gmail.com';
