import http from "http";

const server = http.createServer((req, res) => {
  if (req.method === "GET" && req.url === "/ping") {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end("pong");

    return;
  }

  res.writeHead(404, { "Content-Type": "text/plain" });
  res.end("Not Found");
});

const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
