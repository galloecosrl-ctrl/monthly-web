-- ============================================================================
-- Monthly - Annunci iniziali delle proprieta' Gallo & Co. srl
-- Da eseguire nel SQL Editor di Supabase DOPO schema.sql e DOPO che
-- l'account galloecosrl@gmail.com si e' registrato sul sito (gli annunci
-- vengono intestati a quell'account).
--
-- I contenuti rispecchiano vetrina.js (gli annunci dimostrativi mostrati
-- prima dell'attivazione del database): tenere i due file allineati.
-- Le foto puntano a file serviti dal sito stesso (/foto/...): il frontend
-- riconosce i percorsi che iniziano con "/" e non passa dallo Storage.
--
-- ATTENZIONE: PREZZI E CAUZIONI SONO SEGNAPOSTO da confermare. Gli annunci
-- nascono in stato 'bozza': si rifiniscono e si pubblicano dall'area
-- riservata.
-- ============================================================================

-- Villino Elda: camera in villino con giardino, Pigneto (via Auconi).
with andrea as (
  select id from auth.users where email = 'galloecosrl@gmail.com'
), annuncio as (
  insert into public.annunci
    (proprietario, titolo, tipologia, citta, zona, descrizione,
     camere, bagni, posti_letto, arredato, servizi,
     prezzo_mese, spese_incluse, cauzione, minimo_mesi, stato)
  select id,
    'Villino Elda - Camera in villino con giardino al Pigneto',
    'camera', 'Roma', 'Pigneto',
    'Camera arredata in un villino indipendente con giardino, nel cuore del Pigneto, a 200 metri dalla fermata Malatesta della Metro C.' || E'\n\n' ||
    'La casa e'' pensata per studenti e giovani lavoratori: ogni camera ha il suo carattere, con bagno dedicato, e si condividono la cucina e il giardino, perfetto per studiare o rilassarsi all''aperto.' || E'\n\n' ||
    'Gestione familiare con anni di esperienza nell''ospitalita'' (ex B&B pluripremiato su Booking.com): contratto regolare a uso transitorio, zero sorprese.',
    1, 1, 2, true,
    array['wifi','giardino','cucina condivisa','lavatrice','aria condizionata','biancheria inclusa']::text[],
    550.00,  -- SEGNAPOSTO
    true,
    550.00,  -- SEGNAPOSTO
    3, 'bozza'
  from andrea
  returning id
)
insert into public.foto_annunci (annuncio_id, percorso, posizione)
select annuncio.id, f.percorso, f.posizione from annuncio, (values
  ('/foto/villino-elda/01-camera-lilla.jpg', 0),
  ('/foto/villino-elda/02-giardino.jpg', 1),
  ('/foto/villino-elda/03-camera-pesca.jpg', 2),
  ('/foto/villino-elda/04-camera-verde.jpg', 3),
  ('/foto/villino-elda/05-camera-gialla.jpg', 4),
  ('/foto/villino-elda/06-esterno.jpg', 5),
  ('/foto/villino-elda/07-bagno.jpg', 6)
) as f(percorso, posizione);

-- Berardi: appartamento arredato (via Berardi 15, Roma). Foto da aggiungere
-- dall'area riservata quando disponibili.
insert into public.annunci
  (proprietario, titolo, tipologia, citta, indirizzo, descrizione,
   mq, camere, bagni, posti_letto, arredato, servizi,
   prezzo_mese, spese_incluse, minimo_mesi, stato)
select id,
  'Berardi - Appartamento arredato in affitto mensile',
  'appartamento', 'Roma', 'Via Berardi 15',
  'Appartamento completo e arredato, ideale per professionisti, professori e lavoratori in trasferta che cercano una base comoda per qualche mese.' || E'\n\n' ||
  'Contratto regolare a uso transitorio, gestione diretta della proprieta''.',
  70, 2, 1, 3, true,
  array['wifi','lavatrice','cucina attrezzata']::text[],
  1200.00,  -- SEGNAPOSTO
  false, 1, 'bozza'
from auth.users where email = 'galloecosrl@gmail.com';
