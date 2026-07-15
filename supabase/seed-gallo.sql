-- ============================================================================
-- AffittoMese - Annunci iniziali delle proprieta' Gallo & Co. srl
-- Da eseguire nel SQL Editor di Supabase DOPO schema.sql e DOPO che
-- l'account galloecosrl@gmail.com si e' registrato sul sito (gli annunci
-- vengono intestati a quell'account).
--
-- Gli annunci nascono in stato 'bozza': si completano (indirizzo, prezzi
-- reali, foto) e si pubblicano dall'area riservata del sito.
-- I valori di prezzo/mq/camere qui sotto sono SEGNAPOSTO da correggere.
-- ============================================================================

with andrea as (
  select id from auth.users where email = 'galloecosrl@gmail.com'
)
insert into public.annunci
  (proprietario, titolo, tipologia, citta, zona, descrizione,
   mq, camere, bagni, posti_letto, arredato, servizi,
   prezzo_mese, spese_incluse, minimo_mesi, stato)
select andrea.id, v.* from andrea, (values
  ('Villino Elda - Camera in villino per studenti',
   'camera',
   'Frosinone',            -- CORREGGERE se serve
   null,
   'Camera arredata in villino con spazi comuni condivisi, ideale per studenti e giovani lavoratori. Affitto mensile, contratto flessibile.',
   16, 1, 1, 1, true,
   array['wifi','lavatrice','cucina condivisa']::text[],
   300.00,                 -- SEGNAPOSTO: prezzo reale da inserire
   true, 1, 'bozza'),
  ('Berardi - Appartamento in affitto mensile',
   'appartamento',
   'Frosinone',            -- CORREGGERE se serve
   null,
   'Appartamento completo arredato, adatto a professionisti, professori e lavoratori in trasferta. Affitto mensile.',
   70, 2, 1, 3, true,
   array['wifi','lavatrice','cucina attrezzata']::text[],
   650.00,                 -- SEGNAPOSTO: prezzo reale da inserire
   false, 1, 'bozza')
) as v(titolo, tipologia, citta, zona, descrizione,
       mq, camere, bagni, posti_letto, arredato, servizi,
       prezzo_mese, spese_incluse, minimo_mesi, stato);
