const express = require('express');
const UsuarioController = require('../controllers/usuarios.controller');

const router = express.Router();
const usuarioController = new UsuarioController();

// Obtener todos los usuarios con paginación y filtros
router.get('/', (req, res) => usuarioController.obtenerUsuarios(req, res));

// Obtener roles disponibles (ruta específica)
router.get('/extras/roles', (req, res) => usuarioController.obtenerRoles(req, res));

// Obtener estadísticas de usuarios (ruta específica)
router.get('/extras/estadisticas', (req, res) => usuarioController.obtenerEstadisticas(req, res));

// Obtener usuario por ID (ruta dinámica)
router.get('/:id', (req, res) => usuarioController.obtenerUsuarioPorId(req, res));

// Actualizar usuario
router.put('/:id', (req, res) => usuarioController.actualizar(req, res));

// Desactivar usuario
router.put('/:id/desactivar', (req, res) => usuarioController.desactivar(req, res));

// Activar usuario
router.put('/:id/activar', (req, res) => usuarioController.activar(req, res));

module.exports = router;
