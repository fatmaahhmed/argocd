const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors());

app.get('/api/hello', (req, res) => {
  res.json({
    message: 'Hello from API',
    timestamp: new Date().toISOString(),
    hostname: process.env.HOSTNAME || 'unknown'
  });
});

app.listen(port, () => {
  console.log(`API listening on port ${port}`);
});
