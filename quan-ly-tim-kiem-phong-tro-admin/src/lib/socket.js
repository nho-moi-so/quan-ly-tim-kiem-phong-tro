import { Server } from 'socket.io';

// Use global object to share socket instance between server.js and Next.js webpack bundles
// This prevents Next.js from creating a separate io instance when bundling API routes
const globalForSocket = global;

export function initSocket(server) {
  if (globalForSocket.__socketIO) {
    return globalForSocket.__socketIO;
  }

  const io = new Server(server, {
    cors: { 
      origin: '*',
      methods: ['GET', 'POST'],
      credentials: true
    },
    transports: ['websocket', 'polling'],
    allowEIO3: true
  });

  io.on('connection', (socket) => {
    console.log('✅ Socket connected:', socket.id);

    socket.on('join_room', (roomCode) => {
      socket.join(roomCode);
      console.log(`✅ ${socket.id} joined room: ${roomCode}`);
      socket.emit('joined', { roomCode, success: true });
    });

    socket.on('leave_room', (roomCode) => {
      socket.leave(roomCode);
      console.log(`👋 ${socket.id} left room: ${roomCode}`);
    });

    socket.on('disconnect', () => {
      console.log('❌ Socket disconnected:', socket.id);
    });
  });

  // Store in global to share across all Node.js modules (including webpack bundles)
  globalForSocket.__socketIO = io;
  return io;
}

export function getIO() {
  if (!globalForSocket.__socketIO) {
    throw new Error('Socket not initialized');
  }
  return globalForSocket.__socketIO;
}
