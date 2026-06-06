# Requisitos Funcionais — Sistema VendaProduto

> **Projeto:** VendaProduto
> **Base:** Análise estática do código-fonte (Delphi/FireDAC)
> **Data:** Junho/2026

---

## Módulo: Clientes

**RF001**
O sistema deve permitir o cadastro de um novo cliente informando apenas o nome.

**RF002**
O sistema deve exibir a lista de todos os clientes cadastrados em uma grade com as colunas ID e Nome, carregada a partir da tabela `TBCLIENTES`.

**RF003**
O sistema deve permitir atualizar os dados de um cliente selecionado na grade, usando o ID e o Nome da própria linha selecionada.

**RF004**
O sistema deve permitir excluir um cliente selecionado na grade, passando seu ID para a stored procedure de exclusão.

**RF005**
O sistema deve solicitar confirmação do usuário (diálogo Sim/Não) antes de executar qualquer operação de inserção, atualização ou exclusão de cliente.

**RF006**
O sistema deve exibir a mensagem "Ação Cancelada" quando o usuário recusar a confirmação de qualquer operação sobre clientes.

**RF007**
O sistema deve limpar o campo de nome após a inserção bem-sucedida de um cliente.

**RF008**
O sistema deve recarregar a grade de clientes após cada operação de inserção, atualização ou exclusão.

---

## Módulo: Produtos

**RF009**
O sistema deve permitir o cadastro de um novo produto informando nome, quantidade em estoque e valor unitário.

**RF010**
O sistema deve exibir a lista de todos os produtos cadastrados em uma grade com as colunas ID, Nome, Quantidade e Valor.

**RF011**
O sistema deve recarregar automaticamente a lista de produtos ao abrir a tela de produtos (`FormShow`).

**RF012**
O sistema deve permitir atualizar nome, quantidade e valor de um produto selecionado na grade.

**RF013**
O sistema deve permitir excluir um produto selecionado na grade passando seu ID para a stored procedure de exclusão.

**RF014**
O sistema deve solicitar confirmação do usuário (diálogo Sim/Não) antes de executar qualquer operação de inserção, atualização ou exclusão de produto.

**RF015**
O sistema deve exibir a mensagem "Ação Cancelada" quando o usuário recusar a confirmação de qualquer operação sobre produtos.

**RF016**
O sistema deve limpar os campos de nome, quantidade e valor após a inserção ou atualização bem-sucedida de um produto.

**RF017**
O sistema deve recarregar a grade de produtos após cada operação de inserção, atualização ou exclusão.

---

## Módulo: Vendas

**RF018**
O sistema deve exibir na tela de vendas a lista completa de clientes cadastrados para seleção.

**RF019**
O sistema deve exibir na tela de vendas a lista completa de produtos cadastrados para seleção.

**RF020**
O sistema deve gerar automaticamente o código da venda em andamento ao abrir a tela de vendas, calculado como `MAX(ID_Cod_Venda) + 1`.

**RF021**
O sistema deve exibir o código da venda atual no componente `lblCodVenda`.

**RF022**
O sistema deve permitir filtrar a lista de clientes pelo nome em tempo real, usando correspondência parcial (`NOME_CLI LIKE %termo%`).

**RF023**
O sistema deve permitir filtrar a lista de produtos pelo nome em tempo real, usando correspondência parcial (`NOME_PROD LIKE %termo%`).

**RF024**
O sistema deve preencher automaticamente o campo `edtNomeClie` com o nome do cliente ao clicar em uma linha da grade de clientes.

**RF025**
O sistema deve preencher automaticamente os campos `edtProd` e `edtValorProduto` com o nome e o valor unitário do produto ao clicar em uma linha da grade de produtos.

**RF026**
O sistema deve calcular e exibir automaticamente o subtotal do item (`quantidade × valor unitário`) no campo `edtTotalProduto` quando o foco sair do campo de quantidade (`edtQtdProd`).

**RF027**
O sistema deve validar que a quantidade informada é maior que zero antes de adicionar o item ao carrinho.

**RF028**
O sistema deve exibir a mensagem "Por Favor insira uma quantidade" e manter o foco no campo de quantidade quando a quantidade for zero.

**RF029**
O sistema deve adicionar o produto selecionado ao carrinho (`lstLista`) com as colunas: Produto, Valor Unitário, Quantidade e Total do Item.

**RF030**
O sistema deve calcular e exibir o total geral da venda como a soma dos subtotais de todos os itens do carrinho, atualizado após cada inclusão de item.

**RF031**
O sistema deve permitir remover um item selecionado do carrinho antes de finalizar a venda.

**RF032**
O sistema deve recalcular e atualizar o total geral da venda após a remoção de um item do carrinho.

**RF033**
O sistema deve persistir cada item do carrinho no banco de dados ao finalizar a venda, chamando `st_InsereItensVenda` com nome do produto, quantidade e código da venda.

**RF034**
O sistema deve tratar o retorno da stored procedure de itens:
- Se `@return = 2` ou `@return = 3`: exibir `@erMsg` ao operador.
- Se `@return = 1` ou `@return = 3`: prosseguir com a gravação do cabeçalho.

**RF035**
O sistema deve persistir o cabeçalho da venda no banco de dados chamando `st_InsereVenda` com ID do cliente, total e código da venda, somente quando `@return = 1` ou `@return = 3`.

**RF036**
O sistema deve incrementar o código de venda exibido na tela após a finalização, preparando-o para a próxima operação.

---

## Módulo: Navegação e Interface

**RF037**
O sistema deve disponibilizar atalhos visuais (imagens clicáveis) na tela principal para acesso aos módulos de Clientes, Produtos e Vendas.

**RF038**
O sistema deve disponibilizar menu superior com acesso a `Cadastro > Clientes`, `Cadastro > Produtos` e `Venda`.

**RF039**
O sistema deve exibir a data atual na barra de status da tela principal ao abri-la.

**RF040**
O sistema deve exibir a hora atual na barra de status da tela principal ao abri-la.

---

## Requisitos Não Implementados / Divergências Identificadas

Os itens abaixo são requisitos esperados pelo comportamento documentado que **não estão implementados** no código atual:

| ID    | Requisito ausente                                                              | Impacto    |
|-------|--------------------------------------------------------------------------------|------------|
| RNI01 | Validação de campos obrigatórios antes de salvar (nome vazio em Cliente/Produto) | Alto      |
| RNI02 | Validação de seleção de cliente antes de finalizar venda                       | Alto       |
| RNI03 | Validação de carrinho não vazio antes de finalizar venda                       | Alto       |
| RNI04 | Tratamento de exceção em conversões numéricas (`StrToInt`, `StrToFloat`)        | Alto       |
| RNI05 | Mensagem de sucesso após inserção/atualização/exclusão                         | Médio      |
| RNI06 | Itens de menu `Cliente1` e `Produtos1` funcionais (código comentado)           | Médio      |
| RNI07 | Atualização de hora em tempo real na barra de status                           | Baixo      |
| RNI08 | Envio do total da venda como valor numérico (enviado como string "R$X,XX")     | Alto       |

---

*Requisitos levantados com base na análise estática do código-fonte do projeto VendaProduto.*
*Total: 40 requisitos funcionais identificados, 8 divergências mapeadas.*
