# Tarefas — API de Reservas da TechNova

> Fase 3 do fluxo Spec-Driven. Uma tarefa por vez: implementar → validar o critério de pronto →
> revisão do usuário → commit/merge → próxima. Referências: requisitos (R/C) e seções do design (D).

## Legenda

- [ ] pendente · [x] concluída
- **Pronto quando:** critério objetivo verificado antes do commit
- Commits em Conventional Commits, sem co-autoria

## Fase 0 — Spec (versionada, um commit por fase do fluxo)

### T0 — Especificação Spec-Driven
- [x] `specs/requirements.md` + `specs/prompts.md` → `docs: adiciona requisitos da spec da API de Reservas` (`a4d3392`)
- [x] `specs/design.md` + `specs/prompts.md` → `docs: adiciona design da spec da API de Reservas` (`aed04ad`)
- [x] `specs/tasks.md` + `specs/prompts.md` → `docs: adiciona tarefas da spec da API de Reservas`
- **Requisitos:** R9.1, R9.2
- **Manutenção:** ao fim de cada tarefa, marcar o checkbox aqui e registrar o prompt em
  `specs/prompts.md`, no mesmo commit da tarefa

## Fase A — Fundação

### T1 — README e .gitignore
- [ ] **Branch:** `main`
- [ ] `README.md`: nome (Sirlande Martins), RA (6325269), descrição da API de Reservas, stack, estrutura
      de pastas e seções "Como rodar local" e "Como provisionar na AWS" (preenchidas nas tarefas seguintes)
- [ ] `.gitignore`: `node_modules/`, `.env`, `.terraform/`, `*.tfstate`, `*.tfstate.*`, `*.tfvars`
      (com exceção `!*.tfvars.example`), `*.pem`, `crash.log`, `.terraform.lock.hcl` **versionado** (não ignorar)
- **Requisitos:** R4.4, R4.5, C4 · **Design:** D7
- **Pronto quando:** `git check-ignore` confirma cada padrão proibido; README tem nome + RA
- **Commit:** `chore: adiciona README e .gitignore do projeto`

## Fase B — Aplicação

### T2 — API de Reservas (CRUD + /health)
- [ ] **Branch:** `feat/api`
- [ ] `app/package.json` (Express 4, `pg`; script `start`) + `package-lock.json`
- [ ] `app/src/db.js`: Pool por variáveis de ambiente, SSL com CA quando `DB_SSL=true`,
      `setTypeParser(1082)`, `initDb()` com `CREATE TABLE IF NOT EXISTS` e retry (10× / 3 s)
- [ ] `app/src/validation.js`: `parseId()` e `validarReserva()`
- [ ] `app/src/routes/reservas.js`: POST, GET, GET/:id, PUT (`COALESCE` no status), DELETE
- [ ] `app/src/app.js`: `express.json()`, `/health`, rotas, 404 genérico, handler de erro (400 JSON malformado, 500 sem vazar detalhes)
- [ ] `app/src/server.js`: `initDb()` → `listen(PORT)`
- **Requisitos:** R1, R2, R3.1 · **Design:** D2
- **Pronto quando:** `npm ci` sem erro; `node --check` em todos os arquivos; API sobe contra um
  Postgres temporário (`docker run postgres:16-alpine`) e responde aos casos do contrato D2.4
- **Commits:** `feat: adiciona conexão com PostgreSQL e criação da tabela`,
  `feat: adiciona validação de reservas`, `feat: implementa CRUD de reservas e health check`
- **Merge:** `git merge --no-ff feat/api`

## Fase C — Containers

### T3 — Dockerfile multi-stage
- [ ] **Branch:** `feat/docker`
- [ ] `app/Dockerfile` (estágios `deps` e `runtime`, `USER node`, `HEALTHCHECK`)
- [ ] `app/.dockerignore`
- **Requisitos:** R5.1, R5.2 · **Design:** D3
- **Pronto quando:** `docker build` ok; `docker run` responde `/health`; `docker exec <c> whoami` = `node`
- **Evidência:** `evidencias/docker-build.txt` (build + run + whoami + tamanho da imagem)
- **Commit:** `feat: adiciona Dockerfile multi-stage da API`
- **Merge:** `git merge --no-ff feat/docker`

### T4 — Docker Compose + smoke test
- [ ] **Branch:** `feat/compose`
- [ ] `docker-compose.yml` (db + api, volume `pgdata`, rede `technova-net`, healthchecks de ambos,
      `depends_on: service_healthy`)
- [ ] `.env.example`
- [ ] `scripts/smoke-test.sh BASE_URL`: health, POST 201, POST 400, GET lista, GET/:id 200,
      GET `/abc` 404, GET id inexistente 404, PUT 200 (status mantido), PUT 400, DELETE 204, GET após DELETE 404
- **Requisitos:** R3.2, R6 · **Design:** D4, D6
- **Pronto quando:** `docker compose up -d` sobe os dois `healthy`; smoke test 100% ok;
  `docker compose down` + `up -d` → reserva criada antes continua lá (volume)
- **Evidências:** `evidencias/compose-ps.txt`, `evidencias/curl-local.txt`
- **Commits:** `feat: adiciona docker-compose com API e PostgreSQL`,
  `chore: adiciona script de smoke test da API`, `docs: adiciona evidências do ambiente local`
- **Merge:** `git merge --no-ff feat/compose`

### T5 — Publicar o repositório no GitHub ⚠️ requer autorização
- [ ] `gh repo create Sir-Jr/prova-primeiro-bimestre-devops --public --source . --push`
      (envia só a branch atual)
- [ ] `git push --all origin` (envia `main` e as feature branches)
- **Requisitos:** R4.1 · **Design:** D5.6 (a EC2 clona o repo)
- **Pronto quando:** repo público acessível sem login; `git ls-remote origin` mostra `main` e as
  feature branches; o grafo com os merges `--no-ff` aparece no `main` do GitHub
- **Verificar antes do push:** `git ls-files` sem `.env`, `*.tfstate`, `*.pem`, `node_modules`

## Fase D — Infraestrutura

### T6 — Backend do remote state
- [ ] **Branch:** `feat/infra`
- [ ] `infra/backend/` (providers, main, variables, outputs): S3 + versioning + SSE + public access block + DynamoDB
- [ ] Pré-requisito: credenciais do Learner Lab atualizadas (`aws sts get-caller-identity` ok)
- **Requisitos:** R8.1, R8.2, C1, C2 · **Design:** D5.2
- **Pronto quando:** `apply` ok (ou contornado com `-refresh=false` se a SCP barrar a leitura);
  `aws s3api get-bucket-versioning` = `Enabled`, `get-bucket-encryption` = `AES256`; tabela `ACTIVE`
- **Commit:** `feat: adiciona backend S3 e DynamoDB para remote state`

### T7 — Módulos (vpc, security-group, ec2, rds)
- [ ] Copiar os módulos da Aula 06 para `infra/modules/`
- [ ] `ec2`: variável `iam_instance_profile` (default `null`) e `key_name` opcional
- [ ] `rds`: `engine_version` padrão `"16"`
- **Requisitos:** R7.1–R7.4, R7.10, C3 · **Design:** D5.1, D5.6, D5.7
- **Pronto quando:** `terraform fmt -check -recursive` ok; nenhum `aws_iam_*` em `infra/`
- **Commit:** `feat: adiciona módulos vpc, security-group, ec2 e rds`

### T8 — Composição, validate e plan
- [ ] `infra/providers.tf` (provider `us-east-1` + `default_tags` + `backend "s3"`)
- [ ] `infra/variables.tf` (com `validation` recusando `0.0.0.0/0` no SSH), `infra/terraform.tfvars.example`
- [ ] `infra/main.tf` (AMI, vpc, sg_ec2, sg_rds, rds, ec2 com `templatefile`)
- [ ] `infra/templates/user_data.sh.tftpl` (sem `set -x`)
- [ ] `infra/outputs.tf` (IP, endpoint, `api_url`, `health_url`, `ssh_command`)
- **Requisitos:** R7.5–R7.9, R8.3 · **Design:** D5.3–D5.9, D6
- **Pronto quando:** `init` usa o backend S3; `validate` ok; `plan` sem erros e aprovado no
  checklist D6 (sem IAM, RDS privado + encriptado, 5432 só do SG, 22 só `/32`)
- **Evidência:** `evidencias/terraform-plan.txt`
- **Commits:** `feat: adiciona composição dos módulos da infraestrutura`,
  `docs: adiciona evidência do terraform plan`

### T9 — Apply, teste na AWS e destroy
- [ ] `terraform apply` → aguardar o `user_data` (~3–5 min após a EC2 subir)
- [ ] `scripts/smoke-test.sh http://<ip>:3000` (CRUD gravando no RDS)
- [ ] `aws rds describe-db-instances` (conferir `PubliclyAccessible=false`, `StorageEncrypted=true`)
- [ ] Conferir o state no S3 (`aws s3 ls`) e o lock no DynamoDB
- [ ] `terraform destroy` → confirmar zero recursos
- [ ] Atualizar o README com o passo a passo da AWS
- **Requisitos:** R7.5, C5 · **Design:** D6
- **Evidências:** `evidencias/terraform-apply.txt`, `evidencias/curl-aws.txt`,
  `evidencias/rds-describe.txt`, `evidencias/terraform-destroy.txt` (outputs sem senha)
- **Commits:** `docs: adiciona evidências da execução na AWS`, `docs: documenta provisionamento no README`
- **Merge:** `git merge --no-ff feat/infra` + push

## Fase E — Relatório e entrega

### T10 — Relatório
- [ ] **Branch:** `docs/relatorio`
- [ ] `relatorio.md`: ferramenta de IA no início; Questões 1–4, dissertativas, ≥ 10 linhas cada
- [ ] Estrutura e fatos técnicos montados a partir das specs, do `prompts.md` e das evidências;
      **reflexões e opiniões fornecidas pelo usuário** (apenas revisão de redação)
- **Requisitos:** R10 · **Design:** D8
- **Pronto quando:** as 4 questões respondidas com a experiência real; revisão do usuário
- **Commit:** `docs: adiciona relatório do processo`
- **Merge:** `git merge --no-ff docs/relatorio` + push

### T11 — Revisão final (30/09)
- [ ] Checklist do `entrega.md` item a item contra o repo publicado
- [ ] `git log --oneline --graph` (≥ 6 commits, merges visíveis)
- [ ] `git ls-files` sem arquivos proibidos; repo público
- [ ] Nenhum recurso ativo no Lab (EC2, RDS, VPC)
- [ ] **Backend (S3/DynamoDB) mantido até depois do PR de 01/10** — se precisar refazer alguma
      evidência, o state está lá. Destruir após a entrega (`infra/backend`: esvaziar o bucket
      versionado, então `terraform destroy`)
- **Pronto quando:** todos os itens do checklist do enunciado marcados com evidência

### T12 — Entrega na disciplina (somente 01/10/2026, quinta, na aula)
- [ ] Sincronizar o `main` do fork `devops_20262` com o upstream
- [ ] Criar a branch e `entregas/provaPrimeiroBi/6325269/entrega.md` (modelo do enunciado; campo
      da ferramenta de IA: "descrita no `relatorio.md`")
- [ ] Seção **Evidências** preenchida: trechos de `docker compose ps`, `terraform plan` (resumo
      `Plan: N to add`) e smoke test na AWS, com links diretos para os arquivos em `evidencias/` do repo
- [ ] Checklist do modelo marcado item a item
- [ ] Commit, push e **um único** PR: `[Prova Primeiro Bimestre] RA: 6325269 - Sirlande Martins`
- [ ] **Nenhum commit após abrir o PR**
- **Proibido executar antes de 01/10/2026**
