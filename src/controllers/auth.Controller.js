    const db = require('../config/conexion_db');
    const bcrypt = require('bcrypt');

    class AuthController {
    // Registro de usuario
    static async registrar(req, res) {
        try {
        console.log('📥 Datos recibidos en el backend:', req.body);
        const { nombre, apellido, tipo_documento, numero_documento, telefono, direccion, email, password } = req.body;

        // Validaciones básicas
        if (!nombre || !apellido || !tipo_documento || !numero_documento || !telefono || !direccion || !email || !password) {
            return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
        }
        if (!email.includes('@')) {
            return res.status(400).json({ mensaje: 'El email no es válido' });
        }

        // Verificar si el email ya existe
        const [usuariosEmail] = await db.query('SELECT * FROM usuarios WHERE email = ?', [email]);
        if (usuariosEmail.length > 0) {
            return res.status(400).json({ mensaje: 'El email ya está registrado' });
        }

        // Verificar si el documento ya existe
        const [usuariosDoc] = await db.query('SELECT * FROM usuarios WHERE numero_documento = ?', [numero_documento]);
        if (usuariosDoc.length > 0) {
            return res.status(400).json({ mensaje: 'El número de documento ya está registrado' });
        }

        // Hashear contraseña
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insertar usuario
        const [resultado] = await db.query(
    `INSERT INTO usuarios 
    (nombre, apellido, tipo_documento, numero_documento, telefono, direccion, email, password_hash, id_rol, activo) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [nombre, apellido, tipo_documento, numero_documento, telefono, direccion, email, hashedPassword, 1, true]
    );


        res.status(201).json({
            mensaje: 'Usuario registrado exitosamente',
            usuario: { id_usuario: resultado.insertId, nombre, apellido, email, rol: 'cliente' }
        });

        } catch (error) {
        console.error('Error en registro:', error);
        res.status(500).json({ mensaje: 'Error interno del servidor', error: error.message });
        }
    }

    // Inicio de sesión
    static async iniciarSesion(req, res) {
        try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ mensaje: 'Email y contraseña son obligatorios' });
        }

        // Buscar usuario
        const [usuarios] = await db.query('SELECT * FROM usuarios WHERE email = ?', [email]);
        if (usuarios.length === 0) {
            return res.status(401).json({ mensaje: 'Credenciales inválidas' });
        }

        const usuario = usuarios[0];

        // Verificar contraseña
        const passwordValida = await bcrypt.compare(password, usuario.password);
        if (!passwordValida) {
            return res.status(401).json({ mensaje: 'Credenciales inválidas' });
        }

        if (!usuario.activo) {
            return res.status(401).json({ mensaje: 'Cuenta desactivada. Contacte al administrador' });
        }

        res.json({
            mensaje: 'Inicio de sesión exitoso',
            usuario: { id_usuario: usuario.id_usuario, nombre: usuario.nombre, apellido: usuario.apellido, email: usuario.email, rol: usuario.id_rol }
        });

        } catch (error) {
        console.error('Error en inicio de sesión:', error);
        res.status(500).json({ mensaje: 'Error interno del servidor', error: error.message });
        }
    }

    // Obtener perfil
    static async obtenerPerfil(req, res) {
        try {
        const { id } = req.params; // ejemplo: /perfil/:id
        const [usuarios] = await db.query('SELECT id_usuario, nombre, apellido, email, telefono, direccion, id_rol FROM usuarios WHERE id_usuario = ?', [id]);
        if (usuarios.length === 0) {
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }
        res.json({ usuario: usuarios[0] });
        } catch (error) {
        console.error('Error al obtener perfil:', error);
        res.status(500).json({ mensaje: 'Error interno del servidor', error: error.message });
        }
    }

    // Cambiar contraseña
    static async cambiarPassword(req, res) {
        try {
        const { id } = req.params; // ejemplo: /cambiar-password/:id
        const { password_actual, nueva_password } = req.body;
        if (!password_actual || !nueva_password) {
            return res.status(400).json({ mensaje: 'Debe enviar ambas contraseñas' });
        }

        const [usuarios] = await db.query('SELECT * FROM usuarios WHERE id_usuario = ?', [id]);
        if (usuarios.length === 0) {
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }

        const usuario = usuarios[0];
        const passwordValida = await bcrypt.compare(password_actual, usuario.password);
        if (!passwordValida) {
            return res.status(400).json({ mensaje: 'La contraseña actual es incorrecta' });
        }

        const hashedPassword = await bcrypt.hash(nueva_password, 10);
        await db.query('UPDATE usuarios SET password = ? WHERE id_usuario = ?', [hashedPassword, id]);

        res.json({ mensaje: 'Contraseña cambiada exitosamente' });

        } catch (error) {
        console.error('Error al cambiar contraseña:', error);
        res.status(500).json({ mensaje: 'Error interno del servidor', error: error.message });
        }
    }

    // Cerrar sesión (sólo frontend elimina datos)
    static async cerrarSesion(req, res) {
        try {
        res.json({ mensaje: 'Sesión cerrada exitosamente' });
        } catch (error) {
        console.error('Error al cerrar sesión:', error);
        res.status(500).json({ mensaje: 'Error interno del servidor', error: error.message });
        }
    }
    }

    module.exports = AuthController;
