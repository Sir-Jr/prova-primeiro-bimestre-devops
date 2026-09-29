const express = require('express');
const reservasRouter = require('./routes/reservas');

const app = express();

app.disable('x-powered-by');
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/reservas', reservasRouter);

app.use((req, res) => {
  res.status(404).json({ erro: 'Rota não encontrada' });
});

// Handler central: erros do cliente vindos do parser do corpo (JSON malformado 400, corpo acima
// de 100 kb 413, etc.) mantêm o status; o resto vira 500 sem vazar stack nem erro do banco.
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ erro: 'JSON inválido no corpo da requisição' });
  }
  if (err.type && err.status && err.status < 500) {
    return res.status(err.status).json({ erro: 'Requisição inválida' });
  }
  console.error(err);
  res.status(500).json({ erro: 'Erro interno' });
});

module.exports = app;
