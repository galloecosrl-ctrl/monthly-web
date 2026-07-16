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
-- Prezzi Villino Elda: REALI (confermati dall'utente il 16/07/2026).
-- Prezzo Berardi: ancora SEGNAPOSTO da confermare. Gli annunci nascono in
-- stato 'bozza': si rifiniscono e si pubblicano dall'area riservata.
-- ============================================================================

-- Villino Elda: 4 camere prenotabili separatamente, Pigneto (via Auconi).
with andrea as (
  select id from auth.users where email = 'galloecosrl@gmail.com'
), annuncio as (
  insert into public.annunci
    (proprietario, titolo, tipologia, citta, zona, descrizione,
     camere, bagni, posti_letto, arredato, servizi,
     prezzo_mese, spese_incluse, minimo_mesi, stato)
  select id,
    'Villino Elda - Camere in villino con giardino al Pigneto',
    'camera', 'Roma', 'Pigneto',
    'Villino indipendente nel cuore del Pigneto, a 200 metri dalla fermata Malatesta della Metro C: 4 camere arredate, 3 bagni, salone e cucina in comune e 600 mq di giardino, perfetto per studiare o rilassarsi all''aperto.' || E'\n\n' ||
    'Ogni camera ha il suo carattere e si prenota separatamente, col suo prezzo: due hanno il bagno privato, due condividono il bagno. La casa e'' pensata per studenti e giovani lavoratori.' || E'\n\n' ||
    'Gestione familiare con anni di esperienza nell''ospitalita'' (ex B&B pluripremiato su Booking.com): contratto regolare a uso transitorio, zero sorprese. Cauzione pari a una mensilita''.',
    4, 3, 4, true,
    array['wifi','giardino 600 mq','salone comune','cucina condivisa','lavatrice','aria condizionata','biancheria inclusa']::text[],
    640.00,  -- prezzo di partenza (minimo tra le camere)
    true, 3, 'bozza'
  from andrea
  returning id
), foto as (
  insert into public.foto_annunci (annuncio_id, percorso, posizione)
  select annuncio.id, f.percorso, f.posizione from annuncio, (values
    ('/foto/villino-elda/01-camera-lilla.jpg', 0),
    ('/foto/villino-elda/02-giardino.jpg', 1),
    ('/foto/villino-elda/03-camera-pesca.jpg', 2),
    ('/foto/villino-elda/04-camera-verde.jpg', 3),
    ('/foto/villino-elda/05-camera-gialla.jpg', 4),
    ('/foto/villino-elda/06-esterno.jpg', 5),
    ('/foto/villino-elda/07-bagno.jpg', 6)
  ) as f(percorso, posizione)
)
insert into public.camere_annuncio (annuncio_id, nome, prezzo_mese, bagno, foto, posizione)
select annuncio.id, c.nome, c.prezzo_mese, c.bagno, c.foto, c.posizione from annuncio, (values
  ('Camera gialla',    680.00, 'privato',   '/foto/villino-elda/05-camera-gialla.jpg', 0),
  ('Camera viola',     680.00, 'privato',   '/foto/villino-elda/01-camera-lilla.jpg',  1),
  ('Camera verde',     640.00, 'condiviso', '/foto/villino-elda/04-camera-verde.jpg',  2),
  ('Camera arancione', 640.00, 'condiviso', '/foto/villino-elda/03-camera-pesca.jpg',  3)
) as c(nome, prezzo_mese, bagno, foto, posizione);

-- Berardi: appartamento ristrutturato e arredato (via Angelo Berardi 15, Roma).
with annuncio as (
  insert into public.annunci
    (proprietario, titolo, tipologia, citta, indirizzo, descrizione,
     mq, camere, bagni, posti_letto, arredato, servizi,
     prezzo_mese, spese_incluse, minimo_mesi, stato)
  select id,
    'Berardi - Appartamento arredato in affitto mensile',
    'appartamento', 'Roma', 'Via Angelo Berardi 15',
    'Appartamento completamente ristrutturato e arredato con cura: zona notte con divisorio in doghe di legno e cabina armadio, cucina abitabile attrezzata, bagno moderno con doccia.' || E'\n\n' ||
    'Ideale per professionisti, professori e lavoratori in trasferta che cercano una base comoda per qualche mese. Contratto regolare a uso transitorio, gestione diretta della proprieta''.',
    70, 2, 1, 3, true,
    array['wifi','aria condizionata','lavatrice','cucina attrezzata','biancheria inclusa']::text[],
    1200.00,  -- SEGNAPOSTO
    false, 1, 'bozza'
  from auth.users where email = 'galloecosrl@gmail.com'
  returning id
)
insert into public.foto_annunci (annuncio_id, percorso, posizione)
select annuncio.id, f.percorso, f.posizione from annuncio, (values
  ('/foto/berardi/01-camera.jpg', 0),
  ('/foto/berardi/02-camera-vista.jpg', 1),
  ('/foto/berardi/03-cabina-armadio.jpg', 2),
  ('/foto/berardi/04-cucina.jpg', 3),
  ('/foto/berardi/05-cucina-dettaglio.jpg', 4),
  ('/foto/berardi/06-bagno.jpg', 5),
  ('/foto/berardi/07-ingresso.jpg', 6)
) as f(percorso, posizione);
