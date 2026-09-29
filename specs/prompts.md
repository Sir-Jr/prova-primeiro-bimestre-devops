# Registro de Prompts — IA como Copiloto

Log dos prompts principais usados na construção da solução, o que a IA gerou e o que foi
revisado, corrigido ou questionado antes de aceitar. Serve de base para a Questão 2 do
`relatorio.md`.

| # | Tarefa | Prompt (resumo) | O que a IA gerou | Revisão / correção / questionamento |
|---|--------|-----------------|------------------|-------------------------------------|
| 1 | Planejamento | "Leia as regras da prova e o README, crie um plano de ação spec-driven e uma tabela de recomendações por etapa, para eu ler, pesquisar e questionar antes de qualquer execução" | Plano em 11 etapas com recomendação, risco e tópicos de pesquisa por etapa; levantou bloqueios do ambiente (Docker no WSL, credenciais AWS expiradas) e a pegadinha do SSL obrigatório no RDS PostgreSQL 15+ | Perguntei se a prova exige registrar todos os prompts (resposta: só os principais, na Questão 2) → decidi versionar este log. Defini os valores de `status`, a pasta `specs/` e onde citar a ferramenta de IA |
| 2 | Spec — requisitos | "Escreva o `specs/requirements.md` a partir do enunciado da prova" | Requisitos R1–R10 com critérios de aceite no formato QUANDO/ENTÃO/DEVE, restrições do Learner Lab (C1–C6) e escopo excluído | _(preencher após a revisão)_ |
| 3 | Spec — design | "Escreva o `specs/design.md` a partir do `requirements.md` aprovado, reaproveitando os módulos Terraform da Aula 06 e incorporando as notas da revisão (validar `:id` antes do banco; parser do DATE)" | Arquitetura local × AWS, modelo de dados, contrato das rotas, regras de validação, Dockerfile, Compose, estrutura do `infra/`, composição dos módulos, SGs, `user_data`, estratégia de validação, workflow Git e matriz de rastreabilidade | _(preencher após a revisão)_ |
