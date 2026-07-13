// ============================================================
// Modelo de configuração — copie este arquivo para "config.js"
// e preencha com as credenciais do ambiente (dev ou produção).
//
// config.js NUNCA vai para o Git (está no .gitignore).
// Cada ambiente (implementação/produção vs. desenvolvimento) tem
// o seu próprio config.js, com valores diferentes.
// ============================================================
window.APP_CONFIG = {
  // Painel do Supabase > Project Settings > API
  SUPABASE_URL: 'https://SEU-PROJETO.supabase.co',
  SUPABASE_KEY: 'sua_chave_publica_anon',

  // Token simples que protege a função "chatwoot-proxy" (definido
  // dentro do próprio código da função, no Supabase)
  PROXY_TOKEN: 'seu_token_do_proxy',
};
