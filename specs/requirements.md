# Requisitos — API de Reservas da TechNova

> Fase 1 do fluxo Spec-Driven (requisitos → design → tarefas).
> Fonte: `provas/prova-primeiro-bimestre.md` (Prova do 1º Bimestre — DevOps, Aulas 01 a 07).
> Formato dos critérios de aceite: **QUANDO** [evento] **ENTÃO** o sistema **DEVE** [resposta].

## Contexto

A TechNova precisa entregar um ambiente completo e reproduzível da **API de Reservas**: código
versionado, aplicação containerizada, ambiente local subindo com um comando e infraestrutura na
AWS modularizada com state remoto, tudo no AWS Academy Learner Lab.

## Restrições gerais

| ID | Restrição |
|----|-----------|
| C1 | Região AWS sempre `us-east-1` |
| C2 | Credenciais temporárias do Learner Lab (com Session Token) |
| C3 | Proibido criar IAM users/groups/roles — usar `LabRole` / `LabInstanceProfile` |
| C4 | Nunca versionar `*.tfstate`, `.terraform/`, `.env`, `*.pem`, `node_modules/` |
| C5 | `terraform destroy` após capturar as evidências |
| C6 | Repositório público `prova-primeiro-bimestre-devops`, na estrutura de pastas do enunciado |

---

## R1 — API: CRUD de reservas

**História:** Como atendente da TechNova, quero criar, consultar, alterar e remover reservas para
gerenciar os agendamentos dos clientes.

Recurso `reserva`: `id` (gerado pelo banco), `cliente` (texto, obrigatório), `data` (data,
obrigatória, formato `AAAA-MM-DD`), `status` (`pendente` | `confirmada` | `cancelada`, padrão
`pendente`).

| # | Critério de aceite |
|---|--------------------|
| 1.1 | QUANDO receber `POST /reservas` com `cliente` e `data` válidos ENTÃO DEVE gravar no banco e responder `201` com a reserva criada (incluindo `id`) |
| 1.2 | QUANDO `POST /reservas` vier sem `cliente` ou sem `data`, com `data` inválida ou `status` fora dos valores permitidos ENTÃO DEVE responder `400` com mensagem de erro, sem gravar |
| 1.3 | QUANDO receber `GET /reservas` ENTÃO DEVE responder `200` com a lista de todas as reservas do banco |
| 1.4 | QUANDO receber `GET /reservas/:id` de reserva existente ENTÃO DEVE responder `200` com a reserva |
| 1.5 | QUANDO receber `GET`, `PUT` ou `DELETE /reservas/:id` de reserva inexistente (ou `id` não numérico) ENTÃO DEVE responder `404` |
| 1.6 | QUANDO receber `PUT /reservas/:id` com `cliente` e `data` válidos (`status` opcional; se omitido, mantém o valor atual) ENTÃO DEVE atualizar no banco e responder `200` com a reserva atualizada |
| 1.7 | QUANDO `PUT /reservas/:id` vier com dados inválidos ENTÃO DEVE responder `400`, sem alterar |
| 1.8 | QUANDO receber `DELETE /reservas/:id` de reserva existente ENTÃO DEVE removê-la do banco e responder `204` |

## R2 — Persistência em PostgreSQL

| # | Critério de aceite |
|---|--------------------|
| 2.1 | Todas as rotas de R1 DEVEM ler e gravar no PostgreSQL — nunca em memória |
| 2.2 | QUANDO a API iniciar ENTÃO DEVE garantir que a tabela `reservas` exista |
| 2.3 | A conexão DEVE ser configurada só por variáveis de ambiente (host, porta, usuário, senha, banco, SSL) — nenhuma credencial no código |
| 2.4 | QUANDO rodar na AWS ENTÃO DEVE conectar ao RDS usando SSL |
| 2.5 | As consultas DEVEM ser parametrizadas (sem concatenar entrada do usuário em SQL) |

## R3 — Health check

| # | Critério de aceite |
|---|--------------------|
| 3.1 | QUANDO receber `GET /health` ENTÃO DEVE responder `200` |
| 3.2 | O endpoint DEVE ser usado pelo healthcheck do container da API no Compose |

## R4 — Git e versionamento (Aula 01)

| # | Critério de aceite |
|---|--------------------|
| 4.1 | O repositório DEVE ser público no GitHub com o nome `prova-primeiro-bimestre-devops` |
| 4.2 | O histórico DEVE ter no mínimo 6 commits em Conventional Commits (`feat:`, `docs:`, `fix:`, `chore:`) |
| 4.3 | DEVE haver uso de feature branch + merge visível no histórico |
| 4.4 | DEVE existir `README.md` na raiz com nome, RA e descrição do projeto |
| 4.5 | DEVE existir `.gitignore` cobrindo `node_modules`, `.env`, `.terraform`, `*.tfstate`, `*.pem` |

## R5 — Docker (Aula 01)

| # | Critério de aceite |
|---|--------------------|
| 5.1 | DEVE existir `app/Dockerfile` funcional, multi-stage, rodando com usuário não-root |
| 5.2 | DEVE existir `app/.dockerignore` |
| 5.3 | DEVE haver evidência de build e execução do container em `evidencias/` |

## R6 — Docker Compose (Aula 02)

| # | Critério de aceite |
|---|--------------------|
| 6.1 | QUANDO executar `docker compose up -d` ENTÃO DEVEM subir a API e o PostgreSQL (um único comando) |
| 6.2 | O banco DEVE usar volume nomeado para persistência |
| 6.3 | Os serviços DEVEM estar numa rede bridge customizada |
| 6.4 | O banco DEVE ter healthcheck e a API DEVE usar `depends_on` com `condition: service_healthy` |
| 6.5 | DEVE existir `.env.example` versionado (sem senhas reais) e `.env` DEVE estar no `.gitignore` |
| 6.6 | DEVE haver evidência `docker compose ps` em `evidencias/` |

## R7 — Infraestrutura AWS com Terraform modularizado (Aulas 03–06)

| # | Critério de aceite |
|---|--------------------|
| 7.1 | Módulo `vpc`: VPC com subnets públicas e privadas em 2 AZs |
| 7.2 | Módulo `security-group`: SG da EC2 com 22 e 3000; SG do RDS com 5432 **apenas** a partir do SG da EC2 (menor privilégio) |
| 7.3 | Módulo `ec2`: instância `t2.micro` na subnet pública executando a API; usa `LabInstanceProfile` se precisar de acesso a serviços |
| 7.4 | Módulo `rds`: PostgreSQL `db.t3.micro` nas subnets privadas, com `publicly_accessible = false`, `storage_encrypted = true` e `db_subnet_group_name` com as subnets privadas |
| 7.5 | O RDS DEVE ser o banco da API na nuvem — QUANDO o CRUD for chamado na EC2 ENTÃO os dados DEVEM ser gravados no RDS |
| 7.6 | A composição DEVE ligar módulos (outputs de um alimentam inputs de outro) em `infra/main.tf` |
| 7.7 | Todos os recursos DEVEM ter tags |
| 7.8 | DEVE haver outputs com IP da EC2, endpoint do RDS e URL da API |
| 7.9 | `terraform validate` e `terraform plan` DEVEM rodar sem erros, com evidência em `evidencias/terraform-plan.txt` |
| 7.10 | Nenhum recurso IAM DEVE ser criado (restrição C3) |

## R8 — Remote State

| # | Critério de aceite |
|---|--------------------|
| 8.1 | `infra/backend/` DEVE provisionar bucket S3 com versionamento e encriptação, e tabela DynamoDB para locking |
| 8.2 | O backend DEVE ser criado **antes** de configurar `backend "s3"` no projeto principal |
| 8.3 | `infra/providers.tf` DEVE configurar o backend S3 com `encrypt = true` e a tabela DynamoDB |

## R9 — IA como copiloto (Aulas 02 e 07)

| # | Critério de aceite |
|---|--------------------|
| 9.1 | A solução DEVE ser construída no fluxo Spec-Driven (`specs/requirements.md` → `design.md` → `tasks.md`) |
| 9.2 | Os prompts principais, o que a IA gerou e o que foi corrigido DEVEM ser registrados em `specs/prompts.md` |
| 9.3 | Todo código gerado DEVE ser revisado e validado antes de commit/apply |

## R10 — Relatório

| # | Critério de aceite |
|---|--------------------|
| 10.1 | DEVE existir `relatorio.md` na raiz, informando no início a ferramenta de IA usada |
| 10.2 | DEVE responder às 4 questões do enunciado de forma dissertativa, com no mínimo 10 linhas cada, com base na experiência real |

## Fora de escopo

- CI/CD, registry de imagens, ALB, HTTPS/domínio (aulas 08+)
- Autenticação/autorização na API
- Alta disponibilidade (Multi-AZ no RDS, Auto Scaling)
