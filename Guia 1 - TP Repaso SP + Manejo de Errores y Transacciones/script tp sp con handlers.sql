DROP DATABASE IF EXISTS tp_sp_manejadores;
CREATE DATABASE tp_sp_manejadores;
USE tp_sp_manejadores;

CREATE TABLE ejemplo_tabla (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50)
);

CREATE TABLE socios (
    id_socio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    fecha_nacimiento DATE,
    direccion VARCHAR(100),
    telefono VARCHAR(20)
);

CREATE TABLE planes (
    id_plan INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    duracion INT,
    precio DECIMAL(10, 2),
    servicios TEXT
);

-- ¡Acá está la tabla corregida según el DER!
CREATE TABLE actividades (
    id_actividad INT AUTO_INCREMENT PRIMARY KEY,
    id_socio INT,
    id_plan INT,
    fecha DATE,
    actividad VARCHAR(50),
    FOREIGN KEY (id_socio) REFERENCES socios(id_socio),
    FOREIGN KEY (id_plan) REFERENCES planes(id_plan)
);

-- Insertar datos en ejemplo_tabla
INSERT INTO ejemplo_tabla (nombre) VALUES ('Ejemplo 1'), ('Ejemplo 2');

-- Insertar datos en socios
INSERT INTO socios (nombre, apellido, fecha_nacimiento, direccion, telefono) 
VALUES 
('Juan', 'Pérez', '1990-05-15', 'Calle Falsa 123', '123456789'),
('María', 'Gómez', '1985-10-20', 'Avenida Siempre Viva 456', '987654321');

-- Insertar datos en planes
INSERT INTO planes (nombre, duracion, precio, servicios) 
VALUES 
('Plan Básico', 30, 50.00, 'Acceso a gimnasio'),
('Plan Premium', 90, 120.00, 'Acceso a gimnasio + clases dirigidas');

-- Insertar datos en actividades (Actualizado con las nuevas columnas)
INSERT INTO actividades (id_socio, id_plan, fecha, actividad) 
VALUES 
(1, 1, '2026-04-10', 'Musculación'),
(2, 2, '2026-04-11', 'Zumba');

-- Guardar el sql_mode actual
SET @old_sql_mode = @@sql_mode;

-- Desactivar restricciones temporalmente
SET sql_mode = '';

-- Restaurar el sql_mode original
SET sql_mode = @old_sql_mode;
