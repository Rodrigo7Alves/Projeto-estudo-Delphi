# Cenários de Regressão — Sistema VendaProduto

> **Projeto:** VendaProduto
> **Propósito:** Garantir que correções de bugs não quebrem funcionalidades existentes
> **Data:** Junho/2026

---

## Sobre Este Documento

Os cenários de regressão são organizados por **área de impacto de cada correção**. Para cada bug identificado, listamos os testes que devem ser re-executados após a correção para garantir que nenhuma funcionalidade adjacente foi quebrada.

---

## CR-001 — Correção do Off-by-One nos loops da ListView

**Bug corrigido:** Loops `for I := 0 to lstLista.Items.Count do` alterados para `Count - 1`
**Arquivo:** `Vendas.pas` — `btnIncluiItemClick`, `btnExcluiVendaClick`

### Cenários que devem passar após a correção:

| ID       | Cenário                                             | Verificação                                    |
|----------|-----------------------------------------------------|------------------------------------------------|
| CR001-01 | Incluir 1 item no carrinho                          | Item aparece na lista; total = subtotal do item |
| CR001-02 | Incluir 2 itens distintos                           | Ambos aparecem; total = soma dos dois subtotais |
| CR001-03 | Incluir 5 itens (limite prático)                    | Todos listados; total correto                  |
| CR001-04 | Remover o único item do carrinho                    | Lista fica vazia; total = R$0,00               |
| CR001-05 | Remover item do meio da lista (3 itens, remove o 2º)| Itens restantes corretos; total recalculado    |
| CR001-06 | Remover o último item de uma lista com 2 itens      | 1 item restante; total = subtotal do item restante |
| CR001-07 | Total recalculado é sempre = soma real dos itens    | Propriedade: `Σ SubItems[2]` = `lblTotalVenda` |
| CR001-08 | Finalizar venda após incluir e remover itens        | Apenas os itens finais são gravados no banco   |

### Cenários de não-regressão (não devem ser afetados):

| ID       | Cenário                                             | Verificação                                    |
|----------|-----------------------------------------------------|------------------------------------------------|
| CR001-09 | Seleção de cliente ainda preenche edtNomeClie       | Sem alteração no comportamento                 |
| CR001-10 | Filtro de clientes ainda funciona                   | Filtro por nome parcial opera normalmente      |
| CR001-11 | Seleção de produto ainda preenche campos            | `edtProd` e `edtValorProduto` preenchidos      |
| CR001-12 | Código de venda ainda é carregado ao abrir a tela   | `lblCodVenda` com valor correto                |

---

## CR-002 — Correção da variável `retorno` não inicializada

**Bug corrigido:** `retorno` inicializado com valor padrão 0 antes do loop
**Arquivo:** `Vendas.pas` — `btnRealizaVendaClick`

### Cenários que devem passar após a correção:

| ID       | Cenário                                             | Verificação                                    |
|----------|-----------------------------------------------------|------------------------------------------------|
| CR002-01 | Clicar "Realizar Venda" com carrinho vazio          | Nenhuma gravação no banco; mensagem ao usuário |
| CR002-02 | Venda com 1 item — SP retorna @return = 1           | Cabeçalho gravado; código incrementado         |
| CR002-03 | Venda com múltiplos itens — todos retornam 1        | Todos os itens e cabeçalho gravados            |
| CR002-04 | Venda onde SP retorna @return = 2 no último item    | Cabeçalho NÃO gravado; mensagem de erro exibida |
| CR002-05 | Venda onde SP retorna @return = 3                   | Mensagem exibida E cabeçalho gravado            |
| CR002-06 | Dois cliques consecutivos em "Realizar Venda"       | Segunda gravação não duplica dados (código já foi incrementado) |

### Cenários de não-regressão:

| ID       | Cenário                                             | Verificação                                    |
|----------|-----------------------------------------------------|------------------------------------------------|
| CR002-07 | Loop de itens ainda itera de 0 a Count-1            | Nenhum item perdido ou duplicado               |
| CR002-08 | `@erMsg` ainda é exibida quando @return = 2 ou 3    | Mensagem de SP ainda aparece ao operador       |
| CR002-09 | Incremento de código ainda ocorre após venda        | `lblCodVenda` atualizado após gravação         |

---

## CR-003 — Correção das conversões numéricas sem tratamento de exceção

**Bug corrigido:** `StrToInt` e `StrToFloat` substituídos por versões seguras (`TryStrToInt`, `TryStrToFloat`) ou encapsulados em `try/except`
**Arquivo:** `Vendas.pas` — `edtQtdProdExit`, `btnIncluiItemClick`, `btnExcluiVendaClick`

### Cenários que devem passar após a correção:

| ID       | Cenário                                             | Verificação                                    |
|----------|-----------------------------------------------------|------------------------------------------------|
| CR003-01 | Campo de quantidade vazio ao sair do campo          | Sem crash; subtotal fica 0 ou mensagem         |
| CR003-02 | Campo de valor com texto ("abc") ao calcular subtotal | Sem crash; mensagem orientando o usuário      |
| CR003-03 | Campo de valor vazio ao calcular subtotal            | Sem crash; valor tratado como 0 ou mensagem   |
| CR003-04 | Quantidade negativa digitada manualmente no SpinEdit | Tratada como inválida ou valor 0              |
| CR003-05 | Valor com vírgula ("10,50") — separador regional    | Conversão correta dependendo do `DecimalSeparator` do sistema |
| CR003-06 | Valor com ponto ("10.50") em sistema com vírgula     | Tratamento correto sem crash                  |
| CR003-07 | Recálculo de total com item cujo SubItems[2] é não numérico | Sem crash no loop de recálculo          |

### Cenários de não-regressão:

| ID       | Cenário                                             | Verificação                                    |
|----------|-----------------------------------------------------|------------------------------------------------|
| CR003-08 | Entrada numérica válida ainda calcula corretamente   | `qtd=3, valor=10,00` → subtotal = 30,00       |
| CR003-09 | SpinEdit ainda impede entrada negativa por padrão    | Comportamento nativo do SpinEdit mantido       |
| CR003-10 | Loop de inclusão de item ainda funciona normalmente  | Item adicionado corretamente                   |

---

## CR-004 — Correção do total enviado como string ao banco

**Bug corrigido:** `paramByName('@total').Value` recebe valor numérico (`StrToFloat` do caption sem "R$") em vez de string formatada
**Arquivo:** `Vendas.pas` — `btnRealizaVendaClick`

### Cenários que devem passar após a correção:

| ID       | Cenário                                             | Verificação                                    |
|----------|-----------------------------------------------------|------------------------------------------------|
| CR004-01 | Venda finalizada; total gravado como número no banco | Consulta SQL confirma tipo numérico em `TOTAL` |
| CR004-02 | Total com centavos (R$1.234,50)                     | Gravado corretamente; sem arredondamento       |
| CR004-03 | Total = R$0,00 (venda sem itens — caso limite)      | Não deve chegar neste ponto após CR-002        |
| CR004-04 | Total alto (R$99.999,99)                            | Sem overflow ou truncamento                    |

### Cenários de não-regressão:

| ID       | Cenário                                             | Verificação                                    |
|----------|-----------------------------------------------------|------------------------------------------------|
| CR004-05 | `lblTotalVenda` ainda exibe o prefixo "R$" para o usuário | Visual não alterado                      |
| CR004-06 | Recálculo do total na tela ainda funciona            | Soma dos itens exibida corretamente ao usuário |

---

## CR-005 — Correção dos itens de menu não funcionais

**Bug corrigido:** Código comentado em `Cliente1Click` e `Produtos1Click` descomentado
**Arquivo:** `Main.pas`

### Cenários que devem passar após a correção:

| ID       | Cenário                                             | Verificação                                    |
|----------|-----------------------------------------------------|------------------------------------------------|
| CR005-01 | Clicar em `Cadastro > Clientes` no menu             | Abre `frmCliente` como modal                   |
| CR005-02 | Clicar em `Cadastro > Produtos` no menu             | Abre `frmProdutos` como modal                  |
| CR005-03 | Fechar formulário aberto pelo menu e reabrir        | Reabre normalmente (instância única reutilizada)|

### Cenários de não-regressão:

| ID       | Cenário                                             | Verificação                                    |
|----------|-----------------------------------------------------|------------------------------------------------|
| CR005-04 | Atalhos visuais (imagens) ainda funcionam           | `Image1Click`, `imgProdutosClick` abrem os formulários |
| CR005-05 | Item `Venda` no menu ainda funciona                 | `Venda1Click` abre `frmVendas`                 |
| CR005-06 | `Cadastro > Clientes` (item duplicado) abre correto | Ambos `Cliente1Click` e `Cadastro1Click` funcionam |

---

## CR-006 — Suíte de Regressão Geral (pós qualquer correção)

Execute estes cenários após **qualquer** alteração no código:

| ID       | Cenário                                             | Módulo    | Criticidade |
|----------|-----------------------------------------------------|-----------|-------------|
| CR006-01 | Aplicação inicia sem erros com banco disponível     | Global    | 🔴 Alta     |
| CR006-02 | Tela principal exibe data e hora corretas           | Main      | 🟢 Baixa    |
| CR006-03 | CRUD completo de clientes (inserir, atualizar, excluir) | Clientes | 🔴 Alta  |
| CR006-04 | CRUD completo de produtos (inserir, atualizar, excluir) | Produtos | 🔴 Alta  |
| CR006-05 | Fluxo completo de venda: selecionar cliente → produto → incluir item → finalizar | Vendas | 🔴 Alta |
| CR006-06 | Filtro de clientes funciona durante venda           | Vendas    | 🟡 Média    |
| CR006-07 | Filtro de produtos funciona durante venda           | Vendas    | 🟡 Média    |
| CR006-08 | Abrir e fechar cada tela múltiplas vezes sem vazamento | Global  | 🟡 Média    |
| CR006-09 | Tela de vendas recarrega código correto ao reabrir  | Vendas    | 🟡 Média    |
| CR006-10 | Todas as confirmações Sim/Não ainda aparecem        | Global    | 🔴 Alta     |
| CR006-11 | Grade de clientes sincroniza após inserção          | Clientes  | 🔴 Alta     |
| CR006-12 | Grade de produtos sincroniza após inserção          | Produtos  | 🔴 Alta     |
| CR006-13 | Grade de produtos abre automaticamente no FormShow  | Produtos  | 🟡 Média    |

---

## Ordem de Execução Recomendada

Para garantir cobertura incremental, execute na seguinte ordem:

```
1. CR006 (linha de base — smoke test)
2. CR001 (off-by-one — mais crítico para Vendas)
3. CR002 (retorno não inicializado)
4. CR003 (conversões sem try/except)
5. CR004 (tipo do total)
6. CR005 (menus comentados)
7. CR006 novamente (suíte de regressão completa)
```

---

*Documento gerado com base na análise estática do código-fonte — VendaProduto, Junho/2026.*
*Total: 60 cenários de regressão documentados.*
