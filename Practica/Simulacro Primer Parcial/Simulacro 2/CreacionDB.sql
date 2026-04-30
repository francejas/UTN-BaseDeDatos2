CREATE DATABASE IF NOT EXISTS SIMULACRO_2_agencia_viajes;
USE SIMULACRO_2_agencia_viajes;

-- 1. Tablas sin dependencias (Foreign Keys)
CREATE TABLE destinos (
    destino_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_destino VARCHAR(100) NOT NULL,
    pais VARCHAR(100) NOT NULL,
    tipo ENUM('Playa', 'Montaña', 'Ciudad', 'Aventura') NOT NULL, 
    temporada_recomendada ENUM('Verano', 'Otoño', 'Invierno', 'Primavera', 'Todo el año') NOT NULL, 
    precio_base DECIMAL(10,2) NOT NULL
);

CREATE TABLE promociones (
    promocion_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_promocion VARCHAR(100) NOT NULL,
    descripcion TEXT,
    descuento DECIMAL(5,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    condiciones TEXT
);

CREATE TABLE clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(15),
    fecha_registro DATE NOT NULL,
    tipo_cliente ENUM('Regular', 'VIP', 'Corporativo') NOT NULL
);

-- 2. Tablas con dependencias (Foreign Keys)
CREATE TABLE logerrores (
    error_id INT AUTO_INCREMENT PRIMARY KEY,
    fecha_error DATETIME NOT NULL,
    descripcion_error TEXT NOT NULL,
    cliente_id INT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

CREATE TABLE paquetes (
    paquete_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_paquete VARCHAR(100) NOT NULL,
    destino_id INT NOT NULL,
    duracion_dias INT NOT NULL,
    precio_total DECIMAL(10,2) NOT NULL,
    detalles TEXT,
    FOREIGN KEY (destino_id) REFERENCES destinos(destino_id)
);

CREATE TABLE reservas (
    reserva_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    paquete_id INT NOT NULL,
    fecha_reserva DATE NOT NULL,
    fecha_viaje DATE NOT NULL,
    estado ENUM('Pendiente', 'Confirmada', 'Cancelada') NOT NULL,
    promocion_id INT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
    FOREIGN KEY (paquete_id) REFERENCES paquetes(paquete_id),
    FOREIGN KEY (promocion_id) REFERENCES promociones(promocion_id)
);