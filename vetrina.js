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
    titolo: "Villino Elda - Camera in villino con giardino al Pigneto",
    tipologia: "camera",
    citta: "Roma",
    zona: "Pigneto",
    descrizione: "Camera arredata in un villino indipendente con giardino, nel cuore del Pigneto, a 200 metri dalla fermata Malatesta della Metro C.\n\nLa casa e' pensata per studenti e giovani lavoratori: ogni camera ha il suo carattere, con bagno dedicato, e si condividono la cucina e il giardino, perfetto per studiare o rilassarsi all'aperto.\n\nGestione familiare con anni di esperienza nell'ospitalita' (ex B&B pluripremiato su Booking.com): contratto regolare a uso transitorio, zero sorprese.",
    mq: null,
    camere: 1,
    bagni: 1,
    posti_letto: 2,
    arredato: true,
    servizi: ["wifi", "giardino", "cucina condivisa", "lavatrice", "aria condizionata", "biancheria inclusa"],
    prezzo_mese: 550,
    spese_incluse: true,
    spese_mese: null,
    cauzione: 550,
    minimo_mesi: 3,
    disponibile_dal: null,
    stato: "pubblicato",
    foto_annunci: [
      { percorso: "/foto/villino-elda/01-camera-lilla.jpg", posizione: 0 },
      { percorso: "/foto/villino-elda/02-giardino.jpg", posizione: 1 },
      { percorso: "/foto/villino-elda/03-camera-pesca.jpg", posizione: 2 },
      { percorso: "/foto/villino-elda/04-camera-verde.jpg", posizione: 3 },
      { percorso: "/foto/villino-elda/05-camera-gialla.jpg", posizione: 4 },
      { percorso: "/foto/villino-elda/06-esterno.jpg", posizione: 5 },
      { percorso: "/foto/villino-elda/07-bagno.jpg", posizione: 6 }
    ]
  },
  {
    id: "berardi",
    titolo: "Berardi - Appartamento arredato in affitto mensile",
    tipologia: "appartamento",
    citta: "Roma",
    zona: null,
    descrizione: "Appartamento completo e arredato, ideale per professionisti, professori e lavoratori in trasferta che cercano una base comoda per qualche mese.\n\nContratto regolare a uso transitorio, gestione diretta della proprieta'.",
    mq: 70,
    camere: 2,
    bagni: 1,
    posti_letto: 3,
    arredato: true,
    servizi: ["wifi", "lavatrice", "cucina attrezzata"],
    prezzo_mese: 1200,
    spese_incluse: false,
    spese_mese: null,
    cauzione: null,
    minimo_mesi: 1,
    disponibile_dal: null,
    stato: "pubblicato",
    foto_annunci: []
  }
];
