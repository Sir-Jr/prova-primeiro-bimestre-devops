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
- **Spec-Driven com IA** — requisitos, design e tarefas em [`specs/`](specs/), com revisão cruzada
  entre dois agentes e decisão humana em cada etapa; registro de prompts e erros em
  [`specs/prompts.md`](specs/prompts.md)

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
├── specs/                  # Spec-Driven: requisitos, design, tarefas e registro de prompts
├── app/                    # API de Reservas (código, Dockerfile, .dockerignore)
├── docker-compose.yml      # API + PostgreSQL (ambiente local)
├── .env.example
├── scripts/                # smoke test das rotas
├── infra/                  # Terraform modularizado + backend do remote state
├── evidencias/             # saídas de build, compose, plan, apply, testes e destroy
└── relatorio.md            # relatório do processo com IA
```

## Como rodar localmente

_Preenchido na tarefa T4 (Docker Compose)._

## Como provisionar na AWS

_Preenchido na tarefa T9 (execução na AWS)._
