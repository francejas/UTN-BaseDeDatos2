CREATE DATABASE bdd2_integradores;
USE bdd2_integradores;

-- Tabla Clientes
CREATE TABLE Clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    ciudad VARCHAR(50),
    email VARCHAR(50)
);

-- Tabla Productos
CREATE TABLE Productos (
    producto_id INT PRIMARY KEY,
    nombre_producto VARCHAR(50),
    categoria VARCHAR(50),
    precio DECIMAL(10, 2),
    stock INT NOT NULL
);

-- Tabla Pedidos
CREATE TABLE Pedidos (
    pedido_id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    FOREIGN KEY (cliente_id) REFERENCES Clientes (cliente_id)
);

-- Tabla Detalle_Pedido
CREATE TABLE Detalle_Pedido (
    detalle_id INT PRIMARY KEY,
    pedido_id INT,
    producto_id INT,
    cantidad INT,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos (pedido_id),
    FOREIGN KEY (producto_id) REFERENCES Productos (producto_id)
);

-- Tabla Auditoria Errores
CREATE TABLE Auditoria_Errores (
    auditoria_id INT AUTO_INCREMENT PRIMARY KEY,
    procedimiento VARCHAR(100),
    operacion VARCHAR(100),
    mensaje_error VARCHAR(255),
    fecha_error DATETIME
);

-- Tabla para auditoria de operaciones masivas (Ejercicio 5)
CREATE TABLE Auditoria_Operaciones (
    auditoria_op_id INT AUTO_INCREMENT PRIMARY KEY,
    categoria VARCHAR(50),
    fecha_operacion DATETIME,
    cantidad_productos_actualizados INT
);

-- Tabla para alertas de stock (Ejercicio 6)
CREATE TABLE Alertas_Stock (
    alerta_id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT,
    stock_actual INT,
    fecha_alerta DATETIME,
    FOREIGN KEY (producto_id) REFERENCES Productos (producto_id)
);

-- Datos de ejemplo
INSERT INTO Clientes (nombre, apellido, ciudad, email) VALUES
('Ana', 'Garcia', 'Madrid', 'ana.garcia@email.com'),
('Juan', 'Pérez', 'Barcelona', 'juan.perez@email.com'),
('Maria', 'López', 'Madrid', 'maria.lopez@email.com'),
('Carlos', 'Ruiz', 'Valencia', 'carlos.ruiz@email.com');

INSERT INTO Productos (producto_id, nombre_producto, categoria, precio, stock) VALUES
(1, 'Laptop', 'Electrónicos', 1200.00, 5),
(2, 'Tablet', 'Electrónicos', 300.00, 10),
(3, 'Libro', 'Libros', 25.00, 20),
(4, 'Smartphone', 'Electrónicos', 800.00, 8),
(5, 'Auriculares', 'Electrónicos', 150.00, 15),
(6, 'Monitor', 'Electrónicos', 400.00, 7);

INSERT INTO Pedidos (pedido_id, cliente_id, fecha_pedido) VALUES
(1, 1, '2023-10-26'),
(2, 1, '2023-11-10'),
(3, 2, '2023-11-05'),
(4, 3, '2023-10-28'),
(5, 4, '2023-11-15');

INSERT INTO Detalle_Pedido (detalle_id, pedido_id, producto_id, cantidad) VALUES
(1, 1, 1, 1),
(2, 1, 2, 2),
(3, 2, 4, 1),
(4, 3, 3, 3),
(5, 4, 1, 1),
(6, 5, 2, 2),
(7, 5, 4, 1);