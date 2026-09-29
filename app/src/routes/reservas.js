const express = require('express');
const { pool } = require('../db');
const { parseId, validarReserva } = require('../validation');

const router = express.Router();

// Express 4 não captura rejeições de funções async: repassa o erro para o handler central.
const asyncHandler = (fn) => (req, res, next) => fn(req, res, next).catch(next);

const naoEncontrada = (res) => res.status(404).json({ erro: 'Reserva não encontrada' });
const invalida = (res, erros) =>
  res.status(400).json({ erro: 'Dados inválidos', detalhes: erros });

// Create
router.post('/', asyncHandler(async (req, res) => {
  const { erros, valores } = validarReserva(req.body);
  if (erros.length > 0) {
    return invalida(res, erros);
  }
  const { rows } = await pool.query(
    'INSERT INTO reservas (cliente, data, status) VALUES ($1, $2, $3) RETURNING *',
    [valores.cliente, valores.data, valores.status || 'pendente'],
  );
  res.status(201).json(rows[0]);
}));

// Read (lista)
router.get('/', asyncHandler(async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM reservas ORDER BY id');
  res.json(rows);
}));

// Read (por id)
router.get('/:id', asyncHandler(async (req, res) => {
  const id = parseId(req.params.id);
  if (id === null) {
    return naoEncontrada(res);
  }
  const { rows } = await pool.query('SELECT * FROM reservas WHERE id = $1', [id]);
  if (rows.length === 0) {
    return naoEncontrada(res);
  }
  res.json(rows[0]);
}));

// Update — status omitido mantém o valor atual
router.put('/:id', asyncHandler(async (req, res) => {
  const id = parseId(req.params.id);
  if (id === null) {
    return naoEncontrada(res);
  }
  const { erros, valores } = validarReserva(req.body);
  if (erros.length > 0) {
    return invalida(res, erros);
  }
  const { rows } = await pool.query(
    `UPDATE reservas
        SET cliente = $1, data = $2, status = COALESCE($3, status)
      WHERE id = $4
      RETURNING *`,
    [valores.cliente, valores.data, valores.status, id],
  );
  if (rows.length === 0) {
    return naoEncontrada(res);
  }
  res.json(rows[0]);
}));

// Delete
router.delete('/:id', asyncHandler(async (req, res) => {
  const id = parseId(req.params.id);
  if (id === null) {
    return naoEncontrada(res);
  }
  const { rowCount } = await pool.query('DELETE FROM reservas WHERE id = $1', [id]);
  if (rowCount === 0) {
    return naoEncontrada(res);
  }
  res.status(204).end();
}));

module.exports = router;
