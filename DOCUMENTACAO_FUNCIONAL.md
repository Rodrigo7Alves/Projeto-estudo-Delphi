# Documentação Funcional — Sistema VendaProduto

> **Projeto:** VendaProduto  
> **Tecnologia:** Delphi (VCL) + FireDAC + SQL Server  
> **Tipo:** Aplicação desktop Win32  
> **Versão analisada:** Build Debug (Win32)  
> **Data da análise:** Junho/2026  

---

## Sumário

1. [Objetivo da Aplicação](#1-objetivo-da-aplicação)
2. [Funcionalidades Identificadas](#2-funcionalidades-identificadas)
3. [Fluxos Principais](#3-fluxos-principais)
4. [Telas Encontradas](#4-telas-encontradas)
5. [Regras de Negócio](#5-regras-de-negócio)
6. [Dependências](#6-dependências)
7. [Pontos de Atenção para QA](#7-pontos-de-atenção-para-qa)

---

## 1. Objetivo da Aplicação

O **VendaProduto** é um sistema desktop de **Ponto de Venda (PDV)** desenvolvido em Delphi. Seu propósito é permitir que operadores realizem o cadastro de clientes e produtos, montem um carrinho de compras e registrem vendas em um banco de dados SQL Server.

A aplicação é voltada para uso interno, operando em ambiente Windows 32-bit, e foi estruturada como um projeto de estudo com os módulos essenciais de um PDV básico.

---

## 2. Funcionalidades Identificadas

### 2.1 Cadastro de Clientes

| Funcionalidade | Descrição |
|---|---|
| Inserir cliente | Cadastra um novo cliente informando o nome |
| Listar clientes | Exibe todos os clientes cadastrados em uma grade |
| Atualizar cliente | Atualiza os dados do cliente selecionado na grade |
| Excluir cliente | Remove o cliente selecionado da base de dados |

### 2.2 Cadastro de Produtos

| Funcionalidade | Descrição |
|---|---|
| Inserir produto | Cadastra um novo produto com nome, quantidade e valor unitário |
| Listar produtos | Exibe todos os produtos cadastrados em uma grade |
| Atualizar produto | Atualiza nome, quantidade e valor do produto selecionado |
| Excluir produto | Remove o produto selecionado da base de dados |

### 2.3 Realização de Vendas

| Funcionalidade | Descrição |
|---|---|
| Filtrar clientes | Busca clientes em tempo real pelo nome durante a venda |
| Filtrar produtos | Busca produtos em tempo real pelo nome durante a venda |
| Selecionar cliente | Associa um cliente à venda em andamento |
| Selecionar produto | Seleciona o produto a ser adicionado ao carrinho |
| Calcular subtotal | Calcula automaticamente o total do item (qtd × valor) ao sair do campo de quantidade |
| Incluir item | Adiciona o produto e quantidade ao carrinho da venda |
| Remover item | Remove o item selecionado do carrinho |
| Calcular total geral | Atualiza o total da venda a cada inclusão ou remoção de item |
| Finalizar venda | Persiste os itens e o cabeçalho da venda no banco de dados |
| Gerar código de venda | Gera automaticamente o próximo código sequencial de venda |

### 2.4 Navegação Geral

| Funcionalidade | Descrição |
|---|---|
| Menu principal | Acesso aos módulos via menu superior |
| Atalhos visuais | Acesso aos módulos por imagens clicáveis na tela inicial |
| Barra de status | Exibe data e hora atuais no rodapé da tela principal |

---

## 3. Fluxos Principais

### 3.1 Fluxo de Cadastro de Cliente

```
Abrir tela de Clientes
  → Digitar nome no campo "Nome"
  → Clicar em "Salvar"
    → Confirmação: "Deseja Salvar?" [Sim / Não]
      → [Sim] Executa stored procedure de inserção
             → Grade é recarregada
             → Campo nome é limpo
      → [Não] Exibe "Ação Cancelada"
```

### 3.2 Fluxo de Atualização de Cliente

```
Abrir tela de Clientes
  → Selecionar registro na grade
  → Clicar em "Atualizar"
    → Confirmação: "Deseja Atualizar?" [Sim / Não]
      → [Sim] Executa stored procedure com ID e Nome da linha selecionada
             → Grade é recarregada
      → [Não] Exibe "Ação Cancelada"
```

### 3.3 Fluxo de Exclusão de Cliente

```
Abrir tela de Clientes
  → Selecionar registro na grade
  → Clicar em "Excluir"
    → Confirmação: "Deseja Excluir?" [Sim / Não]
      → [Sim] Executa stored procedure de exclusão com ID do registro
             → Grade é recarregada
      → [Não] Exibe "Ação Cancelada"
```

> Os fluxos de **Cadastro, Atualização e Exclusão de Produtos** seguem o mesmo padrão acima, com os campos adicionais de quantidade e valor.

### 3.4 Fluxo de Realização de Venda

```
Abrir tela de Vendas
  → Sistema carrega o próximo código de venda
  → Selecionar cliente (clique na grade ou filtro por nome)
  → Selecionar produto (clique na grade ou filtro por nome)
  → Informar quantidade (SpinEdit)
    → Ao sair do campo: subtotal é calculado automaticamente
  → Clicar em "Incluir Item"
    → Item é adicionado ao carrinho (ListView)
    → Total geral é recalculado
  → [Opcional] Selecionar item no carrinho → Clicar "Excluir Item"
    → Item removido → Total recalculado
  → Clicar em "Realizar Venda"
    → Para cada item do carrinho:
        → Executa stored procedure de inserção de item
        → Recebe @return e @erMsg
        → Se @return = 2 ou 3: exibe mensagem de erro
    → Se @return = 1 ou 3: executa stored procedure de cabeçalho da venda
    → Código de venda é incrementado para o próximo
```

---

## 4. Telas Encontradas

### 4.1 Tela Principal — `frmMain` (Main.pas)

Tela inicial e hub de navegação do sistema.

**Componentes principais:**
- `Image1` — atalho visual para Clientes
- `imgProdutos` — atalho visual para Produtos
- `imgVendas` — atalho visual para Vendas
- `MainMenu1` — menu superior com itens: Cadastro > Cliente, Cadastro > Produtos, Venda
- `StatusBar1` — barra de status com data e hora (painéis índice 1 e 2)

**Observação:** Os itens de menu `Cliente1` e `Produtos1` estão com código comentado e não funcionam.

---

### 4.2 Tela de Clientes — `frmCliente` (Cliente.pas)

Gerenciamento do cadastro de clientes.

**Componentes principais:**

| Componente | Tipo | Função |
|---|---|---|
| `edtNome` | TEdit | Campo de entrada do nome do cliente |
| `btnSalvar` | TButton | Salva novo cliente |
| `btnAtualizar` | TButton | Atualiza cliente selecionado na grade |
| `btnExcluir` | TButton | Exclui cliente selecionado na grade |
| `dbCliente` | TDBGrid | Exibe lista de clientes (colunas: ID, Nome) |

---

### 4.3 Tela de Produtos — `frmProdutos` (Produtos.pas)

Gerenciamento do cadastro de produtos.

**Componentes principais:**

| Componente | Tipo | Função |
|---|---|---|
| `edtNome` | TEdit | Nome do produto |
| `edtQtd` | TSpinEdit | Quantidade em estoque |
| `edtValor` | TEdit | Valor unitário do produto |
| `btnSalvar` | TButton | Salva novo produto |
| `btnAtualizar` | TButton | Atualiza produto selecionado |
| `btnExcluir` | TButton | Exclui produto selecionado |
| `dbProdutos` | TDBGrid | Exibe lista de produtos (ID, Nome, Qtd, Valor) |

**Evento de carregamento:** A grade de produtos é aberta automaticamente no `FormShow`.

---

### 4.4 Tela de Vendas — `frmVendas` (Vendas.pas)

Tela principal de operação de vendas. Dividida em três painéis.

**Painel de Clientes (`panCliente`):**

| Componente | Tipo | Função |
|---|---|---|
| `edtFiltroCli` | TEdit | Filtro de busca por nome do cliente |
| `dbCliente` | TDBGrid | Lista de clientes filtrados |
| `edtNomeClie` | TEdit | Exibe nome do cliente selecionado |

**Painel de Produtos (`panProd`):**

| Componente | Tipo | Função |
|---|---|---|
| `edtFiltroProd` | TEdit | Filtro de busca por nome do produto |
| `dbProdutos` | TDBGrid | Lista de produtos filtrados |
| `edtProd` | TEdit | Exibe nome do produto selecionado |
| `edtValorProduto` | TEdit | Exibe valor unitário do produto selecionado |

**Painel de Venda (`panVenda`):**

| Componente | Tipo | Função |
|---|---|---|
| `lblCodVenda` | TLabel | Exibe o código da venda atual |
| `edtQtdProd` | TSpinEdit | Quantidade do produto a incluir |
| `edtTotalProduto` | TEdit | Total calculado do item (qtd × valor) |
| `lstLista` | TListView | Carrinho com itens da venda (Produto, Valor, Qtd, Total) |
| `lblTotalVenda` | TLabel | Total geral da venda |
| `btnIncluiItem` | TButton | Adiciona item ao carrinho |
| `btnExcluiVenda` | TButton | Remove item selecionado do carrinho |
| `btnRealizaVenda` | TButton | Finaliza e persiste a venda |

---

### 4.5 Data Module — `dm` (dmDados.pas)

Módulo de dados centralizado. Não é uma tela visível, mas é a camada de acesso a dados compartilhada por todas as telas.

**Conexão:**
- `conProjetoVenda` — TFDConnection para SQL Server

**Queries:**
- `qryClienets` — lista de clientes (campos: ID_CLI, NOME_CLI)
- `qryProdutos` — lista de produtos (campos: ID_PROD, NOME_PROD, QTD_PROD, VL_PROD)
- `qryCodVenda` — retorna o último código de venda para gerar o próximo sequencial

**Stored Procedures:**

| Componente | Operação |
|---|---|
| `stInsereCliente` | Insere novo cliente (`@nome`) |
| `stAtualizaCliente` | Atualiza cliente (`@id`, `@nome`) |
| `stExcluiCliente` | Exclui cliente (`@id`) |
| `stInsereProduto` | Insere novo produto (`@nome`, `@qtd`, `@vl`) |
| `stAtualizaProduto` | Atualiza produto (`@id`, `@nome`, `@qtd`, `@vl`) |
| `stExcluiProduto` | Exclui produto (`@id`) |
| `stInsereItensVenda` | Insere item de venda (`@nm_Prod`, `@qtdVenda`, `@CodVenda`) → retorna `@return`, `@erMsg` |
| `stInsereVenda` | Insere cabeçalho da venda (`@idCli`, `@total`, `@codVenda`) |

---

## 5. Regras de Negócio

| ID | Regra | Localização |
|---|---|---|
| **RN01** | A quantidade de um item na venda deve ser maior que zero para ser incluída no carrinho | `Vendas.pas` — `btnIncluiItemClick` |
| **RN02** | O subtotal de cada item é calculado como: `total = quantidade × valor unitário` | `Vendas.pas` — `edtQtdProdExit` |
| **RN03** | O total geral da venda é a soma dos subtotais de todos os itens do carrinho | `Vendas.pas` — recalculado em `btnIncluiItemClick` e `btnExcluiVendaClick` |
| **RN04** | O código de venda é gerado sequencialmente com base no último código registrado no banco | `Vendas.pas` — `FormShow` e `btnRealizaVendaClick` |
| **RN05** | A stored procedure de itens retorna um código (`@return`) e mensagem de erro (`@erMsg`) que determinam o fluxo da venda | `Vendas.pas` — `btnRealizaVendaClick` |
| **RN06** | O cabeçalho da venda só é gravado se `@return = 1` (sucesso total) ou `@return = 3` (sucesso parcial com erro) | `Vendas.pas` — `btnRealizaVendaClick` |
| **RN07** | Toda operação de escrita (inserir, atualizar, excluir) exige confirmação explícita do usuário via caixa de diálogo Sim/Não | `Cliente.pas`, `Produtos.pas` — todos os botões de ação |
| **RN08** | A atualização de cliente usa o ID e o Nome diretamente da linha selecionada na grade (não do campo de entrada) | `Cliente.pas` — `btnAtualizarClick` |
| **RN09** | A filtragem de clientes e produtos na tela de vendas é feita por correspondência parcial (`LIKE %termo%`) | `Vendas.pas` — `edtFiltroCliChange`, `edtFiltroProdChange` |
| **RN10** | O valor unitário do produto exibido na venda é carregado automaticamente ao selecionar o produto na grade | `Vendas.pas` — `dbProdutosCellClick` |

---

## 6. Dependências

### 6.1 Tecnológicas

| Dependência | Detalhes |
|---|---|
| **Delphi (VCL)** | Framework visual para aplicações Windows |
| **FireDAC** | Biblioteca de acesso a dados utilizada para conexão e execução de queries/stored procedures |
| **SQL Server** | Banco de dados relacional onde estão armazenados clientes, produtos e vendas |
| **Windows 32-bit** | Plataforma de execução (build configurado para Win32) |

### 6.2 Banco de Dados

A aplicação depende das seguintes estruturas no SQL Server:

**Tabelas (inferidas):**
- `Clientes` — com campos `ID_CLI` (auto-increment), `NOME_CLI`
- `Produtos` — com campos `ID_PROD` (auto-increment), `NOME_PROD`, `QTD_PROD`, `VL_PROD`
- Tabela de vendas (cabeçalho) — com campos de ID do cliente, total e código de venda
- Tabela de itens de venda — com campos de nome do produto, quantidade e código de venda

**Stored Procedures necessárias (8 ao total):**
`sp_InsereCliente`, `sp_AtualizaCliente`, `sp_ExcluiCliente`,
`sp_InsereProduto`, `sp_AtualizaProduto`, `sp_ExcluiProduto`,
`sp_InsereItensVenda`, `sp_InsereVenda`

### 6.3 Entre Módulos

```
frmMain
  ├── usa → frmCliente
  ├── usa → frmProdutos
  └── usa → frmVendas
              ├── usa → dm.qryClienets
              ├── usa → dm.qryProdutos
              └── usa → dm.stInsereItensVenda / stInsereVenda

frmCliente  → usa dm (stInsereCliente, stAtualizaCliente, stExcluiCliente, qryClienets)
frmProdutos → usa dm (stInsereProduto, stAtualizaProduto, stExcluiProduto, qryProdutos)
frmVendas   → usa dm (qryClienets, qryProdutos, qryCodVenda, stInsereItensVenda, stInsereVenda)
```

---

## 7. Pontos de Atenção para QA

### 7.1 Bugs Confirmados no Código

#### 🔴 CRÍTICO — Off-by-one na iteração da ListView

**Arquivo:** `Vendas.pas` — `btnIncluiItemClick` e `btnExcluiVendaClick`

```pascal
// ERRADO: Count gera índice inválido na última iteração
for I := 0 to lstLista.Items.Count do

// CORRETO:
for I := 0 to lstLista.Items.Count - 1 do
```

**Impacto:** Causa `Access Violation` (crash) ao incluir ou remover qualquer item do carrinho quando há ao menos um item na lista.  
**Prioridade de correção:** Imediata.

---

#### 🔴 CRÍTICO — Variável `retorno` não inicializada

**Arquivo:** `Vendas.pas` — `btnRealizaVendaClick`

```pascal
var
  retorno, i: integer; // valor indefinido se o loop não executar
```

**Impacto:** Se o carrinho estiver vazio e o usuário clicar em "Realizar Venda", a condição `if (retorno = 1) or (retorno = 3)` pode ser verdadeira acidentalmente, gravando uma venda sem itens no banco.  
**Prioridade de correção:** Imediata.

---

#### 🔴 CRÍTICO — Conversões sem tratamento de exceção

**Arquivo:** `Vendas.pas` — `edtQtdProdExit`, `btnIncluiItemClick`, `btnExcluiVendaClick`

Uso de `StrToInt` e `StrToFloat` diretamente sobre campos de texto sem `try/except`.

**Impacto:** Se o campo estiver vazio ou contiver texto inválido, a aplicação lança `EConvertError` e trava.  
**Cenários a testar:** campo vazio, letras, vírgula/ponto em campos de inteiro, valores negativos.

---

### 7.2 Falhas de Validação de Negócio

#### 🟡 MÉDIO — Nenhum campo obrigatório é validado antes de salvar

| Tela | Campo | Comportamento atual |
|---|---|---|
| Clientes | Nome | Permite salvar cliente com nome vazio |
| Produtos | Nome | Permite salvar produto com nome vazio |
| Produtos | Valor | Campo livre — aceita texto inválido |
| Vendas | Cliente | Permite finalizar venda sem cliente selecionado |
| Vendas | Itens | Permite tentar finalizar venda com carrinho vazio |

---

#### 🟡 MÉDIO — Botão "Atualizar" de Clientes não usa o campo de entrada

O `btnAtualizar` em `Cliente.pas` lê os dados da **grade** (`dbCliente.Fields[1].Value`), não do campo `edtNome`. O usuário não consegue editar o nome pelo formulário — o botão apenas re-salva o valor atual.

---

#### 🟡 MÉDIO — Total da venda enviado como string com prefixo "R$"

```pascal
paramByName('@total').Value := lblTotalVenda.Caption; // ex: "R$1500,50"
```

A stored procedure recebe uma string formatada em vez de um valor numérico, o que pode causar erro de conversão no banco dependendo do tipo do parâmetro.

---

#### 🟡 MÉDIO — Código de venda calculado localmente sem revalidação

O próximo código é calculado com `qryCodVendaUnnamed1.Value + 1` sem reabrir a query. Em uso simultâneo por múltiplos usuários (ou após falha de venda), o código pode ficar dessincronizado com o banco, gerando duplicidade ou salto de sequência.

---

### 7.3 Problemas de Usabilidade

#### 🟢 BAIXO — Itens de menu não funcionais sem indicação visual

`Cliente > Clientes` e `Produtos > Produtos` no menu principal têm código comentado. O usuário clica e nada acontece, sem qualquer feedback.

#### 🟢 BAIXO — Nenhuma validação de seleção antes de Excluir/Atualizar

Clicar em "Excluir" ou "Atualizar" sem selecionar uma linha na grade pode gerar erro ao acessar `Fields[0].Value` em um dataset vazio.

#### 🟢 BAIXO — Barra de status não atualiza o relógio em tempo real

Data e hora são definidas apenas no `FormShow`. O horário exibido não avança enquanto a aplicação está aberta.

#### 🟢 BAIXO — Sem mensagem de sucesso após operações

Após salvar, atualizar ou excluir com sucesso, não há confirmação visual — a grade simplesmente recarrega, podendo confundir o usuário quanto ao resultado da operação.

---

### 7.4 Casos de Teste Sugeridos

| ID | Cenário | Tipo | Prioridade |
|---|---|---|---|
| CT01 | Incluir item no carrinho com 1 produto | Funcional | Alta |
| CT02 | Incluir item com quantidade = 0 | Validação | Alta |
| CT03 | Remover item do carrinho com 1 item | Funcional | Alta |
| CT04 | Remover item do carrinho com 0 itens | Limite | Alta |
| CT05 | Finalizar venda com carrinho vazio | Limite | Alta |
| CT06 | Finalizar venda sem cliente selecionado | Validação | Alta |
| CT07 | Salvar cliente com nome vazio | Validação | Média |
| CT08 | Salvar produto com valor inválido (texto) | Validação | Alta |
| CT09 | Clicar em "Atualizar" sem selecionar linha na grade | Limite | Média |
| CT10 | Clicar em "Excluir" sem selecionar linha na grade | Limite | Média |
| CT11 | Verificar se total da venda é calculado corretamente com múltiplos itens | Funcional | Alta |
| CT12 | Verificar se o código de venda incrementa após cada venda finalizada | Funcional | Média |
| CT13 | Filtrar clientes por nome parcial na tela de vendas | Funcional | Média |
| CT14 | Filtrar produtos por nome parcial na tela de vendas | Funcional | Média |
| CT15 | Abrir tela de vendas e verificar carregamento do código inicial | Funcional | Baixa |

---

*Documento gerado com base na análise estática do código-fonte do projeto VendaProduto (Delphi/FireDAC).*
