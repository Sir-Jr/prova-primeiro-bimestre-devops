# Evidências

Tudo o que comprova o processo e o resultado: saídas de comandos, a spec Spec-Driven, o registro de
prompts das duas IAs e as capturas de tela. Senhas nunca aparecem: quando um comando exibe a senha,
ela é substituída por `***` e o cabeçalho do arquivo avisa.

## Saídas de comandos

| Arquivo | O que mostra |
|---------|--------------|
| [`docker-build.txt`](docker-build.txt) | Build da imagem, execução do container, `whoami` não-root e healthcheck |
| [`compose-ps.txt`](compose-ps.txt) | `docker compose ps` com `api` e `db` saudáveis |
| [`curl-local.txt`](curl-local.txt) | Smoke test das rotas no ambiente local |
| [`terraform-plan.txt`](terraform-plan.txt) | `init` com o backend S3, `validate`, `plan` da infraestrutura (19 recursos) e nome da AMI (IP do administrador mascarado) |
| [`terraform-apply.txt`](terraform-apply.txt) | `apply` do plano revisado: 19 recursos e outputs |
| [`curl-aws.txt`](curl-aws.txt) | Smoke test na EC2 (17/17) e reserva que fica gravada no RDS |
| [`rds-describe.txt`](rds-describe.txt) | RDS privado e encriptado; state remoto no S3 (versões, SSE) e lock no DynamoDB |
| [`terraform-destroy.txt`](terraform-destroy.txt) | `plan -destroy`, `destroy` e conferência de que nada ficou na AWS |
| [`terraform-backend.txt`](terraform-backend.txt) | Backend do remote state: `plan`, `apply`, contorno da SCP do Lab e conferência do bucket e da tabela (dados sensíveis mascarados) |

## Spec-Driven — [`specs/`](specs/)

| Arquivo | Conteúdo |
|---------|----------|
| [`specs/autora/requirements.md`](specs/autora/requirements.md) | Requisitos (R1–R10) e restrições do Learner Lab (C1–C6) |
| [`specs/autora/design.md`](specs/autora/design.md) | Design da solução, com rastreabilidade para os requisitos |
| [`specs/autora/tasks.md`](specs/autora/tasks.md) | Tarefas T0–T12, critérios de pronto e estado de cada uma |
| [`specs/revisora/spec-revisora.md`](specs/revisora/spec-revisora.md) | Respostas literais da IA-revisora (A01…An) e pareceres numerados (V01…Vn) |

## Prompts — [`prompts/`](prompts/)

| Arquivo | Conteúdo |
|---------|----------|
| [`prompts/prompts.md`](prompts/prompts.md) | Resumo analítico por etapa e tabela de erros e correções das duas IAs |
| [`prompts/prompts-autora.md`](prompts/prompts-autora.md) | Prompts do usuário para a IA-autora (P01…Pn), texto literal |
| [`prompts/prompts-revisora.md`](prompts/prompts-revisora.md) | Prompts do usuário para a IA-revisora (R01…Rn), texto literal |

## Imagens — [`imagens/`](imagens/)

Capturas do console AWS e do navegador durante a execução de 30/09/2026. O ID da conta e o IP do
administrador foram cobertos com uma tarja onde apareciam (07 e 13).

| Arquivo | O que mostra |
|---------|--------------|
| `01-ec2-instancia.png` | EC2 em execução, IP público, SG e par de chaves `vockey` |
| `02-rds-lista.png` | RDS disponível: PostgreSQL, `db.t3.micro`, sem Multi-AZ |
| `03-rds-seguranca-conexao.png` | RDS sem acesso pela internet; SG aceita só o SG da EC2 |
| `04-rds-criptografia.png` | Armazenamento do RDS criptografado (KMS `aws/rds`) |
| `05-vpc-subredes.png` | 4 sub-redes (2 públicas, 2 privadas) em 2 AZs |
| `06-sg-rds-entrada.png` | 5432 liberada só a partir do SG da EC2 |
| `07-sg-ec2-entrada.png` | 22 só do IP do administrador (`/32`, coberto); 3000 pública |
| `08-s3-tfstate.png` | State remoto `prova/terraform.tfstate` no bucket |
| `09-s3-tfstate-versoes.png` | Duas versões do state (versionamento ativo) |
| `10-dynamodb-lock.png` | Tabela de lock ativa, chave `LockID` |
| `11-api-reservas-aws.png` | `GET /reservas` na EC2 devolvendo a reserva gravada no RDS |
| `12-api-health-aws.png` | `GET /health` na EC2 |
| `13-ec2-detalhes.png` | AMI Amazon Linux 2023 padrão e par de chaves (proprietário coberto) |
