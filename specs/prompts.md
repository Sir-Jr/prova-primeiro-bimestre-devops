# Registro de Prompts — IA como Copiloto

Log dos prompts principais usados na construção da solução, o que a IA gerou e o que foi
revisado, corrigido ou questionado antes de aceitar. Serve de base para a Questão 2 do
`relatorio.md`.

| # | Tarefa | Prompt (resumo) | O que a IA gerou | Revisão / correção / questionamento |
|---|--------|-----------------|------------------|-------------------------------------|
| 1 | Planejamento | "Leia as regras da prova e o README, crie um plano de ação spec-driven e uma tabela de recomendações por etapa, para eu ler, pesquisar e questionar antes de qualquer execução" | Plano em 11 etapas com recomendação, risco e tópicos de pesquisa por etapa; levantou bloqueios do ambiente (Docker no WSL, credenciais AWS expiradas) e a pegadinha do SSL obrigatório no RDS PostgreSQL 15+ | Perguntei se a prova exige registrar todos os prompts (resposta: só os principais, na Questão 2) → decidi versionar este log. Defini os valores de `status`, a pasta `specs/` e onde citar a ferramenta de IA |
| 2 | Spec — requisitos | "Escreva o `specs/requirements.md` a partir do enunciado da prova" | Requisitos R1–R10 com critérios de aceite no formato QUANDO/ENTÃO/DEVE, restrições do Learner Lab (C1–C6) e escopo excluído | _(preencher após a revisão)_ |
| 3 | Spec — design | "Escreva o `specs/design.md` a partir do `requirements.md` aprovado, reaproveitando os módulos Terraform da Aula 06 e incorporando as notas da revisão (validar `:id` antes do banco; parser do DATE)" | Arquitetura local × AWS, modelo de dados, contrato das rotas, regras de validação, Dockerfile, Compose, estrutura do `infra/`, composição dos módulos, SGs, `user_data`, estratégia de validação, workflow Git e matriz de rastreabilidade | _(preencher após a revisão)_ |
| 4 | Spec — tarefas | "Escreva o `specs/tasks.md` a partir do design aprovado: tarefas numeradas, com branch, arquivos, requisitos atendidos, critério de pronto, evidências e commits" | 12 tarefas em 5 fases (fundação, aplicação, containers, infraestrutura, relatório/entrega), com a publicação do repo marcada como dependente de autorização e a entrega travada em 01/10 | _(preencher após a revisão)_ |

## Erros e correções

Fluxo de trabalho com duas IAs e decisão humana: a **IA-autora** escreve specs e código; o usuário
leva cada entrega para a **IA-revisora** (outro agente, em outro painel), que devolve um parecer;
a IA-autora avalia o parecer contra os fatos do repositório; o usuário decide.

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
