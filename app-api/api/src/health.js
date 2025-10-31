const r = require('express').Router();
r.get('/health', (_req,res)=>res.status(200).send('ok'));
module.exports = r;
