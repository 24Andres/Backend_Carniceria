const db = require('../config/conexion_db');

class UsuarioController {
  // Obtener todos los usuarios con paginación y filtros
  async obtenerUsuarios(req, res) {
    try {
      const { activo, id_rol, pagina = 1, limite = 10 } = req.query;
      const offset = (pagina - 1) * limite;

      let condiciones = [];
      let valores = [];

      if (activo !== undefined) {
        condiciones.push("u.activo = ?");
        valores.push(activo === "true" ? 1 : 0);
      }

      if (id_rol) {
        condiciones.push("u.id_rol = ?");
        valores.push(id_rol);
      }

      const whereClause = condiciones.length > 0 ? "WHERE " + condiciones.join(" AND ") : "";

      const [usuarios] = await db.query(`
        SELECT u.id_usuario, u.nombre, u.apellido, u.telefono, u.email, u.activo,
               r.nombre_rol AS rol
        FROM usuarios u
        LEFT JOIN roles r ON u.id_rol = r.id_rol
        ${whereClause}
        LIMIT ? OFFSET ?
      `, [...valores, parseInt(limite), parseInt(offset)]);

      const [total] = await db.query(`
        SELECT COUNT(*) as total
        FROM usuarios u
        ${whereClause}
      `, valores);

      res.json({
        usuarios,
        paginacion: {
          pagina: parseInt(pagina),
          limite: parseInt(limite),
          total: total[0].total,
          paginas: Math.ceil(total[0].total / limite)
        }
      });
    } catch (error) {
      console.error("Error al obtener usuarios:", error);
      res.status(500).json({ error: 'Error al obtener usuarios', detalle: error.message });
    }
  }

  // Obtener usuario por ID
  async obtenerUsuarioPorId(req, res) {
    const { id } = req.params;
    try {
      const [usuario] = await db.query(`
        SELECT u.id_usuario, u.nombre, u.apellido, u.telefono, u.email, u.activo,
               r.nombre_rol AS rol
        FROM usuarios u
        LEFT JOIN roles r ON u.id_rol = r.id_rol
        WHERE u.id_usuario = ?
      `, [id]);

      if (usuario.length === 0) {
        return res.status(404).json({ error: 'Usuario no encontrado' });
      }

      res.json(usuario[0]);
    } catch (error) {
      console.error("Error al obtener usuario por ID:", error);
      res.status(500).json({ error: 'Error al obtener usuario', detalle: error.message });
    }
  }

  // Actualizar usuario
  async actualizar(req, res) {
    try {
      const { id } = req.params;
      const { nombre, apellido, telefono, id_rol, activo } = req.body;

      // Validaciones simples
      if (!nombre || !apellido || !telefono || !id_rol || activo === undefined) {
        return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
      }

      const [result] = await db.query(
        `UPDATE usuarios 
         SET nombre = ?, apellido = ?, telefono = ?, id_rol = ?, activo = ? 
         WHERE id_usuario = ?`,
        [nombre, apellido, telefono, id_rol, activo, id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Usuario no encontrado' });
      }

      res.json({ mensaje: 'Usuario actualizado correctamente' });
    } catch (error) {
      console.error("Error al actualizar usuario:", error);
      res.status(500).json({ error: 'Error al actualizar usuario', detalle: error.message });
    }
  }

  // Desactivar usuario
  async desactivar(req, res) {
    const { id } = req.params;
    try {
      const [result] = await db.query(
        'UPDATE usuarios SET activo = 0 WHERE id_usuario = ?',
        [id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Usuario no encontrado' });
      }

      res.json({ mensaje: 'Usuario desactivado correctamente' });
    } catch (error) {
      console.error("Error al desactivar usuario:", error);
      res.status(500).json({ error: 'Error al desactivar usuario', detalle: error.message });
    }
  }

  // Activar usuario
  async activar(req, res) {
    const { id } = req.params;
    try {
      const [result] = await db.query(
        'UPDATE usuarios SET activo = 1 WHERE id_usuario = ?',
        [id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Usuario no encontrado' });
      }

      res.json({ mensaje: 'Usuario activado correctamente' });
    } catch (error) {
      console.error("Error al activar usuario:", error);
      res.status(500).json({ error: 'Error al activar usuario', detalle: error.message });
    }
  }

  // Obtener roles disponibles
  async obtenerRoles(req, res) {
    try {
      const [roles] = await db.query('SELECT * FROM roles ORDER BY nombre_rol');
      res.json(roles);
    } catch (error) {
      console.error("Error al obtener roles:", error);
      res.status(500).json({ error: 'Error al obtener roles', detalle: error.message });
    }
  }

  // Obtener estadísticas de usuarios
  async obtenerEstadisticas(req, res) {
    try {
      const [estadisticas] = await db.query(`
        SELECT 
          COUNT(*) as total_usuarios,
          SUM(CASE WHEN activo = 1 THEN 1 ELSE 0 END) as usuarios_activos,
          SUM(CASE WHEN activo = 0 THEN 1 ELSE 0 END) as usuarios_inactivos,
          SUM(CASE WHEN id_rol = 1 THEN 1 ELSE 0 END) as clientes,
          SUM(CASE WHEN id_rol = 2 THEN 1 ELSE 0 END) as administradores
        FROM usuarios
      `);

      res.json(estadisticas[0]);
    } catch (error) {
      console.error("Error al obtener estadísticas:", error);
      res.status(500).json({ error: 'Error al obtener estadísticas', detalle: error.message });
    }
  }
}

module.exports = UsuarioController;
