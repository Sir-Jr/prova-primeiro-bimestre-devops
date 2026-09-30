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

Capturas de tela da execução (console AWS, terminal, navegador).
