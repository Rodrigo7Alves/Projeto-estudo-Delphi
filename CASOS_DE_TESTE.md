# Casos de Teste — Sistema VendaProduto

> **Projeto:** VendaProduto
> **Base:** Análise estática do código-fonte (Delphi/FireDAC)
> **Data:** Junho/2026

---

## Convenções

- **Prioridade:** 🔴 Alta | 🟡 Média | 🟢 Baixa
- **Tipo:** Funcional | Limite | Validação | Regressão | Integração
- **Status esperado:** Resultado que o sistema *deveria* apresentar após as correções dos bugs conhecidos
- Pré-condição padrão (salvo indicação): banco `ProjetoVenda` acessível, ao menos 1 cliente e 1 produto cadastrados.

---

## Módulo: Clientes

### CT-CLI-001 — Inserir cliente com nome válido
- **Prioridade:** 🔴 Alta
- **Tipo:** Funcional
- **Pré-condição:** Tela de clientes aberta.
- **Passos:**
  1. Digitar "João Silva" em `edtNome`.
  2. Clicar em "Salvar".
  3. Confirmar com "Sim" no diálogo.
- **Resultado esperado:** Cliente "João Silva" aparece na grade. Campo `edtNome` fica vazio.
- **Bug atual:** Nenhum neste fluxo.

---

### CT-CLI-002 — Inserir cliente e cancelar confirmação
- **Prioridade:** 🟡 Média
- **Tipo:** Funcional
- **Passos:**
  1. Digitar "Maria Santos" em `edtNome`.
  2. Clicar em "Salvar".
  3. Clicar em "Não" no diálogo.
- **Resultado esperado:** Nenhum cliente inserido. Mensagem "Ação Cancelada" exibida. Campo permanece preenchido.
- **Bug atual:** Nenhum.

---

### CT-CLI-003 — Inserir cliente com nome vazio
- **Prioridade:** 🔴 Alta
- **Tipo:** Validação
- **Passos:**
  1. Deixar `edtNome` em branco.
  2. Clicar em "Salvar" e confirmar.
- **Resultado esperado (após correção):** Mensagem de validação impedindo o salvamento.
- **Comportamento atual:** A stored procedure é chamada com `@nome` vazio — comportamento depende da SP.

---

### CT-CLI-004 — Atualizar cliente selecionado
- **Prioridade:** 🔴 Alta
- **Tipo:** Funcional
- **Passos:**
  1. Selecionar um cliente na grade.
  2. Clicar em "Atualizar" e confirmar.
- **Resultado esperado:** Registro atualizado no banco (re-salva o mesmo valor). Grade recarregada.
- **Observação:** `edtNome` não é usado na atualização — é um comportamento intencional do código atual (ver RN-CLI-02).

---

### CT-CLI-005 — Atualizar sem selecionar registro
- **Prioridade:** 🟡 Média
- **Tipo:** Limite
- **Passos:**
  1. Abrir tela de clientes sem que haja seleção na grade (ex: grade vazia ou recém-aberta).
  2. Clicar em "Atualizar" e confirmar.
- **Resultado esperado (após correção):** Mensagem orientando o usuário a selecionar um registro.
- **Comportamento atual:** Erro ao acessar `Fields[0].Value` em dataset vazio — pode lançar exceção.

---

### CT-CLI-006 — Excluir cliente selecionado
- **Prioridade:** 🔴 Alta
- **Tipo:** Funcional
- **Passos:**
  1. Selecionar um cliente na grade.
  2. Clicar em "Excluir" e confirmar com "Sim".
- **Resultado esperado:** Cliente removido do banco. Grade recarregada sem o registro.

---

### CT-CLI-007 — Cancelar exclusão de cliente
- **Prioridade:** 🟡 Média
- **Tipo:** Funcional
- **Passos:**
  1. Selecionar um cliente na grade.
  2. Clicar em "Excluir", depois clicar "Não".
- **Resultado esperado:** Nenhuma alteração. Mensagem "Ação cancelada" exibida.

---

### CT-CLI-008 — Excluir sem selecionar registro
- **Prioridade:** 🟡 Média
- **Tipo:** Limite
- **Passos:**
  1. Clicar em "Excluir" sem selecionar linha na grade.
  2. Confirmar.
- **Resultado esperado (após correção):** Mensagem pedindo que o usuário selecione um registro.
- **Comportamento atual:** Erro ao acessar `Fields[0].Value` — pode lançar exceção.

---

## Módulo: Produtos

### CT-PRD-001 — Inserir produto com dados válidos
- **Prioridade:** 🔴 Alta
- **Tipo:** Funcional
- **Passos:**
  1. Preencher: Nome = "Caneta Azul", Qtd = 50, Valor = "2,50".
  2. Clicar "Salvar" e confirmar.
- **Resultado esperado:** Produto inserido na grade. Campos limpos.

---

### CT-PRD-002 — Inserir produto com valor não numérico
- **Prioridade:** 🔴 Alta
- **Tipo:** Validação
- **Passos:**
  1. Preencher Nome = "Borracha", Qtd = 10, Valor = "dois reais".
  2. Clicar "Salvar" e confirmar.
- **Resultado esperado (após correção):** Mensagem de validação impedindo o salvamento.
- **Comportamento atual:** A SP recebe string inválida para `@vl` (tipo `ftCurrency`) — comportamento da SP pode causar erro no banco ou silenciosamente gravar zero.

---

### CT-PRD-003 — Inserir produto com nome vazio
- **Prioridade:** 🔴 Alta
- **Tipo:** Validação
- **Passos:**
  1. Deixar nome em branco, informar Qtd = 5, Valor = "1,00".
  2. Clicar "Salvar" e confirmar.
- **Resultado esperado (após correção):** Validação impede o salvamento.
- **Comportamento atual:** SP é chamada com `@nome` vazio.

---

### CT-PRD-004 — Atualizar produto selecionado
- **Prioridade:** 🔴 Alta
- **Tipo:** Funcional
- **Passos:**
  1. Selecionar produto na grade.
  2. Clicar "Atualizar" e confirmar.
- **Resultado esperado:** Dados do registro re-salvos no banco (valores da grade). Grade recarregada. Campos limpos.

---

### CT-PRD-005 — Excluir produto com estoque
- **Prioridade:** 🔴 Alta
- **Tipo:** Funcional
- **Passos:**
  1. Selecionar produto com `QTD_PROD > 0`.
  2. Clicar "Excluir" e confirmar.
- **Resultado esperado:** Produto removido do banco. Grade recarregada.
- **Observação:** A aplicação não valida se o produto está em vendas existentes — regra de integridade referencial fica a cargo da SP/banco.

---

### CT-PRD-006 — Grade carregada automaticamente ao abrir tela
- **Prioridade:** 🟡 Média
- **Tipo:** Funcional
- **Passos:**
  1. Clicar no atalho visual de Produtos na tela principal.
- **Resultado esperado:** Grade `dbProdutos` exibe todos os produtos cadastrados imediatamente.

---

## Módulo: Vendas

### CT-VND-001 — Abrir tela de vendas e verificar código
- **Prioridade:** 🟡 Média
- **Tipo:** Funcional
- **Passos:**
  1. Abrir a tela de vendas.
- **Resultado esperado:** `lblCodVenda` exibe o próximo código sequencial (MAX + 1). Grids de clientes e produtos carregados.

---

### CT-VND-002 — Selecionar cliente na grade
- **Prioridade:** 🔴 Alta
- **Tipo:** Funcional
- **Passos:**
  1. Clicar em um cliente na grade `dbCliente`.
- **Resultado esperado:** `edtNomeClie` preenchido com `NOME_CLI` da linha clicada.

---

### CT-VND-003 — Selecionar produto na grade
- **Prioridade:** 🔴 Alta
- **Tipo:** Funcional
- **Passos:**
  1. Clicar em um produto na grade `dbProdutos`.
- **Resultado esperado:** `edtProd` preenchido com `NOME_PROD`. `edtValorProduto` preenchido com `VL_PROD`.

---

### CT-VND-004 — Calcular subtotal ao sair do campo de quantidade
- **Prioridade:** 🔴 Alta
- **Tipo:** Funcional
- **Passos:**
  1. Selecionar produto com valor = 10,00.
  2. Definir `edtQtdProd` = 3.
  3. Mover foco para outro campo (OnExit).
- **Resultado esperado:** `edtTotalProduto` exibe "30" (ou "30,00" dependendo da formatação).

---

### CT-VND-005 — Calcular subtotal com campo valor vazio
- **Prioridade:** 🔴 Alta
- **Tipo:** Limite
- **Passos:**
  1. Limpar `edtValorProduto` manualmente.
  2. Definir quantidade e sair do campo.
- **Resultado esperado (após correção):** Tratamento de exceção; não trava.
- **Comportamento atual:** `StrToFloat("")` lança `EConvertError` — crash da aplicação.

---

### CT-VND-006 — Incluir item no carrinho com quantidade válida
- **Prioridade:** 🔴 Alta
- **Tipo:** Funcional
- **Passos:**
  1. Selecionar produto, definir quantidade = 2, confirmar subtotal.
  2. Clicar "Incluir Item".
- **Resultado esperado:** Item adicionado à `lstLista`. `lblTotalVenda` atualizado.
- **Bug atual:** Loop `for I := 0 to lstLista.Items.Count do` causa `Access Violation` (off-by-one) na primeira inclusão com 1 item.

---

### CT-VND-007 — Incluir item com quantidade = 0
- **Prioridade:** 🔴 Alta
- **Tipo:** Validação
- **Passos:**
  1. Selecionar produto, manter `edtQtdProd` = 0.
  2. Clicar "Incluir Item".
- **Resultado esperado:** Mensagem "Por Favor insira uma quantidade". Item não adicionado.
- **Bug atual:** `StrToInt(edtQtdProd.Text)` é chamado antes da validação — se o campo estiver em branco, lança exceção.

---

### CT-VND-008 — Incluir múltiplos itens distintos
- **Prioridade:** 🔴 Alta
- **Tipo:** Funcional
- **Passos:**
  1. Incluir Produto A (qtd 2, valor 10,00).
  2. Incluir Produto B (qtd 1, valor 25,00).
- **Resultado esperado:** Dois itens na lista. `lblTotalVenda` = "R$45,00" (após correção do off-by-one).
- **Bug atual:** Loop de recálculo com off-by-one causa crash.

---

### CT-VND-009 — Remover item selecionado do carrinho
- **Prioridade:** 🔴 Alta
- **Tipo:** Funcional
- **Passos:**
  1. Adicionar ao menos 1 item ao carrinho.
  2. Selecionar o item em `lstLista`.
  3. Clicar "Excluir Item".
- **Resultado esperado:** Item removido. `lblTotalVenda` recalculado corretamente.
- **Bug atual:** Loop de recálculo em `btnExcluiVendaClick` também usa `Count` (off-by-one) — causa crash.

---

### CT-VND-010 — Remover item sem seleção no carrinho
- **Prioridade:** 🟡 Média
- **Tipo:** Limite
- **Passos:**
  1. Clicar "Excluir Item" sem selecionar linha no carrinho.
- **Resultado esperado:** Nenhuma ação. Sem crash.
- **Comportamento atual:** O código verifica `lstLista.ItemFocused <> nil` — não deleta. Porém o loop de recálculo ainda é executado, causando crash se houver itens.

---

### CT-VND-011 — Finalizar venda com itens válidos
- **Prioridade:** 🔴 Alta
- **Tipo:** Integração
- **Passos:**
  1. Selecionar cliente, adicionar ao menos 1 item ao carrinho (após correção do off-by-one).
  2. Clicar "Realizar Venda".
- **Resultado esperado:** Itens gravados no banco via `st_InsereItensVenda`. Cabeçalho gravado via `st_InsereVenda`. `lblCodVenda` incrementado.

---

### CT-VND-012 — Finalizar venda com carrinho vazio
- **Prioridade:** 🔴 Alta
- **Tipo:** Limite
- **Passos:**
  1. Abrir tela de vendas sem adicionar itens.
  2. Clicar "Realizar Venda".
- **Resultado esperado (após correção):** Mensagem informando que o carrinho está vazio. Nenhuma gravação no banco.
- **Comportamento atual:** Variável `retorno` não inicializada. Pode gravar venda vazia dependendo do valor de lixo de memória.

---

### CT-VND-013 — Finalizar venda sem selecionar cliente
- **Prioridade:** 🔴 Alta
- **Tipo:** Validação
- **Passos:**
  1. Adicionar produto ao carrinho sem clicar em nenhum cliente.
  2. Clicar "Realizar Venda".
- **Resultado esperado (após correção):** Mensagem pedindo que o cliente seja selecionado.
- **Comportamento atual:** `dbCliente.Fields[0].Value` pode estar vazio ou nulo, passando valor inválido para `@idCli`.

---

### CT-VND-014 — SP retorna @return = 2 (falha de item)
- **Prioridade:** 🔴 Alta
- **Tipo:** Integração
- **Pré-condição:** Produto cadastrado com `QTD_PROD = 0` no banco.
- **Passos:**
  1. Selecionar esse produto, quantidade = 1, incluir no carrinho.
  2. Clicar "Realizar Venda".
- **Resultado esperado:** `@erMsg` exibida ao usuário. Cabeçalho da venda **não** gravado.

---

### CT-VND-015 — SP retorna @return = 3 (sucesso com aviso)
- **Prioridade:** 🟡 Média
- **Tipo:** Integração
- **Passos:** Configurar cenário de sucesso parcial na SP do banco.
- **Resultado esperado:** `@erMsg` exibida E cabeçalho gravado.

---

### CT-VND-016 — Filtro de clientes por nome parcial
- **Prioridade:** 🟡 Média
- **Tipo:** Funcional
- **Passos:**
  1. Digitar "jo" em `edtFiltroCli`.
- **Resultado esperado:** Grade exibe apenas clientes cujo nome contém "jo" (case-insensitive conforme `FireDAC Filter`).

---

### CT-VND-017 — Filtro de produtos por nome parcial
- **Prioridade:** 🟡 Média
- **Tipo:** Funcional
- **Passos:**
  1. Digitar "can" em `edtFiltroProd`.
- **Resultado esperado:** Grade exibe apenas produtos cujo nome contém "can".

---

### CT-VND-018 — Limpar filtro restaura lista completa
- **Prioridade:** 🟢 Baixa
- **Tipo:** Funcional
- **Passos:**
  1. Aplicar filtro de cliente.
  2. Apagar o texto do filtro.
- **Resultado esperado:** Lista completa de clientes restaurada.
- **Observação:** O código seta `Filtered := false` antes de aplicar o novo filtro — ao limpar o campo, o filtro é reaplicado com string vazia, o que pode ou não restaurar todos os registros dependendo da SP do FireDAC.

---

## Módulo: Navegação

### CT-NAV-001 — Atalhos visuais da tela principal
- **Prioridade:** 🟡 Média
- **Tipo:** Funcional
- **Passos:**
  1. Clicar em cada imagem clicável: Cliente, Produtos, Vendas.
- **Resultado esperado:** Abre o formulário correspondente como modal.

---

### CT-NAV-002 — Itens de menu Cadastro > Clientes e Cadastro > Produtos
- **Prioridade:** 🔴 Alta
- **Tipo:** Regressão
- **Passos:**
  1. Clicar em `Cadastro > Cliente` no menu.
  2. Clicar em `Cadastro > Produtos` no menu.
- **Resultado esperado (após correção):** Abre o formulário correspondente.
- **Comportamento atual:** Nenhuma ação — código comentado. Nenhum feedback ao usuário.

---

### CT-NAV-003 — Item de menu Venda
- **Prioridade:** 🟡 Média
- **Tipo:** Funcional
- **Passos:**
  1. Clicar em `Venda` no menu.
- **Resultado esperado:** Abre `frmVendas` como modal.
- **Comportamento atual:** Funciona corretamente (`Venda1Click` não está comentado).

---

### CT-NAV-004 — Barra de status exibe data e hora ao abrir
- **Prioridade:** 🟢 Baixa
- **Tipo:** Funcional
- **Passos:**
  1. Iniciar a aplicação.
- **Resultado esperado:** `StatusBar1` painel[1] = data atual, painel[2] = hora da abertura.

---

## Módulo: Conexão e Dados

### CT-DAD-001 — Aplicação inicia sem conexão com SQL Server
- **Prioridade:** 🔴 Alta
- **Tipo:** Integração
- **Pré-condição:** SQL Server indisponível.
- **Passos:**
  1. Iniciar a aplicação.
- **Resultado esperado (após correção):** Mensagem amigável de erro de conexão.
- **Comportamento atual:** FireDAC lança exceção de conexão com mensagem técnica em inglês ou causa crash dependendo da configuração.

---

### CT-DAD-002 — Stored procedure ausente no banco
- **Prioridade:** 🔴 Alta
- **Tipo:** Integração
- **Pré-condição:** Uma das 8 SPs não existe no banco.
- **Passos:**
  1. Tentar usar o módulo que depende da SP ausente.
- **Resultado esperado (após correção):** Mensagem de erro tratada.
- **Comportamento atual:** Exceção FireDAC não capturada.

---

*Documento gerado com base na análise estática do código-fonte — VendaProduto, Junho/2026.*
*Total: 35 casos de teste documentados.*
