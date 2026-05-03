import express from 'express';
import http from 'http';
import next from 'next';
import { initSocket } from './src/lib/socket.js';

const dev = process.env.NODE_ENV !== 'production';
const app = next({ dev });
const handle = app.getRequestHandler();

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

(async () => {
  await app.prepare();
  
  const server = express();

  // Parse json for REST endpoints (if you add Express routes)
  // NOTE: Do NOT apply body-parsing middleware globally because it will
  // consume the request stream before Next.js can read it (causes
  // "Response body object should not be disturbed or locked" errors).
  // If you need Express-only JSON parsing, mount it on a specific path,
  // e.g. server.use('/express-api', express.json());

  // If you want to proxy Next API routes, let handle do it
  // Use a generic middleware handler to avoid path-to-regexp parsing of route patterns
  server.use((req, res) => handle(req, res));

  // Mount any Express-only routes under a namespace so they can safely
  // use body-parsing middleware without interfering with Next's request handling.
  try {
    const { default: expressRoutes } = await import('./src/server/expressRoutes.js');
    server.use('/express-api', express.json(), expressRoutes);
  } catch (e) {
    // ignore if routes not present / cannot be loaded
  }

  const httpServer = http.createServer(server);

  const io = initSocket(httpServer);

  httpServer.listen(PORT, HOST, () => {
    console.log(`> Server listening on http://${HOST}:${PORT}`);
  });
})();