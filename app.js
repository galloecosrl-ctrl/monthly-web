// Monthly - modulo condiviso: connessione a Supabase e utilita' comuni.
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
          .then(function (r) {
            if (!r.ok) throw new Error("Il servizio non e' configurato su questo server.");
            return r.json();
          })
          .then(function (cfg) {
            if (!cfg.url || !cfg.key) throw new Error(cfg.error || "Configurazione mancante sul server.");
            resolve(window.supabase.createClient(cfg.url, cfg.key));
          })
          .catch(function (e) {
            reject(e instanceof Error ? e : new Error("Configurazione non raggiungibile."));
          });
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
    accettata: { testo: "Confermata", classe: "verde" },
    rifiutata: { testo: "Cancellata dal proprietario", classe: "rossa" },
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

  // URL pubblico di una foto. I percorsi che iniziano con "/" (o con http)
  // sono file serviti dal sito stesso (es. le foto vetrina in /foto/...);
  // gli altri vivono nel bucket Storage di Supabase.
  function urlFoto(client, percorso) {
    if (/^(\/|https?:)/.test(percorso)) return percorso;
    if (!client) return percorso; // senza client non possiamo risolvere lo Storage
    return client.storage.from("foto-annunci").getPublicUrl(percorso).data.publicUrl;
  }

  // Prima foto di un annuncio (dalla join foto_annunci), o null.
  function copertina(client, annuncio) {
    var foto = annuncio.foto_annunci || [];
    if (!foto.length) return null;
    foto.sort(function (a, b) { return a.posizione - b.posizione; });
    return urlFoto(client, foto[0].percorso);
  }

  // Prezzo di partenza di un annuncio: il minimo tra le camere prenotabili
  // separatamente, se esistono (nel qual caso la dicitura e' "da X / mese"),
  // altrimenti il prezzo dell'annuncio intero.
  function prezzoDa(a) {
    var camere = a.camere_annuncio || [];
    if (!camere.length) return { prezzo: a.prezzo_mese, da: false };
    var minimo = camere.reduce(function (m, c) {
      return Math.min(m, Number(c.prezzo_mese));
    }, Infinity);
    return { prezzo: minimo, da: true };
  }

  // Card annuncio per le griglie (home e area riservata).
  function cartaAnnuncio(client, a) {
    var img = copertina(client, a);
    var luogo = a.citta + (a.zona ? " · " + a.zona : "");
    var p = prezzoDa(a);
    return '<a class="carta-annuncio" data-id="' + a.id + '" href="annuncio.html?id=' + a.id + '">' +
      '<div class="foto"' + (img ? ' style="background-image:url(\'' + img + '\')"' : "") + '>' + (img ? "" : "🏠") + "</div>" +
      '<div class="corpo">' +
      '<span class="etichetta">' + (TIPOLOGIE[a.tipologia] || a.tipologia) + "</span>" +
      "<h3>" + testoSicuro(a.titolo) + "</h3>" +
      '<div class="luogo">' + testoSicuro(luogo) + "</div>" +
      '<div class="prezzo">' + (p.da ? '<small>da</small> ' : "") + euro(p.prezzo) + ' <small>/ mese' +
      (a.spese_incluse ? ", spese incluse" : "") + "</small></div>" +
      "</div></a>";
  }

  // Autocompletamento citta' (mondiale): suggerimenti da Photon/OpenStreetMap
  // mentre si digita, selezionabili con click. Nessuna chiave API richiesta.
  function autocompletaCitta(input) {
    var box = document.createElement("div");
    box.className = "suggerimenti-citta";
    input.parentNode.style.position = "relative";
    input.parentNode.appendChild(box);
    input.autocomplete = "off";
    var timer = null;
    var ultimaRicerca = "";

    input.addEventListener("input", function () {
      var q = input.value.trim();
      clearTimeout(timer);
      if (q.length < 2) { box.style.display = "none"; return; }
      timer = setTimeout(function () {
        ultimaRicerca = q;
        fetch("https://photon.komoot.io/api/?q=" + encodeURIComponent(q) +
              "&limit=6&osm_tag=place:city&osm_tag=place:town&osm_tag=place:village")
          .then(function (r) { return r.json(); })
          .then(function (dati) {
            if (input.value.trim() !== ultimaRicerca) return; // risposta superata
            var visti = {};
            var voci = (dati.features || []).map(function (f) {
              var p = f.properties;
              return { nome: p.name, dettaglio: [p.state, p.country].filter(Boolean).join(", ") };
            }).filter(function (v) {
              var chiave = v.nome + "|" + v.dettaglio;
              if (!v.nome || visti[chiave]) return false;
              visti[chiave] = true;
              return true;
            });
            if (!voci.length) { box.style.display = "none"; return; }
            box.innerHTML = "";
            voci.forEach(function (v) {
              var voce = document.createElement("div");
              voce.className = "voce";
              voce.innerHTML = "<b>" + testoSicuro(v.nome) + "</b> <span>" + testoSicuro(v.dettaglio) + "</span>";
              // mousedown, non click: scatta prima del blur del campo.
              voce.addEventListener("mousedown", function (ev) {
                ev.preventDefault();
                input.value = v.nome;
                box.style.display = "none";
              });
              box.appendChild(voce);
            });
            box.style.display = "block";
          })
          .catch(function () { box.style.display = "none"; });
      }, 250);
    });

    input.addEventListener("blur", function () {
      setTimeout(function () { box.style.display = "none"; }, 150);
    });
  }

  window.AM = {
    autocompletaCitta: autocompletaCitta,
    pronto: creaClient,
    TIPOLOGIE: TIPOLOGIE,
    STATI_RICHIESTA: STATI_RICHIESTA,
    euro: euro,
    testoSicuro: testoSicuro,
    dataIt: dataIt,
    urlFoto: urlFoto,
    copertina: copertina,
    prezzoDa: prezzoDa,
    cartaAnnuncio: cartaAnnuncio
  };
})();
