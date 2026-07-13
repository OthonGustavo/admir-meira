-- ============================================================
-- SCHEMA DE BANCO DE DADOS — Ademir Meira Advocacia
-- Sistema de atendimento jurídico com WhatsApp
-- Para usar: copie todo este código e execute no SQL Editor
-- do Supabase (https://app.supabase.com > SQL Editor)
-- ============================================================

-- 1. USUÁRIOS DO WHATSAPP
-- Armazena perfis de clientes/contatos do WhatsApp
CREATE TABLE IF NOT EXISTS usuarios_whatsapp (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  telefone TEXT NOT NULL UNIQUE,
  nome TEXT,
  email TEXT,
  data_criacao TIMESTAMP DEFAULT NOW(),
  ultimo_contato TIMESTAMP,
  ativo BOOLEAN DEFAULT true,
  notas TEXT
);

-- 2. CONVERSAS
-- Histórico de conversas entre cliente e sistema
CREATE TABLE IF NOT EXISTS conversas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES usuarios_whatsapp(id) ON DELETE CASCADE,
  assunto TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  status TEXT DEFAULT 'ativa', -- 'ativa', 'fechada', 'aguardando'
  ultima_mensagem TEXT,
  contador_mensagens INT DEFAULT 0
);

-- 3. MENSAGENS DO OPERADOR
-- Mensagens enviadas pelo operador (advogado/atendente)
CREATE TABLE IF NOT EXISTS mensagens_operador (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversa_id UUID REFERENCES conversas(id) ON DELETE CASCADE,
  usuario_operador TEXT, -- nome do operador
  texto TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  lida BOOLEAN DEFAULT false,
  tipo TEXT DEFAULT 'texto' -- 'texto', 'arquivo', 'imagem'
);

-- 4. ATENDIMENTOS HUMANOS
-- Registro de quando um atendimento foi transferido para humano
CREATE TABLE IF NOT EXISTS atendimentos_humanos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversa_id UUID REFERENCES conversas(id) ON DELETE CASCADE,
  usuario_id UUID REFERENCES usuarios_whatsapp(id) ON DELETE CASCADE,
  operador_responsavel TEXT,
  iniciado_em TIMESTAMP DEFAULT NOW(),
  finalizado_em TIMESTAMP,
  motivo_transferencia TEXT,
  duracao_minutos INT,
  resolucao TEXT
);

-- 5. PROCESSOS JURÍDICOS
-- Informações sobre processos dos clientes
CREATE TABLE IF NOT EXISTS processos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES usuarios_whatsapp(id) ON DELETE CASCADE,
  numero_processo TEXT UNIQUE,
  created_at TIMESTAMP DEFAULT NOW(),
  tipo_acao TEXT, -- 'trabalhista', 'administrativa', 'sindical', 'previdenciária'
  tribunal TEXT,
  uf TEXT,
  status_processo TEXT DEFAULT 'ativo', -- 'ativo', 'arquivado', 'encerrado'
  data_distribuicao DATE,
  data_ultima_movimentacao DATE,
  descricao TEXT,
  valor_causa DECIMAL(12,2),
  advogado_responsavel TEXT
);

-- ============================================================
-- ÍNDICES (para melhorar performance)
-- ============================================================

-- Índice para buscar conversas por usuário
CREATE INDEX IF NOT EXISTS idx_conversas_usuario_id
  ON conversas(usuario_id);

-- Índice para buscar mensagens por conversa
CREATE INDEX IF NOT EXISTS idx_mensagens_operador_conversa_id
  ON mensagens_operador(conversa_id);

-- Índice para buscar processos por usuário
CREATE INDEX IF NOT EXISTS idx_processos_usuario_id
  ON processos(usuario_id);

-- Índice para buscar por status
CREATE INDEX IF NOT EXISTS idx_conversas_status
  ON conversas(status);

CREATE INDEX IF NOT EXISTS idx_processos_status
  ON processos(status_processo);

-- ============================================================
-- DADOS DE TESTE (opcional — comente se não quiser)
-- ============================================================

-- Inserir usuário de teste
INSERT INTO usuarios_whatsapp (telefone, nome, email, ativo)
VALUES
  ('5579999999999', 'João Silva', 'joao@example.com', true),
  ('5579988888888', 'Maria Santos', 'maria@example.com', true)
ON CONFLICT (telefone) DO NOTHING;

-- Inserir conversa de teste
INSERT INTO conversas (usuario_id, assunto, status, ultima_mensagem, contador_mensagens)
SELECT id, 'Dúvida sobre processo trabalhista', 'ativa', 'Quando serei chamado para audiência?', 2
FROM usuarios_whatsapp
WHERE telefone = '5579999999999'
LIMIT 1;

-- Inserir mensagem de operador de teste
INSERT INTO mensagens_operador (conversa_id, usuario_operador, texto, lida)
SELECT id, 'Ademir Meira', 'Sua audiência foi marcada para o próximo mês. Entraremos em contato com mais detalhes.', true
FROM conversas
WHERE assunto = 'Dúvida sobre processo trabalhista'
LIMIT 1;

-- ============================================================
-- PERMISSÕES (RLS — Row Level Security)
-- ============================================================
-- Para um sistema seguro em produção, você precisará configurar RLS.
-- Por enquanto, estamos usando service role (admin).
--
-- Em produção, adicione:
-- ALTER TABLE usuarios_whatsapp ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE conversas ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE mensagens_operador ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE processos ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE atendimentos_humanos ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
