const express = require('express');
const app = express();
app.use(require('./src/health'));
const port = process.env.PORT || 3000;
app.listen(port, ()=>console.log(`listening on ${port}`));
