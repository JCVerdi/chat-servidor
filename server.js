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

  // 1. Manejo de envío de mensajes
  socket.on('send_message', (data) => {
    const recipientToken = socket.token === 'USER_1_TOKEN' ? 'USER_2_TOKEN' : 'USER_1_TOKEN';
    const recipientSocketId = activeUsers.get(recipientToken);

    // Creamos el mensaje con ID y estado no leído
    const messageData = {
      id: data.id || Date.now().toString(),
      sender: socket.token,
      text: data.text || data, // Admite si le mandas texto directo o un objeto
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      read: false
    };

    // Enviar al destinatario (si está conectado)
    if (recipientSocketId) {
      io.to(recipientSocketId).emit('receive_message', messageData);
    }
  });

  // 2. NUEVO: Evento para avisar que el destinatario ya leyó el mensaje
  socket.on('mark_as_read', (data) => {
    const senderToken = socket.token === 'USER_1_TOKEN' ? 'USER_2_TOKEN' : 'USER_1_TOKEN';
    const senderSocketId = activeUsers.get(senderToken);

    // Le notificamos únicamente a la persona que envió el mensaje original
    if (senderSocketId) {
      io.to(senderSocketId).emit('message_read', { id: data.id });
    }
  });

  socket.on('disconnect', () => {
    activeUsers.delete(socket.token);
    console.log(`🔴 Usuario desconectado: ${socket.token}`);
  });
});

server.listen(3000, () => console.log('🚀 Servidor de Chat listo en puerto 3000'));