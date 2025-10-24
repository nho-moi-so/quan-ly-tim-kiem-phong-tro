// Test join nhiều rooms
const io = require('socket.io-client');

const socket = io('http://localhost:3000', {
  transports: ['websocket'],
});

socket.on('connect', () => {
  console.log('✅ Connected:', socket.id);

  // Join 3 rooms
  const rooms = ['A101', 'A102', 'B203'];
  
  rooms.forEach(room => {
    socket.emit('join_room', room);
    console.log(`📤 Sent join_room: ${room}`);
  });
});

socket.on('joined', (data) => {
  console.log('✅ Joined room:', data);
});

socket.on('otp_received', (data) => {
  console.log('🔑 OTP Received:', data);
});

// Giữ kết nối 30 giây để test
setTimeout(() => {
  console.log('⏰ Test completed');
  socket.disconnect();
  process.exit(0);
}, 30000);
