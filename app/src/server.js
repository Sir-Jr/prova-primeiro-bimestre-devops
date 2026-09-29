const app = require('./app');
const { pool, initDb } = require('./db');

const PORT = Number(process.env.PORT || 3000);

async function main() {
  await initDb();

  const server = app.listen(PORT, () => {
    console.log(`API de Reservas ouvindo na porta ${PORT}`);
  });

  // docker stop envia SIGTERM: fecha o servidor HTTP e o pool antes de sair.
  const encerrar = (sinal) => {
    console.log(`${sinal} recebido, encerrando...`);
    server.close(() => {
      pool.end().then(() => process.exit(0));
    });
  };
  process.on('SIGTERM', () => encerrar('SIGTERM'));
  process.on('SIGINT', () => encerrar('SIGINT'));
}

main().catch((err) => {
  console.error('Falha ao iniciar a API:', err.message);
  process.exit(1);
});
