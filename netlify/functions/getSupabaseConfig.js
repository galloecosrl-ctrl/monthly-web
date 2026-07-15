// Netlify Function: fornisce al browser l'URL del progetto Supabase e la
// chiave publishable (pubblica per definizione: la sicurezza dei dati e'
// garantita dalle policy row-level security nel database, non da questa
// chiave). Tenerli nelle variabili d'ambiente invece che scolpiti nell'HTML
// evita di dover toccare il codice se il progetto Supabase cambia.
// La chiave SECRET (service_role) NON passa MAI da qui.

exports.handler = async function () {
  let url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_ANON_KEY;
  // Normalizzazione difensiva: il Dashboard Supabase mostra in giro varianti
  // con percorsi in coda (es. ".../rest/v1/") che rompono l'autenticazione.
  // Al client serve SOLO l'origine "https://xxx.supabase.co".
  if (url) {
    try { url = new URL(url).origin; } catch (e) { /* lasciata com'e': l'errore emerge sotto */ }
  }
  if (!url || !key) {
    return {
      statusCode: 500,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ error: "Configurazione Supabase mancante sul server. Verificare le variabili d'ambiente SUPABASE_URL e SUPABASE_ANON_KEY su Netlify." }),
    };
  }
  return {
    statusCode: 200,
    headers: { "Content-Type": "application/json", "Cache-Control": "public, max-age=300" },
    body: JSON.stringify({ url: url, key: key }),
  };
};
