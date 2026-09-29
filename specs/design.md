# Design — API de Reservas da TechNova

> Fase 2 do fluxo Spec-Driven. Cada decisão referencia os requisitos de `requirements.md` (R/C).

## 1. Visão geral

```
                         LOCAL (docker compose up -d)
  ┌──────────────────────────── rede bridge technova-net ────────────────────────────┐
  │   ┌──────────────┐   5432   ┌───────────────────────┐                             │
  │   │ api (Node 22)│ ───────▶ │ db (postgres:16-alpine)│── volume nomeado pgdata    │
  │   │  :3000       │          │  healthcheck pg_isready│                             │
  │   └──────────────┘          └───────────────────────┘                             │
  └──────┬───────────────────────────────────────────────────────────────────────────┘
         │ localhost:3000

                         AWS (us-east-1, terraform apply)
  ┌──────────────────────────── VPC 10.0.0.0/16 ─────────────────────────────────────┐
  │  us-east-1a                              us-east-1b                              │
  │  ┌─ public-1 10.0.1.0/24 ─────────┐      ┌─ public-2 10.0.2.0/24 ─┐              │
  │  │ EC2 t2.micro (Docker + API)    │      │  (reserva p/ 2ª AZ)    │   ◀── IGW    │
  │  │ SG ec2: 22 (meu IP), 3000      │      └────────────────────────┘              │
  │  └──────────────┬─────────────────┘                                              │
  │                 │ 5432 (TLS) — só a partir do SG da EC2                          │
  │  ┌─ private-1 10.0.11.0/24 ───────┐      ┌─ private-2 10.0.12.0/24 ┐             │
  │  │ RDS PostgreSQL 16 db.t3.micro  │      │  (DB subnet group)       │             │
  │  │ publicly_accessible = false    │      └──────────────────────────┘             │
  │  └────────────────────────────────┘                                              │
  └───────────────────────────────────────────────────────────────────────────────────┘
  Remote state: S3 technova-reservas-tfstate-6325269 + DynamoDB technova-reservas-tf-lock
```

A **mesma imagem Docker** roda nos dois ambientes; só mudam as variáveis de ambiente
(host do banco, SSL). Isso garante que o que foi testado localmente é o que vai para a nuvem.

## 2. Aplicação (R1, R2, R3)

### 2.1 Stack e estrutura

- Node.js 22 (LTS) + Express 4 + `pg` (node-postgres). Sem ORM — SQL explícito e parametrizado.

```
app/
├── package.json          # scripts: start
├── package-lock.json
├── Dockerfile
├── .dockerignore
└── src/
    ├── server.js         # bootstrap: initDb() com retry → app.listen(PORT)
    ├── app.js            # express(), express.json(), rotas, 404 e handler de erro
    ├── db.js             # Pool, parser do DATE, initDb()
    ├── validation.js     # parseId(), validarReserva()
    └── routes/
        └── reservas.js   # CRUD
```

`app.js` separado de `server.js` para a app poder ser importada sem abrir porta.

### 2.2 Modelo de dados (R2.2)

```sql
CREATE TABLE IF NOT EXISTS reservas (
  id         SERIAL PRIMARY KEY,
  cliente    TEXT NOT NULL CHECK (length(trim(cliente)) > 0),
  data       DATE NOT NULL,
  status     TEXT NOT NULL DEFAULT 'pendente'
             CHECK (status IN ('pendente', 'confirmada', 'cancelada')),
  criado_em  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

- Executado em `initDb()` na subida da API (idempotente). Sem ferramenta de migration (fora de escopo).
- Os `CHECK` repetem a validação da API: defesa em profundidade se alguém gravar direto no banco.

### 2.3 Conexão com o banco (R2.3, R2.4)

| Variável | Local (Compose) | AWS (EC2) |
|----------|-----------------|-----------|
| `PORT` | `3000` | `3000` |
| `DB_HOST` | `db` (nome do serviço) | `module.rds.db_address` |
| `DB_PORT` | `5432` | `5432` |
| `DB_NAME` / `DB_USER` / `DB_PASSWORD` | do `.env` | do `terraform.tfvars` (não versionado) |
| `DB_SSL` | `false` | `true` |
| `DB_SSL_CA` | — | `/certs/rds-global-bundle.pem` |

- `DB_SSL=true` → `ssl: { ca, rejectUnauthorized: true }`: conexão **criptografada e com certificado
  validado** contra o bundle oficial da AWS (baixado no `user_data`). Necessário porque o RDS
  PostgreSQL 15+ vem com `rds.force_ssl = 1` e recusa conexões sem TLS.
- **DATE sem fuso:** `pg.types.setTypeParser(1082, v => v)` — o tipo DATE (OID 1082) volta como a
  string `AAAA-MM-DD` crua. Sem isso o `pg` converte para `Date` à meia-noite local e o JSON pode sair
  com o dia anterior (`2026-10-01T03:00:00.000Z`).
- **Retry na subida:** `initDb()` tenta até 10 vezes, com 3 s de intervalo, antes de encerrar o
  processo com erro (cobre o banco ainda aceitando conexões; na AWS o `--restart unless-stopped` do
  Docker reinicia o container).

### 2.4 Contrato das rotas

| Método | Rota | Sucesso | Erros |
|--------|------|---------|-------|
| `POST` | `/reservas` | `201` + reserva criada | `400` validação |
| `GET` | `/reservas` | `200` + array (ordenado por `id`) | — |
| `GET` | `/reservas/:id` | `200` + reserva | `404` |
| `PUT` | `/reservas/:id` | `200` + reserva atualizada | `400` validação, `404` |
| `DELETE` | `/reservas/:id` | `204` sem corpo | `404` |
| `GET` | `/health` | `200` `{ "status": "ok" }` | — |
| qualquer | rota inexistente | — | `404` `{ "erro": "Rota não encontrada" }` |

Formato de erro único: `{ "erro": "<mensagem>" }` (e `detalhes: [...]` na validação).

Exemplo de reserva: `{ "id": 1, "cliente": "Ana Souza", "data": "2026-10-01", "status": "pendente", "criado_em": "..." }`

### 2.5 Validação (R1.2, R1.5, R1.7)

**`parseId(param)`** — roda **antes** de qualquer consulta ao banco:
- aceita só `^[1-9]\d*$` e valor ≤ 2147483647 (limite do `SERIAL`/`INTEGER`);
- se inválido → `404` direto. Sem isso, `/reservas/abc` chegaria ao Postgres e estouraria
  `invalid input syntax for type integer` → `500`.

**`validarReserva(body)`** — usada no `POST` e no `PUT`:

| Campo | Regra | POST | PUT |
|-------|-------|------|-----|
| `cliente` | string, não vazia após `trim()`, até 120 caracteres | obrigatório | obrigatório |
| `data` | `^\d{4}-\d{2}-\d{2}$` **e** data real de calendário (rejeita `2026-02-30`) | obrigatório | obrigatório |
| `status` | `pendente` \| `confirmada` \| `cancelada` | opcional → `pendente` | opcional → **mantém o atual** |

- Erros acumulados numa lista e devolvidos juntos (`400`).
- Campos desconhecidos no corpo são ignorados.
- `PUT` mantendo o status atual numa única query: `UPDATE reservas SET cliente=$1, data=$2,
  status=COALESCE($3, status) WHERE id=$4 RETURNING *` (0 linhas → `404`).
- JSON malformado no corpo → `400` (tratado no handler de erro do Express).

### 2.6 Tratamento de erros

- Handler final de erro: loga no stdout (`console.error`) e responde `500 { "erro": "Erro interno" }`
  — sem vazar stack trace nem mensagem do banco para o cliente.

## 3. Docker (R5)

**`app/Dockerfile`** — multi-stage:

| Estágio | Base | Faz |
|---------|------|-----|
| `deps` | `node:22-alpine` | copia `package*.json`, roda `npm ci --omit=dev` |
| `runtime` | `node:22-alpine` | `NODE_ENV=production`, copia `node_modules` do `deps` + `src/` (dono `root`), `USER node`, `EXPOSE 3000`, `HEALTHCHECK` com `wget` em `/health`, `CMD ["node", "src/server.js"]` |

- Processo roda como `node` (não-root), mas os arquivos da aplicação ficam com **dono `root`** e
  modo 644/755 (sem `--chown`): o `node` só lê. Se a API for comprometida, ela não consegue reescrever
  o próprio código. A API não grava em disco, então nada depende de escrita em `/app`. Mesmo princípio
  de menor privilégio dos Security Groups (D5.5).
- **`app/.dockerignore`**: `node_modules`, `npm-debug.log`, `.env`, `.git`, `Dockerfile`, `.dockerignore`.

## 4. Docker Compose (R6)

`docker-compose.yml` na raiz:

| Item | Configuração |
|------|--------------|
| Serviço `db` | `postgres:16-alpine`; `POSTGRES_DB/USER/PASSWORD` do `.env`; volume `pgdata:/var/lib/postgresql/data`; healthcheck `pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB` (interval 5s, retries 10); **sem publicar a 5432 no host** (só a API precisa do banco) |
| Serviço `api` | `build: ./app`; `ports: "3000:3000"`; env `DB_HOST=db`, `DB_SSL=false` + credenciais do `.env`; `depends_on: db: condition: service_healthy`; `restart: unless-stopped`; **healthcheck explícito** `wget -qO- http://localhost:3000/health` (interval 10s, timeout 3s, retries 5, start_period 10s) |
| Rede | `technova-net`, `driver: bridge` |
| Volume | `pgdata` (nomeado) |

- O healthcheck da `api` é declarado no próprio `docker-compose.yml` (R3.2), mesmo repetindo o
  `HEALTHCHECK` do Dockerfile: o Compose sobrescreve o da imagem e deixa explícito, no arquivo de
  orquestração, que o `/health` é o que define o estado `healthy` do serviço.
- **`.env.example`** versionado com placeholders (`POSTGRES_PASSWORD=troque-esta-senha`); `.env` real no `.gitignore`.

## 5. Infraestrutura AWS (R7, R8, C1–C5)

### 5.1 Estrutura

```
infra/
├── backend/                 # aplicado 1º, state LOCAL (não versionado)
│   ├── main.tf              # S3 + versioning + SSE + public access block + DynamoDB
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf
├── modules/
│   ├── vpc/                 # reaproveitado da Aula 06
│   ├── security-group/      # reaproveitado da Aula 06
│   ├── ec2/                 # Aula 06 + iam_instance_profile + key_name opcional
│   └── rds/                 # Aula 06, engine 16
├── templates/
│   └── user_data.sh.tftpl   # instala Docker, clona o repo, sobe a API
├── main.tf                  # composição
├── variables.tf
├── outputs.tf
├── providers.tf             # provider + backend "s3"
└── terraform.tfvars.example # versionado; terraform.tfvars fica no .gitignore
```

### 5.2 Remote state (R8)

| Recurso | Configuração |
|---------|--------------|
| `aws_s3_bucket` | `technova-reservas-tfstate-6325269` (RA garante nome único global) |
| `aws_s3_bucket_versioning` | `Enabled` |
| `aws_s3_bucket_server_side_encryption_configuration` | `AES256` |
| `aws_s3_bucket_public_access_block` | os 4 bloqueios `true` |
| `aws_dynamodb_table` | `technova-reservas-tf-lock`, `hash_key = "LockID"` (S), `PAY_PER_REQUEST` |

Backend no `infra/providers.tf`:

```hcl
backend "s3" {
  bucket         = "technova-reservas-tfstate-6325269"
  key            = "prova/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "technova-reservas-tf-lock"
}
```

**Risco conhecido do Lab:** a SCP bloqueia `s3:GetBucketObjectLockConfiguration`, que o provider AWS
chama ao ler o `aws_s3_bucket` (visto na Aula 05). Plano: se o refresh do bucket falhar pela SCP,
usar `-refresh=false` e conferir o bucket via `aws s3api` (`head-bucket`, `get-bucket-versioning`,
`get-bucket-encryption`, `get-public-access-block`). Documentar no relatório (Questão 3).

### 5.3 Parâmetros de rede

| Subnet | CIDR | AZ | Tipo |
|--------|------|----|------|
| `public-1` | 10.0.1.0/24 | us-east-1a | public |
| `public-2` | 10.0.2.0/24 | us-east-1b | public |
| `private-1` | 10.0.11.0/24 | us-east-1a | private |
| `private-2` | 10.0.12.0/24 | us-east-1b | private |

Sem NAT Gateway: o RDS não precisa sair para a internet e o NAT é cobrado por hora.

**IP público da EC2:** conferido no módulo `vpc` da Aula 06 — `aws_subnet.this` usa
`map_public_ip_on_launch = each.value.type == "public"`, então as subnets `public-*` já atribuem IP
público na criação da instância. Não é preciso `associate_public_ip_address` na EC2.

### 5.4 Composição dos módulos (R7.6)

```
module.vpc ──vpc_id──────────────▶ module.sg_ec2 ──sg_id──▶ module.sg_rds (origem da 5432)
    │                                    │                        │
    ├─private_subnet_ids─▶ module.rds ◀──┼────────── sg_id ───────┘
    │                         │          │
    └─public_subnet_ids[0]─▶ module.ec2 ◀┘ sg_id
                              ▲
             module.rds.db_address ── templatefile(user_data) ──┘
```

O `db_address` do RDS entra no `user_data` da EC2 → o Terraform cria o RDS **antes** da EC2
(dependência implícita), e a API já sobe com o endpoint certo.

### 5.5 Security Groups (R7.2)

| SG | Regra | Origem | Motivo |
|----|-------|--------|--------|
| `sg_ec2` | 22/tcp | `var.ssh_allowed_cidr` (meu IP `/32`) | SSH só de quem administra |
| `sg_ec2` | 3000/tcp | `0.0.0.0/0` | API pública (requisito) |
| `sg_ec2` | egress all | `0.0.0.0/0` | `dnf`, `git clone`, Docker Hub |
| `sg_rds` | 5432/tcp | `source_security_group_id = sg_ec2` | banco só aceita a EC2 |

A variável `ssh_allowed_cidr` tem `validation` que **recusa `0.0.0.0/0`**.

### 5.6 EC2 (R7.3)

- AMI Amazon Linux 2023 via `data "aws_ami"` (sempre a mais recente, sem ID fixo).
- `t2.micro`, `public_subnet_ids[0]`, `iam_instance_profile = "LabInstanceProfile"` (C3 — nenhum
  recurso IAM criado; o perfil já existe no Lab), `key_name = "vockey"` (key pair padrão do Lab).
- Mudança no módulo `ec2` da Aula 06: nova variável `iam_instance_profile` (default `null`) e
  `key_name` passa a ser opcional.

**`user_data.sh.tftpl`** (via `templatefile()`):
1. `dnf install -y docker git` → `systemctl enable --now docker`
2. `git clone` do repositório público `prova-primeiro-bimestre-devops`
3. Baixa o CA bundle do RDS (`https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem`)
4. `docker build -t technova-reservas ./app`
5. `docker run -d --name api --restart unless-stopped -p 3000:3000 -e DB_HOST=... -e DB_SSL=true -e DB_SSL_CA=/certs/rds-global-bundle.pem -v /opt/certs:/certs:ro technova-reservas`

- Script com `set -euo pipefail` e **sem `set -x`**: o trace ecoaria cada comando — inclusive o
  `docker run -e DB_PASSWORD=...` — em `/var/log/cloud-init-output.log`.
- **Dependência:** o código precisa estar no GitHub **antes** do `terraform apply` (a EC2 clona o repo).
- **Trade-off aceito:** a senha do banco fica no `user_data` (visível para quem tem acesso ao console
  EC2 da conta) e também no **tfstate** (o `aws_db_instance.password` e o `user_data` são gravados em
  texto no state, mesmo com `sensitive = true`, que só esconde da saída do CLI). Mitigação: o state
  fica no S3 com SSE, versionamento e bloqueio de acesso público, nunca no Git. Aceitável no Lab; em
  produção seria Secrets Manager/SSM. Registrar no relatório.

### 5.7 RDS (R7.4, R7.5)

- Módulo da Aula 06 com `engine_version = "16"` (mesma major do Compose): `db.t3.micro`, 20 GB gp2,
  `storage_encrypted = true`, `publicly_accessible = false`, subnet group com as privadas,
  `multi_az = false`, `skip_final_snapshot = true`, `deletion_protection = false`, `backup_retention_period = 0`.
- `db_password` com `sensitive = true`, só alfanumérica (o RDS recusa `/`, `@`, `"` e espaço).

### 5.8 Tags e outputs (R7.7, R7.8)

- `default_tags` no provider: `Project = technova-reservas`, `Environment = prova`,
  `ManagedBy = terraform`, `Owner = 6325269`. Os módulos já mesclam as próprias tags (`Name`, `Type`).
- Outputs: `ec2_public_ip`, `rds_endpoint`, `api_url` (`http://<ip>:3000`), `health_url`, `ssh_command`.

### 5.9 Versões

- Terraform `>= 1.5`; provider `hashicorp/aws ~> 5.0` (mesmo das aulas, comportamento conhecido no Lab).

## 6. Estratégia de validação (R9.3)

| Camada | Como valida | Evidência |
|--------|-------------|-----------|
| API | `scripts/smoke-test.sh BASE_URL`: roda com `curl` os casos felizes + 400 + 404 (`/abc`, id inexistente) + `DELETE` 204 | `evidencias/curl-local.txt`, `evidencias/curl-aws.txt` |
| Docker | `docker build` + `docker run` + `docker exec whoami` (≠ root) | `evidencias/docker-build.txt` |
| Compose | `docker compose up -d` + `docker compose ps` (ambos `healthy`); `down` + `up` → dados persistem | `evidencias/compose-ps.txt` |
| Terraform | `fmt -check` → `validate` → `plan` revisado antes do `apply` | `evidencias/terraform-plan.txt` |
| AWS | `apply`, smoke test na EC2, `aws rds describe-db-instances` (privado + encriptado), `destroy` | `evidencias/terraform-apply.txt`, `terraform-destroy.txt` |

Checklist do `plan` antes do `apply` (base da Questão 4): nenhum `aws_iam_*`; região `us-east-1`;
RDS com `publicly_accessible = false` e `storage_encrypted = true`; 5432 sem CIDR aberto; 22 só `/32`;
contagem de recursos compatível com o esperado.

## 7. Workflow Git (R4)

| Branch | Conteúdo | Merge em `main` |
|--------|----------|-----------------|
| `main` | spec, README, `.gitignore` | — |
| `feat/api` | `app/src`, `package.json` | `--no-ff` |
| `feat/docker` | `Dockerfile`, `.dockerignore` | `--no-ff` |
| `feat/compose` | `docker-compose.yml`, `.env.example` | `--no-ff` |
| `feat/infra` | `infra/` (backend + módulos + composição) | `--no-ff` |
| `docs/relatorio` | `relatorio.md`, evidências finais | `--no-ff` |

Commits em Conventional Commits, sem co-autoria. `--no-ff` preserva o merge commit, que é a
evidência visível do uso de feature branch.

## 8. Rastreabilidade

| Requisito | Seção do design |
|-----------|-----------------|
| R1 | 2.4, 2.5 |
| R2 | 2.2, 2.3 |
| R3 | 2.4, 3, 4 |
| R4 | 7 |
| R5 | 3 |
| R6 | 4 |
| R7 | 5.1, 5.3–5.9 |
| R8 | 5.2 |
| R9 | 6, `specs/prompts.md` |
| R10 | `relatorio.md` (tarefa final) |
| C1–C6 | 5.2, 5.6, 5.7, 5.8 |
