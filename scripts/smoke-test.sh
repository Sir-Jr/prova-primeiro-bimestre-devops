#!/usr/bin/env bash
# Smoke test da API de Reservas: percorre o CRUD e os casos de erro do contrato (design D2.4).
# Uso: scripts/smoke-test.sh [BASE_URL]   (padrão: http://localhost:3000)
# Sai com código 1 se algum caso não retornar o status esperado.
set -uo pipefail

BASE_URL="${1:-http://localhost:3000}"
JSON='Content-Type: application/json'
falhas=0
total=0
CORPO=""

# checa "descrição" status_esperado [args do curl...]
checa() {
  local descricao="$1" esperado="$2"
  shift 2
  local saida status
  # Timeouts: API fora do ar ou SG bloqueando viram status 000 (FALHA) em segundos, sem travar
  saida=$(curl -s --connect-timeout 5 --max-time 15 -w '\n%{http_code}' "$@")
  status="${saida##*$'\n'}"
  CORPO="${saida%$'\n'*}"
  total=$((total + 1))
  # ${#descricao} conta caracteres (não bytes), então o alinhamento funciona com acentos
  local pad=$((54 - ${#descricao}))
  [ "$pad" -lt 1 ] && pad=1
  if [ "$status" = "$esperado" ]; then
    printf 'OK    %s%*s%s\n' "$descricao" "$pad" '' "$status"
  else
    printf 'FALHA %s%*sesperado %s, obtido %s\n' "$descricao" "$pad" '' "$esperado" "$status"
    falhas=$((falhas + 1))
  fi
  [ -n "$CORPO" ] && printf '      %s\n' "$CORPO"
}

echo "Smoke test — $BASE_URL — $(date '+%d/%m/%Y %H:%M:%S %Z')"
echo

checa "GET /health" 200 "$BASE_URL/health"

checa "POST /reservas (válida, sem status)" 201 \
  -X POST "$BASE_URL/reservas" -H "$JSON" -d '{"cliente":"Ana Souza","data":"2026-10-01"}'
ID=$(printf '%s' "$CORPO" | sed -n 's/.*"id":\([0-9]*\).*/\1/p')
if [ -z "$ID" ]; then
  echo "Não foi possível obter o id da reserva criada; abortando."
  exit 1
fi
echo "      (id criado: $ID)"

checa "POST /reservas (sem campos obrigatórios)" 400 \
  -X POST "$BASE_URL/reservas" -H "$JSON" -d '{}'
checa "POST /reservas (data inexistente 2026-02-30)" 400 \
  -X POST "$BASE_URL/reservas" -H "$JSON" -d '{"cliente":"Ana","data":"2026-02-30"}'
checa "POST /reservas (status inválido)" 400 \
  -X POST "$BASE_URL/reservas" -H "$JSON" -d '{"cliente":"Ana","data":"2026-10-01","status":"feita"}'
checa "POST /reservas (sem Content-Type JSON)" 400 \
  -X POST "$BASE_URL/reservas" -d 'cliente=Ana&data=2026-10-01'

checa "GET /reservas (lista)" 200 "$BASE_URL/reservas"
checa "GET /reservas/$ID" 200 "$BASE_URL/reservas/$ID"
checa "GET /reservas/abc (id inválido)" 404 "$BASE_URL/reservas/abc"
checa "GET /reservas/2147483647 (inexistente)" 404 "$BASE_URL/reservas/2147483647"

checa "PUT /reservas/$ID (sem status: mantém o atual)" 200 \
  -X PUT "$BASE_URL/reservas/$ID" -H "$JSON" -d '{"cliente":"Ana Souza","data":"2026-10-02"}'
checa "PUT /reservas/$ID (status confirmada)" 200 \
  -X PUT "$BASE_URL/reservas/$ID" -H "$JSON" -d '{"cliente":"Ana Souza","data":"2026-10-02","status":"confirmada"}'
checa "PUT /reservas/$ID (sem data)" 400 \
  -X PUT "$BASE_URL/reservas/$ID" -H "$JSON" -d '{"cliente":"Ana Souza"}'
checa "PUT /reservas/2147483647 (inexistente)" 404 \
  -X PUT "$BASE_URL/reservas/2147483647" -H "$JSON" -d '{"cliente":"X","data":"2026-10-01"}'

checa "DELETE /reservas/$ID" 204 -X DELETE "$BASE_URL/reservas/$ID"
checa "GET /reservas/$ID (após DELETE)" 404 "$BASE_URL/reservas/$ID"
checa "DELETE /reservas/$ID (de novo)" 404 -X DELETE "$BASE_URL/reservas/$ID"

echo
echo "Resultado: $((total - falhas))/$total casos OK"
[ "$falhas" -eq 0 ]
