
CREATE DATABASE db_vistas_indices;
USE db_vistas_indices;

-- Tabla Clientes
CREATE TABLE Clientes (
    cliente_id INT PRIMARY KEY,
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
    precio DECIMAL(10, 2)
);

-- Tabla Pedidos
CREATE TABLE Pedidos (
    pedido_id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);

-- Tabla Detalle_Pedido
CREATE TABLE Detalle_Pedido (
    detalle_id INT PRIMARY KEY,
    pedido_id INT,
    producto_id INT,
    cantidad INT,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(pedido_id),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id)
);

-- Insertar registros en Clientes
INSERT INTO Clientes (cliente_id, nombre, apellido, ciudad, email) VALUES
(1, 'Ana', 'García', 'Madrid', 'ana.garcia@email.com'),
(2, 'Juan', 'Pérez', 'Barcelona', 'juan.perez@email.com'),
(3, 'María', 'López', 'Madrid', 'maria.lopez@email.com'),
(4, 'Carlos', 'Ruiz', 'Valencia', 'carlos.ruiz@email.com');

-- Insertar registros en Productos
INSERT INTO Productos (producto_id, nombre_producto, categoria, precio) VALUES
(1, 'Laptop', 'Electrónicos', 1200.00),
(2, 'Tablet', 'Electrónicos', 300.00),
(3, 'Libro', 'Libros', 25.00),
(4, 'Smartphone', 'Electrónicos', 800.00);

-- Insertar registros en Pedidos
INSERT INTO Pedidos (pedido_id, cliente_id, fecha_pedido) VALUES
(1, 1, '2023-10-26'),
(2, 1, '2023-11-10'),
(3, 2, '2023-11-05'),
(4, 3, '2023-10-28'),
(5, 4, '2023-11-15');

-- Insertar registros en Detalle_Pedido
INSERT INTO Detalle_Pedido (detalle_id, pedido_id, producto_id, cantidad) VALUES
(1, 1, 1, 1),
(2, 1, 2, 2),
(3, 2, 4, 1),
(4, 3, 3, 3),
(5, 4, 1, 1),
(6, 5, 2, 2),
(7, 5, 4, 1);
