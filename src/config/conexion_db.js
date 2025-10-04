const mysql = require('mysql2/promise');
require('dotenv').config();

const db = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

module.exports = db;

/*Ese código crea una conexión a MySQL usando
el paquete mysql2/promise, tomando los datos de conexión
(host, usuario, contraseña, base de datos) desde un archivo .env.
Después exporta esa conexión (db) para que otros archivos del proyecto la usen.*/