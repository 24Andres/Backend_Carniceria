-- Base de datos para Carnicería Delicias a tu Diestra
CREATE DATABASE IF NOT EXISTS carniceria_delicias;
USE carniceria_delicias;

-- Tabla de roles
CREATE TABLE roles (
    id_rol INT PRIMARY KEY AUTO_INCREMENT,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de usuarios
CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    tipo_documento ENUM('CC', 'CE', 'TI', 'RC', 'NIT') NOT NULL,
    numero_documento VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(15) NOT NULL,
    direccion VARCHAR (100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
);

-- Tabla de direcciones de entrega
CREATE TABLE direcciones_entrega (
    id_direccion INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    direccion TEXT NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    codigo_postal VARCHAR(10),
    telefono_contacto VARCHAR(15),
    es_principal BOOLEAN DEFAULT FALSE,
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- Tabla de categorías de productos
CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    imagen_url VARCHAR(255),
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de productos
CREATE TABLE productos (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    id_categoria INT NOT NULL,
    imagen_url VARCHAR(255),
    unidad_medida ENUM('kg', 'lb', 'unidad', 'paquete') NOT NULL,
    stock_actual INT DEFAULT 0,
    stock_minimo INT DEFAULT 5,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

-- Tabla de promociones
CREATE TABLE promociones (
    id_promocion INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    tipo_descuento ENUM('porcentaje', 'fijo') NOT NULL,
    valor_descuento DECIMAL(10,2) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    uso_maximo INT DEFAULT NULL,
    uso_actual INT DEFAULT 0,
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de carrito de compras
CREATE TABLE carrito (
    id_carrito INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(10,2) NOT NULL,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    UNIQUE KEY unique_carrito_usuario_producto (id_usuario, id_producto)
);

-- Tabla de pedidos
CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_direccion INT NOT NULL,
    numero_pedido VARCHAR(20) NOT NULL UNIQUE,
    subtotal DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2) DEFAULT 0,
    impuestos DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    estado ENUM('pendiente', 'procesado', 'en_camino', 'entregado', 'cancelado') DEFAULT 'pendiente',
    metodo_pago ENUM('contra_entrega', 'transferencia_nequi', 'transferencia_bancolombia', 'transferencia_daviplata') NOT NULL,
    observaciones TEXT,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_entrega DATETIME,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_direccion) REFERENCES direcciones_entrega(id_direccion)
);

-- Tabla de detalles de pedido
CREATE TABLE detalles_pedido (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- Tabla de recetas
CREATE TABLE recetas (
    id_receta INT PRIMARY KEY AUTO_INCREMENT,
    nombre_receta VARCHAR(200) NOT NULL,
    producto_final_id INT NOT NULL,
    descripcion TEXT,
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    usuario_creador INT NOT NULL,
    FOREIGN KEY (producto_final_id) REFERENCES productos(id_producto),
    FOREIGN KEY (usuario_creador) REFERENCES usuarios(id_usuario)
);

-- Tabla de ingredientes de recetas
CREATE TABLE ingredientes_receta (
    id_ingrediente INT PRIMARY KEY AUTO_INCREMENT,
    id_receta INT NOT NULL,
    producto_ingrediente_id INT NOT NULL,
    cantidad_base DECIMAL(10,2) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    orden INT DEFAULT 1,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_receta) REFERENCES recetas(id_receta) ON DELETE CASCADE,
    FOREIGN KEY (producto_ingrediente_id) REFERENCES productos(id_producto)
);

-- Tabla de transformaciones de productos
CREATE TABLE transformaciones (
    id_transformacion INT PRIMARY KEY AUTO_INCREMENT,
    producto_base_id INT NOT NULL,
    producto_elaborado_id INT NOT NULL,
    cantidad_base DECIMAL(10,2) NOT NULL,
    cantidad_elaborada DECIMAL(10,2) NOT NULL,
    insumos_adicionales TEXT,
    id_receta INT NULL,
    fecha_transformacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_responsable INT NOT NULL,
    FOREIGN KEY (producto_base_id) REFERENCES productos(id_producto),
    FOREIGN KEY (producto_elaborado_id) REFERENCES productos(id_producto),
    FOREIGN KEY (id_receta) REFERENCES recetas(id_receta),
    FOREIGN KEY (usuario_responsable) REFERENCES usuarios(id_usuario)
);

-- Tabla de ajustes de inventario
CREATE TABLE ajustes_inventario (
    id_ajuste INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    tipo_ajuste ENUM('entrada', 'salida', 'ajuste') NOT NULL,
    cantidad INT NOT NULL,
    motivo TEXT NOT NULL,
    usuario_responsable INT NOT NULL,
    fecha_ajuste TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (usuario_responsable) REFERENCES usuarios(id_usuario)
);

-- Tabla de auditoría
CREATE TABLE auditoria (
    id_auditoria INT PRIMARY KEY AUTO_INCREMENT,
    tabla_afectada VARCHAR(100) NOT NULL,
    accion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    registro_id INT NOT NULL,
    datos_anteriores JSON,
    datos_nuevos JSON,
    usuario_responsable INT NOT NULL,
    fecha_accion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT,
    FOREIGN KEY (usuario_responsable) REFERENCES usuarios(id_usuario)
);

-- Tabla de facturas
CREATE TABLE facturas (
    id_factura INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    numero_factura VARCHAR(20) NOT NULL UNIQUE,
    fecha_factura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2) DEFAULT 0,
    impuestos DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    estado_pago ENUM('pendiente', 'pagado', 'cancelado', 'reembolsado') DEFAULT 'pendiente',
    metodo_pago ENUM('contra_entrega', 'transferencia_nequi', 'transferencia_bancolombia', 'transferencia_daviplata') NOT NULL,
    referencia_pago VARCHAR(100),
    fecha_pago DATETIME,
    observaciones TEXT,
    nombre_cliente VARCHAR(200) NOT NULL,
    documento_cliente VARCHAR(20) NOT NULL,
    direccion_cliente TEXT NOT NULL,
    ciudad_cliente VARCHAR(100) NOT NULL,
    telefono_cliente VARCHAR(15),
    email_cliente VARCHAR(100),
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

-- Tabla de notificaciones
CREATE TABLE notificaciones (
    id_notificacion INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo ENUM('info', 'success', 'warning', 'error') NOT NULL,
    leida BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- Insertar datos iniciales
INSERT INTO roles (nombre_rol, descripcion) VALUES 
('cliente', 'Usuario cliente de la tienda'),
('administrador', 'Administrador del sistema');

INSERT INTO categorias (nombre_categoria, descripcion) VALUES 
('Res', 'Cortes de carne de res fresca'),
('Pollo', 'Productos de pollo fresco'),
('Cerdo', 'Cortes de carne de cerdo'),
('Embutidos', 'Embutidos artesanales y procesados');

-- Crear índices para mejorar el rendimiento
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_documento ON usuarios(numero_documento);
CREATE INDEX idx_productos_categoria ON productos(id_categoria);
CREATE INDEX idx_productos_activo ON productos(activo);
CREATE INDEX idx_pedidos_usuario ON pedidos(id_usuario);
CREATE INDEX idx_pedidos_estado ON pedidos(estado);
CREATE INDEX idx_carrito_usuario ON carrito(id_usuario);
CREATE INDEX idx_auditoria_tabla ON auditoria(tabla_afectada);
CREATE INDEX idx_auditoria_fecha ON auditoria(fecha_accion);
CREATE INDEX idx_facturas_pedido ON facturas(id_pedido);
CREATE INDEX idx_facturas_numero ON facturas(numero_factura);
CREATE INDEX idx_facturas_estado ON facturas(estado_pago);
CREATE INDEX idx_facturas_fecha ON facturas(fecha_factura);
CREATE INDEX idx_facturas_documento ON facturas(documento_cliente);
CREATE INDEX idx_notificaciones_usuario ON notificaciones(id_usuario);
CREATE INDEX idx_notificaciones_leida ON notificaciones(leida);
CREATE INDEX idx_recetas_producto_final ON recetas(producto_final_id);
CREATE INDEX idx_recetas_usuario_creador ON recetas(usuario_creador);
CREATE INDEX idx_recetas_activa ON recetas(activa);
CREATE INDEX idx_ingredientes_receta ON ingredientes_receta(id_receta);
CREATE INDEX idx_ingredientes_producto ON ingredientes_receta(producto_ingrediente_id);
CREATE INDEX idx_transformaciones_receta ON transformaciones(id_receta);


