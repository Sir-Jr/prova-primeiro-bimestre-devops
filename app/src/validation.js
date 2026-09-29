const STATUS_VALIDOS = ['pendente', 'confirmada', 'cancelada'];
const CLIENTE_MAX = 120;
const INT_MAX = 2147483647; // limite do SERIAL/INTEGER no PostgreSQL

// Valida o :id ANTES de consultar o banco. Retorna o número ou null (a rota responde 404).
// Sem isso, /reservas/abc chegaria ao Postgres e estouraria "invalid input syntax" → 500.
function parseId(param) {
  if (!/^[1-9]\d*$/.test(param)) {
    return null;
  }
  const id = Number(param);
  return id <= INT_MAX ? id : null;
}

// AAAA-MM-DD e data real de calendário (rejeita 2026-02-30).
function dataValida(valor) {
  if (typeof valor !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(valor)) {
    return false;
  }
  const [ano, mes, dia] = valor.split('-').map(Number);
  const data = new Date(Date.UTC(ano, mes - 1, dia));
  return (
    data.getUTCFullYear() === ano &&
    data.getUTCMonth() === mes - 1 &&
    data.getUTCDate() === dia
  );
}

// Usada no POST e no PUT. status omitido volta como null: o POST aplica 'pendente'
// e o PUT mantém o valor atual (COALESCE).
function validarReserva(body) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    return { erros: ['O corpo da requisição deve ser um objeto JSON'], valores: null };
  }

  const erros = [];
  const { cliente, data, status } = body;

  if (typeof cliente !== 'string' || cliente.trim() === '') {
    erros.push('cliente é obrigatório e deve ser um texto não vazio');
  } else if (cliente.trim().length > CLIENTE_MAX) {
    erros.push(`cliente deve ter no máximo ${CLIENTE_MAX} caracteres`);
  }

  if (!dataValida(data)) {
    erros.push('data é obrigatória e deve ser uma data válida no formato AAAA-MM-DD');
  }

  const statusOmitido = status === undefined || status === null;
  if (!statusOmitido && !STATUS_VALIDOS.includes(status)) {
    erros.push(`status deve ser um de: ${STATUS_VALIDOS.join(', ')}`);
  }

  if (erros.length > 0) {
    return { erros, valores: null };
  }

  return {
    erros: [],
    valores: {
      cliente: cliente.trim(),
      data,
      status: statusOmitido ? null : status,
    },
  };
}

module.exports = { parseId, validarReserva, STATUS_VALIDOS };
