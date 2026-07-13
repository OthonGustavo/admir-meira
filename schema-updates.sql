-- ============================================================
-- MELHORIAS DO SCHEMA — Implementação das 10 funcionalidades
-- Execute isto DEPOIS do schema.sql original
-- ============================================================

-- ============================================================
-- 1. TABELA DE OPERADORES (Autenticação + Atribuição)
-- ============================================================
CREATE TABLE IF NOT EXISTS operadores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  telefone TEXT,
  senha_hash TEXT NOT NULL, -- bcrypt em produção
  especialidade TEXT, -- 'trabalhista', 'administrativo', 'sindical', 'previdenciario'
  ativo BOOLEAN DEFAULT true,
  data_criacao TIMESTAMP DEFAULT NOW(),
  ultimo_login TIMESTAMP,
  nivel_acesso TEXT DEFAULT 'operador' -- 'operador', 'admin', 'gestor'
);

-- ============================================================
-- 2. ADIÇÕES À TABELA CONVERSAS (Status, Prioridade, Tags, Atribuição)
-- ============================================================
ALTER TABLE conversas ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'ativa';
-- Status: 'ativa', 'aguardando_cliente', 'resolvida', 'arquivada', 'escalada'

ALTER TABLE conversas ADD COLUMN IF NOT EXISTS prioridade TEXT DEFAULT 'media';
-- Prioridade: 'critica', 'alta', 'media', 'baixa'

ALTER TABLE conversas ADD COLUMN IF NOT EXISTS operador_responsavel_id UUID REFERENCES operadores(id) ON DELETE SET NULL;
-- Quem está atendendo

ALTER TABLE conversas ADD COLUMN IF NOT EXISTS atribuido_em TIMESTAMP;
-- Quando foi atribuído

ALTER TABLE conversas ADD COLUMN IF NOT EXISTS contador_nao_lidas INT DEFAULT 0;
-- Quantas mensagens não lidas

ALTER TABLE conversas ADD COLUMN IF NOT EXISTS tags TEXT;
-- JSON array com tags: ["urgente", "trabalhista", "rescisao"]

ALTER TABLE conversas ADD COLUMN IF NOT EXISTS data_resolucao TIMESTAMP;
-- Quando foi resolvido

-- ============================================================
-- 3. TABELA DE TAGS (Categorização)
-- ============================================================
CREATE TABLE IF NOT EXISTS tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL UNIQUE,
  cor TEXT DEFAULT '#667eea', -- cor para UI
  icone TEXT DEFAULT '🏷️',
  descricao TEXT,
  categoria TEXT, -- 'tipo_caso' ou 'status_interno'
  ativo BOOLEAN DEFAULT true,
  data_criacao TIMESTAMP DEFAULT NOW()
);

-- Inserir tags padrão
INSERT INTO tags (nome, cor, icone, categoria) VALUES
  ('Direito Trabalhista', '#3b82f6', '⚙️', 'tipo_caso'),
  ('Direito Administrativo', '#8b5cf6', '📋', 'tipo_caso'),
  ('Direito Sindical', '#ec4899', '👥', 'tipo_caso'),
  ('Direito Previdenciário', '#f59e0b', '🏦', 'tipo_caso'),
  ('Urgente', '#ef4444', '🚨', 'status_interno'),
  ('Resolvido', '#10b981', '✅', 'status_interno'),
  ('Aguardando Cliente', '#f59e0b', '⏳', 'status_interno'),
  ('Requer Documentação', '#06b6d4', '📎', 'status_interno')
ON CONFLICT (nome) DO NOTHING;

-- Tabela de relacionamento conversa-tags
CREATE TABLE IF NOT EXISTS conversa_tags (
  conversa_id UUID REFERENCES conversas(id) ON DELETE CASCADE,
  tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
  data_adicao TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (conversa_id, tag_id)
);

-- ============================================================
-- 4. APRIMORAMENTO DA TABELA MENSAGENS_OPERADOR
-- ============================================================
ALTER TABLE mensagens_operador ADD COLUMN IF NOT EXISTS tipo_mensagem TEXT DEFAULT 'texto';
-- 'texto', 'arquivo', 'imagem', 'documento', 'template_resposta'

ALTER TABLE mensagens_operador ADD COLUMN IF NOT EXISTS arquivo_url TEXT;
-- URL do arquivo no Supabase Storage

ALTER TABLE mensagens_operador ADD COLUMN IF NOT EXISTS editada_em TIMESTAMP;
-- Quando foi editada (se foi)

ALTER TABLE mensagens_operador ADD COLUMN IF NOT EXISTS reacoes TEXT;
-- JSON: {"👍": 2, "❤️": 1} (para futura gamificação)

-- ============================================================
-- 5. TABELA DE TEMPLATES DE RESPOSTA (Respostas Rápidas)
-- ============================================================
CREATE TABLE IF NOT EXISTS templates_resposta (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  criado_por_id UUID REFERENCES operadores(id) ON DELETE SET NULL,
  titulo TEXT NOT NULL,
  conteudo TEXT NOT NULL,
  categoria TEXT, -- 'trabalhista', 'administrativo', etc
  tags TEXT, -- JSON array
  uso_count INT DEFAULT 0, -- Quantas vezes foi usado
  ativo BOOLEAN DEFAULT true,
  data_criacao TIMESTAMP DEFAULT NOW(),
  data_atualizacao TIMESTAMP DEFAULT NOW()
);

-- Templates padrão
INSERT INTO templates_resposta (titulo, conteudo, categoria) VALUES
  ('Solicitar Documentação', 'Obrigado por nos contatar. Para prosseguirmos, precisarei dos seguintes documentos:\n- Cópia do RG/CNH\n- Comprovante de residência\n- Documentação específica do caso\n\nPoderia enviá-los por aqui?', 'geral'),
  ('Prazo de Resposta', 'Recebemos sua mensagem. Faremos uma análise cuidadosa e retornaremos em até 24 horas úteis.\n\nObrigado pela paciência!', 'geral'),
  ('Agenda Consultoria', 'Gostaríamos de agendar uma consultoria presencial ou por vídeo chamada. Quais são os melhores horários para você?\n\n(seg-sex: 09:00-17:00)', 'geral'),
  ('Rescisão Trabalhista - Informações Iniciais', 'Para avaliamos seu caso de rescisão, preciso de:\n1. Data de admissão\n2. Data da rescisão\n3. Motivo da rescisão\n4. Recebeu verbas rescisórias?\n5. Homologação realizada?\n\nQuando consegue enviar?', 'trabalhista'),
  ('Assédio Moral - Primeiros Passos', 'Sinto muito que esteja passando por isso. Para ajudá-lo:\n1. Registre datas, horas e testemunhas dos episódios\n2. Preserve todos os emails/mensagens relevantes\n3. Se possível, procure médico (laudo)\n\nGostaria de agendar uma conversa confidencial?', 'trabalhista')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 6. TABELA DE AUDITORIA (Segurança/LGPD)
-- ============================================================
CREATE TABLE IF NOT EXISTS auditoria_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operador_id UUID REFERENCES operadores(id) ON DELETE SET NULL,
  tabela_afetada TEXT NOT NULL, -- 'conversas', 'mensagens_operador', etc
  acao TEXT NOT NULL, -- 'CREATE', 'READ', 'UPDATE', 'DELETE'
  dados_antigos JSONB, -- O que era antes
  dados_novos JSONB, -- O que ficou depois
  data_acao TIMESTAMP DEFAULT NOW(),
  ip_origem TEXT,
  motivo TEXT
);

-- ============================================================
-- 7. TABELA DE MÉTRICAS/ANALYTICS
-- ============================================================
CREATE TABLE IF NOT EXISTS metricas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  data TIMESTAMP DEFAULT NOW(),
  tipo_metrica TEXT, -- 'resposta_tiempo', 'satisfacao', 'carga_operador'
  conversa_id UUID REFERENCES conversas(id) ON DELETE CASCADE,
  operador_id UUID REFERENCES operadores(id) ON DELETE CASCADE,
  valor NUMERIC,
  descricao TEXT
);

-- ============================================================
-- 8. TABELA DE PREFERÊNCIAS DO OPERADOR
-- ============================================================
CREATE TABLE IF NOT EXISTS preferencias_operador (
  operador_id UUID PRIMARY KEY REFERENCES operadores(id) ON DELETE CASCADE,
  notificacoes_ativas BOOLEAN DEFAULT true,
  som_notificacao BOOLEAN DEFAULT true,
  categorias_especialidade TEXT, -- JSON: ["trabalhista", "administrativo"]
  max_conversas_simultaneas INT DEFAULT 5,
  tema_ui TEXT DEFAULT 'light', -- 'light', 'dark'
  dados_personalizados JSONB DEFAULT '{}'
);

-- ============================================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================================

-- Busca rápida de conversas por operador
CREATE INDEX IF NOT EXISTS idx_conversas_operador_id
  ON conversas(operador_responsavel_id);

-- Busca rápida por status
CREATE INDEX IF NOT EXISTS idx_conversas_status_prioridade
  ON conversas(status, prioridade);

-- Busca por data de atualização (para ordenar por mais recentes)
CREATE INDEX IF NOT EXISTS idx_conversas_updated_at
  ON conversas(updated_at DESC);

-- Busca rápida de tags
CREATE INDEX IF NOT EXISTS idx_conversa_tags_conversa_id
  ON conversa_tags(conversa_id);

CREATE INDEX IF NOT EXISTS idx_conversa_tags_tag_id
  ON conversa_tags(tag_id);

-- Busca de mensagens não lidas
CREATE INDEX IF NOT EXISTS idx_mensagens_lida
  ON mensagens_operador(lida, conversa_id);

-- ============================================================
-- FUNÇÃO: Atualizar contador de mensagens não lidas
-- ============================================================
CREATE OR REPLACE FUNCTION atualizar_nao_lidas()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversas
  SET contador_nao_lidas = (
    SELECT COUNT(*) FROM mensagens_operador
    WHERE conversa_id = NEW.conversa_id AND lida = false
  )
  WHERE id = NEW.conversa_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar automaticamente
DROP TRIGGER IF EXISTS trigger_atualizar_nao_lidas ON mensagens_operador;
CREATE TRIGGER trigger_atualizar_nao_lidas
AFTER INSERT OR UPDATE ON mensagens_operador
FOR EACH ROW
EXECUTE FUNCTION atualizar_nao_lidas();

-- ============================================================
-- PERMISSÕES RLS (Row Level Security) - Básico
-- ============================================================

-- Enable RLS nas tabelas (opcional, comentado por enquanto)
-- ALTER TABLE operadores ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE conversas ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE mensagens_operador ENABLE ROW LEVEL SECURITY;

-- Policy: Operador vê conversas atribuídas a ele
-- CREATE POLICY "operador_vê_proprias_conversas"
-- ON conversas FOR SELECT
-- USING (auth.uid()::uuid = operador_responsavel_id);

-- ============================================================
-- FIM DO SCRIPT DE MELHORIAS
-- ============================================================
