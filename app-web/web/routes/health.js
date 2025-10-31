const express = require('express');
const r = express.Router();
r.get('/health', (_req, res) => res.status(200).send('ok'));
module.exports = r;
