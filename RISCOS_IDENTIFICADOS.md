# Riscos Identificados — Sistema VendaProduto

> **Projeto:** VendaProduto
> **Base:** Análise estática do código-fonte (Delphi/FireDAC)
> **Data:** Junho/2026

---

## Classificação de Risco

| Criticidade | Descrição                                                        |
|-------------|------------------------------------------------------------------|
| 🔴 Crítico  | Causa crash, corrupção de dados ou falha silenciosa de negócio   |
| 🟠 Alto     | Comportamento incorreto com impacto direto na operação           |
| 🟡 Médio    | Funcionalidade incompleta ou experiência degradada               |
| 🟢 Baixo    | Cosmético, usabilidade ou manutenibilidade                       |

---

## Categoria 1 — Bugs que Causam Crash (Access Violation)

### RISCO-001 — Off-by-one na iteração da ListView
- **Criticidade:** 🔴 Crítico
- **Arquivo:** `Vendas.pas` — `btnIncluiItemClick`, `btnExcluiVendaClick`
- **Descrição:** O loop `for I := 0 to lstLista.Items.Count do` acessa o índice `Count`, que está além do último item válido (índice `Count - 1`). Isso causa `Access Violation` em toda operação de inclusão ou remoção de item quando há ao menos 1 item na lista.
- **Impacto:** Crash imediato. O módulo de vendas fica **completamente inoperante** para o fluxo principal.
- **Probabilidade de ocorrência:** Certa — acontece na primeira inclusão de item.
- **Correção:** Substituir `Count` por `Count - 1` nos dois loops.

```pascal
// Errado
for I := 0 to lstLista.Items.Count do

// Correto
for I := 0 to lstLista.Items.Count - 1 do
```

---

### RISCO-002 — Conversões numéricas sem tratamento de exceção
- **Criticidade:** 🔴 Crítico
- **Arquivo:** `Vendas.pas` — `edtQtdProdExit`, `btnIncluiItemClick`, `btnExcluiVendaClick`
- **Descrição:** As funções `StrToInt` e `StrToFloat` são chamadas diretamente sobre campos de texto sem `try/except`. Se o campo estiver vazio ou contiver texto não numérico, a exceção `EConvertError` não é capturada e a aplicação trava.
- **Impacto:** Crash com campos vazios ou entradas inválidas — cenários comuns de operação.
- **Probabilidade de ocorrência:** Alta — qualquer usuário pode deixar o campo vazio.
- **Correção:** Usar `TryStrToInt`/`TryStrToFloat` ou envolver em `try/except`.

---

## Categoria 2 — Bugs de Corrupção de Dados ou Falha Silenciosa

### RISCO-003 — Variável `retorno` não inicializada
- **Criticidade:** 🔴 Crítico
- **Arquivo:** `Vendas.pas` — `btnRealizaVendaClick`
- **Descrição:** A variável `retorno` é declarada sem valor inicial. Se o carrinho estiver vazio (loop não executa nenhuma iteração), `retorno` retém um valor de lixo de memória. Se esse valor acidentalmente for `1` ou `3`, o cabeçalho de venda é gravado sem nenhum item associado, gerando **registro fantasma no banco**.
- **Impacto:** Corrupção de dados — vendas sem itens gravadas no banco.
- **Probabilidade de ocorrência:** Indeterminada (depende do conteúdo da memória), mas risco real em produção.
- **Correção:** Inicializar `retorno := 0` na declaração da variável.

---

### RISCO-004 — Total da venda enviado como string formatada
- **Criticidade:** 🟠 Alto
- **Arquivo:** `Vendas.pas` — `btnRealizaVendaClick`
- **Descrição:** O parâmetro `@total` da SP `st_InsereVenda` recebe `lblTotalVenda.Caption`, que contém a string `"R$1500,50"`. O parâmetro no data module está tipado como `ftCurrency`. O FireDAC tentará converter a string para número, o que pode:
  - Falhar silenciosamente (gravar 0 no banco)
  - Lançar exceção dependendo da configuração regional
  - Ter comportamento diferente em servidor SQL com locale diferente do cliente
- **Impacto:** Total incorreto ou nulo gravado no banco para todas as vendas.
- **Probabilidade de ocorrência:** Alta — ocorre em toda venda finalizada.
- **Correção:** Converter `lblTotalVenda.Caption` para `Double` após remover o prefixo "R$" antes de passar ao parâmetro.

---

### RISCO-005 — Código de venda calculado sem revalidação
- **Criticidade:** 🟠 Alto
- **Arquivo:** `Vendas.pas` — `FormShow`, `btnRealizaVendaClick`
- **Descrição:** O código da venda é calculado como `MAX(ID_Cod_Venda) + 1` somente uma vez, ao abrir a tela. Se dois operadores abrirem a tela simultaneamente (ou em rápida sucessão), ambos calcularão o mesmo `MAX + 1`, gerando **código de venda duplicado** no banco.
- **Impacto:** Violação de integridade referencial ou dados duplicados (se o banco não tiver constraint UNIQUE em `COD_VENDA`).
- **Probabilidade de ocorrência:** Baixa em instalação monousuário; alta em multi-usuário.
- **Correção:** Reabrir `qryCodVenda` imediatamente antes de chamar `stInsereVenda`, ou usar IDENTITY/SEQUENCE no banco.

---

## Categoria 3 — Falhas de Validação de Negócio

### RISCO-006 — Nenhuma validação de campos obrigatórios
- **Criticidade:** 🟡 Médio
- **Arquivos:** `Cliente.pas` — `btnSalvarClick`; `Produtos.pas` — `btnSalvarClick`
- **Descrição:** O sistema não valida se os campos de entrada estão preenchidos antes de chamar as stored procedures. Campos vazios são passados como parâmetros, cujo comportamento depende da implementação de cada SP.
- **Impacto:** Inserção de registros inválidos no banco (cliente sem nome, produto sem preço).
- **Correção:** Validar campos obrigatórios antes do diálogo de confirmação.

---

### RISCO-007 — Venda sem cliente selecionado pode ser gravada
- **Criticidade:** 🟠 Alto
- **Arquivo:** `Vendas.pas` — `btnRealizaVendaClick`
- **Descrição:** O sistema não verifica se um cliente foi selecionado antes de finalizar a venda. Se `dbCliente.Fields[0].Value` for nulo (nenhum clique na grade), `@idCli` receberá null/0, podendo violar FK no banco ou gravar venda com cliente inválido.
- **Impacto:** Venda sem cliente associado ou erro de FK sem mensagem amigável.
- **Correção:** Validar que `edtNomeClie` não está vazio antes de finalizar.

---

### RISCO-008 — Atualização de cliente não usa o campo de entrada
- **Criticidade:** 🟡 Médio
- **Arquivo:** `Cliente.pas` — `btnAtualizarClick`
- **Descrição:** O botão "Atualizar" lê o nome da **grade** (`dbCliente.Fields[1].Value`), não do campo `edtNome`. O operador não tem como alterar o nome de um cliente pela UI — o botão apenas re-envia o valor já armazenado.
- **Impacto:** Funcionalidade de atualização de nome é inacessível pelo formulário.
- **Correção:** Usar `edtNome.Text` como fonte do parâmetro `@nome` na atualização.

---

## Categoria 4 — Segurança e Configuração

### RISCO-009 — Credenciais em texto plano no arquivo DFM
- **Criticidade:** 🟠 Alto
- **Arquivo:** `dmDados.dfm`
- **Descrição:** A string de conexão com SQL Server contém usuário (`sa`) e senha (`123456`) em texto plano no arquivo de formulário, que é um arquivo de texto incluído no repositório de código.
- **Impacto:** Exposição de credenciais a qualquer pessoa com acesso ao código-fonte ou ao executável (que inclui o DFM compilado como recurso).
- **Agravante:** Uso da conta `sa` (System Administrator do SQL Server) — privilégios máximos.
- **Correção:** Ler credenciais de variável de ambiente, arquivo de configuração externo criptografado, ou usar Windows Integrated Authentication.

---

### RISCO-010 — Senha padrão fraca na conta sa
- **Criticidade:** 🟠 Alto
- **Arquivo:** `dmDados.dfm`
- **Descrição:** A senha `123456` para a conta `sa` do SQL Server é trivialmente adivinhável. Combinada com o risco anterior (exposição em texto plano), representa um vetor crítico de acesso não autorizado ao banco.
- **Impacto:** Acesso total ao SQL Server por qualquer pessoa na rede.
- **Correção:** Trocar senha, usar conta com privilégios mínimos, desabilitar login com `sa`.

---

## Categoria 5 — Usabilidade e Manutenção

### RISCO-011 — Itens de menu sem feedback ao usuário
- **Criticidade:** 🟡 Médio
- **Arquivo:** `Main.pas` — `Cliente1Click`, `Produtos1Click`
- **Descrição:** Os itens de menu `Cliente > Clientes` e `Produtos > Produtos` têm código comentado. O clique não produz nenhum efeito e nenhuma mensagem é exibida. O usuário não tem feedback de por que nada aconteceu.
- **Impacto:** Confusão para o operador; comportamento inconsistente com os atalhos visuais que funcionam.
- **Correção:** Descomentar o código ou adicionar mensagem temporária.

---

### RISCO-012 — Sem mensagem de sucesso após operações de escrita
- **Criticidade:** 🟢 Baixo
- **Arquivos:** `Cliente.pas`, `Produtos.pas`
- **Descrição:** Após inserir, atualizar ou excluir com sucesso, a única indicação é o recarregamento silencioso da grade. Não há mensagem de confirmação de sucesso.
- **Impacto:** Experiência degradada; operador pode não perceber se a operação funcionou.

---

### RISCO-013 — Barra de status com hora estática
- **Criticidade:** 🟢 Baixo
- **Arquivo:** `Main.pas` — `FormShow`
- **Descrição:** Data e hora são capturadas apenas no `FormShow`. O relógio não avança enquanto a aplicação está aberta.
- **Impacto:** Informação de hora incorreta após longa sessão.
- **Correção:** Usar `TTimer` com intervalo de 1 segundo para atualizar continuamente.

---

### RISCO-014 — Typo no nome da query `qryClienets`
- **Criticidade:** 🟢 Baixo
- **Arquivo:** `dmDados.pas`
- **Descrição:** O componente de query de clientes está nomeado `qryClienets` (inversão de "nts") em vez de `qryClientes`. Não causa bug funcional, mas prejudica legibilidade e viola a convenção de nomenclatura do projeto.
- **Impacto:** Manutenção dificultada.

---

### RISCO-015 — Typo `with dm,stAtualizaProduto` (vírgula em vez de ponto)
- **Criticidade:** 🟠 Alto
- **Arquivo:** `Produtos.pas` — `btnAtualizarClick`, `btnSalvarClick`, `btnExcluirClick`
- **Descrição:** O código usa `with dm,stAtualizaProduto` (vírgula) em vez de `with dm.stAtualizaProduto` (ponto). Em Delphi, `with A, B` é sintaxe válida que aplica `with` sobre `dm` e `stAtualizaProduto` sequencialmente. O comportamento pode ser diferente do esperado — `stAtualizaProduto` seria resolvido no escopo de `dm`, o que por acaso funciona, mas a sintaxe é enganosa e não intencional.
- **Impacto:** Pode causar ambiguidade de escopo em refatorações futuras.
- **Correção:** Substituir por `with dm.stAtualizaProduto`.

---

## Resumo por Categoria e Criticidade

| Criticidade | Qtd | Riscos                                    |
|-------------|-----|-------------------------------------------|
| 🔴 Crítico  |  2  | RISCO-001, RISCO-002                      |
| 🟠 Alto     |  6  | RISCO-003, RISCO-004, RISCO-005, RISCO-007, RISCO-009, RISCO-010, RISCO-015 |
| 🟡 Médio    |  3  | RISCO-006, RISCO-008, RISCO-011           |
| 🟢 Baixo    |  3  | RISCO-012, RISCO-013, RISCO-014           |

---

## Backlog Priorizado de Correções

| Prioridade | Risco        | Ação                                                         | Esforço |
|------------|--------------|--------------------------------------------------------------|---------|
| 1          | RISCO-001    | Corrigir `Count` para `Count - 1` nos loops                  | Muito baixo |
| 2          | RISCO-002    | Adicionar `try/except` ou usar `TryStrToXxx`                 | Baixo   |
| 3          | RISCO-003    | Inicializar `retorno := 0`                                   | Muito baixo |
| 4          | RISCO-004    | Converter total para numérico antes de passar à SP           | Baixo   |
| 5          | RISCO-007    | Validar seleção de cliente antes de finalizar venda          | Baixo   |
| 6          | RISCO-009/10 | Mover credenciais para configuração externa                  | Médio   |
| 7          | RISCO-006    | Validar campos obrigatórios nos CRUDs                        | Baixo   |
| 8          | RISCO-008    | Usar `edtNome.Text` na atualização de cliente                | Muito baixo |
| 9          | RISCO-011    | Descomentar handlers dos itens de menu                       | Muito baixo |
| 10         | RISCO-015    | Corrigir sintaxe `with dm,` para `with dm.`                  | Muito baixo |
| 11         | RISCO-005    | Reabrir query de código antes de gravar ou usar SEQUENCE     | Médio   |
| 12         | RISCO-012    | Adicionar mensagem de sucesso após operações                 | Baixo   |
| 13         | RISCO-013    | Adicionar TTimer para atualizar relógio                      | Baixo   |
| 14         | RISCO-014    | Renomear `qryClienets` para `qryClientes`                    | Médio (impacto em todo o código) |

---

*Documento gerado com base na análise estática do código-fonte — VendaProduto, Junho/2026.*
*Total: 15 riscos identificados.*
