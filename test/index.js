const http = require('http');

const hostname = '0.0.0.0';
const port = process.env.PORT;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end(process.env.DEFANG_GH_ACTION_TEST_MESSAGE);
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});