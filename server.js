const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);

// Configuración de Socket.io con soporte para archivos/imágenes de hasta 10 MB
const io = new Server(server, {
  maxHttpBufferSize: 1e7, // Limitador de peso máximo por paquete (10 MB)
  cors: {
    origin: "*", 
    methods: ["GET", "POST"]
  }
});

// "Base de datos" en memoria para validar usuarios y guardar sus sockets
const users = {
  'USER_1_TOKEN': { name: 'ROJO', socketId: null },
  'USER_2_TOKEN': { name: 'ROSA', socketId: null }
};

// Middleware para autenticar al usuario mediante el token recibido en los headers
io.use((socket, next) => {
  const token = socket.handshake.headers.token;
  if (token && users[token]) {
    socket.token = token;
    return next();
  }
  return next(new Error('Autenticación fallida: Token inválido'));
});

io.on('connection', (socket) => {
  const token = socket.token;
  users[token].socketId = socket.id;
  console.log(`Usuario conectado: ${users[token].name} (Socket ID: ${socket.id})`);

  // Evento para enviar mensaje (texto, imágenes o archivos)
  socket.on('send_message', (data) => {
    // Determinar quién es el destinatario (el usuario opuesto)
    const recipientToken = token === 'USER_1_TOKEN' ? 'USER_2_TOKEN' : 'USER_1_TOKEN';
    const recipientSocketId = users[recipientToken].socketId;

    // Si el destinatario está conectado, le enviamos el mensaje
    if (recipientSocketId) {
      io.to(recipientSocketId).emit('receive_message', data);
    }
  });

  // Evento para marcar mensaje como leído (tics verdes)
  socket.on('mark_as_read', (data) => {
    const senderToken = token === 'USER_1_TOKEN' ? 'USER_2_TOKEN' : 'USER_1_TOKEN';
    const senderSocketId = users[senderToken].socketId;

    if (senderSocketId) {
      io.to(senderSocketId).emit('message_read', { id: data.id });
    }
  });

  // Evento al desconectarse
  socket.on('disconnect', () => {
    console.log(`Usuario desconectado: ${users[token].name}`);
    users[token].socketId = null;
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Servidor de chat corriendo en el puerto ${PORT}`);
});