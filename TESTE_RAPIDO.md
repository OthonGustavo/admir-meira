# 🚀 Guia Rápido de Teste — 5 Minutos

## ✅ O Que Foi Implementado

| # | Funcionalidade | Status | Como Testar |
|---|---|---|---|
| 1 | 🔐 Autenticação | ✅ Completo | Ir para `/login.html` |
| 2 | 👤 Atribuição | ✅ Completo | Login como Gestor → Dashboard → Atribuir |
| 3 | 🔔 Realtime | ✅ Completo | Nova msg aparece sozinha |
| 4 | 🏷️ Tags | ✅ Completo | Dashboard → Filtros → Categoria |
| 5 | ⭐ Prioridades | ✅ Completo | Ver badges coloridas nas conversas |
| 6 | 💬 Templates | ✅ Completo | Chat Operador → Botões acima |
| 7 | 📊 Analytics | 📐 Estrutura | Tabela criada, visual pending |
| 8 | 📎 Upload | 📐 Estrutura | Coluna pronta, integração pending |
| 9 | 🔍 Busca | ✅ Completo | Dashboard → Campo de busca |
| 10 | 🛡️ Auditoria | 📐 Estrutura | Tabela criada, logging ready |

---

## 🎯 Teste em 3 Etapas

### **ETAPA 1: Preparar Banco de Dados (2 min)**

1. Acesse **https://app.supabase.com**
2. Vá para **SQL Editor**
3. Crie nova query
4. **Copie TUDO** deste arquivo: `site/schema-updates.sql`
5. **Cole** na query
6. Clique **▶️ Run**

✅ Pronto! Tabelas criadas.

---

### **ETAPA 2: Criar Operador de Teste (1 min)**

Na mesma aba SQL Editor, execute:

```sql
-- Criar operador de teste
INSERT INTO operadores (nome, email, senha_hash, especialidade, nivel_acesso)
VALUES ('João Silva', 'joao@admeirm.adv.br', 'senha123', 'trabalhista', 'operador');

-- Criar gestor de teste
INSERT INTO operadores (nome, email, senha_hash, especialidade, nivel_acesso)
VALUES ('Gerente', 'gerente@admeirm.adv.br', 'senha123', NULL, 'gestor');
```

✅ Pronto! Operadores criados.

---

### **ETAPA 3: Testar o Sistema (2 min)**

**Passo 1: Ir para Login**
```
http://localhost:60140/login.html
```

**Passo 2: Tab "Operador" → Login**
- Email: `joao@admeirm.adv.br`
- Senha: `senha123`
- Perfil: "Operador"

**Resultado:** ✅ Redirecionado para Dashboard

**Passo 3: Ver Dashboard**
- [✅] Vê suas conversas atribuídas
- [✅] Stats: Abertas, Urgentes, Não Lidas, Resolvidas
- [✅] Filtros funcionando

**Passo 4: Teste Login como Gestor**
- Email: `gerente@admeirm.adv.br`
- Senha: `senha123`
- Perfil: "Gestor"

**Resultado:** ✅ Vê TODAS as conversas + opção de atribuir

**Passo 5: Teste Atribuição**
- Clique em uma conversa
- Selecione "Eu" no dropdown
- Clique "✅ Atribuir"
- ✅ Conversa atribuída

**Passo 6: Teste Filtros**
- Status: Selecione "ativa"
- Prioridade: Selecione "🔴 Crítica"
- Categoria: Selecione "⚙️ Direito Trabalhista"
- Clique "✅ Aplicar Filtros"
- ✅ Lista filtrada

**Passo 7: Teste Busca**
- Digite algo no campo de busca
- Clique "Buscar"
- ✅ Resultados aparecem

**Passo 8: Abrir Chat do Operador**
- Clique em uma conversa
- ✅ Abre `/chat-operador.html`
- Ver:
  - [✅] Histórico de mensagens
  - [✅] Sidebar com dados do cliente
  - [✅] Botões de Templates acima do input
  - [✅] Botões: Atribuir, Resolver, Escalar

**Passo 9: Testar Template**
- Clique em um dos botões de template acima do input
- ✅ Texto é inserido automaticamente

**Passo 10: Testar Realtime**
- Em 2 abas do navegador, faça login com operadores diferentes
- Uma envia mensagem em `/chat.html`
- A outra em `/operador-dashboard.html`
- ✅ Dashboard atualiza sozinho (sem F5)

---

## 📱 Diferentes Papéis

### **Cliente**
```
http://localhost:60140/login.html
Tab: Cliente
Telefone: (79) 99999-9999
Nome: João Silva

Resultado: Acessa /chat.html
├─ Vê histórico
├─ Envia mensagens
└─ "IA" responde
```

### **Operador**
```
http://localhost:60140/login.html
Tab: Operador
Email: joao@admeirm.adv.br
Senha: senha123
Perfil: Operador

Resultado: Acessa /operador-dashboard.html
├─ Vê suas conversas atribuídas
├─ Filtros funcionam
├─ Clica conversa → /chat-operador.html
└─ Pode usar templates
```

### **Gestor**
```
http://localhost:60140/login.html
Tab: Operador
Email: gerente@admeirm.adv.br
Senha: senha123
Perfil: Gestor

Resultado: Acessa /operador-dashboard.html
├─ Vê TODAS conversas
├─ Pode atribuir
├─ Filtros + Busca funcionam
└─ Pode ver relatórios (estrutura pronta)
```

---

## 🎬 Vídeo Teste Rápido

1. **Tela 1:** Login (5s)
2. **Tela 2:** Dashboard com conversas (10s)
3. **Tela 3:** Filtrar por prioridade (5s)
4. **Tela 4:** Atribuir conversa (5s)
5. **Tela 5:** Abrir chat operador (10s)
6. **Tela 6:** Usar template (5s)

**Total: ~40 segundos**

---

## ✅ Checklist de Validação

- [ ] SQL executado sem erros
- [ ] Login funciona para Cliente
- [ ] Login funciona para Operador
- [ ] Login funciona para Gestor
- [ ] Dashboard mostra conversas
- [ ] Filtros funcionam
- [ ] Busca funciona
- [ ] Atribuição funciona
- [ ] Chat operador abre
- [ ] Templates aparecem
- [ ] Realtime atualiza dashboard
- [ ] Badges de prioridade aparecem
- [ ] Tags aparecem nas conversas

---

## 🆘 Se Algo Não Funcionar

### Erro: "config.js não encontrado"
✅ Solução: Verifique se `config.js` está em `/site/config.js` com credenciais corretas

### Erro: "Tabela não existe"
✅ Solução: Execute `schema-updates.sql` no SQL Editor do Supabase

### Erro: "Login rejeitado"
✅ Solução: Confirme que inseriu operadores (veja ETAPA 2)

### Dashboard branco
✅ Solução: Abra console (F12) para ver erros, verifique URL do Supabase

### Realtime não funciona
✅ Solução: Verifique se Realtime está habilitado no Supabase Settings

---

## 📊 Estrutura de Pastas

```
site/
├─ login.html ..................... Novo! Autenticação
├─ operador-dashboard.html ......... Novo! Dashboard operador
├─ chat-operador.html ............. Novo! Chat avançado
├─ chat.html ...................... (Melhorado)
├─ dashboard.html ................. (Melhorado)
├─ config.js ...................... (Credenciais)
├─ schema-updates.sql ............. Novo! 10 tabelas
├─ GUIA_IMPLEMENTACAO.md .......... Novo! Documentação completa
└─ TESTE_RAPIDO.md ................ Este arquivo!
```

---

## 🎯 Próximos Passos Depois do Teste

1. **Integrar WhatsApp** (próxima iteração)
2. **Upload de Arquivos** (Supabase Storage)
3. **Dashboard Analytics** (gráficos em tempo real)
4. **Mobile App** (React Native)
5. **IA Melhorada** (GPT-4 ou Claude)

---

## 💡 Dicas Profissionais

✅ **Sempre filtrar por Categoria** → Conversas organizadas  
✅ **Atribuir por Prioridade** → Urgentes primeiro  
✅ **Usar Templates** → Responde em 30 segundos  
✅ **Resolver quando terminar** → Fila sempre limpa  
✅ **Escalar se complexo** → Gestor analisa  

---

## 📞 Suporte

**Problema?** Verifique:
1. `schema-updates.sql` foi executado ✅
2. `config.js` tem credenciais corretas ✅
3. Operadores foram criados ✅
4. Servidor rodando em `localhost:60140` ✅

**Ainda não funciona?** Abra console (F12) e veja mensagens de erro.

---

**Status:** 🟢 Pronto para usar  
**Tempo de setup:** ~5 minutos  
**Tempo de teste:** ~10 minutos  
**Satisfação garantida:** 100% ✨
