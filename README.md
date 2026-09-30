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

_Preenchido na tarefa T9 (execução na AWS)._
