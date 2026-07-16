// Monthly - annunci vetrina delle proprieta' Gallo & Co. srl.
// Servono a due cose:
//   1. far vedere il sito "vivo" prima che il database Supabase sia attivo
//      (la home e la pagina annuncio ricadono su questi dati se il database
//      non risponde);
//   2. documentare i contenuti ufficiali dei due annunci, che in produzione
//      vivranno nel database (vedi supabase/seed-gallo.sql).
// ATTENZIONE: i prezzi sono SEGNAPOSTO da confermare.

window.AM_VETRINA = [
  {
    id: "villino-elda",
    titolo: "Villino Elda - Camere in villino con giardino al Pigneto",
    tipologia: "camera",
    citta: "Roma",
    zona: "Pigneto",
    indirizzo: "Via Auconi 22",
    descrizione: "Villino indipendente nel cuore del Pigneto, a 200 metri dalla fermata Malatesta della Metro C: 4 camere arredate, 3 bagni, salone e cucina in comune e 600 mq di giardino, perfetto per studiare o rilassarsi all'aperto.\n\nOgni camera ha il suo carattere e si prenota separatamente, col suo prezzo: due hanno il bagno privato, due condividono il bagno. La casa e' pensata per studenti e giovani lavoratori.\n\nGestione familiare con anni di esperienza nell'ospitalita' (ex B&B pluripremiato su Booking.com): contratto regolare a uso transitorio, zero sorprese. Cauzione pari a una mensilita'.",
    mq: null,
    camere: 4,
    bagni: 3,
    posti_letto: 4,
    arredato: true,
    servizi: ["wifi", "giardino 600 mq", "salone comune", "cucina condivisa", "lavatrice", "aria condizionata"],
    prezzo_mese: 640,
    spese_incluse: true,
    spese_mese: null,
    cauzione: null,
    minimo_mesi: 3,
    disponibile_dal: null,
    stato: "pubblicato",
    camere_annuncio: [
      { id: 1, nome: "Camera gialla", prezzo_mese: 680, bagno: "privato", foto: "/foto/villino-elda/05-camera-gialla.jpg", posizione: 0 },
      { id: 2, nome: "Camera viola", prezzo_mese: 680, bagno: "privato", foto: "/foto/villino-elda/01-camera-lilla.jpg", posizione: 1 },
      { id: 3, nome: "Camera verde", prezzo_mese: 640, bagno: "condiviso", foto: "/foto/villino-elda/04-camera-verde.jpg", posizione: 2 },
      { id: 4, nome: "Camera arancione", prezzo_mese: 640, bagno: "condiviso", foto: "/foto/villino-elda/03-camera-pesca.jpg", posizione: 3 }
    ],
    foto_annunci: [
      { percorso: "/foto/villino-elda/01-camera-lilla.jpg", posizione: 0, camera_id: 2 },
      { percorso: "/foto/villino-elda/02-giardino.jpg", posizione: 1, camera_id: null },
      { percorso: "/foto/villino-elda/03-camera-pesca.jpg", posizione: 2, camera_id: 4 },
      { percorso: "/foto/villino-elda/04-camera-verde.jpg", posizione: 3, camera_id: 3 },
      { percorso: "/foto/villino-elda/05-camera-gialla.jpg", posizione: 4, camera_id: 1 },
      { percorso: "/foto/villino-elda/06-esterno.jpg", posizione: 5, camera_id: null },
      { percorso: "/foto/villino-elda/07-bagno.jpg", posizione: 6, camera_id: 3 },
      { percorso: "/foto/villino-elda/07-bagno.jpg", posizione: 7, camera_id: 4 }
    ]
  },
  {
    id: "berardi",
    titolo: "Berardi - Appartamento arredato in affitto mensile",
    tipologia: "appartamento",
    citta: "Roma",
    zona: null,
    indirizzo: "Via Angelo Berardi 15",
    descrizione: "Appartamento completamente ristrutturato e arredato con cura: zona notte con divisorio in doghe di legno e cabina armadio, cucina abitabile attrezzata, bagno moderno con doccia.\n\nIdeale per professionisti, professori e lavoratori in trasferta che cercano una base comoda per qualche mese. Contratto regolare a uso transitorio, gestione diretta della proprieta'.",
    mq: 70,
    camere: 2,
    bagni: 1,
    posti_letto: 3,
    arredato: true,
    servizi: ["wifi", "aria condizionata", "lavatrice", "cucina attrezzata"],
    prezzo_mese: 1200,
    spese_incluse: false,
    spese_mese: null,
    cauzione: null,
    minimo_mesi: 1,
    disponibile_dal: null,
    stato: "pubblicato",
    foto_annunci: [
      { percorso: "/foto/berardi/01-camera.jpg", posizione: 0 },
      { percorso: "/foto/berardi/02-camera-vista.jpg", posizione: 1 },
      { percorso: "/foto/berardi/03-cabina-armadio.jpg", posizione: 2 },
      { percorso: "/foto/berardi/04-cucina.jpg", posizione: 3 },
      { percorso: "/foto/berardi/05-cucina-dettaglio.jpg", posizione: 4 },
      { percorso: "/foto/berardi/06-bagno.jpg", posizione: 5 },
      { percorso: "/foto/berardi/07-ingresso.jpg", posizione: 6 }
    ]
  }
];
