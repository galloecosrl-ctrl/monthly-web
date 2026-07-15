# AffittoMese

Piattaforma di affitti mensili in stile booking: i proprietari pubblicano camere,
monolocali, appartamenti e case; studenti, professionisti e lavoratori in trasferta
inviano richieste di prenotazione per periodi di uno o piu' mesi. Servizio di
Gallo & Co. srl. **"AffittoMese" e' un nome di lavoro**: quando si sceglie il brand
definitivo basta un trova-e-sostituisci nei file HTML/CSS e nel `package.json`.

Stessa infrastruttura di ComputoAI: sito statico + Netlify Functions + Supabase
(autenticazione e database PostgreSQL con row-level security), deploy manuale su
Netlify, repo GitHub separato.

## Struttura

| File | Cosa fa |
|---|---|
| `index.html` | Home con ricerca (citta', tipologia, budget) e griglia annunci pubblicati |
| `annuncio.html` | Dettaglio annuncio: galleria foto, caratteristiche, richiesta di prenotazione |
| `area-riservata.html` | Login/registrazione, profilo, richieste inviate, gestione annunci e foto, richieste ricevute, pannello admin |
| `privacy.html` | Informativa privacy (titolare Gallo & Co. srl) |
| `stile.css`, `app.js` | Stile e utilita' condivisi da tutte le pagine |
| `netlify/functions/getSupabaseConfig.js` | Consegna al browser URL e chiave pubblica Supabase (dalle env Netlify) |
| `supabase/schema.sql` | Tabelle, policy RLS, trigger e bucket Storage: da eseguire una volta nel SQL Editor |
| `supabase/seed-gallo.sql` | Bozze degli annunci Villino Elda e Berardi (prezzi segnaposto da correggere) |

## Messa online (da fare una volta)

1. **Supabase**: creare un NUOVO progetto (non riusare quello di ComputoAI).
   Nel SQL Editor eseguire `supabase/schema.sql`.
   In Authentication > URL Configuration impostare il dominio del sito come Site URL.
   Per Google OAuth: stessa procedura fatta per ComputoAI (progetto Google Cloud,
   client web, redirect al callback Supabase).
2. **Netlify**: creare un nuovo sito, caricare questa cartella (deploy manuale come
   per ComputoAI). Nelle variabili d'ambiente impostare:
   - `SUPABASE_URL` = URL del progetto (solo origine, es. `https://xxx.supabase.co`)
   - `SUPABASE_ANON_KEY` = chiave publishable/anon
3. **Admin**: registrarsi sul sito con galloecosrl@gmail.com, poi nel SQL Editor:
   `update public.profili set ruolo = 'admin' where email = 'galloecosrl@gmail.com';`
4. **Annunci Gallo & Co.**: eseguire `supabase/seed-gallo.sql`, poi dall'area
   riservata completare indirizzi e prezzi reali, caricare le foto e pubblicare.
5. **Dominio**: quando scelto, aggiornare `robots.txt` e `sitemap.xml`.
6. **GitHub**: creare un repo privato dedicato (es. `galloecosrl-ctrl/affittomese-web`)
   e collegarlo come remote `origin`.

## Regole di sicurezza (imposte dal database, non dal codice)

- Gli annunci **pubblicati** sono visibili a tutti, anche senza account; bozze e
  sospesi solo al proprietario e all'admin.
- L'**indirizzo completo** non e' mai mostrato al pubblico (solo citta' e zona).
- Le **richieste** le vedono solo inquilino e proprietario dell'annuncio.
- I **contatti** (nome, email, telefono) si aprono solo in trattativa: il
  proprietario vede quelli di chi gli scrive; l'inquilino vede quelli del
  proprietario solo dopo l'accettazione.
- Le **foto** si caricano solo nella propria cartella del bucket `foto-annunci`.
- Nessuna chiave segreta nel codice: tutto nelle env di Netlify.

## Prossimi passi possibili (non ancora implementati)

- Pagamenti Stripe (caparra o canone online) — per ora l'accordo si chiude fuori piattaforma.
- Calendario disponibilita' e blocco date.
- Notifiche email a proprietario/inquilino su nuove richieste e risposte.
- Recensioni e verifica dell'identita'.
