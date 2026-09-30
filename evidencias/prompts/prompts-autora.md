# Prompts do usuário para a IA-autora

Todos os prompts enviados pelo usuário à **IA-autora**, em ordem, com o texto **literal**
(inclusive erros de digitação), extraídos do histórico da sessão. Os pareceres da
**IA-revisora** aparecem aqui quando o usuário os colou como prompt para a IA-autora.
Os prompts do usuário para a IA-revisora estão em [`prompts-revisora.md`](prompts-revisora.md);
o resumo analítico por etapa, em [`prompts.md`](prompts.md).

> **Texto literal, inclusive nomes de ferramentas; a ferramenta usada é apresentada no
> [`relatorio.md`](../../relatorio.md).**

Horários em BRT (UTC−3).

### P01 — 29/09/2026 17:29 · Preparação — sincronizar o fork da disciplina

> sincronize esse repo com o meu local, hoje nós vamos fazer a prova

### P02 — 29/09/2026 17:33 · Planejamento

> vamos começar, vamos no baseiar em spec driven, vamos criar um plano de ação e executar as tarefas uma por uma, solicito que você crie uma tabela de recomendações para cada etapa do projeto, para eu ler, pesquisar e questionar antes de qualquer execução. leia as regras da prova, readme.md

### P03 — 29/09/2026 17:36 · Planejamento

> também pede todos os prompts?

### P04 — 29/09/2026 17:39 · Planejamento — decisões

> pode versionar, status ok, specs/, cita a ferramenta só no relatório, e não acrescente coauditoria claude nos commits

### P05 — 29/09/2026 17:42 · Planejamento — data do PR

> PR vai ser feito apenas no dia da aula dia 1/10, quinta feira, é proibido qualquer PR antes desse dia

### P06 — 29/09/2026 17:52 · Spec — requisitos (revisão)

_Parecer da IA-revisora, colado pelo usuário:_

> Revisão da Tarefa 1 (specs/requirements.md): APROVADA com 1 ajuste.
>
> Decisões confirmadas: DELETE 204 sem corpo; id inválido → 404; data AAAA-MM-DD; PUT com campos completos.
>
> Ajuste obrigatório:
> - Reescrever o critério 1.6 para: "QUANDO receber PUT /reservas/:id com cliente e data válidos (status opcional; se omitido, mantém o valor atual) ENTÃO DEVE atualizar no banco e responder 200 com a reserva atualizada."
>
> Anotar para o design.md (não mexer no requirements):
> - Validar que :id é inteiro positivo ANTES de consultar o banco (senão o Postgres dá erro 500 em /reservas/abc).
> - Configurar pg.types.setTypeParser(1082, v => v) para o DATE voltar como string AAAA-MM-DD, sem deslocamento de fuso.
>
> prompts.md linha 2: deixar a coluna Revisão para o usuário preencher.

### P07 — 29/09/2026 17:57 · Spec — design (revisão)

_Parecer da IA-revisora, colado pelo usuário:_

> Revisão da Tarefa 2 (specs/design.md): APROVADA com 1 ajuste.
>
> Decisões 1 a 10: todas confirmadas como estão.
>
> Ajuste obrigatório:
> - Seção 4 (Compose): declarar healthcheck explícito no serviço api,
>   usando wget em http://localhost:3000/health. O enunciado diz que o
>   /health é "usado pelo healthcheck do Compose" (R3.2), e o HEALTHCHECK
>   herdado do Dockerfile não fica visível no docker-compose.yml, que é o
>   arquivo que o avaliador lê.
>
> Pontos de atenção (incluir no design, sem mudar decisões):
> - 5.6 user_data: não usar "set -x", porque ecoaria a senha do banco
>   em /var/log/cloud-init-output.log. Acrescentar ao trade-off da decisão 3
>   que a senha também fica no tfstate (mitigado pelo S3 com SSE e acesso
>   privado).
> - 5.3/5.6: garantir IP público na EC2 (map_public_ip_on_launch = true
>   nas subnets públicas do módulo vpc, ou associate_public_ip_address = true
>   na instância). Conferir no módulo reaproveitado da Aula 06.
> - 5.2: remover a menção a "terraform untaint". Não se aplica a esse erro
>   de leitura. Deixar só: se o refresh do bucket falhar pela SCP, usar
>   -refresh=false e conferir o bucket via aws s3api.
>
> Dependência de ordem: sem objeção técnica a criar o repo público e dar
> push antes do apply. O usuário autoriza quando chegar na infra (o PR na
> disciplina continua só em 01/10).

### P08 — 29/09/2026 18:01 · Spec — tarefas (revisão)

> veja se faz sentido:

_Parecer da IA-revisora, colado pelo usuário:_

> Li o tasks.md e conferi que os ajustes do design entraram. Sobre o Docker: ele já responde no WSL (Docker Engine 29.5.3), então a T2 pode ser testada direto. Sobre o backend na T11, recomendo manter até o PR de quinta e destruir depois. A professora não teria como usar seu bucket de qualquer forma, porque ele está na conta do seu Lab.
>
> Revisão da Tarefa 3 (specs/tasks.md): APROVADA com 3 ajustes.
> Pontos 1, 2 e 4: confirmados (.terraform.lock.hcl versionado; *.tfvars
> ignorado com *.tfvars.example versionado; ~16 commits + 5 merges).
> Ponto 3: manter o backend até depois do PR de 01/10 (se precisar refazer
> alguma evidência, o state está lá); destruir depois da entrega. Registrar
> isso na T11.
> Ajustes obrigatórios:
> 1. T1: a pasta specs/ não é commitada em nenhuma tarefa, mas R9.1 exige
>    o fluxo Spec-Driven versionado. Incluir na T1 um commit separado:
>    "docs: adiciona especificação spec-driven (requisitos, design e tarefas)"
>    com specs/requirements.md, design.md, tasks.md e prompts.md.
> 2. T5: "gh repo create --push" envia só a branch atual. Para o critério
>    "git ls-remote mostra main e as branches", acrescentar
>    "git push --all origin" (ou trocar o critério para: o grafo com os
>    merges --no-ff aparece no main do GitHub).
> 3. T12: o enunciado diz que o PR leva "entrega.md com link do repositório
>    + evidências". Incluir no entrega.md a seção Evidências preenchida
>    (trechos do docker compose ps, terraform plan e smoke test na AWS,
>    ou links diretos para os arquivos em evidencias/ no repo).
> Pré-requisito da T2: Docker já está ativo no WSL, pode testar com o
> Postgres temporário.

### P09 — 29/09/2026 18:04 · Processo de trabalho

> vou explicar o meu fluxo, existe outro painel conectado no projeto, é outro agente, eu mando a sua decisão e recomendações para ele avaliar e mando a resposta dele para você, nessa prova, existem partes para relatar erros que a IA cometem durante a produção?

### P10 — 29/09/2026 18:06 · Processo de trabalho — registro de erros

> pode criar a tabela, use IA-autora e IA-revisora, como fazer para relatar os erros dele comos seus? o seus você relata, e ele?

### P11 — 29/09/2026 18:08 · Spec — tarefas (resposta à contestação E6)

> primeiro dela

_Parecer da IA-revisora, colado pelo usuário:_

> Confirmado, o erro foi meu. Quando li o repo pela primeira vez ainda não havia commits, e não conferi de novo. O git log mostra a4d3392 (requisitos) e aed04ad (design) no main, e o tasks.md está sem commit.
>
> Ajuste 1 da revisão da Tarefa 3: SUBSTITUÍDO.
> Aprovada a proposta: um commit por fase da spec.
> - Fase 0 (retroativa) no tasks.md, marcada [x]: requisitos (a4d3392) e
>   design (aed04ad).
> - Commit desta fase: "docs: adiciona tarefas da spec da API de Reservas"
>   com specs/tasks.md + specs/prompts.md.
> Ajustes 2 e 3 continuam valendo. Pode aplicar e commitar.

### P12 — 29/09/2026 18:14 · Registro de prompts — coluna Revisão

> antes disso,a revisadora me informou sobre isso: Ela fica em specs/prompts.md, na primeira tabela ("Registro de Prompts"). É a última coluna, chamada "Revisão / correção / questionamento" (linha 7 do arquivo). As linhas 10 a 13, que correspondem aos prompts 2 (requisitos), 3 (design), 4 (tarefas) e 5 (T1), ainda estão com "(preencher após a revisão)" nessa coluna.
>
> Cada célula é para uma frase curta sobre o que você revisou ou mudou naquela etapa. Na linha 2 (requisitos), por exemplo: "Confirmei DELETE 204, id inválido 404, data AAAA-MM-DD e PUT completo; pedi para explicitar no 1.6 que status omitido mantém o atual."

### P13 — 29/09/2026 18:15 · Processo de trabalho

> a tomada de decisão em usar dois agentes entre em algum lugar?

### P14 — 29/09/2026 18:17 · T1 — README e .gitignore

> pode mover e ajustar o README, e usar os rascunhos, e eu peço que você me avise quando chegar em etapas de reflexoês minhas.

### P15 — 29/09/2026 18:32 · T1 (commit) → T2 — API; reflexão do usuário

> pode commitar a T1 e seguir para a T2, e aqui está aminha primeira reflexão Decidi usar dois agentes com funções diferentes para gerar questionamentos e ajustes nas tomadas de decisão antes da execução. A IA responsável pela execução cria a tabela de recomendações. A IA revisora lê essa tabela e, só depois de checar o estado atual do projeto, apresenta a sua análise. Eu leio, tiro as dúvidas que tiver e envio a análise para a IA que executa, que a confere com o estado do projeto, contesta se discordar e segue o fluxo de trabalho. A decisão final é sempre minha. Escolhi esse fluxo para facilitar a minha compreensão das decisões por meio dos conceitos técnicos trabalhados.

### P16 — 29/09/2026 18:49 · Registro de prompts completo

> antes de commitar a T2 e fazer o merge, o professor solicitou que deixasse todos os prompts usados aqui em um documento para ele, como você está relatando os nossos avanços?

### P17 — 29/09/2026 18:52 · Registro de prompts completo — decisões

> no repositório, só os prompts, deixa a seção da revisora, vou mande um plano para ela mandar para a revisadora sobre essa decisão.

### P18 — 29/09/2026 18:56 · Registro de prompts completo — opção A (literal) e commit docs: separado

> opção A, pode manter literal o prompts-completos.md pode entrar num commit docs: separado

### P19 — 29/09/2026 18:58 · Registro de prompts completo — revisão do plano; T2 — pool.on('error')

_Parecer da IA-revisora, colado pelo usuário:_

> Revisão do plano "registro completo de prompts": APROVADO com 3 ajustes.
>
> Decisões 1 a 6: confirmadas. E9 de acordo (paráfrase entre aspas
> parecia citação).
> Ponto em aberto (P04): Opção A, manter literal. Um registro "literal"
> editado deixa de ser literal. Acrescentar no topo do arquivo uma nota:
> "texto literal, inclusive nomes de ferramentas; a ferramenta usada é
> apresentada no relatorio.md".
>
> Ajustes obrigatórios:
> 1. Ordem: a T2 NÃO pode ser commitada ainda. O ajuste obrigatório da
>    revisão da T2 (pool.on('error') no src/db.js) não está aplicado;
>    conferido com grep no estado atual. Aplicar e testar antes do commit.
> 2. Commits: não colocar specs/ no commit feat:. Fazer um commit à parte,
>    antes do merge:
>    "docs: adiciona registro completo de prompts e atualiza spec da T2"
>    com prompts-completos.md, prompts.md e tasks.md.
> 3. Script gerador: não versionar no repo da prova. Ele lê o histórico
>    local da sessão (caminho da máquina e da ferramenta). No topo do
>    prompts-completos.md basta dizer "extraído do histórico da sessão".
>
> Seção "Prompts do usuário para a IA-revisora": preencher com o arquivo
> prompts-revisora.md que o usuário vai fornecer (R01–R17, literal, BRT),
> seguindo a mesma regra: só os prompts do usuário.
>
> Erros meus reconhecidos:
> - E10 (IA-revisora): no parecer da T3 (P08) escrevi "A professora não
>   teria como usar seu bucket", mas o enunciado identifica o professor
>   Alexandre da Costa Tavares Jr. Verificado em provas/prova-primeiro-
>   bimestre.md. Sem impacto em código; registrar e manter o P08 literal.

### P20 — 29/09/2026 19:02 · T2 — parecer do código (repassado após a contestação E11)

> resposta da revisora:

_Parecer da IA-revisora, colado pelo usuário:_

> Resposta à contestação E11: o parecer do código da T2 EXISTE.
> Emitido pela IA-revisora em 29/09 18:52 BRT; não foi repassado.
> Registrar no E11: falha de repasse entre painéis, sem erro de conteúdo
> de nenhuma das IAs. Colar no prompts-completos.md como prompt literal.
>
> Conteúdo do parecer (literal), além do pool.on('error') já aplicado:
> - Pontos 1, 2 e 3 confirmados (/health sem SELECT 1; POST sem
>   Content-Type → 400; commits ok, com specs/ em commit docs: separado).
> - Opcional (src/app.js): o handler só trata entity.parse.failed; corpo
>   acima de 100 kb (entity.too.large → 413) cai em 500. Trocar por:
>     if (err.type && err.status && err.status < 500) {
>       return res.status(err.status).json({ erro: 'Requisição inválida' });
>     }
>   mantendo a mensagem específica para JSON malformado.
> - E8 (pkill): de acordo com o registro.
>
> Decisão sobre o opcional: aplicar antes do commit 3 (é pequeno e evita
> um fix: depois). Se o usuário preferir não aplicar, a T2 está aprovada
> do mesmo jeito.
>
> Commits 1 a 4 + merge --no-ff: APROVADOS. Pode fechar a T2 depois de
> substituir a seção da revisora pelo prompts-revisora.md (R01–R20).

### P21 — 29/09/2026 19:05 · T2 — prompts-revisora.md (R01–R21); commit 4 e merge aprovados → T3 — Dockerfile

_Parecer da IA-revisora, colado pelo usuário:_

> prompts-revisora.md: /home/sirla/faculdade/projeto_ale/prompts-revisora.md
> (R01–R21). A numeração cresce a cada mensagem do usuário à revisora;
> R17 e R20 eram as versões corretas quando foram geradas. Usar sempre o
> arquivo mais recente e substituir a seção inteira. Não copiar o arquivo
> para a raiz do repo; só o conteúdo entra em specs/prompts-completos.md.
>
> T2: commits 1–3 conferidos (f81cc10, 36427eb, b22a847), specs/ fora
> deles. Commit 4 (docs:) e merge --no-ff feat/api: aprovados.

### P22 — 29/09/2026 19:08 · T3 — revisão (endurecer a imagem; aviso de senha mascarada) → T4

> resposta da revisora:

_Parecer da IA-revisora, colado pelo usuário:_

> Revisão da T3 (Dockerfile, branch feat/docker): APROVADA com 2 ajustes.
>
> Ponto 1 (tamanho 244 MB × 62 MB): aprovado registrar os dois números
> sem conclusão além da diferença de contagem do image store.
>
> Ponto 2 (dono dos arquivos): ENDURECER.
> - Tirar o --chown=node:node das 3 linhas COPY. O código fica com dono
>   root e modo 644/755 (leitura para o node), e o processo continua
>   rodando como USER node. Se a API for comprometida, ela não consegue
>   reescrever o próprio código. A API não grava em disco, então nada
>   quebra.
> - Atualizar o design (seção 3) com o motivo e refazer a parte de
>   execução da evidência: o "ls -la /app" deve mostrar root:root e
>   o whoami continua node. Bom exemplo de menor privilégio para a
>   Questão 4, junto com os SGs.
>
> Ponto 3 (dois commits, feat: + docs:, depois merge --no-ff): aprovado.
>
> Ajuste de evidência:
> - A linha do docker run mostra DB_PASSWORD=***, mas o arquivo não diz
>   que a senha foi mascarada, e parece que o comando rodou assim.
>   Acrescentar no cabeçalho: "# DB_PASSWORD substituída por *** nesta
>   evidência; a senha real não é registrada."

### P23 — 29/09/2026 19:15 · T4 — revisão (timeout no smoke test; nota para a T9)

> resposta da revisora, veja se faz sentido:

_Parecer da IA-revisora, colado pelo usuário:_

> Revisão da T4 (Compose, branch feat/compose): APROVADA com 1 ajuste.
>
> docker-compose.yml: aprovado como está (volume pgdata, rede bridge,
> healthcheck do db e da api, depends_on service_healthy, banco sem porta
> no host, senha obrigatória com :?). .env ignorado (conferido com
> git check-ignore); senha real ausente de evidencias/, README, specs/,
> scripts/ e .env.example (conferido).
> E13: de acordo.
> Commits 1–3 + merge --no-ff: aprovados.
>
> Ajuste obrigatório (scripts/smoke-test.sh):
> - curl sem timeout. Na AWS, se a EC2 ainda não subiu a API ou o SG
>   estiver errado, cada caso pode travar por minutos. Acrescentar
>   --connect-timeout 5 --max-time 15 no curl da função checa. Falha de
>   conexão já vira status 000 e conta como FALHA.
>
> Anotar para a T9 (não mexer agora):
> - O smoke test apaga a reserva que cria, então no fim o RDS fica vazio.
>   Para provar o R7.5 (dados gravados no RDS), depois do smoke test na
>   AWS fazer um POST que fica gravado + GET /reservas, e registrar em
>   curl-aws.txt.
>
> prompts-revisora.md atualizado: R01–R23, mesmo caminho.

### P24 — 29/09/2026 19:17 · T5 — autorização para publicar o repositório (sem PR)

> pode executar a T5, sem PR

### P25 — 29/09/2026 19:20 · Memória — salvar o progresso

> salve na memória o nosso progresso até aqui

### P26 — 29/09/2026 19:23 · E7 — resolvido (parecer não repassado)

_Parecer da IA-revisora, colado pelo usuário:_

> E7: RESOLVIDO, erro da IA-revisora (parecer de 29/09 ~18:12 BRT, que
> não chegou à IA-autora; mesma falha de repasse do E11).
> - Fato: entregas/aula-05/6325269/entrega.md (l. 97-98) no repo da
>   disciplina. Após a falha de leitura pela SCP o aws_s3_bucket fica
>   tainted; o contorno que funcionou foi head-bucket → terraform untaint
>   → apply -refresh=false -target=(versioning, encryption, public access
>   block); destroy com plan -destroy -refresh=false.
> - Antes de começar a T6: restaurar esse contorno no design 5.2 e no
>   critério de pronto da T6, e atualizar a linha E7 do prompts.md
>   (De quem = IA-revisora; Quem detectou = IA-autora; Status =
>   confirmado, untaint restaurado).
> - Memória compartilhada: já corrigi as duas linhas do E7.

### P27 — 29/09/2026 19:25 · T6 — como atualizar as credenciais do Lab pelo terminal

> como atualizar as credenciais por aqui peo terminal?

### P28 — 29/09/2026 19:34 · T6 — atualização das credenciais (falhou: área de transferência sem o bloco)

_Comando executado pelo usuário no terminal (`!`):_

```
bash /tmp/claude-1000/-home-sirla-faculdade-projeto-ale-devops-20262/4b563b39-3c3a-4e29-aa81-6513226b10d2/scratchpad/atualizar-credenciais-aws.sh
```

### P29 — 29/09/2026 19:36 · T6 — Lab com falha; parecer V01 (controle de repasse)

> O laboratório deu falha, já reportei o problema para o professor, enquanto isso vou enviar a última nota da IA revisora:

_Parecer da IA-revisora, colado pelo usuário:_

> Parecer V01 — 19:27 BRT
>
> E7: correções conferidas no estado atual (design 5.2 l. 221, tasks.md
> T6 l. 98, prompts.md E7). De acordo; entram no commit docs: da T6.
>
> Controle de repasse (a partir deste parecer):
> - Todo parecer da IA-revisora começa com "Parecer Vnn — hh:mm BRT",
>   com numeração contínua.
> - Ao responder, a IA-autora informa o último Vnn que recebeu. Se
>   houver buraco na numeração, o usuário repassa o que faltou.
> - Os pareceres anteriores (sem número) já estão todos conciliados:
>   E7 e E11 resolvidos, nenhum outro pendente.
>
> Pareceres emitidos desde o último confirmado: V01.

### P30 — 29/09/2026 19:39 · T6 — seguir para a T7 depois da revisão

> pode seguir para a T7 depois da revisão

### P31 — 29/09/2026 19:42 · T6 — parecer V02 (backend aprovado) → T7

> resposta da revisora:

_Parecer da IA-revisora, colado pelo usuário:_

> Parecer V02 — 19:43 BRT (último confirmado pela IA-autora: V01)
>
> Revisão da T6 — código do backend (branch feat/infra): APROVADA.
>
> Ponto 1 (AES256 em vez de aws:kms): mantido AES256, como no design.
> Protege em repouso, sem depender de permissão KMS no Lab.
> Ponto 2 (sem force_destroy): aprovado. Anotar na T11 que "aws s3 rm
> --recursive" NÃO basta num bucket versionado: é preciso apagar todas
> as versões e delete markers (aws s3api list-object-versions +
> delete-objects) antes do destroy.
>
> Conferido: região travada em us-east-1 por validation; 4 bloqueios de
> acesso público; DynamoDB LockID (S) PAY_PER_REQUEST; default_tags;
> nenhum recurso IAM; .terraform/ ignorado; lock versionado.
>
> Observação (sem ação agora): o terraform.tfstate do backend é local e
> só existe nesta máquina. Se ele se perder, a limpeza da T11 é manual
> via CLI. Aceitável; citar na Questão 3.
>
> Commit "feat: adiciona backend S3 e DynamoDB para remote state":
> aprovado agora. Evidência do apply em docs: depois, como proposto.
> Adiantar o código da T7 e da T8 sem a AWS: aprovado. O plan e o apply
> esperam o Lab, e o plan passa por mim antes do apply.
>
> Pareceres emitidos desde o último confirmado: V02.

### P32 — 29/09/2026 19:48 · T7 — parecer V03 (módulos aprovados; IMDSv2) → T8

> resposta da revisora:

_Parecer da IA-revisora, colado pelo usuário:_

> Parecer V03 — 19:49 BRT (último confirmado pela IA-autora: V02)
>
> Revisão da T7 — módulos (branch feat/infra): APROVADA com 1 acréscimo.
>
> Conferido por diff contra unifaat-devops-portfolio/aula-06/modules:
> vpc e security-group idênticos; ec2 e rds só com os 5 ajustes
> descritos. RDS mantém storage_encrypted = true, publicly_accessible =
> false, subnet group próprio, senha sensitive; nenhum output expõe senha.
>
> Ajustes 1–5: aprovados, inclusive os 2 fora do design original:
> - user_data_replace_on_change = true: correto (cloud-init só roda no
>   1º boot). Registrar no design 5.6.
> - validation da senha: correta; recusa no plan em vez de no apply.
>   Registrar no design 5.7.
>
> Ponto 1 (dois commits, cópia literal + adaptação): aprovado. Deixa o
> reaproveitamento da Aula 06 visível no histórico.
>
> Ponto 2 (IMDSv2): APLICAR, no módulo ec2:
>   metadata_options {
>     http_tokens   = "required"
>     http_endpoint = "enabled"
>   }
> Protege as credenciais do LabInstanceProfile contra SSRF, fica
> documentado no código e é um bom ponto para a Questão 4. Entra no 2º
> commit ("adapta módulos ec2 e rds ao Learner Lab"). Registrar no
> design 5.6.
>
> Registro de prompts (comandos "!" do usuário marcados como comando,
> saídas fora): de acordo.
>
> Seguir para o código da T8: aprovado.
>
> Pareceres emitidos desde o último confirmado: V03.

### P33 — 29/09/2026 19:57 · T8 — parecer V04 (composição aprovada; filtro da AMI)

> resposta da revisora, com 1 ajuste obrigatório, veja se faz sentido:

_Parecer da IA-revisora, colado pelo usuário:_

> Parecer V04 — 19:58 BRT (último confirmado pela IA-autora: V03)
>
> Revisão da T8 — composição (branch feat/infra): APROVADA com 1 ajuste.
>
> Conferido: backend s3 com encrypt + dynamodb_table; região travada;
> ssh_allowed_cidr sem default e só /32; db_password sensitive sem
> default; composição vpc → sg_ec2 → sg_rds (5432 só do SG da EC2) →
> rds (subnets privadas) → ec2 (db_address no user_data, dependência
> implícita); IMDSv2 no módulo ec2 (e5be53c); nenhum aws_iam_*;
> terraform.tfvars ignorado.
>
> Ajuste obrigatório (main.tf, data "aws_ami"):
> - O filtro "al2023-ami-*-x86_64" também casa com as AMIs
>   "al2023-ami-minimal-*". Com most_recent = true, a EC2 pode subir numa
>   imagem mínima (sem SSM agent e com menos pacotes base), e o
>   resultado muda conforme a data. Trocar por:
>     values = ["al2023-ami-2023.*-x86_64"]
>   e, no plan, conferir o nome da AMI escolhida.
>
> Ponto 1 (senha por --env-file com modo 600): aprovado. O install -m 600
> antes do cat mantém a permissão; com a senha só alfanumérica, o
> heredoc sem aspas é seguro. Trade-off (docker inspect, user_data,
> tfstate) já registrado.
> Ponto 2 (warning do dynamodb_table no Terraform 1.16): manter, porque o
> enunciado exige DynamoDB. Citar na Questão 3 e guardar o warning na
> evidência do init.
> Ponto 3 (commits feat: + docs:): aprovados.
> E14: de acordo.
>
> Para a T9 (sem ação agora): se a API não responder, o primeiro lugar
> para olhar é /var/log/cloud-init-output.log via SSH, porque o set -e
> encerra o user_data sem aviso externo.
>
> Pareceres emitidos desde o último confirmado: V04.

### P34 — 29/09/2026 20:01 · Registro de prompts — export da IA-revisora R01–R29

> prompts-revisora.md atualizado: R01–R29 (29/09, até 20:00 BRT).
> Substituir a seção inteira da revisora no prompts-completos.md.

### P35 — 29/09/2026 20:02 · Backup — push da feat/infra (sem merge, sem PR)

> pode fazer o push da feat/infra como backup

### P36 — 29/09/2026 20:03 · Memória — salvar o progresso

> salve na memória o nosso progresso até aqui.

### P37 — 29/09/2026 20:05 · Encerramento da sessão — conferência do que está salvo

> sessão pronta para ser encerrada? os prompts estão salvos também?

### P38 — 30/09/2026 12:22 · Retomada — onde paramos

> onde paramos?

### P39 — 30/09/2026 12:29 · Reorganização — pasta evidencias/ com specs, prompts e imagens (orientação do professor)

> antes de iniciar a T6, eu tenho uma nova modificação orientada pelo professor, pois nós estamos criando duas specs, uma aqui e outra da IA revisadora, porém o professor mandou a seguinte mensagem após meu questionamento: cria uma pasta de evidência no seu repo e coloca todos os prompts e specs nela. E nessa mesma pasta vamos colocar as evidências de imagens. vamos fazer isso?

### P40 — 30/09/2026 12:37 · Reorganização — spec-revisora.md dos Downloads (idêntico ao do repo)

> C:\Users\sirla\Downloads\spec-revisora.md

### P41 — 30/09/2026 12:40 · Reorganização — parecer V05 (2 ajustes: E16 e nota de texto literal)

> resposta da revisora:

_Parecer da IA-revisora, colado pelo usuário:_

> Parecer V05 — 12:38 BRT 30/09 (último confirmado pela IA-autora: V04)
>
> Revisão da reorganização em evidencias/ (staged, feat/infra):
> APROVADA com 2 ajustes.
>
> Conferido: renames com git mv (specs/ → evidencias/specs/autora e
> evidencias/prompts); README e spec com caminhos novos; AMI filtrada por
> "al2023-ami-2023.*" (fd581b6); senha do .env ausente de todo o staged;
> nenhum link relativo quebrado nos .md, exceto os 2 abaixo. O link para
> ../../relatorio.md só vai funcionar quando a T10 criar o relatorio.md
> (esperado).
>
> Ajuste 1 — spec-revisora.md (erro da IA-revisora, registrar como E16):
> - O export tinha 2 links para /mnt/project-files/..., uma pasta local
>   que não existe no GitHub (links quebrados no repo público).
> - Versão corrigida em /home/sirla/faculdade/projeto_ale/spec-revisora.md:
>   os links viraram texto simples, e o cabeçalho declara essa única
>   alteração e aponta para prompts-revisora.md. Substituir
>   evidencias/specs/revisora/spec-revisora.md por ela.
>
> Ajuste 2 — prompts-revisora.md:
> - O R11 cita literalmente o nome do modelo da IA-revisora, mas este
>   arquivo não tem a nota "texto literal, inclusive nomes de
>   ferramentas; a ferramenta usada é apresentada no relatorio.md" que o
>   prompts-autora.md tem. Acrescentar a mesma nota no topo (decisão P04,
>   opção A, vale para os dois arquivos).
>
> Respostas pela janela de perguntas registradas na coluna Revisão da
> linha #13: de acordo.
> Commit "docs: reorganiza spec, prompts e imagens na pasta evidencias":
> aprovado depois dos 2 ajustes.
>
> Pareceres emitidos desde o último confirmado: V05.

### P42 — 30/09/2026 12:42 · Reorganização — commit e push aprovados

> pode commitar e dar push

### P43 — 30/09/2026 12:51 · T6 — atualização das credenciais do Lab

_Comando executado pelo usuário no terminal (`!`):_

```
bash /home/sirla/faculdade/projeto_ale/.ferramentas-prova/atualizar-credenciais-aws.sh
```

### P44 — 30/09/2026 12:51 · T6 — interrupção antes do plan

> stop

### P45 — 30/09/2026 12:52 · T6 — credenciais do laboratório novo

> só um momento, as credenciais estão válidas, mas eu não atualizei elas com o laboratório novo

### P46 — 30/09/2026 12:53 · T6 — como passar o bloco de credenciais ao script

> copiei o bloco, vou colar ele após o comando?

### P47 — 30/09/2026 12:54 · T6 — atualização das credenciais do Lab (de novo)

_Comando executado pelo usuário no terminal (`!`):_

```
bash /home/sirla/faculdade/projeto_ale/.ferramentas-prova/atualizar-credenciais-aws.sh
```

### P48 — 30/09/2026 12:56 · T6 — confirmação da chave; regra: nada sensível em evidencias/

> começa com ASIA****, pode seguir com a T6, mensagens que mostram partes de credenciais ou dados sensíveis não podem ir para a pasta evidencias!

### P49 — 30/09/2026 12:58 · T6 — apply do backend aprovado

> pode aplicar

### P50 — 30/09/2026 13:03 · T6 — parecer V06 (aprovada; E7 confirmado na execução; backup do state)

> resposta da revisora:

_Parecer da IA-revisora, colado pelo usuário:_

> Parecer V06 — 13:02 BRT 30/09 (último confirmado pela IA-autora: V05)
>
> Revisão da T6 — apply do backend (staged, feat/infra): APROVADA.
>
> Conferido:
> - evidencias/terraform-backend.txt: erro real da SCP (l. 161),
>   untaint (l. 175) e conferências; conta, sessão, org e policy
>   mascaradas, com aviso no cabeçalho.
> - Varredura no staged e em git log -p --all: nenhuma chave ASIA/AKIA,
>   secret, session token ou número de conta de 12 dígitos.
> - Nenhum tfplan versionado (E17 sem consequência no repo); o
>   terraform.tfstate do backend continua ignorado.
> - V05 aplicado: nota de texto literal no prompts-revisora.md;
>   spec-revisora.md sem /mnt/project-files; E16 registrado.
>
> E7: atualizar o status para "confirmado também na execução da T6
> (tainted → untaint → plan -refresh=false com 3 a adicionar, 0 a
> destruir)". O fato fecha a divergência.
>
> Recomendação (fora do repo): copiar infra/backend/terraform.tfstate
> para um backup local fora do repositório. É a única cópia, e sem ela
> a limpeza da T11 vira manual.
>
> Commit "docs: adiciona evidência do backend do remote state e atualiza
> spec da T6": aprovado. Seguir para o init da T8; o plan passa por mim
> antes do apply.
>
> Pareceres emitidos desde o último confirmado: V06.

### P51 — 30/09/2026 13:05 · T6 (commit) → T8 — init e plan; avisar na etapa das evidências do painel da AWS

> pode commitar e dar push

### P52 — 30/09/2026 13:07 · T8 — parecer V07 (plan aprovado) e apply aprovado pelo usuário

> pode seguir com a T8, quando chegar a etapa das evidências do painel da AWS você me avisa.

### P53 — 30/09/2026 13:12 · —

> resposta da revisora:

_Parecer da IA-revisora, colado pelo usuário:_

> Parecer V07 — 13:12 BRT 30/09 (último confirmado pela IA-autora: V06)
>
> Revisão do plan da T8 (evidencias/terraform-plan.txt): APROVADO para
> apply.
>
> Conferido no plan (não no resumo):
> - 19 recursos batem com o design: VPC, IGW, 4 subnets (públicas com
>   map_public_ip_on_launch = true, privadas false), route table + 2
>   associações, 2 SGs + 5 regras, subnet group, RDS, EC2. 0 change,
>   0 destroy.
> - Nenhum aws_iam_*; iam_instance_profile = "LabInstanceProfile".
> - RDS: publicly_accessible = false, storage_encrypted = true, engine 16,
>   db.t3.micro, multi_az false, backup 0, skip_final_snapshot true,
>   deletion_protection false (destroy limpo no fim da T9).
> - 5432: só source_security_group_id, sem cidr_blocks. 22: /32
>   mascarado. 3000: 0.0.0.0/0 (API pública, requisito).
> - EC2: t2.micro, vockey, http_tokens = "required", user_data e senha
>   como (sensitive value), user_data_replace_on_change = true.
> - AMI al2023-ami-2023.12.20260928.0-kernel-6.12-x86_64 (sem minimal).
> - default_tags presentes (Owner 6325269) nos recursos que aceitam tags.
> - terraform.tfvars (modo 600) e infra.tfplan ignorados; IP e senhas
>   ausentes do staged.
>
> Para o apply (T9):
> 1. Aplicar o plano salvo: terraform apply infra.tfplan. Assim o que vai
>    para a AWS é exatamente o que foi revisado. Se ele ficar "stale",
>    refazer o plan e me mostrar o diff.
> 2. Checar antes se as credenciais do Lab têm tempo restante: o RDS
>    leva vários minutos, e um ExpiredToken no meio deixa o apply pela
>    metade.
> 3. Depois do apply: esperar o user_data, rodar o smoke test, fazer o
>    POST que fica gravado + GET (R7.5), describe-db-instances e só
>    então o destroy.
>
> Commit "docs: adiciona evidência do terraform plan": aprovado.
>
> Pareceres emitidos desde o último confirmado: V07.

> Eu como revisador, aprovo o apply.
