const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/auth.controller');

// Registro de usuario
router.post('/registro', (req, res) => AuthController.registrar(req, res));

// Inicio de sesión
router.post('/login', (req, res) => AuthController.iniciarSesion(req, res));

// Obtener perfil del usuario autenticado
router.get('/perfil', (req, res) => AuthController.obtenerPerfil(req, res));

// Actualizar perfil
router.put('/perfil', (req, res) => AuthController.actualizarPerfil(req, res));

// Cambiar contraseña
router.put('/perfil/password', (req, res) => AuthController.cambiarPassword(req, res));

// Verificar token
router.get('/verificar-token', (req, res) => AuthController.verificarToken(req, res));

// Cerrar sesión
router.post('/logout', (req, res) => AuthController.cerrarSesion(req, res));

module.exports = router;
