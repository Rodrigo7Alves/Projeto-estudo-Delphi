# Documentação Funcional — Sistema VendaProduto

> **Projeto:** VendaProduto
> **Tecnologia:** Delphi (VCL) + FireDAC + SQL Server
> **Tipo:** Aplicação desktop Win32
> **Versão analisada:** Build Debug (Win32)
> **Data da análise:** Junho/2026

---

## Sumário

1. [Objetivo da Aplicação](#1-objetivo-da-aplicação)
2. [Visão Geral da Arquitetura](#2-visão-geral-da-arquitetura)
3. [Módulos e Funcionalidades](#3-módulos-e-funcionalidades)
4. [Fluxos Principais](#4-fluxos-principais)
5. [Telas e Componentes](#5-telas-e-componentes)
6. [Data Module e Acesso a Dados](#6-data-module-e-acesso-a-dados)
7. [Regras de Negócio](#7-regras-de-negócio)
8. [Dependências](#8-dependências)

---

## 1. Objetivo da Aplicação

O **VendaProduto** é um sistema desktop de **Ponto de Venda (PDV)** desenvolvido em Delphi para Windows 32-bit. Permite que operadores cadastrem clientes e produtos, montem um carrinho de compras e registrem vendas concluídas em um banco de dados SQL Server.

A aplicação é voltada para uso interno e foi estruturada como projeto de estudo com os módulos essenciais de um PDV básico.

---

## 2. Visão Geral da Arquitetura

### Arquitetura de duas camadas (VCL Two-Tier)

```
┌─────────────────────────────────────────────────────────┐
│                     Camada de Apresentação               │
│  frmMain   frmCliente   frmProdutos   frmVendas         │
└────────────────────────┬────────────────────────────────┘
                         │ acessa
┌────────────────────────▼────────────────────────────────┐
│              Data Module (dm: Tdm)                       │
│  TFDConnection │ TFDQuery │ TFDStoredProc               │
└────────────────────────┬────────────────────────────────┘
                         │ comunica-se via
┌────────────────────────▼────────────────────────────────┐
│              SQL Server (ProjetoVenda)                   │
│  TBCLIENTES │ TBPRODUTOS │ TBVENDAS │ Stored Procedures │
└─────────────────────────────────────────────────────────┘
```

- Todos os formulários são criados na inicialização (`VendaProduto.dpr`) e permanecem em memória durante toda a execução.
- Todos os formulários são abertos com `ShowModal`.
- Toda escrita no banco ocorre exclusivamente via stored procedures — sem SQL inline nas units de formulário.
- O data module `dm` é um singleton global acessado por todos os formulários.

### Dependências entre módulos

```
frmMain
  ├── frmCliente  → dm (stInsereCliente, stAtualizaCliente, stExcluiCliente, qryClienets)
  ├── frmProdutos → dm (stInsereProduto, stAtualizaProduto, stExcluiProduto, qryProdutos)
  └── frmVendas   → dm (qryClienets, qryProdutos, qryCodVenda, stInsereItensVenda, stInsereVenda)
```

---

## 3. Módulos e Funcionalidades

### 3.1 Cadastro de Clientes

| Funcionalidade     | Descrição                                                         |
|--------------------|-------------------------------------------------------------------|
| Inserir cliente    | Cadastra novo cliente informando o nome; confirmação obrigatória  |
| Listar clientes    | Exibe todos os clientes em grade (ID, Nome)                       |
| Atualizar cliente  | Atualiza dados da linha selecionada na grade; confirmação         |
| Excluir cliente    | Remove o cliente selecionado da base; confirmação                 |

### 3.2 Cadastro de Produtos

| Funcionalidade     | Descrição                                                         |
|--------------------|-------------------------------------------------------------------|
| Inserir produto    | Cadastra novo produto com nome, quantidade e valor unitário       |
| Listar produtos    | Exibe todos os produtos em grade (ID, Nome, Qtd, Valor)           |
| Atualizar produto  | Atualiza nome, quantidade e valor da linha selecionada na grade   |
| Excluir produto    | Remove o produto selecionado da base                              |

### 3.3 Realização de Vendas

| Funcionalidade       | Descrição                                                            |
|----------------------|----------------------------------------------------------------------|
| Gerar código venda   | Carrega próximo código sequencial ao abrir a tela                    |
| Filtrar clientes     | Busca por nome parcial em tempo real                                 |
| Filtrar produtos     | Busca por nome parcial em tempo real                                 |
| Selecionar cliente   | Clique na grade preenche nome do cliente na venda                    |
| Selecionar produto   | Clique na grade preenche nome e valor unitário                       |
| Calcular subtotal    | Ao sair do campo de quantidade: `subtotal = qtd × valor`             |
| Incluir item         | Adiciona produto+quantidade ao carrinho e recalcula total            |
| Remover item         | Remove item selecionado do carrinho e recalcula total                |
| Finalizar venda      | Persiste itens e cabeçalho no banco; incrementa código de venda      |

### 3.4 Navegação

| Funcionalidade      | Descrição                                                            |
|---------------------|----------------------------------------------------------------------|
| Atalhos visuais     | Imagens clicáveis na tela principal abrem os módulos                 |
| Menu superior       | Acesso via `Cadastro > Cliente`, `Cadastro > Produtos`, `Venda`      |
| Barra de status     | Exibe data e hora no `FormShow` da tela principal                    |

---

## 4. Fluxos Principais

### 4.1 Fluxo de Cadastro de Cliente

```
Abrir frmCliente
  → Digitar nome em edtNome
  → Clicar btnSalvar
    → Confirmação "Deseja Salvar?" [Sim | Não]
      [Sim] → dm.stInsereCliente(@nome) → ExecProc
             → dm.qryClienets: Close; Open
             → edtNome.Clear
      [Não] → MessageBox "Ação Cancelada"
```

### 4.2 Fluxo de Atualização de Cliente

```
Abrir frmCliente
  → Selecionar linha em dbCliente
  → Clicar btnAtualizar
    → Confirmação "Deseja Atualizar?" [Sim | Não]
      [Sim] → dm.stAtualizaCliente(@id = Fields[0], @nome = Fields[1]) → ExecProc
             → dm.qryClienets: Close; Open
      [Não] → MessageBox "Ação Cancelada"
```

> **Atenção:** a atualização lê ID e Nome da **grade** — não do campo `edtNome`.

### 4.3 Fluxo de Exclusão de Cliente

```
Abrir frmCliente
  → Selecionar linha em dbCliente
  → Clicar btnExcluir
    → Confirmação "Deseja Excluir?" [Sim | Não]
      [Sim] → dm.stExcluiCliente(@id = Fields[0]) → ExecProc
             → dm.qryClienets: Close; Open
      [Não] → MessageBox "Ação Cancelada"
```

> Os fluxos de **Inserir, Atualizar e Excluir Produto** seguem o mesmo padrão, adicionando os parâmetros `@qtd` e `@vl`.

### 4.4 Fluxo de Realização de Venda

```
Abrir frmVendas
  → dm.qryCodVenda: Close; Open
  → lblCodVenda ← MAX(ID_Cod_Venda) + 1

  [Seleção de cliente]
  → Digitar em edtFiltroCli (opcional) → filtra qryClienets em tempo real
  → Clicar em linha de dbCliente → edtNomeClie ← Fields[1]

  [Seleção de produto]
  → Digitar em edtFiltroProd (opcional) → filtra qryProdutos em tempo real
  → Clicar em linha de dbProdutos
      → edtProd ← Fields[1]
      → edtValorProduto ← Fields[3]

  [Incluir item]
  → Ajustar edtQtdProd (SpinEdit)
  → Sair do campo edtQtdProd (OnExit)
      → edtTotalProduto ← edtQtdProd × edtValorProduto
  → Clicar btnIncluiItem
      → Se qtd > 0: adiciona linha em lstLista (Produto | Valor | Qtd | Total)
                    recalcula lblTotalVenda
      → Se qtd = 0: ShowMessage "Por Favor insira uma quantidade"

  [Remover item]
  → Selecionar linha em lstLista
  → Clicar btnExcluiVenda
      → lstLista.DeleteSelected
      → recalcula lblTotalVenda

  [Finalizar venda]
  → Clicar btnRealizaVenda
  → Para cada item (i = 0 to Count-1):
        dm.stInsereItensVenda(@nm_Prod, @qtdVenda, @CodVenda) → ExecProc
        retorno ← @return; erMsg ← @erMsg
        Se retorno = 2 ou 3 → ShowMessage(erMsg)
  → Se retorno = 1 ou 3:
        dm.stInsereVenda(@idCli = dbCliente.Fields[0],
                         @total = lblTotalVenda.Caption,
                         @codVenda = lblCodVenda.Caption) → ExecProc
  → lblCodVenda ← qryCodVendaUnnamed1 + 1
```

---

## 5. Telas e Componentes

### 5.1 frmMain — Tela Principal

Hub de navegação da aplicação.

| Componente    | Tipo         | Função                                          |
|---------------|--------------|-------------------------------------------------|
| `Image1`      | TImage       | Atalho visual → abre frmCliente                 |
| `imgProdutos` | TImage       | Atalho visual → abre frmProdutos                |
| `imgVendas`   | TImage       | Atalho visual → abre frmVendas                  |
| `MainMenu1`   | TMainMenu    | Menu superior: Cadastro > Cliente/Produtos, Venda |
| `StatusBar1`  | TStatusBar   | Painel[1] = Data, Painel[2] = Hora              |

> **Bug:** `Cliente1Click` e `Produtos1Click` têm o código comentado — não funcionam.

---

### 5.2 frmCliente — Cadastro de Clientes

| Componente    | Tipo      | Função                                               |
|---------------|-----------|------------------------------------------------------|
| `edtNome`     | TEdit     | Entrada do nome do cliente (inserção)                |
| `btnSalvar`   | TButton   | Insere novo cliente                                  |
| `btnAtualizar`| TButton   | Atualiza cliente selecionado na grade                |
| `btnExcluir`  | TButton   | Exclui cliente selecionado na grade                  |
| `dbCliente`   | TDBGrid   | Grade de clientes (ID_CLI, NOME_CLI)                 |

---

### 5.3 frmProdutos — Cadastro de Produtos

| Componente    | Tipo       | Função                                              |
|---------------|------------|-----------------------------------------------------|
| `edtNome`     | TEdit      | Nome do produto                                     |
| `edtQtd`      | TSpinEdit  | Quantidade em estoque (numérico com spin)            |
| `edtValor`    | TEdit      | Valor unitário (campo livre — sem máscara)           |
| `btnSalvar`   | TButton    | Insere novo produto                                 |
| `btnAtualizar`| TButton    | Atualiza produto selecionado                        |
| `btnExcluir`  | TButton    | Exclui produto selecionado                          |
| `dbProdutos`  | TDBGrid    | Grade de produtos (ID_PROD, NOME_PROD, QTD_PROD, VL_PROD) |

> **Evento:** `FormShow` reabre `qryProdutos` automaticamente.

---

### 5.4 frmVendas — Tela de Vendas

**Painel de Clientes (panCliente)**

| Componente     | Tipo      | Função                                              |
|----------------|-----------|-----------------------------------------------------|
| `edtFiltroCli` | TEdit     | Filtro em tempo real por NOME_CLI                   |
| `dbCliente`    | TDBGrid   | Lista de clientes (ID_CLI, NOME_CLI)                |
| `edtNomeClie`  | TEdit     | Nome do cliente selecionado (somente leitura lógica)|

**Painel de Produtos (panProd)**

| Componente      | Tipo      | Função                                             |
|-----------------|-----------|----------------------------------------------------|
| `edtFiltroProd` | TEdit     | Filtro em tempo real por NOME_PROD                 |
| `dbProdutos`    | TDBGrid   | Lista de produtos (ID, Nome, Qtd, Valor)           |
| `edtProd`       | TEdit     | Nome do produto selecionado                        |
| `edtValorProduto`| TEdit    | Valor unitário do produto selecionado              |

**Painel de Venda (panVenda)**

| Componente         | Tipo       | Função                                          |
|--------------------|------------|-------------------------------------------------|
| `lblCodVenda`      | TLabel     | Código da venda em andamento                    |
| `edtQtdProd`       | TSpinEdit  | Quantidade do produto a incluir                 |
| `edtTotalProduto`  | TEdit      | Subtotal calculado (qtd × valor)                |
| `lstLista`         | TListView  | Carrinho: Produto \| Valor Unit. \| Qtd \| Total |
| `lblTotalVenda`    | TLabel     | Total geral da venda (ex: `R$150,00`)           |
| `btnIncluiItem`    | TButton    | Adiciona item ao carrinho                        |
| `btnExcluiVenda`   | TButton    | Remove item selecionado do carrinho              |
| `btnRealizaVenda`  | TButton    | Finaliza e persiste a venda                      |

---

## 6. Data Module e Acesso a Dados

### 6.1 Conexão

```
Servidor : localhost\SQLSERVER2022
Banco    : ProjetoVenda
Usuário  : sa
Senha    : 123456 (armazenada em texto plano no dmDados.dfm)
Driver   : MSSQL (FireDAC)
```

### 6.2 Queries (leitura)

| Componente       | SQL                                   | Campos expostos                          |
|------------------|---------------------------------------|------------------------------------------|
| `qryClienets`    | `SELECT * FROM TBCLIENTES`            | ID_CLI (int, autoincrement), NOME_CLI    |
| `qryProdutos`    | `select * from tbprodutos`            | ID_PROD, NOME_PROD, QTD_PROD, VL_PROD   |
| `qryCodVenda`    | `SELECT MAX(ID_Cod_Venda) FROM TBVENDAS` | Unnamed1 (integer)                    |

### 6.3 Stored Procedures (escrita)

| Componente           | SP no banco                         | Parâmetros de entrada              | Retorno                    |
|----------------------|-------------------------------------|------------------------------------|----------------------------|
| `stInsereCliente`    | `dbo.st_InsereCli`                  | `@nome` (string 50)                | `@RETURN_VALUE`            |
| `stAtualizaCliente`  | `dbo.st_AlteraCli`                  | `@id` (int), `@nome` (string 50)   | `@RETURN_VALUE`            |
| `stExcluiCliente`    | `dbo.ST_APAGACLI`                   | `@ID` (int)                        | `@RETURN_VALUE`            |
| `stInsereProduto`    | `dbo.st_InsereProd`                 | `@nome`, `@qtd` (int), `@vl` (currency) | `@RETURN_VALUE`       |
| `stAtualizaProduto`  | `dbo.st_AtualizaProd`               | `@id`, `@nome`, `@qtd`, `@vl`      | `@RETURN_VALUE`            |
| `stExcluiProduto`    | `dbo.stExcluiProd`                  | `@id` (int)                        | `@RETURN_VALUE`            |
| `stInsereItensVenda` | `dbo.st_InsereItensVenda`           | `@nm_Prod`, `@qtdVenda`, `@codVenda` | `@return` (int I/O), `@erMsg` (string I/O) |
| `stInsereVenda`      | `dbo.st_InsereVenda`                | `@idCli`, `@total` (currency), `@codVenda` | `@RETURN_VALUE`   |

### 6.4 Semântica de retorno da SP de itens

| `@return` | Significado                                          | Comportamento no código              |
|-----------|------------------------------------------------------|--------------------------------------|
| `1`       | Sucesso — item inserido, estoque suficiente          | Grava cabeçalho da venda             |
| `2`       | Falha — produto não encontrado ou erro de item       | Exibe `@erMsg`, não grava cabeçalho  |
| `3`       | Sucesso parcial / aviso (ex: estoque zerado)         | Exibe `@erMsg` E grava cabeçalho     |

---

## 7. Regras de Negócio

| ID    | Regra                                                                                                        | Localização                          |
|-------|--------------------------------------------------------------------------------------------------------------|--------------------------------------|
| RN01  | Quantidade do item na venda deve ser > 0 para inclusão no carrinho                                           | `Vendas.pas` — `btnIncluiItemClick`  |
| RN02  | Subtotal do item = quantidade × valor unitário                                                                | `Vendas.pas` — `edtQtdProdExit`      |
| RN03  | Total geral = soma de todos os subtotais do carrinho; recalculado a cada inclusão ou remoção                 | `Vendas.pas` — botões de item        |
| RN04  | Código de venda gerado como `MAX(ID_Cod_Venda) + 1` no `FormShow`                                           | `Vendas.pas` — `FormShow`            |
| RN05  | Cabeçalho de venda é gravado somente se `@return = 1` ou `@return = 3`                                       | `Vendas.pas` — `btnRealizaVendaClick`|
| RN06  | Se `@return = 2` ou `@return = 3`, a mensagem `@erMsg` da SP é exibida ao operador                           | `Vendas.pas` — `btnRealizaVendaClick`|
| RN07  | Toda operação de escrita (inserir/atualizar/excluir) requer confirmação explícita via diálogo Sim/Não         | `Cliente.pas`, `Produtos.pas`        |
| RN08  | Atualização de cliente usa ID e Nome da linha selecionada na grade — não do campo de entrada                  | `Cliente.pas` — `btnAtualizarClick`  |
| RN09  | Filtro de clientes e produtos usa correspondência parcial (`LIKE %termo%`) sobre a query em memória           | `Vendas.pas` — eventos OnChange      |
| RN10  | Valor unitário do produto é carregado automaticamente do campo `VL_PROD` (índice 3) ao selecionar na grade   | `Vendas.pas` — `dbProdutosCellClick` |
| RN11  | Após finalizar venda, o código exibido é incrementado localmente (`qryCodVendaUnnamed1.Value + 1`) sem reabrir a query | `Vendas.pas` — `btnRealizaVendaClick` |
| RN12  | O total da venda é enviado ao banco como `lblTotalVenda.Caption` (string com prefixo "R$") — não como número | `Vendas.pas` — `btnRealizaVendaClick`|

---

## 8. Dependências

### 8.1 Tecnológicas

| Dependência      | Detalhes                                                         |
|------------------|------------------------------------------------------------------|
| Delphi / VCL     | Framework visual; VCL para todos os componentes de UI            |
| FireDAC          | Acesso a dados: `TFDConnection`, `TFDQuery`, `TFDStoredProc`     |
| SQL Server 2022  | Banco de dados; instância `localhost\SQLSERVER2022`              |
| Windows 32-bit   | Plataforma de execução; sem DLLs externas além de VCL/FireDAC    |

### 8.2 Estruturas de banco necessárias

**Tabelas (inferidas das queries e SPs):**

| Tabela       | Campos inferidos                                                   |
|--------------|--------------------------------------------------------------------|
| `TBCLIENTES` | `ID_CLI` (identity), `NOME_CLI` (varchar 50)                       |
| `TBPRODUTOS` | `ID_PROD` (identity), `NOME_PROD` (varchar 50), `QTD_PROD` (int), `VL_PROD` (decimal/money) |
| `TBVENDAS`   | `ID_Cod_Venda` (identity), `ID_CLI` (FK), `TOTAL` (?), `COD_VENDA` (int) |
| Itens venda  | `NM_PROD` (varchar), `QTD_VENDA` (int), `COD_VENDA` (int)         |

**Stored procedures (8 obrigatórias):**

```
dbo.st_InsereCli        dbo.st_AlteraCli        dbo.ST_APAGACLI
dbo.st_InsereProd       dbo.st_AtualizaProd     dbo.stExcluiProd
dbo.st_InsereItensVenda dbo.st_InsereVenda
```

---

*Documento gerado com base na análise estática do código-fonte — VendaProduto (Delphi/FireDAC), Junho/2026.*
