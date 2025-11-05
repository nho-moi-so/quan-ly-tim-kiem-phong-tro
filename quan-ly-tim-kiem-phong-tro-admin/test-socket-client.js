const { io } = require("socket.io-client");
const socket = io("http://localhost:3000", { transports: ["websocket"] });

socket.on("connect", () => {
  console.log("Connected", socket.id);
  socket.emit("join_room", "A102"); // join room A102
});

socket.on("otp_received", (data) => {
  console.log("otp_received", data);
});

socket.on("disconnect", () => console.log("disconnected"));
