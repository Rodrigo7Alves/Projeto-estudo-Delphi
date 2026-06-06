# QA-001 — Documentação de Testes: Cadastro de Clientes

---

## Cabeçalho

| Campo | Informação |
|---|---|
| **Identificador** | QA-001 |
| **Tipo de Teste** | Funcional · Limite · Validação · Regressão · Exploratório · Integridade de Dados · Concorrência · Usabilidade |
| **Objetivo do Teste** | Garantir que o módulo de Cadastro de Clientes funcione corretamente em todos os cenários — positivos, negativos, limites, regressão, usabilidade, integridade dos dados e concorrência — assegurando a consistência entre os dados exibidos na grid e os armazenados na base. |
| **Requisitos Motivadores** | REQ-1 (Inserção), REQ-2 (Atualização), REQ-3 (Exclusão), REQ-4 (Sincronização da Grid), REQ-5 (Tratamento de Erros), REQ-6 (Validação de Entrada), REQ-7 (Usabilidade), REQ-8 (Integridade dos Dados) |
| **Módulos Impactados** | `TfrmCliente` (Cliente.pas / Cliente.dfm), `Tdm` (dmDados.pas), Tabela `TBCLIENTES`, Stored Procedures `st_InsereCli`, `st_AlteraCli`, `ST_APAGACLI`, `qryClienets` / `dsClientes` |
| **Versão** | 1.0 |
| **Data** | Junho/2026 |
| **Responsável** | QA |

---

## Dados Básicos para Simulação

### Pré-condições

- Aplicação VendaProduto compilada e iniciada (`VendaProduto.exe`)
- Banco de dados `ProjetoVenda` no SQL Server acessível e responsivo
- As stored procedures `st_InsereCli`, `st_AlteraCli` e `ST_APAGACLI` existem no banco
- A tabela `TBCLIENTES` existe e possui as colunas `ID_CLI` (INT IDENTITY) e `NOME_CLI` (VARCHAR 50)
- O formulário `frmCliente` está acessível via atalho visual na tela principal ou menu de navegação
- O operador tem permissões de leitura e escrita no banco

### Massa de Dados Necessária

| Dado | Descrição | Uso |
|---|---|---|
| **Cliente A** | Nome: "João Silva" | Inserção (fluxo feliz) |
| **Cliente B** | Nome: "Maria Santos" | Inserção e posterior atualização |
| **Cliente C** | Nome: "Pedro Almeida" | Inserção e posterior exclusão |
| **Cliente vinculado a venda** | Cliente com ao menos 1 venda gravada em `TBVENDAS` | Teste de integridade referencial na exclusão |
| **Nome com 50 chars** | "AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJKKKKLLLLLM" (exato) | Teste de valor limite superior |
| **Nome com 51 chars** | 51 caracteres quaisquer | Teste de bloqueio de MaxLength |
| **Nome só espaços** | "     " (5 ou mais espaços) | Teste de validação whitespace |
| **Nome vazio** | "" (string vazia) | Teste de campo obrigatório |
| **Nome com caracteres especiais** | "José D'Ávila & Cia" | Teste exploratório |
| **Nome com caracteres Unicode** | "Müller Ações" | Teste exploratório |

### Cadastros Necessários

- Ao menos 3 clientes previamente cadastrados no banco para os testes de seleção, atualização e exclusão
- Ao menos 1 cliente vinculado a uma venda para o teste de integridade referencial (CT-CLI-I-06)

### Configurações Necessárias

- SQL Server deve estar em execução com a instância configurada em `conProjetoVenda`
- String de conexão em `dmDados.dfm` aponta para `localhost\SQLSERVER2022`, banco `ProjetoVenda`
- Para testes de banco indisponível: parar o serviço do SQL Server ou alterar a string de conexão

---

## Passo a Passo para Simulação Básica da Rotina

1. Iniciar a aplicação `VendaProduto.exe`
2. Na tela principal, clicar no atalho visual de **Clientes** (ou acessar pelo menu `Cadastro > Clientes`)
3. A tela `frmCliente` abre e a grid exibe os clientes cadastrados
4. **Inserção:** digitar o nome no campo `edtNome` → clicar **Salvar** → confirmar com **Sim** → verificar que o registro aparece na grid e o campo é limpo
5. **Atualização:** clicar em um cliente na grid (o nome carrega em `edtNome`) → editar o nome → clicar **Atualizar** → confirmar com **Sim** → verificar que a grid reflete o novo nome
6. **Exclusão:** clicar em um cliente na grid → clicar **Excluir** → confirmar com **Sim** → verificar que o registro desaparece da grid

---

## Testes Funcionais

### Bloco 1 — Inserção de Cliente (Fluxo Feliz)

| Nº | Validar | Resultado Esperado | Aprovado? | Evidências |
|---|---|---|---|---|
| CT-CLI-F-01 | Inserir cliente com nome válido "João Silva" e confirmar | Cliente aparece na grid com Código gerado automaticamente e Nome "João Silva". Campo `edtNome` fica vazio. Foco retorna para `edtNome`. | | |
| CT-CLI-F-02 | Verificar que o diálogo de confirmação exibe o texto correto ao clicar em Salvar | Diálogo exibe exatamente "Deseja Salvar?" com ícone de aviso (correção BUG-001) | | |
| CT-CLI-F-03 | Após inserção bem-sucedida, verificar que o campo `edtNome` está vazio | `edtNome.Text = ""` imediatamente após o retorno da operação | | |
| CT-CLI-F-04 | Após inserção bem-sucedida, verificar que o foco está em `edtNome` | Cursor posicionado em `edtNome` sem ação adicional do operador | | |
| CT-CLI-F-05 | Inserir dois clientes consecutivos sem fechar a tela | Ambos aparecem na grid com códigos únicos e sequenciais. Campo limpo entre as inserções. | | |
| CT-CLI-F-06 | Verificar que o código do cliente é gerado automaticamente pelo banco | O campo Código na grid é preenchido automaticamente — o operador não informa código em nenhum momento | | |
| CT-CLI-F-07 | Após inserção, a grid recarrega em até 3 segundos | O novo registro está visível na grid em até 3 segundos após a confirmação | | |

### Bloco 2 — Inserção de Cliente (Fluxo Alternativo — Cancelamento)

| Nº | Validar | Resultado Esperado | Aprovado? | Evidências |
|---|---|---|---|---|
| CT-CLI-A-01 | Digitar nome válido, clicar Salvar e escolher **Não** no diálogo | Nenhum registro inserido no banco. Mensagem "Ação Cancelada" exibida. Campo `edtNome` permanece preenchido com o texto digitado. | | |
| CT-CLI-A-02 | Verificar que a grid não é alterada após cancelar a inserção | Grid mantém exatamente os mesmos registros anteriores ao cancelamento | | |

### Bloco 3 — Atualização de Cliente (Fluxo Feliz)

| Nº | Validar | Resultado Esperado | Aprovado? | Evidências |
|---|---|---|---|---|
| CT-CLI-F-08 | Clicar em uma linha na grid e verificar que o nome é carregado em `edtNome` | `edtNome.Text` recebe o `NOME_CLI` da linha clicada automaticamente (correção BUG-004) | | |
| CT-CLI-F-09 | Selecionar cliente, editar nome para "Novo Nome Teste" e confirmar atualização | Grid exibe o novo nome na linha do cliente atualizado. Dados no banco refletem a mudança. | | |
| CT-CLI-F-10 | Verificar que o diálogo de confirmação de atualização exibe o texto correto | Diálogo exibe exatamente "Deseja Atualizar?" com ícone de aviso | | |
| CT-CLI-F-11 | Após atualização, a grid recarrega em até 2 segundos | Nome atualizado visível na grid em até 2 segundos | | |
| CT-CLI-F-12 | Verificar que apenas o registro atualizado foi modificado no banco | Os demais clientes permanecem inalterados na grid e no banco | | |

### Bloco 4 — Atualização de Cliente (Fluxo Alternativo — Cancelamento)

| Nº | Validar | Resultado Esperado | Aprovado? | Evidências |
|---|---|---|---|---|
| CT-CLI-A-03 | Selecionar cliente, editar nome e clicar **Não** no diálogo de atualização | Nenhuma alteração persistida. Mensagem de cancelamento exibida. Grid permanece com o nome original. | | |
| CT-CLI-A-04 | Verificar que `edtNome` mantém o texto editado após cancelar a atualização | Estado da tela (campo e seleção) permanece inalterado após cancelamento | | |

### Bloco 5 — Exclusão de Cliente (Fluxo Feliz)

| Nº | Validar | Resultado Esperado | Aprovado? | Evidências |
|---|---|---|---|---|
| CT-CLI-F-13 | Selecionar cliente e confirmar exclusão com **Sim** | Cliente removido do banco. Grid recarregada sem o registro. Nenhuma linha permanece selecionada após exclusão. | | |
| CT-CLI-F-14 | Verificar que o diálogo de confirmação de exclusão exibe o texto correto | Diálogo exibe exatamente "Deseja Excluir?" com ícone de aviso | | |
| CT-CLI-F-15 | Verificar que apenas o cliente selecionado foi excluído | Os demais clientes permanecem na grid e no banco | | |

### Bloco 6 — Exclusão de Cliente (Fluxo Alternativo — Cancelamento)

| Nº | Validar | Resultado Esperado | Aprovado? | Evidências |
|---|---|---|---|---|
| CT-CLI-A-05 | Selecionar cliente, clicar Excluir e escolher **Não** | Nenhum registro removido. Mensagem "Ação Cancelada" exibida. Grid inalterada. | | |

### Bloco 7 — Sincronização da Grid

| Nº | Validar | Resultado Esperado | Aprovado? | Evidências |
|---|---|---|---|---|
| CT-CLI-F-16 | Abrir a tela de clientes com banco vazio | Grid exibe sem registros e sem exibir nenhuma mensagem de erro | | |
| CT-CLI-F-17 | Abrir a tela de clientes com registros cadastrados | Grid exibe todos os clientes na ordem crescente de Código | | |
| CT-CLI-F-18 | Verificar que a grid permanece estável enquanto nenhuma operação é realizada | Grid não recarrega espontaneamente sem ação do operador | | |

---

## Testes Negativos e de Validação

| Nº | Validar | Resultado Esperado | Aprovado? | Evidências |
|---|---|---|---|---|
| CT-CLI-N-01 | Clicar em **Salvar** com campo `edtNome` completamente vazio | Mensagem modal de validação informando que o nome é obrigatório. SP não é chamada. Foco retorna para `edtNome`. (correção BUG-002) | | |
| CT-CLI-N-02 | Clicar em **Salvar** com `edtNome` contendo apenas espaços ("     ") | Mensagem modal de validação. SP não é chamada. Campo não é limpo. | | |
| CT-CLI-N-03 | Clicar em **Salvar** com `edtNome` contendo apenas uma tabulação ou caractere invisível | Mensagem modal de validação. SP não é chamada. | | |
| CT-CLI-N-04 | Clicar em **Atualizar** sem nenhuma linha selecionada na grid | Mensagem modal orientando o operador a selecionar um cliente. SP não é chamada. | | |
| CT-CLI-N-05 | Clicar em **Atualizar** com `edtNome` vazio após selecionar cliente | Mensagem modal de validação do campo obrigatório. SP não é chamada. | | |
| CT-CLI-N-06 | Clicar em **Atualizar** com `edtNome` contendo apenas espaços | Mensagem modal de validação. SP não é chamada. | | |
| CT-CLI-N-07 | Clicar em **Excluir** sem nenhuma linha selecionada na grid | Mensagem modal orientando o operador a selecionar um cliente. SP não é chamada. | | |
| CT-CLI-N-08 | Clicar em **Excluir** com a grid vazia (banco sem registros) | Mensagem modal orientando seleção. Nenhum erro de exceção. | | |
| CT-CLI-N-09 | Verificar que o diálogo de confirmação de inserção não aparece quando o nome é inválido | Nenhum diálogo de confirmação é exibido antes da mensagem de validação | | |

---

## Testes de Valor Limite (Particionamento de Equivalência e Análise de Valor Limite)

| Nº | Validar | Massa de Dados | Resultado Esperado | Aprovado? | Evidências |
|---|---|---|---|---|---|
| CT-CLI-L-01 | Inserir cliente com nome de **1 caractere** (mínimo válido) | Nome: "A" | Aceito e persistido corretamente. Registro na grid com código e nome "A". | | |
| CT-CLI-L-02 | Inserir cliente com nome de **2 caracteres** | Nome: "AB" | Aceito e persistido. | | |
| CT-CLI-L-03 | Inserir cliente com nome de **49 caracteres** (limite inferior — fronteira) | Nome com 49 chars | Aceito e persistido sem truncamento. | | |
| CT-CLI-L-04 | Inserir cliente com nome de **50 caracteres** (limite superior exato) | Nome com exatos 50 chars | Aceito e persistido sem truncamento nem erro. Todos os 50 caracteres gravados. | | |
| CT-CLI-L-05 | Tentar digitar o **51º caractere** no campo `edtNome` | Digitar 51 chars sequencialmente | O campo bloqueia silenciosamente no 50º caractere. Nenhuma mensagem de erro. O campo exibe apenas 50 chars. | | |
| CT-CLI-L-06 | Verificar propriedade `MaxLength` do campo `edtNome` | Inspeção visual e funcional | `edtNome.MaxLength = 50` — campo aceita no máximo 50 caracteres | | |
| CT-CLI-L-07 | Inserir nome com **1 espaço** no início seguido de caractere válido (ex: " João") | Nome: " João" | Aceito — Trim não deve remover espaços internos, apenas verificar se a string trimada não é vazia. Comportamento depende da implementação de NomeValido. | | |
| CT-CLI-L-08 | Inserir nome com **apenas 1 espaço** | Nome: " " | Rejeitado — mensagem de validação exibida. | | |
| CT-CLI-L-09 | Atualizar nome para **50 caracteres** exatos | Nome com 50 chars | Aceito e persistido sem truncamento. | | |

---

## Testes Exploratórios

| Nº | Explorar | Procedimento | Resultado Esperado | Aprovado? | Evidências |
|---|---|---|---|---|---|
| CT-CLI-E-01 | Comportamento com nome contendo caracteres especiais | Inserir "José D'Ávila & Cia." | Sistema aceita e persiste corretamente. Grid exibe nome completo. | | |
| CT-CLI-E-02 | Comportamento com nome contendo acentuação e Unicode | Inserir "Müller Ações Ltda" | Sistema aceita sem corrupção de encoding. Banco armazena corretamente. | | |
| CT-CLI-E-03 | Comportamento com nome somente em números | Inserir "123456789" | Aceito — não há restrição de tipo no campo nome. | | |
| CT-CLI-E-04 | Clicar múltiplas vezes rapidamente em **Salvar** com nome válido | 3 cliques rápidos com confirmação | Apenas 1 cliente inserido por sequência de confirmação. Sem duplicatas inesperadas. | | |
| CT-CLI-E-05 | Clicar em **Salvar** antes de o banco terminar de carregar a grid | Logo após abrir a tela, clicar rapidamente em Salvar | Nenhum crash. A operação aguarda ou exibe erro tratado. | | |
| CT-CLI-E-06 | Selecionar cliente, editar nome e depois selecionar outro cliente na grid | Selecionar cliente A → editar nome → clicar no cliente B | `edtNome` carrega o nome do cliente B (nova seleção sobrescreve). | | |
| CT-CLI-E-07 | Inserir cliente com nome que já existe no banco | Inserir "João Silva" quando já existe outro "João Silva" | Sistema aceita (não há constraint UNIQUE no nome). Dois registros com o mesmo nome. | | |
| CT-CLI-E-08 | Fechar e reabrir a tela de clientes após inserção | Inserir cliente, fechar tela, reabrir | Grid exibe todos os clientes incluindo o recém-inserido. Dados persistidos corretamente. | | |
| CT-CLI-E-09 | Verificar ordenação da grid após múltiplas inserções | Inserir 5 clientes em ordem aleatória de nomes | Grid exibe na ordem crescente de Código_Cliente (ID_CLI ASC). | | |
| CT-CLI-E-10 | Pressionar Enter no campo `edtNome` | Digitar nome e pressionar Enter | Comportamento documentado: sem ação (Enter não aciona Salvar), ou comportamento navegação padrão VCL. Sem crash. | | |
| CT-CLI-E-11 | Verificar comportamento com colar (Ctrl+V) texto de 100 caracteres | Colar string de 100 chars em `edtNome` | O campo aceita apenas os primeiros 50 caracteres (MaxLength = 50). | | |

---

## Testes de Regressão

| Nº | Validar | Relacionado a | Resultado Esperado | Aprovado? | Evidências |
|---|---|---|---|---|---|
| CT-CLI-R-01 | Verificar que o texto do diálogo de inserção é "Deseja Salvar?" (sem typo) | BUG-001 | Diálogo exibe "Deseja Salvar?" e não "Deseja Salavar" | | |
| CT-CLI-R-02 | Verificar que inserção com campo vazio é rejeitada antes de exibir qualquer diálogo | BUG-002 | Mensagem de validação aparece diretamente, sem diálogo de confirmação | | |
| CT-CLI-R-03 | Verificar que erro de banco na inserção não trava a aplicação | BUG-003 (try/except) | Mensagem de erro exibida; aplicação continua funcionando; foco retorna ao formulário | | |
| CT-CLI-R-04 | Verificar que erro de banco na atualização não trava a aplicação | BUG-003 (try/except) | Mensagem de erro exibida; aplicação continua; grid preservada | | |
| CT-CLI-R-05 | Verificar que erro de banco na exclusão não trava a aplicação | BUG-003 (try/except) | Mensagem de erro exibida; aplicação continua; grid preservada | | |
| CT-CLI-R-06 | Verificar que ao selecionar linha na grid o nome é carregado em `edtNome` | BUG-004 | `edtNome.Text` = `NOME_CLI` da linha selecionada (não mais lê da grid na hora da gravação) | | |
| CT-CLI-R-07 | Após corrigir BUG-004: confirmar que atualização usa o nome editado em `edtNome` e não o da grid | BUG-004 | Atualizar nome para valor diferente do original — banco reflete o nome digitado em `edtNome`, não o valor anterior da grid | | |
| CT-CLI-R-08 | Verificar que tela de Vendas ainda exibe clientes na grid | Regressão geral | Grid de clientes em `frmVendas` carrega normalmente após qualquer alteração no módulo de clientes | | |
| CT-CLI-R-09 | CRUD completo de clientes em sequência: inserir → atualizar → excluir | CR006-03 | Todas as três operações executadas com sucesso sem travamentos ou dados corrompidos | | |
| CT-CLI-R-10 | Verificar que os diálogos de cancelamento ainda exibem "Ação Cancelada" em todos os handlers | Regressão geral | Mensagem "Ação Cancelada" (ou equivalente) aparece ao negar qualquer confirmação | | |

---

## Testes Não Funcionais

### Performance

| Nº | Validar | Critério de Aceite | Aprovado? | Evidências |
|---|---|---|---|---|
| CT-CLI-P-01 | Tempo de resposta da inserção com banco local | A grid é recarregada e o campo limpo em ≤ 3 segundos após a confirmação | | |
| CT-CLI-P-02 | Tempo de resposta da atualização com banco local | A grid reflete o novo nome em ≤ 2 segundos após a confirmação | | |
| CT-CLI-P-03 | Tempo de abertura da tela com 1.000 registros na tabela | Grid carregada e visível em ≤ 5 segundos | | |
| CT-CLI-P-04 | Inserção de 50 clientes consecutivos sem fechar a tela | Nenhuma degradação de performance. Tempo de cada inserção estável. Sem vazamento de memória aparente. | | |

### Segurança e Integridade

| Nº | Validar | Critério de Aceite | Aprovado? | Evidências |
|---|---|---|---|---|
| CT-CLI-S-01 | SQL Injection no campo nome | Inserir `'; DROP TABLE TBCLIENTES; --` no campo nome | A stored procedure recebe o valor como parâmetro seguro. Nenhuma ação destrutiva no banco. | | |
| CT-CLI-S-02 | Verificar que nenhuma operação usa SQL inline nos formulários | Análise de código | Toda operação de banco ocorre via `TFDStoredProc` declarado no DataModule | | |

### Concorrência

| Nº | Validar | Procedimento | Resultado Esperado | Aprovado? | Evidências |
|---|---|---|---|---|---|
| CT-CLI-C-01 | Dois operadores inserem cliente com mesmo nome simultaneamente | Simular abertura dupla da aplicação (duas instâncias) e inserção simultânea do mesmo nome | Ambos os registros são inseridos com códigos distintos. Sem deadlock ou erro de violação de PK (o código é autoincrement). | | |
| CT-CLI-C-02 | Operador A exclui cliente enquanto Operador B tenta atualizar o mesmo | Instância 1 exclui; imediatamente, Instância 2 tenta atualizar o mesmo ID | Instância 2 recebe erro de banco tratado (try/except). Mensagem exibida. Grid recarregada reflete exclusão. | | |
| CT-CLI-C-03 | Abrir a tela de clientes em duas instâncias da aplicação e realizar inserções alternadas | Inserir cliente na instância 1, depois na instância 2 | Cada instância vê somente seus próprios dados até recarregar a grid. Nenhuma instância trava. | | |

### Integridade de Dados

| Nº | Validar | Critério de Aceite | Aprovado? | Evidências |
|---|---|---|---|---|
| CT-CLI-I-01 | O nome persistido no banco é idêntico ao digitado na tela | Inserir "Carlos Magno" → consultar `SELECT NOME_CLI FROM TBCLIENTES WHERE NOME_CLI = 'Carlos Magno'` | Registro encontrado com exatamente o mesmo texto — sem truncamento, acréscimos ou modificações | | |
| CT-CLI-I-02 | O Código do cliente é único e não se repete | Inserir 10 clientes → verificar `SELECT ID_CLI, COUNT(*) FROM TBCLIENTES GROUP BY ID_CLI HAVING COUNT(*) > 1` | Nenhum resultado — todos os códigos são únicos | | |
| CT-CLI-I-03 | O Código não é reutilizado após exclusão | Excluir cliente com ID X → inserir novo cliente | Novo cliente recebe ID > X (autoincrement não recicla) | | |
| CT-CLI-I-04 | A atualização afeta apenas o registro selecionado | Atualizar "João" para "João Atualizado" → verificar todos os registros no banco | Somente o registro com o ID_CLI correto foi alterado. Demais clientes inalterados. | | |
| CT-CLI-I-05 | A exclusão remove apenas o registro selecionado | Excluir cliente de ID = X → `SELECT COUNT(*) FROM TBCLIENTES WHERE ID_CLI = X` | Resultado = 0 para o ID excluído. Outros registros intactos. | | |
| CT-CLI-I-06 | Exclusão de cliente vinculado a venda resulta em erro tratado | Tentar excluir cliente que tem `ID_CLI` referenciado em `TBVENDAS` | Mensagem de erro indicando violação de integridade referencial. Registro não é removido. Grid inalterada. | | |
| CT-CLI-I-07 | Os dados exibidos na grid são lidos do banco após cada operação | Após qualquer inserção/atualização/exclusão, comparar grid com `SELECT * FROM TBCLIENTES ORDER BY ID_CLI ASC` | Grid reflete exatamente o estado do banco no momento da recarga | | |

### Usabilidade

| Nº | Validar | Critério de Aceite | Aprovado? | Evidências |
|---|---|---|---|---|
| CT-CLI-U-01 | Colunas da grid exibidas na ordem correta | Abrir tela de clientes | Coluna 0 = Código_Cliente (centro), Coluna 1 = Nome_Cliente (esquerda) | | |
| CT-CLI-U-02 | Foco em `edtNome` após mensagem de validação | Acionar Salvar/Atualizar com campo inválido e fechar a mensagem | Cursor retorna automaticamente para `edtNome` | | |
| CT-CLI-U-03 | Tela centralizada na área de trabalho | Abrir `frmCliente` em diferentes resoluções | Formulário aparece centralizado na tela (Position = poDesktopCenter) | | |
| CT-CLI-U-04 | Mensagens em português sem erros de digitação | Acionar todos os fluxos | Todas as mensagens exibidas em português, sem typos | | |
| CT-CLI-U-05 | Diálogos exibem ícone de aviso visível | Acionar confirmações de Salvar, Atualizar e Excluir | Ícone de exclamação (aviso) presente em todos os diálogos de confirmação | | |
| CT-CLI-U-06 | `edtNome` limpo e com foco após inserção bem-sucedida | Inserir cliente com sucesso | Campo vazio e cursor posicionado sem ação adicional do operador | | |

---

## Informações Complementares

### Riscos Identificados

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| Campo `edtNome` sem MaxLength definido (BUG em aberto) | Média | Alto — SP recebe string > 50 chars, erro de banco não tratado | Configurar `MaxLength = 50` no DFM (tarefa 2.1 do tasks.md) |
| BUG-003: ausência de try/except — exceção de banco trava a aplicação | Alta | Crítico | Implementar try/except em todos os handlers (tarefas 6.3, 7.3, 8.2) |
| BUG-004: atualização sobrescreve nome com o valor da grid | Alta | Alto — operador não consegue editar nomes | Implementar `dbClienteCellClick` e corrigir `@nome` para `edtNome.Text` |
| Exclusão de cliente vinculado a venda | Média | Alto — violação de integridade sem tratamento | try/except captura EDatabaseError com mensagem para o operador |
| Dois operadores excluem/atualizam o mesmo registro | Baixa | Médio | Exceção capturada; grid recarregada reflete estado real |
| Nome com SQL Injection enviado para a SP | Baixa | Crítico em potencial | Stored procedures com parâmetros tipados protegem contra SQL Injection |

### Dependências

| Dependência | Tipo | Impacto se indisponível |
|---|---|---|
| SQL Server `localhost\SQLSERVER2022` | Infraestrutura | Nenhum teste pode ser executado |
| Stored procedure `st_InsereCli` | Banco | CT-CLI-F-01 a F-07 bloqueados |
| Stored procedure `st_AlteraCli` | Banco | CT-CLI-F-08 a F-12 bloqueados |
| Stored procedure `ST_APAGACLI` | Banco | CT-CLI-F-13 a F-15 bloqueados |
| Tabela `TBCLIENTES` | Banco | Toda a suíte bloqueada |
| Correções BUG-001 a BUG-004 implementadas | Código | Testes de regressão CT-CLI-R-01 a R-07 falharão |

### Impactos

- Qualquer alteração nos parâmetros das stored procedures (`@nome`, `@id`) impacta diretamente os handlers de botão em `Cliente.pas`
- Mudança na ordem das colunas em `qryClienets` pode impactar `dbCliente.Fields[0]` e `Fields[1]` — mitigado pelo uso de `FieldByName` no `dbClienteCellClick`
- Alteração no `TDataSource` (`dsClientes`) afeta a vinculação com a `TDBGrid` e quebra a sincronização visual

---

## Alterações da Versão

### Componentes Impactados pela Tarefa QA-001

| Componente | Arquivo | Tipo de Alteração |
|---|---|---|
| `btnSalvarClick` | `Cliente.pas` | Correção de texto (BUG-001), validação de campo (BUG-002), adição de try/except (BUG-003) |
| `btnAtualizarClick` | `Cliente.pas` | Adição de try/except (BUG-003), correção de `@nome` para `edtNome.Text` (BUG-004), guard clauses |
| `btnExcluirClick` | `Cliente.pas` | Adição de try/except (BUG-003), guard clause de seleção |
| `dbClienteCellClick` | `Cliente.pas` | Novo handler — carrega `NOME_CLI` em `edtNome` ao clicar na grid (BUG-004) |
| `edtNome.MaxLength` | `Cliente.dfm` | Novo atributo — `MaxLength = 50` |
| `dbCliente.OnCellClick` | `Cliente.dfm` | Novo evento vinculado — `dbClienteCellClick` |
| `NomeValido` | `Cliente.pas` | Nova função auxiliar privada |
| `LinhaGridSelecionada` | `Cliente.pas` | Nova função auxiliar privada |
| `RecarregarGrid` | `Cliente.pas` | Nova procedure auxiliar privada |

---

## Informações do Ambiente

| Parâmetro | Valor |
|---|---|
| **Sistema Operacional** | Windows (Win32) |
| **Banco de Dados** | Microsoft SQL Server 2022 |
| **Instância** | `localhost\SQLSERVER2022` |
| **Banco** | `ProjetoVenda` |
| **Servidor de Aplicação** | N/A — aplicação desktop local |
| **Ambiente** | Desenvolvimento / Teste |
| **IDE** | Embarcadero RAD Studio / Delphi |
| **Framework Visual** | VCL (Visual Component Library) |
| **Biblioteca de Acesso a Dados** | FireDAC |
| **Plataforma de Build** | Win32 Debug |
| **Executável** | `Win32\Debug\VendaProduto.exe` |

---

## Novidades da Versão

### Resumo Executivo — Tarefa QA-001

A **Tarefa QA-001** implementa o módulo de **Cadastro de Clientes** do sistema PDV VendaProduto com quatro correções críticas de defeitos pré-existentes e novos comportamentos de qualidade.

**O que foi entregue:**

- **Inserção de clientes** com validação obrigatória do nome antes de qualquer chamada ao banco, código gerado automaticamente pelo banco de dados e grid sincronizada após cada operação
- **Atualização de clientes** com carregamento automático do nome ao clicar na grid (eliminando o BUG-004 que impedia a edição real), validação de seleção obrigatória e nome obrigatório
- **Exclusão de clientes** com confirmação, validação de seleção e tratamento de violação de integridade referencial
- **Robustez total**: todos os três handlers de botão protegidos com `try/except`, garantindo que nenhuma falha de banco trave ou encerre a aplicação
- **UX consistente**: campo `edtNome` com limite de 50 caracteres (MaxLength), limpeza e foco automático após inserção, mensagens em português sem erros de digitação

**Bugs corrigidos nesta versão:**

| Bug | Descrição | Impacto |
|---|---|---|
| BUG-001 | Typo "Deseja Salavar" → "Deseja Salvar?" | Baixo (cosmético) |
| BUG-002 | Ausência de validação de campo vazio antes de chamar a SP | Alto (dados inválidos no banco) |
| BUG-003 | Ausência de try/except nos 3 handlers | Crítico (application crash) |
| BUG-004 | Atualização lia o nome da grid em vez de `edtNome` | Alto (edição de nome impossível) |

**Total de casos de teste documentados: 68**
- Funcionais (fluxo feliz + alternativo): 18
- Negativos e de validação: 9
- Valor limite e equivalência: 9
- Exploratórios: 11
- Regressão: 10
- Performance: 4
- Segurança/Integridade: 9
- Concorrência: 3
- Usabilidade: 6
