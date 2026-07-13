-- ============================================================
-- CLIENTE DE TESTE — Ademir Meira Advocacia
-- Execute DEPOIS de schema.sql e schema-updates.sql
-- Cria um cliente de exemplo (usuarios_whatsapp) com uma
-- conversa e um processo vinculados, para testar o dashboard.
-- ============================================================

-- Cliente
INSERT INTO usuarios_whatsapp (telefone, nome, email, ativo, notas)
VALUES ('5579977776666', 'Carlos Eduardo Souza', 'carlos.souza@example.com', true,
        'Cliente cadastrado para testes do dashboard')
ON CONFLICT (telefone) DO NOTHING;

-- Conversa vinculada ao cliente
INSERT INTO conversas (usuario_id, assunto, status, prioridade, ultima_mensagem, contador_mensagens)
SELECT id, 'Consulta sobre rescisão indireta', 'aguardando_cliente', 'alta',
       'Preciso enviar os documentos da rescisão, pode me orientar?', 1
FROM usuarios_whatsapp
WHERE telefone = '5579977776666'
LIMIT 1
ON CONFLICT DO NOTHING;

-- Processo vinculado ao cliente
INSERT INTO processos (usuario_id, numero_processo, tipo_acao, tribunal, uf,
                        status_processo, data_distribuicao, descricao,
                        valor_causa, advogado_responsavel)
SELECT id, '0001234-56.2026.5.20.0001', 'trabalhista', 'TRT20', 'SE',
       'ativo', '2026-03-10', 'Rescisão indireta por assédio moral',
       25000.00, 'Ademir Meira'
FROM usuarios_whatsapp
WHERE telefone = '5579977776666'
LIMIT 1
ON CONFLICT (numero_processo) DO NOTHING;
