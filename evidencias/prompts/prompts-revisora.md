# Prompts do usuário para a IA-revisora

As respostas da IA-revisora a cada prompt estão em
[`../specs/revisora/spec-revisora.md`](../specs/revisora/spec-revisora.md).

> **Texto literal, inclusive nomes de ferramentas; a ferramenta usada é apresentada no
> [`relatorio.md`](../../relatorio.md).**


_Texto literal das mensagens do usuário no painel da IA-revisora, em ordem. Horários em BRT (UTC−3)._

### R01 — 29/09/2026 17:43

> mande o painel de controle para eu conectar na pasta do projeto.

### R02 — 29/09/2026 17:49

> faça uma leitura de estudo da prova, e em seguida vou mandar a primeira etapa do meu spec de decisões.

### R03 — 29/09/2026 17:50

> pode confirmar os 4 pontos? A Tarefa 1 está escrita e aguarda sua revisão. Nada foi commitado. Por enquanto existem só a pasta local /home/sirla/faculdade/projeto_ale/prova-primeiro-bimestre-devops/, com Git iniciado na branch main, e dois arquivos:
>
> - specs/requirements.md: 10 requisitos (R1 a R10) com critérios de aceite no formato QUANDO… ENTÃO… DEVE…, as restrições do Lab (C1 a C6) e o que fica fora do escopo.
> - specs/prompts.md: o registro de prompts, já com o planejamento e esta tarefa. Falta preencher a coluna "Revisão" da linha 2 com o que você achar na revisão.
>
> Pontos que decidi por você no requirements.md. Confirme ou mude:
>
> ┌─────────────────────────┬─────────────────────────────────────┬───────────────────────────────┐
> │          Item           │            O que escrevi            │          Alternativa          │
> ├─────────────────────────┼─────────────────────────────────────┼───────────────────────────────┤
> │ Resposta do DELETE      │ 204 sem corpo                       │ 200 retornando a reserva      │
> │                         │                                     │ removida                      │
> ├─────────────────────────┼─────────────────────────────────────┼───────────────────────────────┤
> │ id inválido (ex.:       │ 404                                 │ 400                           │
> │ /reservas/abc)          │                                     │                               │
> ├─────────────────────────┼─────────────────────────────────────┼───────────────────────────────┤
> │ Formato de data         │ AAAA-MM-DD, só a data               │ data + hora (timestamp)       │
> ├─────────────────────────┼─────────────────────────────────────┼───────────────────────────────┤
> │ PUT                     │ Pede os campos completos (cliente e │ Atualização parcial, que no   │
> │                         │  data obrigatórios)                 │ rigor seria PATCH             │
> └─────────────────────────┴─────────────────────────────────────┴──────────────────────────────

### R04 — 29/09/2026 17:51

> você é o agente de decisão, o outro recebe seu feedback e ele executa.

### R05 — 29/09/2026 17:56

> As duas notas da sua revisão entraram na seção 2:
> - Validar o :id: a seção 2.5 aceita só ^[1-9]\d*$ e valores até o limite do INTEGER. Qualquer outro valor devolve 404 antes de consultar o banco.
> - DATE sem fuso: a seção 2.3 usa setTypeParser(1082, v => v) e explica o bug que ele evita.
>
> Decisões que tomei no design. Confirme ou mude:
>
> #: 1
> Decisão: O SSL no RDS valida o certificado usando o bundle de CAs oficial da AWS, baixado no
> user_data
> Motivo: Criptografia e autenticidade do servidor, um bom ponto para a Questão 4
> Alternativa: rejectUnauthorized: false, mais simples, mas só criptografa e não confere quem está do
> outro lado
> ────────────────────────────────────────
> #: 2
> Decisão: A EC2 faz git clone do seu repositório público e build da imagem nela mesma
> Motivo: Não precisa de registry, que é assunto da Aula 09
> Alternativa: Copiar os arquivos por scp à mão, o que não é reproduzível
> ────────────────────────────────────────
> #: 3
> Decisão: A senha do banco fica no user_data
> Motivo: É o caminho simples, aceitável no Lab, e o trade-off vai registrado no relatório
> Alternativa: SSM Parameter Store lido pela EC2 via LabInstanceProfile. É mais seguro, mas a permissão
> da LabRole precisa ser testada
> ────────────────────────────────────────
> #: 4
> Decisão: PostgreSQL 16 local e no RDS
> Motivo: A mesma versão principal nos dois ambientes evita diferenças de comportamento
> Alternativa: Manter o 15 da Aula 06
> ────────────────────────────────────────
> #: 5
> Decisão: A porta 22 só aceita o seu IP /32, e a variável recusa 0.0.0.0/0
> Motivo: Menor privilégio
> Alternativa: —
> ────────────────────────────────────────
> #: 6
> Decisão: Sem NAT Gateway
> Motivo: O RDS não precisa de internet, e o NAT gasta créditos por hora
> Alternativa: —
> ────────────────────────────────────────
> #: 7
> Decisão: Campo extra criado_em na tabela
> Motivo: Serve para auditoria e não altera o contrato do enunciado
> Alternativa: Deixar só os 4 campos
> ────────────────────────────────────────
> #: 8
> Decisão: Limite de 120 caracteres em cliente
> Motivo: Evita entradas absurdas
> Alternativa: Sem limite
> ────────────────────────────────────────
> #: 9
> Decisão: O CRUD é testado por um scripts/smoke-test.sh, o mesmo script local e na AWS
> Motivo: As evidências dos dois ambientes ficam comparáveis
> Alternativa: Rodar curl à mão
> ────────────────────────────────────────
> #: 10
> Decisão: Branches: feat/api, feat/docker, feat/compose, feat/infra, docs/relatorio, com merge --no-ff
> Motivo: O merge commit fica visível no histórico
> Alternativa: —
>
> Uma dependência de ordem: como a EC2 clona o repositório, ele precisa existir no GitHub, público e com o código, antes do terraform apply. Por isso, quando chegarmos na infra, vou pedir sua autorização para criar o repositório no GitHub e fazer o push.

### R06 — 29/09/2026 17:59

> Tarefa 3 pronta para revisão. O arquivo é specs/tasks.md, e a linha 4 do specs/prompts.md já está registrada. Ainda não commitado. São 12 tarefas em 5 fases, cada uma com branch, requisitos atendidos, critério de pronto, evidências e mensagens de commit:
>
> ┌─────────────┬───────────────────────────────────────────────┬─────────────────────────────────┐
> │    Fase     │                    Tarefas                    │           Observação            │
> ├─────────────┼───────────────────────────────────────────────┼─────────────────────────────────┤
> │ A: Fundação │ T1: README + .gitignore                       │ Direto no main                  │
> ├─────────────┼───────────────────────────────────────────────┼─────────────────────────────────┤
> │ B:          │ T2: API (3 commits)                           │ Testada contra um Postgres      │
> │ Aplicação   │                                               │ temporário em container         │
> ├─────────────┼───────────────────────────────────────────────┼─────────────────────────────────┤
> │ C:          │ T3: Dockerfile · T4: Compose + smoke test ·   │ T5 é o ponto onde peço sua      │
> │ Containers  │ T5: publicar no GitHub ⚠️                     │ autorização                     │
> ├─────────────┼───────────────────────────────────────────────┼─────────────────────────────────┤
> │ D: Infra    │ T6: backend · T7: módulos · T8: composição +  │ Precisa das credenciais do Lab  │
> │             │ plan · T9: apply → teste → destroy            │ a partir da T6                  │
> ├─────────────┼───────────────────────────────────────────────┼─────────────────────────────────┤
> │ E: Entrega  │ T10: relatório · T11: revisão final (30/09) · │ Na T10, a reflexão vem de você  │
> │             │  T12: PR (só 01/10)                           │                                 │
> └─────────────┴───────────────────────────────────────────────┴─────────────────────────────────┘
>
> Quatro pontos para você avaliar:
> 1. .terraform.lock.hcl versionado: é a recomendação oficial da HashiCorp, porque fixa a versão do provider. O enunciado não fala dele.
> 2. *.tfvars ignorado e *.tfvars.example versionado: o terraform.tfvars guarda a senha do RDS e o seu IP.
> 3. Backend depois da prova (T11): o bucket S3 e a tabela DynamoDB custam quase nada parados. Destruir tudo é mais limpo, mas quebra o terraform plan caso a professora queira reproduzir algo. Decidimos na quarta.
> 4. Total de commits: com esse plano ficam uns 16 commits mais 5 merges, bem acima do mínimo de 6.
>
> Para a T2, depois da sua aprovação: o Docker precisa estar ativo no WSL para o teste com o Postgres temporário. Você já ligou a integração no Docker Desktop? Se ainda não, dá para escrever o código da API primeiro e testar quando o Docker estiver pronto.

### R07 — 29/09/2026 18:02

> Verifiquei os pontos da revisão: quase todos fazem sentido, mas o Ajuste 1 precisa de correção — a spec já está versionada em dois commits (a4d3392 e aed04ad), faltando só o tasks.md. Proponho manter um commit por fase da spec (incluindo uma "Fase 0" retroativa) e vou aplicar isso junto com os demais ajustes no tasks.md, aguardando sua confirmação antes de commitar.

### R08 — 29/09/2026 18:09

> se atualize sobre as novas funções que o agente executor fez

### R09 — 29/09/2026 18:11

> você viu algo assim: Entendido. Agora sei que os blocos de revisão vêm do outro agente, e registrei isso em memória para as próximas sessões.
>
> Sim, a prova pede que você relate os erros da IA. Não há uma seção só para isso, mas o tema aparece em três lugares:
>
> ┌──────────────────────┬─────────────────────────────────────────────────────────────────┬──────┐
> │         Onde         │                           O que pede                            │ Peso │
> ├──────────────────────┼─────────────────────────────────────────────────────────────────┼──────┤
> │ Questão 2            │ "o que a IA gerou bem e o que precisou corrigir… onde a IA      │ 10%  │
> │                      │ economizou tempo e onde atrapalhou?"                            │      │
> ├──────────────────────┼─────────────────────────────────────────────────────────────────┼──────┤
> │                      │ *"Que checklist aplicou antes do apply em código gerado por     │      │
> │ Questão 4            │ IA?… O que aconteceria se aceitasse o código da IA sem          │ 10%  │
> │                      │ revisar?"*                                                      │      │
> ├──────────────────────┼─────────────────────────────────────────────────────────────────┼──────┤
> │ Critério "Uso de IA  │ "Uso documentado e crítico da IA"                               │ 10%  │
> │ como copiloto"       │                                                                 │      │
> └──────────────────────┴─────────────────────────────────────────────────────────────────┴──────┘
>
> Seu fluxo, com um agente revisando o outro e você decidindo, é um material muito bom para essas respostas. Já existem casos reais:
>
> ┌─────┬────────────────────────────────────────────────────┬─────────────┬─────────────────────┐
> │  #  │                        Erro                        │   De quem   │     Quem pegou      │
> ├─────┼────────────────────────────────────────────────────┼─────────────┼─────────────────────┤
> │ 1   │ Afirmei que o PR precisava ser aberto hoje, e o    │ Eu          │ Você                │
> │     │ certo é 01/10                                      │             │                     │
> ├─────┼────────────────────────────────────────────────────┼─────────────┼─────────────────────┤
> │ 2   │ Compose sem healthcheck explícito da API, ou seja, │ Eu          │ Revisor             │
> │     │  R3.2 atendido só de forma implícita               │             │                     │
> ├─────┼────────────────────────────────────────────────────┼─────────────┼─────────────────────┤
> │ 3   │ Não citei que o set -x vazaria a senha no log nem  │ Eu          │ Revisor             │
> │     │ que a senha também vai para o tfstate              │             │                     │
> ├─────┼────────────────────────────────────────────────────┼─────────────┼─────────────────────┤
> │     │ O critério da T5 ("ls-remote mostra as branches")  │             │                     │
> │ 4   │ não batia com o comando (--push envia só uma       │ Eu          │ Revisor             │
> │     │ branch)                                            │             │                     │
> ├─────┼────────────────────────────────────────────────────┼─────────────┼─────────────────────┤
> │ 5   │ Não conferi o IP público da EC2 no módulo          │ Eu          │ Revisor pediu, eu   │
> │     │ reaproveitado                                      │ (omissão)   │ conferi e estava ok │
> ├─────┼────────────────────────────────────────────────────┼─────────────┼─────────────────────┤
> │ 6   │ Afirmou que a specs/ não era commitada, mas ela já │ Revisor     │ Eu, conferindo o    │
> │     │  estava em 2 commits                               │             │ git log             │
> ├─────┼────────────────────────────────────────────────────┼─────────────┼─────────────────────┤
> │     │ Divergência sobre o untaint: o revisor diz que não │ Os dois     │ Em aberto, resolve  │
> │ 7   │  se aplica, e o seu histórico da Aula 05 mostra    │ discordam   │ na execução da T6   │
> │     │ que foi necessário                                 │             │                     │
> └─────┴────────────────────────────────────────────────────┴─────────────┴─────────────────────┘
>
> O caso 6 é bom para a Questão 4, porque mostra que o revisor também erra e que a verificação contra os fatos (git log) decide, não a opinião de nenhum dos dois.
>
> Recomendação: acrescentar ao specs/prompts.md uma segunda tabela, "Erros e correções", com as colunas Erro · De quem (IA-autora / IA-revisora) · Quem detectou · Como foi verificado · Correção, e registrar os 7 casos acima. Duas decisões:
> 1. Como chamar as duas IAs no registro: sugiro "IA-autora" e "IA-revisora", sem nome de ferramenta, e você explica no relatorio.md, onde já decidimos citar as ferramentas. Isso inclui a do outro painel, que você também vai precisar nomear.
> 2. Posso criar essa tabela agora, entrando no mesmo commit do tasks.md?
>
> Continuam pendentes as duas confirmações da mensagem anterior: a Fase 0 no lugar do commit único e quem preenche a coluna "Revisão".

### R10 — 29/09/2026 18:12

> essa coluna está aonde? A decisão sobre quem preenche a coluna "Revisão" é sua. A minha recomendação continua sendo que você preencha, porque é o registro do que você mesmo questionou.

### R11 — 29/09/2026 18:24

> faz sentido essa minha decisão? A minha decisão sobre usar dois agentes para ações diferentes é causar questionamentos e ajustes sobre a decisão da IA de execução, a IA revisadora está sendo utilizada em um versão Opus que gasta mais tokens, como ela não executa, apenas lê as decisões e acompanha os commits, ela se torna uma avaliadora de apoio para ajustes, e o executor fica responsável pela produção principal, análise, edição de arquivos, etc.

### R12 — 29/09/2026 18:26

> mude a sua regra aqui, você não executa, mas só avalia as decisões se verificar o estado atual.

### R13 — 29/09/2026 18:30

> melhor? A minha decisão de usar dois agentes para funções diferentes é para gerar questionamentos e ajustes nas tomadas de decisões antes da execução, a IA responsável pela execução cria a tabela de recomendações, e a IA revisadora lê essa tabela, e só depois de checar o estado atual do projeto, ela mostra a sua análise, eu olho, leio, tiro dúvidas se tiver, e mando para a IA que executa, ela aprova e segue o fluxo de trabalho. Escolhi esse fluxo para facilitar a minha compreensão entre as decisões por meio dos conceitos técnicos trabalhados.

### R14 — 29/09/2026 18:31

> corrige esse texto

### R15 — 29/09/2026 18:48

> 2 - todas mensagens com o número 2 no começo é para você analisar depois de verificar o estado atual do projeto.

### R16 — 29/09/2026 18:48

> 2 - A T2 está pronta para revisão, na branch feat/api. Ainda sem commits.
>
> Arquivos criados (app/):
>
> ┌───────────────────────────┬───────────────────────────────────────────────────────────────────┐
> │          Arquivo          │                             O que faz                             │
> ├───────────────────────────┼───────────────────────────────────────────────────────────────────┤
> │ package.json +            │ Express 4.22 e pg 8.23, npm install sem vulnerabilidades          │
> │ package-lock.json         │                                                                   │
> ├───────────────────────────┼───────────────────────────────────────────────────────────────────┤
> │                           │ Pool configurado por variáveis de ambiente, SSL com validação do  │
> │ src/db.js                 │ certificado quando DB_SSL=true, setTypeParser(1082) e initDb()    │
> │                           │ com 10 tentativas a cada 3 s                                      │
> ├───────────────────────────┼───────────────────────────────────────────────────────────────────┤
> │ src/validation.js         │ parseId() (inteiro positivo, até o limite do INTEGER) e           │
> │                           │ validarReserva() (acumula os erros)                               │
> ├───────────────────────────┼───────────────────────────────────────────────────────────────────┤
> │ src/routes/reservas.js    │ CRUD com queries parametrizadas e COALESCE no PUT                 │
> ├───────────────────────────┼───────────────────────────────────────────────────────────────────┤
> │ src/app.js                │ /health, 404 genérico e handler de erro (400 para JSON            │
> │                           │ malformado, 500 sem vazar detalhes)                               │
> ├───────────────────────────┼───────────────────────────────────────────────────────────────────┤
> │ src/server.js             │ Chama initDb() antes do listen e encerra de forma limpa com       │
> │                           │ SIGTERM                                                           │
> └───────────────────────────┴───────────────────────────────────────────────────────────────────┘
>
> Testes contra um Postgres 16 temporário, todos ok:
> - Os 24 casos do contrato: POST 201/400 (sem campos, 2026-02-30, status inválido, 121 caracteres, array, JSON malformado), GET 200/404 (abc, 0, estouro de inteiro, inexistente), PUT 200 mantendo o status/400/404, DELETE 204 e depois 404, rota inexistente 404. O psql confirma o estado final gravado no banco.
> - Data sem deslocamento de fuso: "data":"2026-10-01" volta igual.
> - Retry: a API subiu antes do banco, falhou nas tentativas 1 e 2 e conectou na 3.
> - Banco fora do ar: resposta 500 {"erro":"Erro interno"}, com o detalhe só no log.
> - SIGTERM: a API encerrou com exit code 0.
>
> Registrei um erro meu no teste (E8): o pkill -f derrubou o próprio shell de teste. Refiz o teste pelo PID, e o código da API não foi afetado.
>
> Três pontos para a revisão:
> 1. /health responde 200 mesmo com o banco fora. É o que o design pede, uma checagem de que a API está viva. A alternativa é incluir um SELECT 1, mas aí o container da API ficaria unhealthy quando o banco oscilasse.
> 2. POST sem Content-Type: application/json devolve 400, porque o corpo chega vazio. É o comportamento correto, e o smoke test da T4 cobre isso.
> 3. Commits planejados:
>    - feat: adiciona conexão com PostgreSQL e criação da tabela: package*.json e db.js
>    - feat: adiciona validação de reservas: validation.js
>    - feat: implementa CRUD de reservas e health check: rotas, app, server e as atualizações da spec
>
> Depois vem o merge --no-ff no main. Pode levar para a IA-revisora.

### R17 — 29/09/2026 18:54

> Decisão nova antes do commit da T2 — registro completo de prompts
>
> Contexto: o professor pediu todos os prompts usados, num documento.
>
> Decisões do usuário:
> 1. Novo arquivo specs/prompts-completos.md, versionado no repo da prova.
> 2. Contém SÓ os prompts do usuário (texto literal, com data/hora BRT e etapa),
>    não as respostas das IAs. Hoje: P01–P17.
> 3. Pareceres da IA-revisora aparecem quando o usuário os colou como prompt
>    para a IA-autora, marcados como "Parecer da IA-revisora, colado pelo usuário".
> 4. Seção reservada no fim para os prompts do usuário para a IA-revisora
>    (exportados por ele deste painel).
> 5. Gerado por script a partir do histórico da sessão da IA-autora e
>    regenerado no fim de cada tarefa, dentro do commit dela.
> 6. specs/prompts.md vira resumo analítico: coluna "Prompt (paráfrase)",
>    aspas removidas, cada linha referencia o prompt literal (P04, P06…).
>    Erro E9 registrado (paráfrases entre aspas pareciam citação literal).
>
> Plano de commit: os arquivos acima entram no 3º commit da T2
> ("feat: implementa CRUD de reservas e health check"), junto com
> tasks.md e prompts.md, depois merge --no-ff de feat/api no main.
>
> Ponto em aberto: o P04 literal cita o nome da ferramenta, e a regra é
> citar a ferramenta só no relatório. Opção A: manter literal. Opção B:
> substituir por [ferramenta] com nota no topo. A IA-autora recomenda A.
>
> Pedido: avaliar o plano, conferir specs/prompts-completos.md e
> specs/prompts.md no estado atual, e responder no formato de sempre,
> incluindo a seção "Erros meus reconhecidos" se houver.
>
> nesse caso,  a partir das mensagens com 2 na frente.

### R18 — 29/09/2026 18:56

> salvou na memória?

### R19 — 29/09/2026 18:57

> nesse caso, eu vou pedir para você o nosso histórico de prompt aqui, você me envia e eu mando para a IA que executa, ok?

### R20 — 29/09/2026 19:01

> 2 - Todos os ajustes estão aplicados e o pool.on('error') foi testado. Nada foi commitado.
>
> ┌───────────────────────────────────────────┬───────────────────────────────────────────────────┐
> │             Ajuste do parecer             │                      Status                       │
> ├───────────────────────────────────────────┼───────────────────────────────────────────────────┤
> │ Nota no topo: "texto literal, inclusive   │ ✅ Feito                                          │
> │ nomes de ferramentas…"                    │                                                   │
> ├───────────────────────────────────────────┼───────────────────────────────────────────────────┤
> │ 1. pool.on('error') no db.js, aplicado e  │ ✅ Feito, com prova antes e depois                │
> │ testado                                   │                                                   │
> ├───────────────────────────────────────────┼───────────────────────────────────────────────────┤
> │ 2. specs/ fora do commit feat:, em commit │ ✅ A regra da Fase 0 no tasks.md também foi       │
> │  docs: separado                           │ atualizada                                        │
> ├───────────────────────────────────────────┼───────────────────────────────────────────────────┤
> │ 3. Script gerador fora do repositório     │ ✅ Ele nunca esteve no repo, fica numa pasta      │
> │                                           │ temporária minha                                  │
> ├───────────────────────────────────────────┼───────────────────────────────────────────────────┤
> │ Seção da revisora (R01 a R17)             │ ✅ Reservada, falta o prompts-revisora.md         │
> ├───────────────────────────────────────────┼───────────────────────────────────────────────────┤
> │ E10                                       │ ✅ Registrado, com a origem corrigida: começou    │
> │                                           │ comigo e a revisora propagou                      │
> └───────────────────────────────────────────┴───────────────────────────────────────────────────┘
>
> Também registrei o E11 como contestação: o parecer do código da T2 nunca chegou até mim. O ajuste foi aplicado mesmo assim, porque é tecnicamente correto. Pergunte à revisora se ela chegou a gerar esse parecer. Se sim, cole-o aqui, porque pode ter outros ajustes que eu não vi, e ele também precisa entrar no registro literal.
>
> Commits planejados na feat/api, depois do seu ok:
>
> ┌─────┬──────────────────────────────────────────────────────────────────────────────────────────┐
> │  #  │                                          Commit                                          │
> ├─────┼──────────────────────────────────────────────────────────────────────────────────────────┤
> │ 1   │ feat: adiciona conexão com PostgreSQL e criação da tabela: package*.json e db.js         │
> ├─────┼──────────────────────────────────────────────────────────────────────────────────────────┤
> │ 2   │ feat: adiciona validação de reservas: validation.js                                      │
> ├─────┼──────────────────────────────────────────────────────────────────────────────────────────┤
> │ 3   │ feat: implementa CRUD de reservas e health check: routes/reservas.js, app.js e server.js │
> ├─────┼──────────────────────────────────────────────────────────────────────────────────────────┤
> │ 4   │ docs: adiciona registro completo de prompts e atualiza spec da T2: prompts-completos.md, │
> │     │  prompts.md e tasks.md                                                                   │
> ├─────┼──────────────────────────────────────────────────────────────────────────────────────────┤
> │ —   │ git merge --no-ff feat/api                                                               │
> └─────┴──────────────────────────────────────────────────────────────────────────────────────────┘
>
> Recomendo esperar o parecer da T2. Se ele existir e tiver outros ajustes, eles entram antes dos commits, e o histórico fica limpo, sem fix:. Quando você mandar o parecer, ou confirmar que não existe, e mandar o prompts-revisora.md, eu fecho a T2.

### R21 — 29/09/2026 19:04

> Os três commits de código da T2 estão feitos:
>
> b22a847 feat: implementa CRUD de reservas e health check
> 36427eb feat: adiciona validação de reservas
> f81cc10 feat: adiciona conexão com PostgreSQL e criação da tabela
>
> O parecer da revisora entrou antes dos commits:
> - pool.on('error'): testado sem ele (o processo morre) e com ele (continua respondendo 200).
> - Ajuste opcional aplicado: o handler agora devolve 413 para corpo acima de 100 kb e 415 para charset inválido, em vez de 500. O 400 continua específico para JSON malformado, e os erros do banco continuam 500.
> - E11 atualizado: "falha de repasse entre painéis, sem erro de conteúdo", com a confirmação da revisora.
> - Parecer no registro: entrou como P20 no prompts-completos.md, literal.
>
> O que falta para fechar a T2: o commit 4 (docs:) e o merge dependem do prompts-revisora.md, que ainda não recebi. Duas observações sobre ele:
> 1. Como mandar: pode colar o conteúdo aqui ou salvar o arquivo em alguma pasta e me passar o caminho. Por exemplo, ~/prova-primeiro-bimestre-devops/specs/prompts-revisora.md, e eu incorporo.
> 2. Numeração: o parecer anterior dizia R01 a R17, e este diz R01 a R20. Confira com a revisora qual é o certo. Imagino que seja R20, porque você mandou mais prompts para ela depois, mas vou usar o que vier no arquivo.
>
> Quando o arquivo chegar, faço o commit docs: adiciona registro completo de prompts e atualiza spec da T2 e o merge --no-ff feat/api, e sigo para a T3 (Dockerfile)

### R22 — 29/09/2026 19:07

> 2 -A T3 está pronta para revisão, na branch feat/docker. Ainda sem commits.
>
> app/Dockerfile, multi-stage:
>
> ┌─────────────────────┬─────────────────────────────────────────────────────────────────────────┐
> │       Estágio       │                                O que faz                                │
> ├─────────────────────┼─────────────────────────────────────────────────────────────────────────┤
> │ deps                │ Copia só o package*.json e roda npm ci --omit=dev. Essa camada fica em  │
> │ (node:22-alpine)    │ cache enquanto as dependências não mudam                                │
> ├─────────────────────┼─────────────────────────────────────────────────────────────────────────┤
> │ runtime             │ Leva só o node_modules de produção e o src/, com --chown=node:node,     │
> │ (node:22-alpine)    │ USER node, EXPOSE 3000, HEALTHCHECK com wget em /health e CMD ["node",  │
> │                     │ "src/server.js"]                                                        │
> └─────────────────────┴─────────────────────────────────────────────────────────────────────────┘
>
> app/.dockerignore: node_modules, .env*, .git, o próprio Dockerfile e *.md.
>
> Resultado, salvo em evidencias/docker-build.txt (116 linhas):
> - Build sem cache: ok.
> - Imagem: technova-reservas:1.0.
> - Execução: o container ligado a um Postgres responde /health com 200, e um POST cria a reserva com 201.
> - Usuário: whoami → node, id → uid 1000, Config.User = node.
> - Healthcheck: docker ps mostra Up (healthy).
> - Senha: mascarada como *** no comando registrado. Conferi, e ela não aparece nenhuma vez no arquivo.
>
> Três pontos para a revisão:
> 1. Tamanho da imagem: o docker image ls mostra 244 MB, e o inspect mostra 62 MB. A diferença vem do image store do Docker 29 (containerd), que conta de forma diferente o espaço em disco descompactado e o conteúdo. Deixo os dois números registrados no relatório, sem tirar conclusão além disso.
> 2. Dono dos arquivos: o --chown=node:node deixa o processo dono do próprio código. É o padrão comum, mas numa versão mais rígida o código fica com dono root, só leitura para o node, e o processo não consegue alterar os próprios arquivos se for comprometido. A API não grava nada em disco, então as duas opções funcionam. Mantenho a do design ou endureço?
> 3. Commits: o tasks.md previa um commit só. Proponho dois, seguindo a regra de manter specs/ separado:
>    - feat: adiciona Dockerfile multi-stage da API: Dockerfile e .dockerignore
>    - docs: adiciona evidência do Docker e atualiza spec da T3: evidencias/docker-build.txt, tasks.md, prompts.md e prompts-completos.md regenerado
>
>    Depois vem o merge --no-ff feat/docker.
>
> Pode levar para a IA-revisora. Para o registro dela ficar completo, lembre de reexportar o prompts-revisora.md quando for fechar a tarefa.

### R23 — 29/09/2026 19:14

> 2 - A T4 está pronta para revisão, na branch feat/compose. Ainda sem commits.
>
> docker-compose.yml:
>
> ┌───────────────────────────────────┬───────────────────────────────────────────────────────────┐
> │             Requisito             │                        Como ficou                         │
> ├───────────────────────────────────┼───────────────────────────────────────────────────────────┤
> │ API + PostgreSQL com um comando   │ docker compose up -d                                      │
> ├───────────────────────────────────┼───────────────────────────────────────────────────────────┤
> │ Volume nomeado                    │ pgdata, e a persistência foi testada (abaixo)             │
> ├───────────────────────────────────┼───────────────────────────────────────────────────────────┤
> │ Rede bridge customizada           │ technova-net, driver: bridge                              │
> ├───────────────────────────────────┼───────────────────────────────────────────────────────────┤
> │ Healthcheck no banco              │ pg_isready, a cada 5 s, até 10 tentativas                 │
> ├───────────────────────────────────┼───────────────────────────────────────────────────────────┤
> │ Healthcheck da API explícito      │ wget em /health                                           │
> │ (R3.2)                            │                                                           │
> ├───────────────────────────────────┼───────────────────────────────────────────────────────────┤
> │ depends_on com condição           │ condition: service_healthy                                │
> ├───────────────────────────────────┼───────────────────────────────────────────────────────────┤
> │ .env.example versionado, .env     │ ✅ O .env local tem uma senha aleatória e não aparece no  │
> │ ignorado                          │ git status                                                │
> └───────────────────────────────────┴───────────────────────────────────────────────────────────┘
>
> Dois pontos a mais:
> - Banco sem porta publicada no host: só a API acessa o Postgres, pela rede interna.
> - Senha obrigatória: com ${POSTGRES_PASSWORD:?}, o Compose recusa subir sem o .env e diz o motivo.
>
> Evidências:
> - compose-ps.txt: os dois serviços (healthy), a rede com driver=bridge e o volume pgdata. Também registra o teste de persistência: criei uma reserva, rodei docker compose down, vi ps -a vazio, subi de novo, e a reserva voltou pela API e pelo psql.
> - curl-local.txt: smoke test com 17 de 17 casos OK.
> - Senha: conferi que o valor do .env não aparece em nenhum arquivo de evidencias/.
>
> scripts/smoke-test.sh: recebe a BASE_URL como argumento, e o mesmo script será usado na AWS. Ele sai com código 1 se qualquer caso falhar. O README ganhou a seção "Como rodar localmente".
>
> Registrei um erro meu (E13): na T2 eu disse que o smoke test cobriria o POST sem Content-Type, e a primeira versão não cobria. O caso já foi incluído. Também corrigi o alinhamento da saída com acentos.
>
> Commits planejados:
> 1. feat: adiciona docker-compose com API e PostgreSQL: docker-compose.yml e .env.example
> 2. chore: adiciona script de smoke test da API: scripts/smoke-test.sh
> 3. docs: adiciona evidências do ambiente local e atualiza spec da T4: evidencias/compose-ps.txt, evidencias/curl-local.txt, README.md e specs/
>
> Depois vem o merge --no-ff feat/compose.
>
> ⚠️ A próxima tarefa, T5, precisa da sua autorização explícita: ela cria o repositório público Sir-Jr/prova-primeiro-bimestre-devops no GitHub e envia tudo (push --all). A partir daí o código fica público. Antes do push vou mostrar o git ls-files para você conferir que não há nada proibido. Na volta com o parecer da T4, diga também se autoriza a T5. Lembre ainda de reexportar o prompts-revisora.md.

### R24 — 29/09/2026 19:22

> eu pedi para a IA executadora salvar na memória o progresso: Salvei o progresso em prova-1bi-progresso.md e atualizei a linha correspondente no índice da memória.
>
> O arquivo é compartilhado com a IA-revisora. Os dois painéis leem a mesma pasta de memória, e ela também tinha escrito nele. Por isso o texto misturava instruções dos dois papéis. Uma linha dela dizia "sou o agente de decisão/revisão, não edito o repo", e numa sessão futura eu poderia ler isso como se fosse sobre mim e parar de executar.
>
> Reorganizei o arquivo sem apagar nada do que ela registrou:
>
> ┌───────────────────┬───────────────────────────────────────────────────────────────────────────┐
> │       Seção       │                                 O que tem                                 │
> ├───────────────────┼───────────────────────────────────────────────────────────────────────────┤
> │ Comum: prazo,     │ PR só em 01/10, link do repositório, decisões de API, regra da ferramenta │
> │ repo, decisões    │  de IA, fluxo de revisão, backend mantido até depois do PR                │
> ├───────────────────┼───────────────────────────────────────────────────────────────────────────┤
> │ Comum: estado das │ Tabela da T0 à T12 com os hashes dos commits. As tarefas T0 a T5 estão    │
> │  tarefas          │ concluídas, a T6 está bloqueada pelas credenciais do Lab e as notas para  │
> │                   │ a T9 estão incluídas                                                      │
> ├───────────────────┼───────────────────────────────────────────────────────────────────────────┤
> │ Reflexão do       │ O seu texto sobre os dois agentes, literal. Acrescentei o complemento que │
> │ usuário           │  você mandou para a revisora no R11, sobre o custo em tokens do modelo    │
> │                   │ dela                                                                      │
> ├───────────────────┼───────────────────────────────────────────────────────────────────────────┤
> │ Para a IA-autora  │ A minha rotina de fechamento de tarefa, como regenerar o registro de      │
> │                   │ prompts e a regra de mascarar senha nas evidências                        │
> ├───────────────────┼───────────────────────────────────────────────────────────────────────────┤
> │ Para a            │ O papel dela (não executa nada, só dá parecer depois de verificar), a     │
> │ IA-revisora       │ convenção do "2", o export de prompts e os erros que ela já reconheceu    │
> └───────────────────┴───────────────────────────────────────────────────────────────────────────┘
>
> Também tirei uma nota que estava desatualizada: "coluna Revisão preenchida só pelo usuário". A prática que você aprovou é eu rascunhar o texto factual e você revisar.
>
> Vale avisar a revisora da reorganização, para ela saber que agora tem uma seção própria. Quando as credenciais do Lab estiverem atualizadas, começo a T6.

### R25 — 29/09/2026 19:26

> notas da outra IA:
> Conferi e está confirmado. As linhas 97 e 98 da sua entrega da Aula 05 registram que o recurso fica tainted e que o contorno foi head-bucket, depois untaint, depois apply -refresh=false -target=…. Apliquei tudo antes de começar a T6:
>
> ┌───────────────────┬───────────────────────────────────────────────────────────────────────────┐
> │       Onde        │                                O que mudou                                │
> ├───────────────────┼───────────────────────────────────────────────────────────────────────────┤
> │ specs/design.md   │ O contorno completo voltou em 5 passos: head-bucket, untaint, apply       │
> │ 5.2               │ -refresh=false -target=…, conferência via aws s3api e destroy com plan    │
> │                   │ -destroy -refresh=false                                                   │
> ├───────────────────┼───────────────────────────────────────────────────────────────────────────┤
> │ specs/tasks.md T6 │ O critério de pronto agora prevê o caso tainted com o untaint             │
> ├───────────────────┼───────────────────────────────────────────────────────────────────────────┤
> │ specs/prompts.md  │ De quem: IA-revisora. Quem detectou: IA-autora. Status: confirmado pela   │
> │ E7                │ IA-revisora, com o parecer das ~18:12 que também não foi repassado, a     │
> │                   │ mesma falha do E11. O untaint foi restaurado                              │
> └───────────────────┴───────────────────────────────────────────────────────────────────────────┘
>
> Criei a branch feat/infra, e essas mudanças estão nela junto com a marcação da T5. Ainda sem commit: elas entram no commit docs: da T6.
>
> Com esta, já são duas falhas de repasse entre os painéis (E7 e E11). Sugiro pedir à revisora que termine cada parecer com uma linha do tipo "Pareceres emitidos desde o último repasse: …". Assim, se algum ficar para trás, ele aparece logo.

### R26 — 29/09/2026 19:41

> 2 - o lab da AWS deu falha por hora, enquanto isso solicitei que a executora adiantasse as próximas etapas: O código da T6 está pronto e validado sem a AWS, na branch feat/infra. Ainda sem commit. Último parecer recebido: V01.
>
> infra/backend/:
>
> ┌─────────────────────┬──────────────────────────────────────────────────────────────────────────┐
> │       Arquivo       │                                 Conteúdo                                 │
> ├─────────────────────┼──────────────────────────────────────────────────────────────────────────┤
> │                     │ Terraform >= 1.5, provider AWS ~> 5.0 (instalou a v5.100.0, a mesma da   │
> │ providers.tf        │ Aula 05) e default_tags: Project, Environment=prova, ManagedBy,          │
> │                     │ Owner=6325269, Purpose                                                   │
> ├─────────────────────┼──────────────────────────────────────────────────────────────────────────┤
> │ variables.tf        │ A região tem uma validation que só aceita us-east-1 (C1). Bucket         │
> │                     │ technova-reservas-tfstate-6325269 e tabela technova-reservas-tf-lock     │
> ├─────────────────────┼──────────────────────────────────────────────────────────────────────────┤
> │ main.tf             │ Bucket S3, versionamento Enabled, SSE AES256, os 4 bloqueios de acesso   │
> │                     │ público e DynamoDB LockID (S) PAY_PER_REQUEST                            │
> ├─────────────────────┼──────────────────────────────────────────────────────────────────────────┤
> │ outputs.tf          │ Nome e ARN do bucket, nome da tabela                                     │
> ├─────────────────────┼──────────────────────────────────────────────────────────────────────────┤
> │ .terraform.lock.hcl │ Versionado, fixa o provider em v5.100.0                                  │
> └─────────────────────┴──────────────────────────────────────────────────────────────────────────┘
>
> Validação: terraform fmt -check ok, init -backend=false ok, validate com Success. O .terraform/ e o terraform.tfstate do backend estão ignorados.
>
> Dois pontos para a revisão:
> 1. Criptografia AES256 (SSE-S3) em vez da aws:kms da Aula 05. Segui o design. As duas protegem o state em repouso, e a SSE-S3 é mais simples porque não depende de permissão em chave KMS dentro do Lab. Se preferir a aws:kms da Aula 05, é uma linha.
> 2. Sem force_destroy no bucket. Com isso, o destroy falha enquanto houver versões do state no bucket, o que protege contra apagar sem querer. O custo é que a limpeza depois do PR exige esvaziar o bucket antes, e isso já está anotado na T11.
>
> O que fica para quando o Lab voltar:
> 1. Atualizar as credenciais com o script e confirmar com aws sts.
> 2. Rodar terraform plan e mostrar para você antes do apply.
> 3. Rodar terraform apply. Se a SCP deixar o bucket tainted, aplico o contorno restaurado no D5.2.
> 4. Conferir via aws s3api e aws dynamodb describe-table.
>
> Commits propostos: o código agora, depois da revisão, como feat: adiciona backend S3 e DynamoDB para remote state. A evidência do apply fica para depois, num docs: com a spec.
>
> Enquanto o Lab estiver fora, também dá para adiantar o código da T7 (os módulos) e da T8 (composição + validate) sem AWS. Só o plan depende do Lab.

### R27 — 29/09/2026 19:47

> 2 - A T7 está pronta para revisão, na branch feat/infra. Ainda sem commit. Último parecer recebido: V02.
>
> infra/modules/: a cópia dos 4 módulos da Aula 06 foi conferida com diff e estava idêntica antes dos ajustes. O diff final contém só estes ajustes:
>
> Módulo: ec2
> Ajuste: Nova variável iam_instance_profile, padrão null
> Motivo: Receber o LabInstanceProfile já existente. O módulo não cria IAM (C3)
> ────────────────────────────────────────
> Módulo: ec2
> Ajuste: key_name passa a ser opcional, padrão null
> Motivo: No Lab o valor é vockey, mas o módulo não obriga
> ────────────────────────────────────────
> Módulo: ec2
> Ajuste: user_data_replace_on_change = true
> Motivo: Fora do design original. O cloud-init só roda no primeiro boot. Sem essa opção, uma correção
> no user_data durante a T9 não teria efeito, porque a instância seria só atualizada, sem rodar o
> script de novo
> ────────────────────────────────────────
> Módulo: rds
> Ajuste: engine_version padrão "16"
> Motivo: A mesma versão do Compose (decisão 4)
> ────────────────────────────────────────
> Módulo: rds
> Ajuste: validation na senha: só letras e números, de 8 a 128 caracteres
> Motivo: Fora do design original, mas o design já dizia "só alfanumérica". Agora uma senha inválida é
> recusada já no plan, e não no meio do apply
>
> Validação: terraform fmt -check ok, validate com Success nos 4 módulos e nenhum aws_iam_* em infra/.
>
> Ajuste no registro de prompts: os comandos que você roda com ! passam a aparecer como "Comando executado pelo usuário no terminal", e as saídas desses comandos saem do registro, porque não são prompts. Ficou P01 a P31.
>
> Dois pontos para a revisão:
> 1. Commits: proponho dois, em vez do único que o tasks.md prevê:
>    - feat: reaproveita módulos vpc, security-group, ec2 e rds da Aula 06, com a cópia sem alteração
>    - feat: adapta módulos ec2 e rds ao Learner Lab, com os 5 ajustes acima
>
>    Assim o histórico mostra o reaproveitamento e a evolução, o que ajuda na Questão 1, onde cada aula aparece na solução.
> 2. Uma sugestão, não aplicada: forçar IMDSv2 na EC2 com metadata_options { http_tokens = "required" }. Isso protege as credenciais do LabInstanceProfile contra ataques de SSRF. A AMI Amazon Linux 2023 já vem com IMDSv2 por padrão, mas deixar explícito no código documenta a decisão. É uma linha. Aplico?
>
> Depois da revisão, sigo para o código da T8: providers.tf com o backend, variables.tf, main.tf, o template do user_data e outputs.tf, validado com init -backend=false.

### R28 — 29/09/2026 19:56

> 2 - O código da T8 está pronto e validado sem a AWS, na branch feat/infra. Ainda sem commit. Último parecer recebido: V03.
>
> Arquivos em infra/:
>
> ┌──────────────────────────────┬─────────────────────────────────────────────────────────────────┐
> │           Arquivo            │                            Conteúdo                             │
> ├──────────────────────────────┼─────────────────────────────────────────────────────────────────┤
> │                              │ backend "s3" com o bucket technova-reservas-tfstate-6325269, a  │
> │ providers.tf                 │ chave prova/terraform.tfstate, encrypt = true e dynamodb_table. │
> │                              │  Também tem as default_tags                                     │
> ├──────────────────────────────┼─────────────────────────────────────────────────────────────────┤
> │                              │ A região só aceita us-east-1. O ssh_allowed_cidr não tem padrão │
> │ variables.tf                 │  e só aceita /32. A db_password é sensitive e sem padrão. O     │
> │                              │ LabInstanceProfile e a chave vockey são padrões. Também estão   │
> │                              │ aqui o repo_url e a branch                                      │
> ├──────────────────────────────┼─────────────────────────────────────────────────────────────────┤
> │                              │ AMI AL2023 buscada por filtro, e a composição vpc → sg_ec2 →    │
> │ main.tf                      │ sg_rds → rds → ec2. O user_data recebe module.rds.db_address,   │
> │                              │ então o RDS é criado antes da EC2                               │
> ├──────────────────────────────┼─────────────────────────────────────────────────────────────────┤
> │                              │ Instala Docker e Git, baixa o CA bundle do RDS, clona o         │
> │ templates/user_data.sh.tftpl │ repositório e faz o build. As variáveis vão para um api.env com │
> │                              │  modo 600, e o container sobe com --env-file. Não usa set -x    │
> ├──────────────────────────────┼─────────────────────────────────────────────────────────────────┤
> │ outputs.tf                   │ ec2_public_ip, rds_endpoint, api_url, health_url, ssh_command   │
> ├──────────────────────────────┼─────────────────────────────────────────────────────────────────┤
> │ terraform.tfvars.example     │ Placeholders para o IP /32 e a senha. O arquivo real fica fora  │
> │                              │ do Git                                                          │
> └──────────────────────────────┴─────────────────────────────────────────────────────────────────┘
>
> Validação sem a AWS: fmt ok, validate com Success e nenhum aws_iam_*. Também renderizei o template e testei as validações (tabela acima).
>
> Registrei um erro meu (E14): o primeiro teste deu falso positivo, porque o bash -n passou num arquivo vazio. Refiz o teste do jeito certo. É um bom exemplo para a Questão 4: um teste que "passa" também precisa ser conferido.
>
> Três pontos para a revisão:
> 1. Uma mudança em relação ao design: a senha vai por --env-file, num arquivo com modo 600, e não por -e DB_PASSWORD= no docker run. Com isso ela sai da lista de processos (ps). Ela ainda aparece no docker inspect, no user_data e no tfstate, que é o trade-off já registrado. Atualizei o design D5.6.
> 2. Aviso esperado no init: no Terraform 1.16, o parâmetro dynamodb_table do backend S3 está deprecated em favor do use_lockfile, e vai aparecer um warning no init. Mantenho o dynamodb_table porque o enunciado exige DynamoDB para o locking. Vale citar na Questão 3.
> 3. Commits propostos:
>    - feat: adiciona composição dos módulos da infraestrutura: os arquivos de infra/, fora o backend e os módulos
>    - docs: atualiza spec das tarefas T5 a T8: specs/, com a T5, o E7, a nota da T11, T7, T8, E14 e o prompts-completos.md regenerado
>
> O que não dá para testar sem o Lab: o user_data na EC2 real e a conexão TLS com o RDS. Isso fica para a T9. O plan passa pela revisora antes do apply, como ela pediu no V02.

### R29 — 29/09/2026 20:00

> 2 - faça um novo export do prompts-revisora.md
