# Regras de Negócio — Sistema VendaProduto

> **Projeto:** VendaProduto
> **Base:** Análise estática do código-fonte (Delphi/FireDAC)
> **Data:** Junho/2026

---

## Sumário

1. [Módulo Clientes](#1-módulo-clientes)
2. [Módulo Produtos](#2-módulo-produtos)
3. [Módulo Vendas](#3-módulo-vendas)
4. [Interface e Navegação](#4-interface-e-navegação)
5. [Acesso a Dados](#5-acesso-a-dados)
6. [Tabela Consolidada](#6-tabela-consolidada)

---

## 1. Módulo Clientes

### RN-CLI-01 — Confirmação obrigatória para escrita
Toda operação de inserção, atualização ou exclusão de cliente exige confirmação prévia do usuário via diálogo modal (Sim/Não). A operação é executada no banco somente após resposta "Sim".

> *Implementado em:* `btnSalvarClick`, `btnAtualizarClick`, `btnExcluirClick` — `Cliente.pas`

---

### RN-CLI-02 — Atualização via seleção na grade
A operação de atualização de cliente utiliza o **ID e o Nome da linha atualmente selecionada na grade** (`dbCliente.Fields[0].Value`, `dbCliente.Fields[1].Value`). O campo de entrada `edtNome` não participa da atualização — apenas da inserção.

> *Consequência:* O operador não pode editar o nome de um cliente pelo formulário. O botão "Atualizar" re-salva o valor já existente na grade.

---

### RN-CLI-03 — Exclusão por ID
A exclusão remove o registro cujo `ID_CLI` corresponde à primeira coluna da linha selecionada na grade. A operação é irreversível no nível da aplicação.

---

### RN-CLI-04 — Limpeza após inserção
Após inserir um novo cliente com sucesso, o campo `edtNome` é limpo automaticamente para facilitar a entrada do próximo cadastro.

---

### RN-CLI-05 — Recarregamento da grade
A lista de clientes é recarregada (`Close; Open`) imediatamente após qualquer operação de escrita bem-sucedida, refletindo o estado atual do banco.

---

## 2. Módulo Produtos

### RN-PRD-01 — Confirmação obrigatória para escrita
Toda operação de inserção, atualização ou exclusão de produto exige confirmação prévia do usuário via diálogo modal (Sim/Não).

> *Implementado em:* `btnSalvarClick`, `btnAtualizarClick`, `btnExcluirClick` — `Produtos.pas`

---

### RN-PRD-02 — Produto com três atributos de dados
Um produto é definido por três atributos: **Nome** (texto), **Quantidade em estoque** (inteiro) e **Valor Unitário** (monetário). Todos os três são obrigatórios pela stored procedure — mas a aplicação não valida campos vazios antes de chamar a SP.

---

### RN-PRD-03 — Atualização por linha selecionada na grade
A atualização de produto lê ID, Nome, Quantidade e Valor diretamente da linha selecionada em `dbProdutos`. Os campos de entrada (`edtNome`, `edtQtd`, `edtValor`) são limpos após a operação, mas **não são usados como fonte de dados para atualização**.

---

### RN-PRD-04 — Carregamento automático ao abrir a tela
A grade de produtos é carregada automaticamente no evento `FormShow`, garantindo que o operador sempre veja o estado atual do estoque ao abrir a tela.

---

### RN-PRD-05 — Recarregamento após escrita
A lista de produtos é recarregada após qualquer operação de escrita bem-sucedida.

---

## 3. Módulo Vendas

### RN-VND-01 — Código de venda sequencial
O código da venda em andamento é calculado como `MAX(ID_Cod_Venda) + 1` no momento em que a tela de vendas é aberta. O cálculo é local, sem revalidação contra o banco durante a sessão.

> *Risco:* Em ambiente multi-usuário ou após falha de venda, o código pode colidir ou saltar sequências.

---

### RN-VND-02 — Quantidade mínima de item
A quantidade informada para um item de venda deve ser **estritamente maior que zero**. Quantidade igual a zero bloqueia a inclusão e exibe aviso ao operador.

> *Implementado em:* `btnIncluiItemClick` — `Vendas.pas`

---

### RN-VND-03 — Cálculo de subtotal do item
O subtotal de cada item é calculado como:

```
subtotal_item = quantidade × valor_unitário
```

O cálculo ocorre no evento `OnExit` do campo `edtQtdProd` e o resultado é exibido em `edtTotalProduto`.

---

### RN-VND-04 — Cálculo do total geral
O total geral da venda é a soma dos valores da coluna "Total" (SubItems[2]) de todos os itens presentes no carrinho (`lstLista`). Recalculado a cada inclusão ou remoção de item.

---

### RN-VND-05 — Estrutura do carrinho
Cada item do carrinho armazena quatro valores na ListView:
- `Caption` → Nome do produto
- `SubItems[0]` → Valor unitário
- `SubItems[1]` → Quantidade
- `SubItems[2]` → Total do item

---

### RN-VND-06 — Persistência de itens via stored procedure
Ao finalizar a venda, o sistema itera sobre todos os itens do carrinho e chama `st_InsereItensVenda` para cada um, passando nome do produto, quantidade e código da venda.

---

### RN-VND-07 — Semântica do retorno da SP de itens

| Valor de `@return` | Significado                        | Ação do sistema                         |
|--------------------|------------------------------------|-----------------------------------------|
| `1`                | Sucesso — item inserido normalmente | Grava cabeçalho da venda               |
| `2`                | Falha — erro no item               | Exibe `@erMsg`; não grava cabeçalho    |
| `3`                | Sucesso com aviso (ex: estoque baixo) | Exibe `@erMsg` E grava cabeçalho    |

---

### RN-VND-08 — Persistência condicional do cabeçalho
O cabeçalho da venda (`st_InsereVenda`) é gravado **somente se** o último valor de `@return` for `1` ou `3`. A condição é avaliada após o loop de itens — usa o valor de `retorno` da última iteração.

> *Risco:* Se o carrinho estiver vazio, `retorno` é uma variável não inicializada. Seu valor indeterminado pode satisfazer acidentalmente a condição `(retorno = 1) or (retorno = 3)`.

---

### RN-VND-09 — Total enviado ao banco como string
O total da venda é enviado à stored procedure como o texto do label `lblTotalVenda.Caption` (ex: `"R$1500,50"`), não como valor numérico. A stored procedure recebe um parâmetro do tipo `ftCurrency` — a conversão pode falhar dependendo da configuração regional do servidor.

---

### RN-VND-10 — Filtro por correspondência parcial
Os filtros de cliente e produto na tela de vendas aplicam a expressão `LIKE %termo%` sobre os dados já carregados em memória pela query (filtro do FireDAC via `TFDQuery.Filter`), sem nova consulta ao banco.

---

### RN-VND-11 — Incremento local do código após venda
Após a gravação, o código exibido é incrementado localmente com `qryCodVendaUnnamed1.Value + 1` sem reabrir a query. Isso garupa apenas a exibição — o próximo código real depende do que o banco tiver registrado.

---

## 4. Interface e Navegação

### RN-NAV-01 — Abertura de telas como modal
Todas as telas são abertas via `ShowModal`, bloqueando a tela chamadora até o fechamento.

### RN-NAV-02 — Instâncias únicas de formulário
Todos os formulários são criados uma única vez na inicialização da aplicação (`Application.CreateForm`) e reutilizados em todas as aberturas. Não há criação/destruição dinâmica de formulários.

### RN-NAV-03 — Itens de menu não funcionais
Os itens `Cliente1` e `Produtos1` no menu principal têm seus handlers com código comentado. O clique não produz nenhum efeito e nenhuma mensagem é exibida ao usuário.

---

## 5. Acesso a Dados

### RN-DAD-01 — Todas as escritas via stored procedure
Nenhuma unit de formulário executa SQL inline. Toda operação de escrita (INSERT, UPDATE, DELETE) é delegada a uma stored procedure via `TFDStoredProc`.

### RN-DAD-02 — Padrão de chamada de stored procedure
```pascal
with dm.stNomeProcedure do
begin
  Close;
  paramByName('@param').Value := valor;
  ExecProc; // ou Open para queries
end;
```

### RN-DAD-03 — Recarregamento após escrita
Após qualquer `ExecProc`, a query de leitura correspondente é recarregada com `Close; Open` para refletir o estado atual do banco.

### RN-DAD-04 — Credenciais em texto plano
A string de conexão com usuário `sa` e senha `123456` está armazenada em texto plano no arquivo `dmDados.dfm`, sem criptografia ou leitura de variável de ambiente.

---

## 6. Tabela Consolidada

| ID          | Regra (resumo)                                             | Módulo    | Status atual        |
|-------------|------------------------------------------------------------|-----------|---------------------|
| RN-CLI-01   | Confirmação obrigatória antes de escrita de cliente        | Clientes  | ✅ Implementado     |
| RN-CLI-02   | Atualização usa dados da grade, não do campo de entrada    | Clientes  | ✅ Implementado (comportamento questionável) |
| RN-CLI-03   | Exclusão por ID da linha selecionada                       | Clientes  | ✅ Implementado     |
| RN-CLI-04   | Limpa edtNome após inserção                                | Clientes  | ✅ Implementado     |
| RN-CLI-05   | Recarrega grade após escrita                               | Clientes  | ✅ Implementado     |
| RN-PRD-01   | Confirmação obrigatória antes de escrita de produto        | Produtos  | ✅ Implementado     |
| RN-PRD-02   | Produto com 3 atributos: nome, qtd, valor                  | Produtos  | ✅ Implementado     |
| RN-PRD-03   | Atualização usa dados da grade                             | Produtos  | ✅ Implementado     |
| RN-PRD-04   | Carrega grade no FormShow                                  | Produtos  | ✅ Implementado     |
| RN-PRD-05   | Recarrega grade após escrita                               | Produtos  | ✅ Implementado     |
| RN-VND-01   | Código de venda = MAX + 1 ao abrir a tela                  | Vendas    | ✅ Implementado (risco de colisão) |
| RN-VND-02   | Quantidade mínima do item > 0                              | Vendas    | ✅ Implementado     |
| RN-VND-03   | Subtotal = qtd × valor                                     | Vendas    | ✅ Implementado     |
| RN-VND-04   | Total geral = soma dos subtotais do carrinho               | Vendas    | ⚠️ Bug off-by-one  |
| RN-VND-05   | Carrinho armazena 4 colunas por item                       | Vendas    | ✅ Implementado     |
| RN-VND-06   | Persistência de itens via SP em loop                       | Vendas    | ✅ Implementado     |
| RN-VND-07   | Semântica de retorno da SP de itens (1/2/3)                | Vendas    | ✅ Implementado     |
| RN-VND-08   | Cabeçalho gravado condicionalmente por @return             | Vendas    | ⚠️ retorno não inicializado |
| RN-VND-09   | Total enviado como string "R$X,XX"                         | Vendas    | 🔴 Bug — tipo errado |
| RN-VND-10   | Filtro em memória com LIKE                                 | Vendas    | ✅ Implementado     |
| RN-VND-11   | Incremento local do código após venda                      | Vendas    | ⚠️ Sem revalidação  |
| RN-NAV-01   | Telas abertas como modal                                   | Navegação | ✅ Implementado     |
| RN-NAV-02   | Instâncias únicas de formulário                            | Navegação | ✅ Implementado     |
| RN-NAV-03   | Menu itens não funcionais (código comentado)               | Navegação | 🔴 Bug — sem feedback |
| RN-DAD-01   | Toda escrita via stored procedure                          | Dados     | ✅ Implementado     |
| RN-DAD-02   | Padrão Close/Params/ExecProc                               | Dados     | ✅ Implementado     |
| RN-DAD-03   | Recarrega query após escrita                               | Dados     | ✅ Implementado     |
| RN-DAD-04   | Credenciais em texto plano no DFM                          | Dados     | 🔴 Risco de segurança |

**Legenda:** ✅ OK | ⚠️ Risco/comportamento questionável | 🔴 Bug ou vulnerabilidade

---

*Documento gerado com base na análise estática do código-fonte — VendaProduto, Junho/2026.*
