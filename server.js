const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

// Solo 2 tokens válidos para vosotros dos
const VALID_TOKENS = ['USER_1_TOKEN', 'USER_2_TOKEN'];
const activeUsers = new Map(); // token -> socketId

io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  if (VALID_TOKENS.includes(token)) {
    socket.token = token;
    return next();
  }
  next(new Error('Acceso no autorizado'));
});

io.on('connection', (socket) => {
  activeUsers.set(socket.token, socket.id);
  console.log(`🟢 Usuario conectado: ${socket.token}`);

  // Cuando uno envía un mensaje, se le reenvía al otro inmediatamente
  socket.on('send_message', (text) => {
    const recipientToken = socket.token === 'USER_1_TOKEN' ? 'USER_2_TOKEN' : 'USER_1_TOKEN';
    const recipientSocketId = activeUsers.get(recipientToken);

    const messageData = {
      sender: socket.token,
      text: text,
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    };

    // Enviar al destinatario (si está conectado)
    if (recipientSocketId) {
      io.to(recipientSocketId).emit('receive_message', messageData);
    }
  });

  socket.on('disconnect', () => {
    activeUsers.delete(socket.token);
    console.log(`🔴 Usuario desconectado: ${socket.token}`);
  });
});

server.listen(3000, () => console.log('🚀 Servidor de Chat listo en puerto 3000'));