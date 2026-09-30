# API de Reservas — TechNova

**Aluno:** Sirlande Martins
**RA:** 6325269
**Disciplina:** DevOps — Análise e Desenvolvimento de Sistemas, UniFAAT 2026.2
**Avaliação:** Prova do Primeiro Bimestre (Aulas 01 a 07)

## Descrição

A **API de Reservas** é uma API REST em Node.js/Express que gerencia as reservas da TechNova
(`id`, `cliente`, `data`, `status`), com CRUD completo gravando em PostgreSQL.

Este repositório entrega a jornada completa da aplicação:

- **Git** — histórico em Conventional Commits, feature branches e merges
- **Docker** — imagem multi-stage rodando com usuário não-root
- **Docker Compose** — API + PostgreSQL subindo com um comando
- **Terraform** — infraestrutura AWS modularizada (VPC, Security Groups, EC2, RDS) com remote
  state em S3 + DynamoDB, no AWS Academy Learner Lab
- **Spec-Driven com IA** — requisitos, design e tarefas em
  [`evidencias/specs/`](evidencias/specs/), com revisão cruzada entre dois agentes e decisão humana
  em cada etapa; registro de prompts e erros em
  [`evidencias/prompts/prompts.md`](evidencias/prompts/prompts.md)

## Stack

| Camada | Tecnologia |
|--------|------------|
| API | Node.js 22 + Express + node-postgres (`pg`) |
| Banco | PostgreSQL 16 (container local / Amazon RDS na nuvem) |
| Containers | Docker, Docker Compose |
| Infraestrutura | Terraform + AWS (`us-east-1`) |

## Rotas

| Método | Rota | Ação |
|--------|------|------|
| `POST` | `/reservas` | Cria uma reserva |
| `GET` | `/reservas` | Lista as reservas |
| `GET` | `/reservas/:id` | Busca uma reserva (404 se não existir) |
| `PUT` | `/reservas/:id` | Atualiza uma reserva |
| `DELETE` | `/reservas/:id` | Remove uma reserva |
| `GET` | `/health` | Health check |

## Estrutura

```
prova-primeiro-bimestre-devops/
├── app/                    # API de Reservas (código, Dockerfile, .dockerignore)
├── docker-compose.yml      # API + PostgreSQL (ambiente local)
├── .env.example
├── scripts/                # smoke test das rotas
├── infra/                  # Terraform modularizado + backend do remote state
├── evidencias/             # saídas de build, compose, plan, apply, testes e destroy
│   ├── specs/              # Spec-Driven: spec da IA-autora e pareceres da IA-revisora
│   ├── prompts/            # registro de prompts (resumo, IA-autora, IA-revisora) e erros
│   └── imagens/            # screenshots
└── relatorio.md            # relatório do processo com IA
```

## Como rodar localmente

Pré-requisitos: Docker com o plugin Compose.

```bash
cp .env.example .env          # troque POSTGRES_PASSWORD por uma senha sua
docker compose up -d --build  # sobe PostgreSQL e API (a API espera o banco ficar healthy)
docker compose ps             # os dois serviços devem aparecer como (healthy)
scripts/smoke-test.sh         # testa o CRUD e os casos de erro em http://localhost:3000
```

- O banco não publica a porta 5432 no host: só a API o acessa, pela rede `technova-net`.
- Os dados ficam no volume nomeado `pgdata` e sobrevivem a `docker compose down`.
  Para apagar tudo, inclusive os dados: `docker compose down -v`.
- Sem o `.env`, o Compose recusa subir e informa que `POSTGRES_PASSWORD` precisa ser definida.

Exemplos:

```bash
curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
  -d '{"cliente":"Ana Souza","data":"2026-10-01"}'
curl http://localhost:3000/reservas
curl -X PUT http://localhost:3000/reservas/1 -H "Content-Type: application/json" \
  -d '{"cliente":"Ana Souza","data":"2026-10-02","status":"confirmada"}'
curl -X DELETE http://localhost:3000/reservas/1
```

Evidências: [`evidencias/docker-build.txt`](evidencias/docker-build.txt),
[`evidencias/compose-ps.txt`](evidencias/compose-ps.txt),
[`evidencias/curl-local.txt`](evidencias/curl-local.txt).

## Como provisionar na AWS

Pré-requisitos: Terraform ≥ 1.5, AWS CLI e as credenciais do AWS Academy Learner Lab em
`~/.aws/credentials` (`aws sts get-caller-identity` deve responder). Região `us-east-1`; nenhum recurso
IAM é criado — a EC2 usa o `LabInstanceProfile` já existente no Lab.

**1. Backend do remote state** (uma vez; state local, fora do Git):

```bash
cd infra/backend
terraform init
terraform apply        # bucket S3 versionado e criptografado + tabela DynamoDB de lock
```

No Learner Lab, a SCP da conta nega `s3:GetBucketObjectLockConfiguration`: o bucket é criado, mas a
leitura logo depois falha e o recurso fica *tainted*. Contorno (o bucket está bom, só a leitura falhou):

```bash
aws s3api head-bucket --bucket technova-reservas-tfstate-6325269
terraform untaint aws_s3_bucket.state
terraform apply -refresh=false \
  -target=aws_s3_bucket_versioning.state \
  -target=aws_s3_bucket_server_side_encryption_configuration.state \
  -target=aws_s3_bucket_public_access_block.state
```

**2. Infraestrutura da API** (VPC, Security Groups, RDS PostgreSQL privado e EC2):

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars   # seu IP /32 e a senha do RDS (só letras e números)
chmod 600 terraform.tfvars
terraform init                                 # usa o backend S3 + DynamoDB do passo 1
terraform plan -out=infra.tfplan               # revise antes de aplicar
terraform apply infra.tfplan                   # ~6 min (o RDS é o mais demorado)
terraform output                               # api_url, health_url, rds_endpoint, ssh_command
```

A EC2 clona este repositório, constrói a imagem da API e sobe o container apontando para o RDS
(`user_data`); a API responde uns 2 a 5 minutos depois do `apply`. Teste:

```bash
scripts/smoke-test.sh "$(terraform -chdir=infra output -raw api_url)"
```

Se a API não responder: `ssh -i labsuser.pem ec2-user@<ip>` e `sudo cat /var/log/cloud-init-output.log`.

**3. Destruir** (depois de capturar as evidências — os recursos consomem créditos do Lab):

```bash
cd infra && terraform destroy
```

O backend fica por último: esvazie o bucket, inclusive as versões antigas do state, e só então rode
`terraform destroy` em `infra/backend`.

Evidências: [`evidencias/terraform-backend.txt`](evidencias/terraform-backend.txt),
[`evidencias/terraform-plan.txt`](evidencias/terraform-plan.txt),
[`evidencias/terraform-apply.txt`](evidencias/terraform-apply.txt),
[`evidencias/curl-aws.txt`](evidencias/curl-aws.txt),
[`evidencias/rds-describe.txt`](evidencias/rds-describe.txt),
[`evidencias/terraform-destroy.txt`](evidencias/terraform-destroy.txt) e as capturas do console em
[`evidencias/imagens/`](evidencias/imagens/).
