const { Server } = require('socket.io');

// Use global object to share socket instance between server.js and Next.js webpack bundles
// This prevents Next.js from creating a separate io instance when bundling API routes
const globalForSocket = global;

function initSocket(server) {
  if (globalForSocket.__socketIO) {
    return globalForSocket.__socketIO;
  }

  const io = new Server(server, {
    cors: { origin: '*' },
  });

  io.on('connection', (socket) => {
    console.log('Socket connected', socket.id);

    socket.on('join_room', (roomCode) => {
      socket.join(roomCode);
      console.log(`${socket.id} joined ${roomCode}`);
    });

    socket.on('leave_room', (roomCode) => {
      socket.leave(roomCode);
    });

    socket.on('disconnect', () => {
      console.log('Socket disconnected', socket.id);
    });
  });

  // Store in global to share across all Node.js modules (including webpack bundles)
  globalForSocket.__socketIO = io;
  return io;
}

function getIO() {
  if (!globalForSocket.__socketIO) {
    throw new Error('Socket not initialized');
  }
  return globalForSocket.__socketIO;
}

module.exports = { initSocket, getIO };
