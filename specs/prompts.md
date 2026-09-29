# Registro de Prompts — IA como Copiloto

Resumo analítico dos prompts principais usados na construção da solução, o que a IA gerou e o que foi
revisado, corrigido ou questionado antes de aceitar. Serve de base para a Questão 2 do
`relatorio.md`. O texto literal de todos os prompts está em
[`prompts-completos.md`](prompts-completos.md).

## Processo de trabalho

Revisão cruzada entre duas IAs, com decisão humana em cada etapa:

1. A **IA-autora** produz a entrega da etapa (spec, código, configuração) e para antes do commit.
2. O usuário leva a entrega para a **IA-revisora** (outro agente, em outro painel), que devolve um
   parecer: aprovado, ajustes obrigatórios e pontos de atenção.
3. A IA-autora avalia o parecer **contra os fatos do repositório** (arquivos, `git log`, saídas de
   comando) e aplica os ajustes ou registra uma contestação.
4. O usuário decide cada ponto; só então a etapa é commitada.

Os erros encontrados nesse ciclo, de qualquer uma das partes, ficam na tabela
[Erros e correções](#erros-e-correções).

## Registro de prompts

| # | Tarefa | Prompt (paráfrase · texto literal em [prompts-completos](prompts-completos.md)) | O que a IA gerou | Revisão / correção / questionamento |
|---|--------|-----------------|------------------|-------------------------------------|
| 1 | Planejamento | Leia as regras da prova e o README, crie um plano de ação spec-driven e uma tabela de recomendações por etapa, para eu ler, pesquisar e questionar antes de qualquer execução (P02–P03) | Plano em 11 etapas com recomendação, risco e tópicos de pesquisa por etapa; levantou bloqueios do ambiente (Docker no WSL, credenciais AWS expiradas) e a pegadinha do SSL obrigatório no RDS PostgreSQL 15+ | Perguntei se a prova exige registrar todos os prompts (resposta: só os principais, na Questão 2) → decidi versionar este log. Defini os valores de `status`, a pasta `specs/` e onde citar a ferramenta de IA |
| 2 | Spec — requisitos | Escreva o `specs/requirements.md` a partir do enunciado da prova (P04) | Requisitos R1–R10 com critérios de aceite no formato QUANDO/ENTÃO/DEVE, restrições do Learner Lab (C1–C6) e escopo excluído | Confirmei DELETE 204, id inválido 404, data AAAA-MM-DD e PUT completo; pedi para explicitar no 1.6 que status omitido mantém o atual; anotei para o design validar o `:id` antes do banco e fixar o parser do DATE. |
| 3 | Spec — design | Escreva o `specs/design.md` a partir do `requirements.md` aprovado, reaproveitando os módulos Terraform da Aula 06 e incorporando as notas da revisão (validar `:id` antes do banco; parser do DATE) (P06) | Arquitetura local × AWS, modelo de dados, contrato das rotas, regras de validação, Dockerfile, Compose, estrutura do `infra/`, composição dos módulos, SGs, `user_data`, estratégia de validação, workflow Git e matriz de rastreabilidade | Confirmei as 10 decisões; pedi healthcheck explícito da `api` no Compose (R3.2), proibir `set -x` no `user_data`, registrar que a senha também fica no tfstate, conferir o IP público da EC2 e tirar o `untaint` do contorno da SCP. |
| 4 | Spec — tarefas | Escreva o `specs/tasks.md` a partir do design aprovado: tarefas numeradas, com branch, arquivos, requisitos atendidos, critério de pronto, evidências e commits (P07) | 12 tarefas em 5 fases (fundação, aplicação, containers, infraestrutura, relatório/entrega), com a publicação do repo marcada como dependente de autorização e a entrega travada em 01/10 | Confirmei `.terraform.lock.hcl` versionado, `*.tfvars` ignorado e o volume de commits; decidi manter o backend até depois do PR de 01/10; pedi `push --all` na T5 e Evidências no `entrega.md`; o pedido de commit único da spec foi substituído pela Fase 0 depois da contestação (E6). |
| 5 | T1 — README e .gitignore | Execute a T1: README com nome, RA e descrição, e .gitignore cobrindo os arquivos proibidos pelo enunciado (P11) | `README.md` (descrição, stack, rotas, estrutura, seções de execução a preencher) e `.gitignore` (Node, `.env` com exceção do `.env.example`, Terraform com exceção do `*.tfvars.example`, chaves); padrões conferidos com `git check-ignore` | Aprovei o README e o `.gitignore`; pedi para descrever o fluxo de revisão cruzada numa seção própria ("Processo de trabalho") e citá-lo no README. |
| 6 | T2 — API | Execute a T2 conforme o design D2: conexão com PostgreSQL por variáveis de ambiente, validação, CRUD e /health, e teste contra um Postgres temporário (P15) | `app/src/` (db, validation, routes, app, server), `package.json` com Express 4 e `pg`; 24 casos do contrato testados com `curl` contra `postgres:16-alpine`, mais retry na subida, 500 sem vazar erro do banco e encerramento limpo com SIGTERM; depois, `pool.on('error')` testado derrubando as conexões pelo Postgres (sem ele: processo morre com `Unhandled 'error' event`; com ele: continua respondendo 200); handler de erro passa a devolver 413/415 do parser em vez de 500 | Confirmei `/health` sem `SELECT 1`, o 400 sem `Content-Type` e os commits, com `specs/` num commit `docs:` separado; pedi `pool.on('error')` e, como opcional, manter o status 413/415 do parser no handler de erro. |
| 7 | T3 — Dockerfile | Execute a T3 conforme o design D3: Dockerfile multi-stage com usuário não-root e healthcheck, `.dockerignore` e evidência de build e execução (P21) | `app/Dockerfile` (estágios `deps` e `runtime`, `npm ci --omit=dev`, código com dono `root`, `USER node`, `HEALTHCHECK` com `wget`) e `app/.dockerignore`; `evidencias/docker-build.txt` com build sem cache, camadas, execução ligada a um Postgres, `/health`, POST 201, `whoami` = `node`, arquivos `root:root`, escrita em `/app` negada (`Permission denied`) e status `healthy` (senha mascarada, com aviso no cabeçalho) | Aprovei registrar os dois tamanhos da imagem e os dois commits; pedi para endurecer a imagem tirando o `--chown` (código com dono `root`, o processo `node` só lê) e avisar no cabeçalho da evidência que a senha foi mascarada. |
| 8 | T4 — Compose e smoke test | Execute a T4 conforme o design D4 e D6: `docker-compose.yml` com API e PostgreSQL, `.env.example`, smoke test do contrato e evidências do ambiente local (P22) | `docker-compose.yml` (volume `pgdata`, rede bridge `technova-net`, healthchecks do `db` e da `api`, `depends_on: service_healthy`, banco sem porta no host, senha obrigatória via `${POSTGRES_PASSWORD:?}`), `.env.example`, `scripts/smoke-test.sh` (17 casos, timeouts de 5 s/15 s no `curl`, sai com código 1 se algum falhar), seção "Como rodar localmente" no README; evidências `compose-ps.txt` (inclui teste de persistência com `down`/`up`) e `curl-local.txt` (17/17) | Aprovei o Compose como está e os três commits; pedi timeout no `curl` do smoke test (API fora do ar ou SG errado não pode travar o teste na AWS) e anotei para a T9 um POST que fica gravado, para provar o R7.5. |

## Erros e correções

**Protocolo de registro**

- Erro só é registrado como erro depois de **verificado contra um fato** (saída de comando, arquivo,
  enunciado). Sem verificação, entra como **divergência** até ser resolvida na execução.
- Erros da IA-autora apontados pela IA-revisora ou pelo usuário: registrados pela IA-autora.
- Erros da IA-revisora detectados pela IA-autora: registrados como *contestação* e levados pelo
  usuário à IA-revisora, que confirma ou refuta; o resultado atualiza a linha.
- Erros da IA-revisora detectados pelo usuário ou reconhecidos por ela mesma: o usuário repassa e
  a IA-autora registra.

| # | Tarefa | Erro | De quem | Quem detectou | Como foi verificado | Correção / status |
|---|--------|------|---------|---------------|---------------------|-------------------|
| E1 | Planejamento | Afirmou que o PR da prova precisava ser aberto no mesmo dia (29/09); a data correta é 01/10 | IA-autora | Usuário | Informação do usuário (regra da aula: PR proibido antes de 01/10) | Plano refeito com cronograma 29/09–01/10; T12 travada em 01/10 |
| E2 | Design | Compose sem healthcheck explícito na `api` — R3.2 atendido só pelo `HEALTHCHECK` herdado do Dockerfile, invisível no `docker-compose.yml` | IA-autora | IA-revisora | Leitura do design D4 contra R3.2 | Healthcheck `wget /health` declarado no serviço `api` |
| E3 | Design | Omitiu que `set -x` no `user_data` vazaria a senha no `cloud-init-output.log` e que a senha também fica no tfstate | IA-autora | IA-revisora | Comportamento documentado do bash (`xtrace`) e do Terraform (state em texto) | D5.6: proibido `set -x`; trade-off da senha no tfstate registrado |
| E4 | Design | Não conferiu se as subnets públicas do módulo reaproveitado atribuem IP público à EC2 | IA-autora (omissão) | IA-revisora | `modules/vpc/main.tf` da Aula 06: `map_public_ip_on_launch = each.value.type == "public"` | Sem mudança de código; conferência registrada no D5.3 |
| E5 | Tarefas | Critério da T5 ("`ls-remote` mostra as branches") incompatível com `gh repo create --push`, que envia só a branch atual | IA-autora | IA-revisora | Comportamento do `gh repo create --push` (`git push -u origin HEAD`) | `git push --all origin` acrescentado à T5 |
| E6 | Tarefas | Afirmou que a pasta `specs/` não era commitada em nenhuma tarefa | IA-revisora | IA-autora (contestação) | `git log --stat`: `a4d3392` (requirements) e `aed04ad` (design) já versionados | **Confirmado pela IA-revisora:** leu o repo antes do primeiro commit e não conferiu de novo. Adotada a Fase 0 com um commit por fase da spec |
| E7 | Design | Divergência: a IA-revisora pediu remover `terraform untaint` do plano de contorno da SCP; o histórico da Aula 05 registra que o bucket ficou *tainted* após a falha de leitura | — (divergência) | IA-autora | Pendente — resolver na execução da T6 | `untaint` removido do design; se o bucket ficar *tainted*, registrar aqui |
| E8 | T2 | No teste de encerramento, usou `pkill -f "node src/server.js"`, que casou com a linha de comando do próprio shell de teste e o derrubou (exit 144) | IA-autora | IA-autora | Exit code 144 e saída interrompida logo após o `pkill` | Teste refeito controlando o processo pelo PID (`$!` + `kill -TERM` + `wait`); sem impacto no código da API |
| E9 | Registro de prompts | Registrou os prompts como paráfrases, mas entre aspas, o que sugeria citação literal | IA-autora | IA-autora | Comparação do `prompts.md` com o histórico da sessão, ao atender o pedido do professor (P16) | Aspas removidas, coluna renomeada para "paráfrase" com referência ao `prompts-completos.md`, que traz o texto literal |
| E10 | Planejamento → Tarefas | Tratou o docente como "a professora" (3 vezes nas respostas); o enunciado identifica o professor Alexandre da Costa Tavares Jr. A IA-revisora repetiu o erro no parecer da T3 (P08) | IA-autora (origem) e IA-revisora (propagou) | IA-revisora (reconheceu a própria parte) | `provas/prova-primeiro-bimestre.md`; histórico da sessão mostra a origem nas respostas da IA-autora | Nenhum arquivo do repo afetado; P08 mantido literal |
| E11 | T2 | O parecer do plano de prompts citou como pendente "o ajuste obrigatório da revisão da T2 (`pool.on('error')`)", mas o parecer do código da T2 não havia chegado à IA-autora | — (falha de repasse entre painéis, sem erro de conteúdo de nenhuma das IAs) | IA-autora (contestação) | `grep pool.on` nos 18 prompts recebidos: 0 ocorrências. **A IA-revisora confirmou:** parecer emitido em 29/09 18:52 BRT e não repassado (P20) | Ajustes do parecer aplicados: `pool.on('error')` e handler de erros do cliente (413/415) |
| E12 | T3 | A evidência mostrava `DB_PASSWORD=***` no `docker run` sem avisar que a senha foi mascarada, dando a entender que o comando rodou assim | IA-autora (omissão) | IA-revisora | Leitura do `evidencias/docker-build.txt` | Cabeçalho da evidência passa a declarar o mascaramento |
| E13 | T2 → T4 | Na T2 afirmou que "o smoke test da T4 cobre" o POST sem `Content-Type`, mas a primeira versão do script não tinha esse caso | IA-autora | IA-autora | Conferência do script contra a promessa feita na revisão da T2 (R16) | Caso incluído no `smoke-test.sh` (17/17 OK) |
