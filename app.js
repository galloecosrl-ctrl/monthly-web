// AffittoMese - modulo condiviso: connessione a Supabase e utilita' comuni.
// Espone il globale AM. Le pagine chiamano AM.pronto() e ricevono il client.

(function () {
  "use strict";

  var clientPromise = null;

  // Carica supabase-js dal CDN (non bloccante) e crea il client con la
  // configurazione fornita dalla Netlify Function. Il fetch della config usa
  // cache no-store: una config vecchia in cache ha gia' causato guai altrove.
  function creaClient() {
    if (clientPromise) return clientPromise;
    clientPromise = new Promise(function (resolve, reject) {
      var s = document.createElement("script");
      s.src = "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js";
      s.onload = function () {
        fetch("/api/supabaseConfig", { cache: "no-store" })
          .then(function (r) { return r.json(); })
          .then(function (cfg) {
            if (!cfg.url || !cfg.key) throw new Error(cfg.error || "Configurazione mancante");
            resolve(window.supabase.createClient(cfg.url, cfg.key));
          })
          .catch(reject);
      };
      s.onerror = function () { reject(new Error("Impossibile caricare supabase-js dal CDN")); };
      document.head.appendChild(s);
    });
    return clientPromise;
  }

  var TIPOLOGIE = {
    camera: "Camera",
    monolocale: "Monolocale",
    appartamento: "Appartamento",
    casa: "Casa intera"
  };

  var STATI_RICHIESTA = {
    inviata: { testo: "In attesa", classe: "ambra" },
    accettata: { testo: "Accettata", classe: "verde" },
    rifiutata: { testo: "Rifiutata", classe: "rossa" },
    annullata: { testo: "Annullata", classe: "grigia" }
  };

  function euro(n) {
    if (n === null || n === undefined) return "";
    return Number(n).toLocaleString("it-IT", { style: "currency", currency: "EUR", maximumFractionDigits: 0 });
  }

  function testoSicuro(s) {
    var d = document.createElement("div");
    d.textContent = s == null ? "" : String(s);
    return d.innerHTML;
  }

  function dataIt(iso) {
    if (!iso) return "";
    var d = new Date(iso);
    return d.toLocaleDateString("it-IT", { day: "numeric", month: "long", year: "numeric" });
  }

  // URL pubblico di una foto nel bucket Storage.
  function urlFoto(client, percorso) {
    return client.storage.from("foto-annunci").getPublicUrl(percorso).data.publicUrl;
  }

  // Prima foto di un annuncio (dalla join foto_annunci), o null.
  function copertina(client, annuncio) {
    var foto = annuncio.foto_annunci || [];
    if (!foto.length) return null;
    foto.sort(function (a, b) { return a.posizione - b.posizione; });
    return urlFoto(client, foto[0].percorso);
  }

  // Card annuncio per le griglie (home e area riservata).
  function cartaAnnuncio(client, a) {
    var img = copertina(client, a);
    var luogo = a.citta + (a.zona ? " · " + a.zona : "");
    return '<a class="carta-annuncio" href="annuncio.html?id=' + a.id + '">' +
      '<div class="foto"' + (img ? ' style="background-image:url(\'' + img + '\')"' : "") + '>' + (img ? "" : "🏠") + "</div>" +
      '<div class="corpo">' +
      '<span class="etichetta">' + (TIPOLOGIE[a.tipologia] || a.tipologia) + "</span>" +
      "<h3>" + testoSicuro(a.titolo) + "</h3>" +
      '<div class="luogo">' + testoSicuro(luogo) + "</div>" +
      '<div class="prezzo">' + euro(a.prezzo_mese) + ' <small>/ mese' +
      (a.spese_incluse ? ", spese incluse" : "") + "</small></div>" +
      "</div></a>";
  }

  window.AM = {
    pronto: creaClient,
    TIPOLOGIE: TIPOLOGIE,
    STATI_RICHIESTA: STATI_RICHIESTA,
    euro: euro,
    testoSicuro: testoSicuro,
    dataIt: dataIt,
    urlFoto: urlFoto,
    copertina: copertina,
    cartaAnnuncio: cartaAnnuncio
  };
})();
