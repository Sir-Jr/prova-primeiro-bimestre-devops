const fs = require('fs');
const { Pool, types } = require('pg');

// DATE (OID 1082) volta como a string AAAA-MM-DD crua. Sem isso o pg converte para Date
// à meia-noite local e o JSON pode sair com o dia anterior por causa do fuso.
types.setTypeParser(1082, (valor) => valor);

// DB_SSL=true (RDS): conexão criptografada e com certificado validado contra o CA bundle da AWS.
function sslConfig() {
  if (process.env.DB_SSL !== 'true') {
    return false;
  }
  const config = { rejectUnauthorized: true };
  if (process.env.DB_SSL_CA) {
    config.ca = fs.readFileSync(process.env.DB_SSL_CA, 'utf8');
  }
  return config;
}

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: sslConfig(),
  max: 10,
});

// Uma conexão ociosa do pool pode cair (reinício do RDS, rede). Sem este listener o evento
// 'error' não é tratado e derruba o processo; com ele, o pool descarta a conexão e abre outra.
pool.on('error', (err) => {
  console.error('Conexão ociosa com o banco encerrada:', err.message);
});

const CREATE_TABLE = `
  CREATE TABLE IF NOT EXISTS reservas (
    id         SERIAL PRIMARY KEY,
    cliente    TEXT NOT NULL CHECK (length(trim(cliente)) > 0),
    data       DATE NOT NULL,
    status     TEXT NOT NULL DEFAULT 'pendente'
               CHECK (status IN ('pendente', 'confirmada', 'cancelada')),
    criado_em  TIMESTAMPTZ NOT NULL DEFAULT now()
  )
`;

const esperar = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Garante a tabela na subida da API. Tenta de novo enquanto o banco ainda não aceita conexões.
async function initDb({ tentativas = 10, intervaloMs = 3000 } = {}) {
  for (let tentativa = 1; tentativa <= tentativas; tentativa++) {
    try {
      await pool.query(CREATE_TABLE);
      console.log('Banco pronto: tabela reservas verificada');
      return;
    } catch (err) {
      console.error(`Banco indisponível (tentativa ${tentativa}/${tentativas}): ${err.message}`);
      if (tentativa === tentativas) {
        throw err;
      }
      await esperar(intervaloMs);
    }
  }
}

module.exports = { pool, initDb };
