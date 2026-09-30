# Spec da IA-revisora — pareceres e decisões

Registro literal das respostas da **IA-revisora** (painel de revisão), em ordem, com horário BRT (UTC−3).
Papel: não executa nada no repositório; só emite parecer depois de verificar o estado atual
(`git log`/`git status`, arquivos reais, histórico das aulas). A partir de 29/09 19:27 os pareceres
são numerados (V01, V02…) para controlar o repasse à IA-autora.

> Texto literal. Única alteração: links para arquivos da pasta local de trabalho viraram texto
> simples (`nome.md`), porque esses caminhos não existem no repositório. Os prompts correspondentes
> estão em [`../../prompts/prompts-revisora.md`](../../prompts/prompts-revisora.md).

### A01 — 29/09/2026 17:47

_Em resposta a:_ “mande o painel de controle para eu conectar na pasta do projeto.”

Já estou conectado na pasta do projeto no seu computador: `/home/sirla/faculdade/projeto_ale/devops_20262`, na branch `main`. A única mudança local no momento é a pasta `entregas/aula-07/6325269/`, que ainda não foi commitada.

Não existe um painel de controle separado para enviar. A conexão já está ativa por este thread. O que você quer fazer nessa pasta?

### A02 — 29/09/2026 17:49

_Em resposta a:_ “faça uma leitura de estudo da prova, e em seguida vou mandar a primeira etapa do meu spec de decisões.”

Li o enunciado (`provas/prova-primeiro-bimestre.md`) e o que já existe no repo da prova. Pode mandar a primeira etapa do spec quando quiser.

**O essencial da prova**
- Entrega: PR só na quinta, 01/10, presencial. É um PR único e imutável, contendo apenas `entregas/provaPrimeiroBi/SEU-RA/entrega.md`.
- Pesos: Terraform + módulos + remote state 25%, Git + Docker 15%, Compose 10%, uso de IA 10% e as 4 questões do relatório 10% cada. O relatório soma 40%, mais que qualquer parte do código.
- Os critérios que mais derrubam nota: o CRUD precisa gravar no PostgreSQL (no Compose e no RDS, nunca em memória), o RDS tem que estar funcional e acessível só pelo SG da EC2, a infra precisa ser modularizada com composição, o remote state precisa de S3 + DynamoDB, e o histórico precisa de no mínimo 6 commits convencionais e um merge de feature branch.

**Pegadinhas do Learner Lab que já conhecemos**
- Nada de IAM próprio, só `LabInstanceProfile`. O plan funciona, mas o apply de IAM é bloqueado.
- O SCP bloqueia a leitura de Object Lock no S3, o que pode quebrar o refresh do bucket do backend. Aconteceu na Aula 05.
- O RDS PostgreSQL 15+ exige SSL, então a API precisa de `ssl` configurável por variável de ambiente.
- A EC2 precisa subir a API sozinha (user_data) apontando para o endpoint do RDS, senão o critério 7.5 não tem como ser provado.

**Estado atual do repo** (`prova-primeiro-bimestre-devops`)
- Ainda não há nenhum commit. Só existem `specs/requirements.md` (R1 a R10, cobrindo o enunciado inteiro) e `specs/prompts.md` (2 entradas, com a revisão da segunda ainda pendente).
- Conferi os requisitos contra o enunciado e não encontrei nenhum item faltando.

### A03 — 29/09/2026 17:50

_Em resposta a:_ “pode confirmar os 4 pontos? A Tarefa 1 está escrita e aguarda sua revisão. Nada foi commitado. Por enquanto existem só a”

Confirmo os quatro pontos, mas dois deles precisam de um ajuste no texto do `requirements.md`.

1. **DELETE 204 sem corpo.** Confirmo. É o padrão REST e o enunciado não pede corpo nessa resposta.
2. **id inválido → 404.** Confirmo. O enunciado só fala em 404, e tratar `abc` como "não existe" é defensável. Tem um detalhe de implementação: a API precisa validar o id antes de ir ao banco, porque o Postgres dá erro 500 ao comparar `'abc'` com uma coluna inteira. Vale deixar isso explícito no design.
3. **Data AAAA-MM-DD.** Confirmo, mas com uma pegadinha para o design. O driver `pg` converte `DATE` em objeto `Date` do JavaScript à meia-noite local, e o JSON pode sair com o dia anterior por causa do fuso horário. A solução é configurar o parser do tipo DATE (OID 1082) para devolver texto puro.
4. **PUT com campos completos.** Confirmo a decisão, mas ela ainda não está escrita no arquivo. O 1.6 diz só "dados válidos". Sugiro mudar para: "QUANDO receber `PUT /reservas/:id` com `cliente` e `data` válidos (`status` opcional, mantém o atual se omitido)...". Sem isso, fica ambíguo se o `status` omitido volta para `pendente`.

Sobre a linha 2 do `prompts.md`: a coluna Revisão é o seu registro do que você questionou, então prefiro não escrever por você. Se ajudar, um resumo fiel do que aconteceu seria algo como: "Revisei as 4 decisões (DELETE 204, id inválido 404, data AAAA-MM-DD, PUT completo); deixei explícito no 1.6 que o PUT exige cliente e data e que status omitido mantém o valor atual."

Quer que eu aplique a mudança no 1.6?

### A04 — 29/09/2026 17:52

_Em resposta a:_ “você é o agente de decisão, o outro recebe seu feedback e ele executa.”

Entendido. Eu reviso e decido, e não mexo no repo. Abaixo está o feedback da Tarefa 1, pronto para você repassar ao executor:

```
Revisão da Tarefa 1 (specs/requirements.md): APROVADA com 1 ajuste.

Decisões confirmadas: DELETE 204 sem corpo; id inválido → 404; data AAAA-MM-DD; PUT com campos completos.

Ajuste obrigatório:
- Reescrever o critério 1.6 para: "QUANDO receber PUT /reservas/:id com cliente e data válidos (status opcional; se omitido, mantém o valor atual) ENTÃO DEVE atualizar no banco e responder 200 com a reserva atualizada."

Anotar para o design.md (não mexer no requirements):
- Validar que :id é inteiro positivo ANTES de consultar o banco (senão o Postgres dá erro 500 em /reservas/abc).
- Configurar pg.types.setTypeParser(1082, v => v) para o DATE voltar como string AAAA-MM-DD, sem deslocamento de fuso.

prompts.md linha 2: deixar a coluna Revisão para o usuário preencher.
```

Quando o executor aplicar, me mande a próxima etapa.

### A05 — 29/09/2026 17:56

_Em resposta a:_ “As duas notas da sua revisão entraram na seção 2:”

Li o `design.md` inteiro. As 10 decisões estão aprovadas. Achei 1 ajuste obrigatório e 3 pontos de atenção, todos no bloco para repassar. Sobre o push: criar o repo e dar push no GitHub pode ser feito antes de quinta, mas essa autorização é sua. A regra de data vale só para o PR no repositório da disciplina.

```
Revisão da Tarefa 2 (specs/design.md): APROVADA com 1 ajuste.

Decisões 1 a 10: todas confirmadas como estão.

Ajuste obrigatório:
- Seção 4 (Compose): declarar healthcheck explícito no serviço api,
  usando wget em http://localhost:3000/health. O enunciado diz que o
  /health é "usado pelo healthcheck do Compose" (R3.2), e o HEALTHCHECK
  herdado do Dockerfile não fica visível no docker-compose.yml, que é o
  arquivo que o avaliador lê.

Pontos de atenção (incluir no design, sem mudar decisões):
- 5.6 user_data: não usar "set -x", porque ecoaria a senha do banco
  em /var/log/cloud-init-output.log. Acrescentar ao trade-off da decisão 3
  que a senha também fica no tfstate (mitigado pelo S3 com SSE e acesso
  privado).
- 5.3/5.6: garantir IP público na EC2 (map_public_ip_on_launch = true
  nas subnets públicas do módulo vpc, ou associate_public_ip_address = true
  na instância). Conferir no módulo reaproveitado da Aula 06.
- 5.2: remover a menção a "terraform untaint". Não se aplica a esse erro
  de leitura. Deixar só: se o refresh do bucket falhar pela SCP, usar
  -refresh=false e conferir o bucket via aws s3api.

Dependência de ordem: sem objeção técnica a criar o repo público e dar
push antes do apply. O usuário autoriza quando chegar na infra (o PR na
disciplina continua só em 01/10).
```

### A06 — 29/09/2026 18:00

_Em resposta a:_ “Tarefa 3 pronta para revisão. O arquivo é specs/tasks.md, e a linha 4 do specs/prompts.md já está registrada. Ainda não ”

Li o `tasks.md` e conferi que os ajustes do design entraram. Sobre o Docker: ele já responde no WSL (Docker Engine 29.5.3), então a T2 pode ser testada direto. Sobre o backend na T11, recomendo manter até o PR de quinta e destruir depois. A professora não teria como usar seu bucket de qualquer forma, porque ele está na conta do seu Lab.

```
Revisão da Tarefa 3 (specs/tasks.md): APROVADA com 3 ajustes.

Pontos 1, 2 e 4: confirmados (.terraform.lock.hcl versionado; *.tfvars
ignorado com *.tfvars.example versionado; ~16 commits + 5 merges).
Ponto 3: manter o backend até depois do PR de 01/10 (se precisar refazer
alguma evidência, o state está lá); destruir depois da entrega. Registrar
isso na T11.

Ajustes obrigatórios:
1. T1: a pasta specs/ não é commitada em nenhuma tarefa, mas R9.1 exige
   o fluxo Spec-Driven versionado. Incluir na T1 um commit separado:
   "docs: adiciona especificação spec-driven (requisitos, design e tarefas)"
   com specs/requirements.md, design.md, tasks.md e prompts.md.
2. T5: "gh repo create --push" envia só a branch atual. Para o critério
   "git ls-remote mostra main e as branches", acrescentar
   "git push --all origin" (ou trocar o critério para: o grafo com os
   merges --no-ff aparece no main do GitHub).
3. T12: o enunciado diz que o PR leva "entrega.md com link do repositório
   + evidências". Incluir no entrega.md a seção Evidências preenchida
   (trechos do docker compose ps, terraform plan e smoke test na AWS,
   ou links diretos para os arquivos em evidencias/ no repo).

Pré-requisito da T2: Docker já está ativo no WSL, pode testar com o
Postgres temporário.
```

As linhas 2, 3 e 4 do `prompts.md` continuam com a coluna Revisão para você preencher.

### A07 — 29/09/2026 18:02

_Em resposta a:_ “Verifiquei os pontos da revisão: quase todos fazem sentido, mas o Ajuste 1 precisa de correção — a spec já está versiona”

Confirmado, o erro foi meu. Quando li o repo pela primeira vez ainda não havia commits, e não conferi de novo. O `git log` mostra a4d3392 (requisitos) e aed04ad (design) no `main`, e o `tasks.md` está sem commit.

```
Ajuste 1 da revisão da Tarefa 3: SUBSTITUÍDO.
Aprovada a proposta: um commit por fase da spec.
- Fase 0 (retroativa) no tasks.md, marcada [x]: requisitos (a4d3392) e
  design (aed04ad).
- Commit desta fase: "docs: adiciona tarefas da spec da API de Reservas"
  com specs/tasks.md + specs/prompts.md.
Ajustes 2 e 3 continuam valendo. Pode aplicar e commitar.
```

### A08 — 29/09/2026 18:09

_Em resposta a:_ “se atualize sobre as novas funções que o agente executor fez”

Estou atualizado. O executor commitou o `tasks.md` (e25d6b7) com os 3 ajustes aplicados: Fase 0 retroativa, `git push --all` na T5 e a seção Evidências no `entrega.md` da T12. A T1 está pronta, mas ainda sem commit: `README.md`, `.gitignore`, a linha 5 do `prompts.md` e os checks da T1 no `tasks.md`. Testei o `.gitignore` com `git check-ignore`. `node_modules`, `.env`, `.terraform/`, `*.tfstate*`, `*.tfvars` e `*.pem` são ignorados, e `.env.example`, `*.tfvars.example` e `.terraform.lock.hcl` continuam versionáveis.

```
Revisão da T1 (README + .gitignore): APROVADA com 1 ajuste de forma.

.gitignore: aprovado como está (conferido com git check-ignore).

README.md, ajuste:
- As linhas Aluno / RA / Disciplina / Avaliação estão em linhas seguidas
  sem quebra, e no GitHub viram um parágrafo só. Terminar cada uma com
  dois espaços (ou usar lista com "-") para o nome e o RA ficarem
  visíveis de cara.

Pode commitar: "chore: adiciona README e .gitignore do projeto".
```

Confirme só uma coisa: "Sirlande Martins" é o seu nome completo como a professora espera? O mesmo nome vai no `entrega.md`, que pede nome completo.

### A09 — 29/09/2026 18:11

_Em resposta a:_ “você viu algo assim: Entendido. Agora sei que os blocos de revisão vêm do outro agente, e registrei isso em memória para”

Não, essa mensagem não chegou até mim. Agora li a tabela "Erros e correções", que já está no `specs/prompts.md`, e conferi o caso 7. Nele o executor tem razão e o erro é meu: o seu registro da Aula 05 (`entregas/aula-05/6325269/entrega.md`, linhas 97 e 98) mostra que o bucket ficou *tainted* e que o `terraform untaint` foi necessário.

```
Parecer sobre "Erros e correções" (specs/prompts.md):

E7: RESOLVIDO, erro da IA-revisora.
- Verificado em entregas/aula-05/6325269/entrega.md (l. 97-98): após a
  falha de leitura pela SCP o aws_s3_bucket fica tainted, e o contorno
  que funcionou foi head-bucket → terraform untaint → apply
  -refresh=false -target=(versioning, encryption, public access block).
- Restaurar no design 5.2 e na T6 esse contorno completo, incluindo
  o destroy com "plan -destroy -refresh=false".
- Linha E7: De quem = IA-revisora; Quem detectou = IA-autora
  (contestação); Como foi verificado = entrega da Aula 05; Status =
  confirmado pela IA-revisora, untaint restaurado.

E6: confirmado como está.
E1 a E5: de acordo.

Decisão 1: aprovado "IA-autora" / "IA-revisora", sem nome de
ferramenta; os nomes ficam só no relatorio.md.
Decisão 2: a tabela já está no arquivo; entra no commit da T1 junto com
a linha 5, ou num commit próprio "docs: registra erros e correções da
IA", à escolha do usuário.
Fase 0: já confirmada na revisão anterior.
```

A decisão sobre quem preenche a coluna "Revisão" é sua. A minha recomendação continua sendo que você preencha, porque é o registro do que você mesmo questionou.

### A10 — 29/09/2026 18:12

_Em resposta a:_ “essa coluna está aonde? A decisão sobre quem preenche a coluna "Revisão" é sua. A minha recomendação continua sendo que ”

Ela fica em `specs/prompts.md`, na primeira tabela ("Registro de Prompts"). É a última coluna, chamada **"Revisão / correção / questionamento"** (linha 7 do arquivo). As linhas 10 a 13, que correspondem aos prompts 2 (requisitos), 3 (design), 4 (tarefas) e 5 (T1), ainda estão com _"(preencher após a revisão)"_ nessa coluna.

Cada célula é para uma frase curta sobre o que você revisou ou mudou naquela etapa. Na linha 2 (requisitos), por exemplo: "Confirmei DELETE 204, id inválido 404, data AAAA-MM-DD e PUT completo; pedi para explicitar no 1.6 que status omitido mantém o atual."

### A11 — 29/09/2026 18:24

_Em resposta a:_ “faz sentido essa minha decisão? A minha decisão sobre usar dois agentes para ações diferentes é causar questionamentos e”

Faz sentido, e o registro de hoje confirma. A revisão pegou 4 falhas reais do executor (E2 a E5). O executor pegou 2 erros meus (E6 e E7). Nos dois sentidos, quem decidiu foi o fato verificado (git log, a entrega da Aula 05), não a opinião de nenhuma das IAs. É exatamente o "uso crítico da IA" que o critério de 10% e a Questão 4 pedem.

Três ressalvas para o modelo funcionar melhor:

- **Os meus dois erros vieram de revisar sem olhar o estado atual.** O E6 aconteceu porque li o repo antes dos commits, e o E7 porque confiei em conhecimento geral em vez do seu histórico. A regra que tiro disso: toda revisão minha começa por `git log`/`git status` e pelos arquivos reais, nunca só pelo resumo que o executor manda.
- **Custo:** a revisão rende mais nos pontos de decisão (spec, design, `plan` antes do `apply`, relatório) do que em cada arquivo pequeno. Tarefas mecânicas, como a T1, podem passar direto e só ser conferidas no commit.
- **Ponto cego comum:** duas IAs podem concordar no mesmo erro. Por isso a sua palavra final e o checklist do `plan` antes do `apply` continuam sendo a última barreira.

O porquê da escolha e o que você achou dela ficam por sua conta no `relatorio.md`.

### A12 — 29/09/2026 18:26

_Em resposta a:_ “mude a sua regra aqui, você não executa, mas só avalia as decisões se verificar o estado atual.”

Regra alterada e salva na memória do projeto:

> **IA-revisora:** não executa nada no repo da prova (não edita, não commita, não roda Docker nem Terraform). Só emite parecer depois de verificar o estado atual (`git log`, `git status`, os arquivos reais e o seu histórico das aulas). Se não conseguir verificar algo, diz isso e não aprova.

Marquei a regra como válida só para o papel de revisor, porque a memória é compartilhada com o executor e ele não pode herdar a restrição.

### A13 — 29/09/2026 18:30

_Em resposta a:_ “melhor? A minha decisão de usar dois agentes para funções diferentes é para gerar questionamentos e ajustes nas tomadas ”

Melhor, sim. O texto está claro e o motivo final ("facilitar a minha compreensão... por meio dos conceitos técnicos") é seu e convence. Tenho dois ajustes de precisão, porque o texto atual não bate com o que aconteceu hoje:

1. **"ela aprova e segue"**: a executora não só aprova. Ela conferiu o parecer contra os fatos e contestou duas vezes (E6 e E7), e nas duas tinha razão. Algo como: "ela confere a análise com o estado do projeto, contesta se discordar, e segue o fluxo".
2. **Quem decide:** fica implícito que é você. Vale dizer isso com todas as letras, porque é o ponto central da Questão 4. Por exemplo: "...e mando para a IA que executa; a decisão final é minha."

Detalhe de redação: "a IA revisadora" normalmente se escreve "a IA revisora".

### A14 — 29/09/2026 18:31

_Em resposta a:_ “corrige esse texto”

Texto corrigido está no rascunho acima, pronto para copiar. Mudei três coisas: "ela aprova e segue" virou "confere com o estado do projeto, contesta se discordar e segue", entrou a frase "A decisão final é sempre minha", e troquei "revisadora" por "revisora". O conteúdo e o motivo continuam seus.

### A15 — 29/09/2026 18:48

_Em resposta a:_ “2 - todas mensagens com o número 2 no começo é para você analisar depois de verificar o estado atual do projeto.”

Combinado, salvei a regra na memória: mensagem que começa com "2" é para eu analisar, e só depois de conferir o estado do repo.

Conferi agora. A T1 foi commitada (be5d986), e o executor já está na branch `feat/api` com a T2 em andamento. Os arquivos de `app/` e as mudanças em `tasks.md` e `prompts.md` ainda não foram commitados. Analiso a T2 quando você mandar a tabela dela com "2".

### A16 — 29/09/2026 18:48

_Em resposta a:_ “2 - A T2 está pronta para revisão, na branch feat/api. Ainda sem commits.”

Li os 7 arquivos de `app/` na branch `feat/api`. O código segue o design, e os 3 pontos estão aprovados. Achei 1 ajuste obrigatório e 1 opcional, no bloco para repassar. Os testes eu não rodei, então valem pelo relato do executor.

```
Revisão da T2 (API, branch feat/api): APROVADA com 1 ajuste.

Pontos 1, 2 e 3: confirmados.
- /health sem SELECT 1: correto (liveness; o Compose já espera o banco
  pelo depends_on service_healthy).
- POST sem Content-Type → 400: correto.
- Commits: ok. Sugestão: tirar as mudanças de specs/ do 3º commit e
  fazer um 4º "docs: atualiza tarefas e registro de prompts da T2",
  para o feat: conter só código.

Ajuste obrigatório (src/db.js):
- Falta pool.on('error', ...). Pela documentação do node-postgres, quando
  um cliente OCIOSO do pool perde a conexão (banco reiniciado, RDS em
  manutenção, docker compose restart db), o Pool emite 'error'; sem
  listener, o Node derruba o processo inteiro. O teste "banco fora do
  ar" deu 500 provavelmente porque não havia cliente ocioso naquele
  momento. Correção:
    pool.on('error', (err) => {
      console.error('Erro em conexão ociosa do pool:', err.message);
    });
  Teste: subir API + banco, fazer 1 GET, reiniciar só o banco dentro
  de 10 s (antes do idle timeout) e confirmar que a API continua viva
  e volta a responder quando o banco volta.

Opcional (src/app.js):
- O handler só trata entity.parse.failed; corpo acima de 100 kb
  (entity.too.large → 413) cai em 500. Trocar por:
    if (err.type && err.status && err.status < 500) {
      return res.status(err.status).json({ erro: 'Requisição inválida' });
    }
  mantendo a mensagem específica para JSON malformado.

E8 (pkill): de acordo com o registro.
```

### A17 — 29/09/2026 18:55

_Em resposta a:_ “Decisão nova antes do commit da T2 — registro completo de prompts”

Conferi o estado atual: a branch `feat/api` ainda não tem commits, o `specs/prompts-completos.md` existe com P01 a P17 e o `app/src/db.js` ainda está sem o `pool.on('error')` da revisão da T2.

Também exportei deste painel os seus 17 prompts para mim, com texto literal e horário BRT: `prompts-revisora.md`. Incluí todos, não só os que começam com "2". O professor pediu todos, e os anteriores (leitura da prova, os 4 pontos, a revisão do texto) também são prompts de decisão. Se quiser só os marcados com "2", são R15 a R17.

```
Revisão do plano "registro completo de prompts": APROVADO com 3 ajustes.

Decisões 1 a 6: confirmadas. E9 de acordo (paráfrase entre aspas
parecia citação).
Ponto em aberto (P04): Opção A, manter literal. Um registro "literal"
editado deixa de ser literal. Acrescentar no topo do arquivo uma nota:
"texto literal, inclusive nomes de ferramentas; a ferramenta usada é
apresentada no relatorio.md".

Ajustes obrigatórios:
1. Ordem: a T2 NÃO pode ser commitada ainda. O ajuste obrigatório da
   revisão da T2 (pool.on('error') no src/db.js) não está aplicado;
   conferido com grep no estado atual. Aplicar e testar antes do commit.
2. Commits: não colocar specs/ no commit feat:. Fazer um commit à parte,
   antes do merge:
   "docs: adiciona registro completo de prompts e atualiza spec da T2"
   com prompts-completos.md, prompts.md e tasks.md.
3. Script gerador: não versionar no repo da prova. Ele lê o histórico
   local da sessão (caminho da máquina e da ferramenta). No topo do
   prompts-completos.md basta dizer "extraído do histórico da sessão".

Seção "Prompts do usuário para a IA-revisora": preencher com o arquivo
prompts-revisora.md que o usuário vai fornecer (R01–R17, literal, BRT),
seguindo a mesma regra: só os prompts do usuário.

Erros meus reconhecidos:
- E10 (IA-revisora): no parecer da T3 (P08) escrevi "A professora não
  teria como usar seu bucket", mas o enunciado identifica o professor
  Alexandre da Costa Tavares Jr. Verificado em provas/prova-primeiro-
  bimestre.md. Sem impacto em código; registrar e manter o P08 literal.
```

### A18 — 29/09/2026 18:56

_Em resposta a:_ “salvou na memória?”

Salvei agora. Parte já estava na memória: meu papel de revisor sem execução, a regra de só dar parecer depois de verificar o estado atual, a convenção do "2" e as decisões da spec. Acabei de acrescentar o que faltava: as decisões do registro completo de prompts (P04 literal, todos os prompts entram e o script fica fora do repo), onde está o export R01 a R17 e os meus erros até aqui (E6, E7 e E10).

### A19 — 29/09/2026 18:58

_Em resposta a:_ “nesse caso, eu vou pedir para você o nosso histórico de prompt aqui, você me envia e eu mando para a IA que executa, ok?”

Ok, combinado. Quando você pedir o histórico, eu gero de novo o arquivo completo, do R01 até a última mensagem, com texto literal e horário BRT, e te mando. A IA que executa só substitui a seção inteira, então não há risco de faltar ou duplicar prompt. A versão atual (R01 a R17) é a que mandei acima. Salvei esse fluxo na memória.

### A20 — 29/09/2026 19:01

_Em resposta a:_ “2 - Todos os ajustes estão aplicados e o pool.on('error') foi testado. Nada foi commitado.”

Conferi no repo: o `pool.on('error')` está no `db.js` (linhas 32 a 34), a nota de texto literal está no topo do `prompts-completos.md`, o E10 e o E11 estão no `prompts.md` e nada foi commitado. O parecer do código da T2 existe: eu mandei neste thread às 18:52 BRT, mas ele não foi repassado. Vai abaixo, junto com o histórico atualizado (R01 a R20): `prompts-revisora.md`.

```
Resposta à contestação E11: o parecer do código da T2 EXISTE.
Emitido pela IA-revisora em 29/09 18:52 BRT; não foi repassado.
Registrar no E11: falha de repasse entre painéis, sem erro de conteúdo
de nenhuma das IAs. Colar no prompts-completos.md como prompt literal.

Conteúdo do parecer (literal), além do pool.on('error') já aplicado:
- Pontos 1, 2 e 3 confirmados (/health sem SELECT 1; POST sem
  Content-Type → 400; commits ok, com specs/ em commit docs: separado).
- Opcional (src/app.js): o handler só trata entity.parse.failed; corpo
  acima de 100 kb (entity.too.large → 413) cai em 500. Trocar por:
    if (err.type && err.status && err.status < 500) {
      return res.status(err.status).json({ erro: 'Requisição inválida' });
    }
  mantendo a mensagem específica para JSON malformado.
- E8 (pkill): de acordo com o registro.

Decisão sobre o opcional: aplicar antes do commit 3 (é pequeno e evita
um fix: depois). Se o usuário preferir não aplicar, a T2 está aprovada
do mesmo jeito.

Commits 1 a 4 + merge --no-ff: APROVADOS. Pode fechar a T2 depois de
substituir a seção da revisora pelo prompts-revisora.md (R01–R20).
```

Recomendo aplicar o opcional, mas a decisão é sua.

### A21 — 29/09/2026 19:04

_Em resposta a:_ “Os três commits de código da T2 estão feitos:”

Salvei o histórico fora do repo da prova, para eu não mexer nele: `/home/sirla/faculdade/projeto_ale/prompts-revisora.md`. A IA que executa lê de lá e incorpora.

Sobre a numeração: as duas versões estavam certas no momento em que foram geradas, porque o arquivo cresce a cada mensagem sua. Agora vai do R01 ao R21, e o R21 é a mensagem que você acabou de mandar. Conferi os 3 commits de código (f81cc10, 36427eb e b22a847). As mudanças de `specs/` estão fora deles, como combinado.

```
prompts-revisora.md: /home/sirla/faculdade/projeto_ale/prompts-revisora.md
(R01–R21). A numeração cresce a cada mensagem do usuário à revisora;
R17 e R20 eram as versões corretas quando foram geradas. Usar sempre o
arquivo mais recente e substituir a seção inteira. Não copiar o arquivo
para a raiz do repo; só o conteúdo entra em specs/prompts-completos.md.

T2: commits 1–3 conferidos (f81cc10, 36427eb, b22a847), specs/ fora
deles. Commit 4 (docs:) e merge --no-ff feat/api: aprovados.
```

### A22 — 29/09/2026 19:08

_Em resposta a:_ “2 -A T3 está pronta para revisão, na branch feat/docker. Ainda sem commits.”

Conferi a `feat/docker`: a T2 foi mergeada com `--no-ff` (3463de5), e o `Dockerfile`, o `.dockerignore` e o `evidencias/docker-build.txt` estão sem commit. A senha não aparece na evidência, só `***`.

```
Revisão da T3 (Dockerfile, branch feat/docker): APROVADA com 2 ajustes.

Ponto 1 (tamanho 244 MB × 62 MB): aprovado registrar os dois números
sem conclusão além da diferença de contagem do image store.

Ponto 2 (dono dos arquivos): ENDURECER.
- Tirar o --chown=node:node das 3 linhas COPY. O código fica com dono
  root e modo 644/755 (leitura para o node), e o processo continua
  rodando como USER node. Se a API for comprometida, ela não consegue
  reescrever o próprio código. A API não grava em disco, então nada
  quebra.
- Atualizar o design (seção 3) com o motivo e refazer a parte de
  execução da evidência: o "ls -la /app" deve mostrar root:root e
  o whoami continua node. Bom exemplo de menor privilégio para a
  Questão 4, junto com os SGs.

Ponto 3 (dois commits, feat: + docs:, depois merge --no-ff): aprovado.

Ajuste de evidência:
- A linha do docker run mostra DB_PASSWORD=***, mas o arquivo não diz
  que a senha foi mascarada, e parece que o comando rodou assim.
  Acrescentar no cabeçalho: "# DB_PASSWORD substituída por *** nesta
  evidência; a senha real não é registrada."
```

### A23 — 29/09/2026 19:14

_Em resposta a:_ “2 - A T4 está pronta para revisão, na branch feat/compose. Ainda sem commits.”

Conferi a `feat/compose`. Os ajustes da T3 entraram (COPY sem `--chown` e a nota de senha mascarada), e a T3 foi mergeada (a403774). O smoke test registrado dá 17/17. Também comparei o valor real da senha do `.env` com todos os arquivos que vão ser commitados, e ela não aparece em nenhum.

Atualizei o histórico no mesmo caminho: `/home/sirla/faculdade/projeto_ale/prompts-revisora.md` (R01 a R23).

```
Revisão da T4 (Compose, branch feat/compose): APROVADA com 1 ajuste.

docker-compose.yml: aprovado como está (volume pgdata, rede bridge,
healthcheck do db e da api, depends_on service_healthy, banco sem porta
no host, senha obrigatória com :?). .env ignorado (conferido com
git check-ignore); senha real ausente de evidencias/, README, specs/,
scripts/ e .env.example (conferido).
E13: de acordo.
Commits 1–3 + merge --no-ff: aprovados.

Ajuste obrigatório (scripts/smoke-test.sh):
- curl sem timeout. Na AWS, se a EC2 ainda não subiu a API ou o SG
  estiver errado, cada caso pode travar por minutos. Acrescentar
  --connect-timeout 5 --max-time 15 no curl da função checa. Falha de
  conexão já vira status 000 e conta como FALHA.

Anotar para a T9 (não mexer agora):
- O smoke test apaga a reserva que cria, então no fim o RDS fica vazio.
  Para provar o R7.5 (dados gravados no RDS), depois do smoke test na
  AWS fazer um POST que fica gravado + GET /reservas, e registrar em
  curl-aws.txt.

prompts-revisora.md atualizado: R01–R23, mesmo caminho.
```

A T5 depende de você: ela torna o código público. Tecnicamente não vejo objeção. O enunciado manda construir no repo público durante a semana, e só o PR na disciplina é travado em 01/10. Recomendo autorizar, mas só depois de ver o `git ls-files` que o executor vai mostrar. Se autorizar, diga isso com suas palavras para ele.

### A24 — 29/09/2026 19:22

_Em resposta a:_ “eu pedi para a IA executadora salvar na memória o progresso: Salvei o progresso em prova-1bi-progresso.md e atualizei a ”

Li a memória reorganizada. A separação por papel está correta, e a minha seção reflete o que combinamos. Também conferi o repo: a T4 foi mergeada (0a4332f), o timeout do curl entrou e o GitHub tem `main` + 3 feature branches.

Achei uma pendência que afeta a T6: o meu parecer sobre o E7 (18:12 BRT) nunca chegou ao executor. No repo, o E7 ainda está como "divergência pendente", e o `untaint` não aparece no design nem no `tasks.md`. Corrigi as duas linhas do E7 na memória e deixo o parecer abaixo para repassar antes da T6:

```
E7: RESOLVIDO, erro da IA-revisora (parecer de 29/09 ~18:12 BRT, que
não chegou à IA-autora; mesma falha de repasse do E11).
- Fato: entregas/aula-05/6325269/entrega.md (l. 97-98) no repo da
  disciplina. Após a falha de leitura pela SCP o aws_s3_bucket fica
  tainted; o contorno que funcionou foi head-bucket → terraform untaint
  → apply -refresh=false -target=(versioning, encryption, public access
  block); destroy com plan -destroy -refresh=false.
- Antes de começar a T6: restaurar esse contorno no design 5.2 e no
  critério de pronto da T6, e atualizar a linha E7 do prompts.md
  (De quem = IA-revisora; Quem detectou = IA-autora; Status =
  confirmado, untaint restaurado).
- Memória compartilhada: já corrigi as duas linhas do E7.
```

Quando as credenciais do Lab estiverem atualizadas, mande a T6 com "2" que eu reviso.

### A25 — 29/09/2026 19:27

_Em resposta a:_ “notas da outra IA:”

Conferi na `feat/infra`: o `untaint` voltou ao design (5.2, linha 221) e ao critério da T6 (linha 98 do `tasks.md`), e o E7 está como erro da IA-revisora. Tudo certo, sem commit, como combinado.

Aceito a sugestão, com um ajuste: eu não sei o que você repassou, só o que eu emiti. Por isso vou numerar os pareceres, e o executor confirma o último número que recebeu. Salvei a regra na memória, na minha seção.

```
Parecer V01 — 19:27 BRT

E7: correções conferidas no estado atual (design 5.2 l. 221, tasks.md
T6 l. 98, prompts.md E7). De acordo; entram no commit docs: da T6.

Controle de repasse (a partir deste parecer):
- Todo parecer da IA-revisora começa com "Parecer Vnn — hh:mm BRT",
  com numeração contínua.
- Ao responder, a IA-autora informa o último Vnn que recebeu. Se
  houver buraco na numeração, o usuário repassa o que faltou.
- Os pareceres anteriores (sem número) já estão todos conciliados:
  E7 e E11 resolvidos, nenhum outro pendente.

Pareceres emitidos desde o último confirmado: V01.
```

### A26 — 29/09/2026 19:42

_Em resposta a:_ “2 - o lab da AWS deu falha por hora, enquanto isso solicitei que a executora adiantasse as próximas etapas: O código da ”

Conferi a `feat/infra`: os 4 `.tf` do `infra/backend/` e o lock com o provider 5.100.0 estão lá, o `.terraform/` está ignorado e nada foi commitado. Aprovado, sem ajuste obrigatório.

```
Parecer V02 — 19:43 BRT (último confirmado pela IA-autora: V01)

Revisão da T6 — código do backend (branch feat/infra): APROVADA.

Ponto 1 (AES256 em vez de aws:kms): mantido AES256, como no design.
Protege em repouso, sem depender de permissão KMS no Lab.
Ponto 2 (sem force_destroy): aprovado. Anotar na T11 que "aws s3 rm
--recursive" NÃO basta num bucket versionado: é preciso apagar todas
as versões e delete markers (aws s3api list-object-versions +
delete-objects) antes do destroy.

Conferido: região travada em us-east-1 por validation; 4 bloqueios de
acesso público; DynamoDB LockID (S) PAY_PER_REQUEST; default_tags;
nenhum recurso IAM; .terraform/ ignorado; lock versionado.

Observação (sem ação agora): o terraform.tfstate do backend é local e
só existe nesta máquina. Se ele se perder, a limpeza da T11 é manual
via CLI. Aceitável; citar na Questão 3.

Commit "feat: adiciona backend S3 e DynamoDB para remote state":
aprovado agora. Evidência do apply em docs: depois, como proposto.
Adiantar o código da T7 e da T8 sem a AWS: aprovado. O plan e o apply
esperam o Lab, e o plan passa por mim antes do apply.

Pareceres emitidos desde o último confirmado: V02.
```

### A27 — 29/09/2026 19:48

_Em resposta a:_ “2 - A T7 está pronta para revisão, na branch feat/infra. Ainda sem commit. Último parecer recebido: V02.”

Fiz um diff dos módulos contra a Aula 06 do seu portfólio (`unifaat-devops-portfolio/aula-06/modules`). As diferenças são exatamente os 5 ajustes descritos, e o backend da T6 já está commitado (6ce7937). Aprovado.

```
Parecer V03 — 19:49 BRT (último confirmado pela IA-autora: V02)

Revisão da T7 — módulos (branch feat/infra): APROVADA com 1 acréscimo.

Conferido por diff contra unifaat-devops-portfolio/aula-06/modules:
vpc e security-group idênticos; ec2 e rds só com os 5 ajustes
descritos. RDS mantém storage_encrypted = true, publicly_accessible =
false, subnet group próprio, senha sensitive; nenhum output expõe senha.

Ajustes 1–5: aprovados, inclusive os 2 fora do design original:
- user_data_replace_on_change = true: correto (cloud-init só roda no
  1º boot). Registrar no design 5.6.
- validation da senha: correta; recusa no plan em vez de no apply.
  Registrar no design 5.7.

Ponto 1 (dois commits, cópia literal + adaptação): aprovado. Deixa o
reaproveitamento da Aula 06 visível no histórico.

Ponto 2 (IMDSv2): APLICAR, no módulo ec2:
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
Protege as credenciais do LabInstanceProfile contra SSRF, fica
documentado no código e é um bom ponto para a Questão 4. Entra no 2º
commit ("adapta módulos ec2 e rds ao Learner Lab"). Registrar no
design 5.6.

Registro de prompts (comandos "!" do usuário marcados como comando,
saídas fora): de acordo.

Seguir para o código da T8: aprovado.

Pareceres emitidos desde o último confirmado: V03.
```

### A28 — 29/09/2026 19:57

_Em resposta a:_ “2 - O código da T8 está pronto e validado sem a AWS, na branch feat/infra. Ainda sem commit. Último parecer recebido: V0”

Li os 7 arquivos da T8 em `infra/`. O IMDSv2 do V03 entrou no módulo ec2 (e5be53c), o `terraform.tfvars` está ignorado e o Terraform local é mesmo o 1.16.0. Aprovado, com 1 ajuste obrigatório.

```
Parecer V04 — 19:58 BRT (último confirmado pela IA-autora: V03)

Revisão da T8 — composição (branch feat/infra): APROVADA com 1 ajuste.

Conferido: backend s3 com encrypt + dynamodb_table; região travada;
ssh_allowed_cidr sem default e só /32; db_password sensitive sem
default; composição vpc → sg_ec2 → sg_rds (5432 só do SG da EC2) →
rds (subnets privadas) → ec2 (db_address no user_data, dependência
implícita); IMDSv2 no módulo ec2 (e5be53c); nenhum aws_iam_*;
terraform.tfvars ignorado.

Ajuste obrigatório (main.tf, data "aws_ami"):
- O filtro "al2023-ami-*-x86_64" também casa com as AMIs
  "al2023-ami-minimal-*". Com most_recent = true, a EC2 pode subir numa
  imagem mínima (sem SSM agent e com menos pacotes base), e o
  resultado muda conforme a data. Trocar por:
    values = ["al2023-ami-2023.*-x86_64"]
  e, no plan, conferir o nome da AMI escolhida.

Ponto 1 (senha por --env-file com modo 600): aprovado. O install -m 600
antes do cat mantém a permissão; com a senha só alfanumérica, o
heredoc sem aspas é seguro. Trade-off (docker inspect, user_data,
tfstate) já registrado.
Ponto 2 (warning do dynamodb_table no Terraform 1.16): manter, porque o
enunciado exige DynamoDB. Citar na Questão 3 e guardar o warning na
evidência do init.
Ponto 3 (commits feat: + docs:): aprovados.
E14: de acordo.

Para a T9 (sem ação agora): se a API não responder, o primeiro lugar
para olhar é /var/log/cloud-init-output.log via SSH, porque o set -e
encerra o user_data sem aviso externo.

Pareceres emitidos desde o último confirmado: V04.
```

### A29 — 29/09/2026 20:00

_Em resposta a:_ “2 - faça um novo export do prompts-revisora.md”

Export atualizado no mesmo caminho: `/home/sirla/faculdade/projeto_ale/prompts-revisora.md`, do R01 ao R29. O R29 é este pedido.

```
prompts-revisora.md atualizado: R01–R29 (29/09, até 20:00 BRT).
Substituir a seção inteira da revisora no prompts-completos.md.
```

### A30 — 30/09/2026 12:31

_Em resposta a:_ “onde está sua spec? exporte seu spec em um arquivo”

Eu não tinha uma spec em arquivo. As minhas decisões estavam só nos pareceres deste thread e na minha seção da memória. Agora exportei tudo em `spec-revisora.md`, com uma cópia local em `/home/sirla/faculdade/projeto_ale/spec-revisora.md`, fora do repo da prova.

O arquivo tem as minhas 29 respostas literais (A01 a A29), com horário BRT e a sua mensagem a que cada uma responde. Os pareceres numerados V01 a V04 estão no fim. No cabeçalho estão o papel e as regras da revisora. Ele complementa o `prompts-revisora.md`: um tem os seus prompts, e este tem as minhas respostas.

### A31 — 30/09/2026 12:39

_Em resposta a:_ “atualização : A reorganização está feita e staged na feat/infra. Ainda não fiz o commit: pelo nosso fluxo, ele espera o ”

Conferi o staged na `feat/infra`. A reorganização está coerente: os `git mv` preservam o histórico, a correção da AMI do V04 entrou (fd581b6) e a senha do `.env` não aparece em nenhum arquivo staged. Achei 2 problemas nos arquivos de registro. Um deles vem do meu próprio export, e já gerei a versão corrigida.

```
Parecer V05 — 12:38 BRT 30/09 (último confirmado pela IA-autora: V04)

Revisão da reorganização em evidencias/ (staged, feat/infra):
APROVADA com 2 ajustes.

Conferido: renames com git mv (specs/ → evidencias/specs/autora e
evidencias/prompts); README e spec com caminhos novos; AMI filtrada por
"al2023-ami-2023.*" (fd581b6); senha do .env ausente de todo o staged;
nenhum link relativo quebrado nos .md, exceto os 2 abaixo. O link para
../../relatorio.md só vai funcionar quando a T10 criar o relatorio.md
(esperado).

Ajuste 1 — spec-revisora.md (erro da IA-revisora, registrar como E16):
- O export tinha 2 links para /mnt/project-files/..., uma pasta local
  que não existe no GitHub (links quebrados no repo público).
- Versão corrigida em /home/sirla/faculdade/projeto_ale/spec-revisora.md:
  os links viraram texto simples, e o cabeçalho declara essa única
  alteração e aponta para prompts-revisora.md. Substituir
  evidencias/specs/revisora/spec-revisora.md por ela.

Ajuste 2 — prompts-revisora.md:
- O R11 cita literalmente o nome do modelo da IA-revisora, mas este
  arquivo não tem a nota "texto literal, inclusive nomes de
  ferramentas; a ferramenta usada é apresentada no relatorio.md" que o
  prompts-autora.md tem. Acrescentar a mesma nota no topo (decisão P04,
  opção A, vale para os dois arquivos).

Respostas pela janela de perguntas registradas na coluna Revisão da
linha #13: de acordo.
Commit "docs: reorganiza spec, prompts e imagens na pasta evidencias":
aprovado depois dos 2 ajustes.

Pareceres emitidos desde o último confirmado: V05.
```

### A32 — 30/09/2026 13:01

_Em resposta a:_ “O backend do remote state está criado na AWS e passou em todas as conferências da T6.”

Conferi o staged: a evidência mostra o erro real da SCP, o `untaint` e as conferências. Não há credencial, ID de conta nem senha no staged nem em todo o histórico do Git. Os ajustes do V05 entraram (d31736f). Pode commitar.

```
Parecer V06 — 13:02 BRT 30/09 (último confirmado pela IA-autora: V05)

Revisão da T6 — apply do backend (staged, feat/infra): APROVADA.

Conferido:
- evidencias/terraform-backend.txt: erro real da SCP (l. 161),
  untaint (l. 175) e conferências; conta, sessão, org e policy
  mascaradas, com aviso no cabeçalho.
- Varredura no staged e em git log -p --all: nenhuma chave ASIA/AKIA,
  secret, session token ou número de conta de 12 dígitos.
- Nenhum tfplan versionado (E17 sem consequência no repo); o
  terraform.tfstate do backend continua ignorado.
- V05 aplicado: nota de texto literal no prompts-revisora.md;
  spec-revisora.md sem /mnt/project-files; E16 registrado.

E7: atualizar o status para "confirmado também na execução da T6
(tainted → untaint → plan -refresh=false com 3 a adicionar, 0 a
destruir)". O fato fecha a divergência.

Recomendação (fora do repo): copiar infra/backend/terraform.tfstate
para um backup local fora do repositório. É a única cópia, e sem ela
a limpeza da T11 vira manual.

Commit "docs: adiciona evidência do backend do remote state e atualiza
spec da T6": aprovado. Seguir para o init da T8; o plan passa por mim
antes do apply.

Pareceres emitidos desde o último confirmado: V06.
```

Sobre as credenciais que você colou no painel do executor: no repo elas ficaram mascaradas, mas continuam no histórico da sessão local dele. Como são temporárias do Lab, expiram sozinhas. Mesmo assim, evite colar essas credenciais em conversa.

### A33 — 30/09/2026 13:11

_Em resposta a:_ “O plan da T8 está pronto e parei antes do apply, para ele passar pela revisora como combinado.”

Li o plan inteiro em `evidencias/terraform-plan.txt` e conferi recurso por recurso. Está correto e seguro para aplicar. A autorização do apply é sua, porque ele cria recursos pagos na conta do Lab.

```
Parecer V07 — 13:12 BRT 30/09 (último confirmado pela IA-autora: V06)

Revisão do plan da T8 (evidencias/terraform-plan.txt): APROVADO para
apply.

Conferido no plan (não no resumo):
- 19 recursos batem com o design: VPC, IGW, 4 subnets (públicas com
  map_public_ip_on_launch = true, privadas false), route table + 2
  associações, 2 SGs + 5 regras, subnet group, RDS, EC2. 0 change,
  0 destroy.
- Nenhum aws_iam_*; iam_instance_profile = "LabInstanceProfile".
- RDS: publicly_accessible = false, storage_encrypted = true, engine 16,
  db.t3.micro, multi_az false, backup 0, skip_final_snapshot true,
  deletion_protection false (destroy limpo no fim da T9).
- 5432: só source_security_group_id, sem cidr_blocks. 22: /32
  mascarado. 3000: 0.0.0.0/0 (API pública, requisito).
- EC2: t2.micro, vockey, http_tokens = "required", user_data e senha
  como (sensitive value), user_data_replace_on_change = true.
- AMI al2023-ami-2023.12.20260928.0-kernel-6.12-x86_64 (sem minimal).
- default_tags presentes (Owner 6325269) nos recursos que aceitam tags.
- terraform.tfvars (modo 600) e infra.tfplan ignorados; IP e senhas
  ausentes do staged.

Para o apply (T9):
1. Aplicar o plano salvo: terraform apply infra.tfplan. Assim o que vai
   para a AWS é exatamente o que foi revisado. Se ele ficar "stale",
   refazer o plan e me mostrar o diff.
2. Checar antes se as credenciais do Lab têm tempo restante: o RDS
   leva vários minutos, e um ExpiredToken no meio deixa o apply pela
   metade.
3. Depois do apply: esperar o user_data, rodar o smoke test, fazer o
   POST que fica gravado + GET (R7.5), describe-db-instances e só
   então o destroy.

Commit "docs: adiciona evidência do terraform plan": aprovado.

Pareceres emitidos desde o último confirmado: V07.
```

### A34 — 30/09/2026 14:20

_Em resposta a:_ “O destroy terminou, e a execução da T9 na AWS acabou.”

Conferi o staged da T9 e abri as 13 capturas uma a uma. Não há dado sensível em nenhuma: o seu IP aparece tarjado no SG da EC2 (07) e o ID da conta tarjado em "Proprietário" (13). Nos `.txt`, a varredura não achou o seu IP, conta de 12 dígitos nem chave. Pode commitar.

```
Parecer V08 — 14:16 BRT 30/09 (último confirmado pela IA-autora: V07)

Revisão da T9 — apply, teste e destroy (staged, feat/infra): APROVADA.

Conferido nos arquivos e nas 13 imagens (abertas uma a uma):
- curl-aws.txt: smoke test 17/17 na EC2 + reserva id 2 gravada e lida
  (prova do R7.5); a imagem 11 mostra o mesmo registro.
- rds-describe.txt: PubliclyAccessible false, StorageEncrypted true;
  imagens 02-04 confirmam db.t3.micro, us-east-1b, sem internet
  gateway, KMS aws/rds.
- SGs: 06 mostra 5432 só a partir do SG da EC2; 07 mostra 22 com o IP
  tarjado /32 e 3000 aberta.
- Remote state: 08-09 mostram o terraform.tfstate em prova/ com 2
  versões; 10 mostra a tabela de lock ativa com LockID (S).
- terraform-destroy.txt: 19 destroyed; backend mantido (decisão T11).
- Dados sensíveis: IP do administrador tarjado (07), conta tarjada em
  "Proprietário" (13); nenhum IP do admin, conta de 12 dígitos ou chave
  nos .txt. O IP da EC2 e os IDs de VPC/SG são de recursos já
  destruídos, e o IP da EC2 é a própria URL da API (evidência exigida).

E18 e exportador ignorando <task-notification>: de acordo.

Commit docs da T9 e merge --no-ff feat/infra no main: aprovados.
Depois do merge, push do main e da feat/infra.

Próxima (T10): relatório. As reflexões das 4 questões vêm do usuário;
a IA-autora monta estrutura e fatos e para para pedir o texto dele.

Pareceres emitidos desde o último confirmado: V08.
```

A próxima tarefa é o relatório, e as reflexões das 4 questões vêm de você. O executor deve parar e pedir o seu texto antes de escrever essa parte.

### A35 — 30/09/2026 14:20

_Em resposta a:_ “O destroy terminou, e a execução da T9 na AWS acabou.”

Essa mensagem é a mesma de antes, e o parecer V08 acima já responde a ela. Conferi de novo: o repo continua igual (último commit dffe2a7, com os mesmos 22 arquivos staged), então o V08 vale como está. Pode repassar e seguir com o commit e o merge.

### A36 — 30/09/2026 15:19

_Em resposta a:_ “O relatório está completo. Encaixei o último texto só com ajustes de redação. Uma mudança de sentido para você conferir:”

Li o `relatorio.md` inteiro e conferi as afirmações contra o repo, porque o avaliador pode checar. Batem: o mapeamento das aulas (Aula 03 IAM, 04 VPC/EC2, 05 RDS + Remote State, 06 Modules), o `describe-images` na evidência do plan, o backup do state do backend (em `.ferramentas-prova/backup-tfstate`), E1–E18, 17/17, 19 recursos e o contorno da SCP. As 4 questões passam de 10 linhas, e a ferramenta está no início. Aprovado, com 2 ajustes de precisão.

Sobre a mudança de sentido: a nova frase amplia um pouco a original. "Inseguro em aceitar" fala do que a IA entrega. "Deixar a IA continuar uma tarefa" fala de autonomia. A decisão é sua. Se quiser ficar mais perto do original: "não me sinto seguro em aceitar o que a IA entrega sem passar por verificação".

```
Parecer V09 — 15:19 BRT 30/09 (último confirmado pela IA-autora: V08)

Revisão da T10 — relatorio.md (staged, docs/relatorio): APROVADA com 2
ajustes de precisão.

Conferido contra o repo: mapeamento das aulas (READMEs das aulas 03-06
no repo da disciplina); describe-images na evidência do plan (l. 636);
backup do state do backend fora do repo; E1–E18; 17/17; 19 recursos;
contorno SCP/untaint; Q1 25, Q2 33, Q3 48, Q4 32 linhas; ferramenta no
início; nenhuma chave, conta, IP ou senha.

Ajustes:
1. l. 67: "numerados de V01 a V08" fica desatualizado a cada parecer.
   Trocar por "numerados a partir de V01" (ou atualizar para o número
   final na T11).
2. l. 177: "o mesmo erro no plano da infraestrutura levaria a senha do
   banco para o repositório" → "poderia levar": o arquivo de plano
   guarda os valores sensíveis em texto, mas o erro não chegou a ser
   commitado. A frase deve dizer o risco, não um fato.

Mudança de sentido na reflexão final: decisão do usuário (alternativa
mais literal sugerida a ele).

Commit "docs: adiciona relatório do processo", merge --no-ff
docs/relatorio e push: aprovados depois dos 2 ajustes e da decisão do
usuário sobre a frase.

Pareceres emitidos desde o último confirmado: V09.
```

### A37 — 30/09/2026 15:28

_Em resposta a:_ “Registrei a opção A para o entrega.md. O campo vai ficar: "Ferramenta de IA utilizada: Claude (Opus 5.5), descrita no re”

Conferi a `docs/revisao-final` e refiz de forma independente as checagens da T11. Tudo bate, e os 2 ajustes do V09 entraram no relatório (e7efbe2). A opção A para o campo do `entrega.md` segue o modelo do enunciado, que pede o nome da ferramenta. Aprovado.

```
Parecer V10 — 15:29 BRT 30/09 (último confirmado pela IA-autora: V09)

Revisão da T11 — revisão final (staged, docs/revisao-final): APROVADA.

Refeito de forma independente:
- main local = origin/main (0310217); repo responde 200 sem login.
- 31 commits, 5 merges --no-ff; todos os assuntos em Conventional
  Commits ou "Merge branch"; nenhum Co-authored-by.
- git ls-files: nenhum .env, *.tfvars, *.tfstate, *.tfplan/tfplan,
  *.pem, node_modules ou .terraform/.
- prompts.md: nenhuma célula "(preencher após a revisão)" restante.
- V09 aplicado: "a partir de V01" (l. 8 da Q2) e "poderia levar"
  (l. 177); frase final escolhida pelo usuário.

Campo "Ferramenta de IA utilizada" no entrega.md (opção A): de acordo;
o modelo do enunciado pede esse campo.

Commit "docs: registra revisão final da entrega", merge --no-ff
docs/revisao-final e push: aprovados.

T12 (só amanhã, 01/10, na aula): o entrega.md passa por mim antes do
PR, porque o PR é imutável. Depois do PR: destruir o backend, esvaziando
todas as versões do bucket antes.

Pareceres emitidos desde o último confirmado: V10.
```
