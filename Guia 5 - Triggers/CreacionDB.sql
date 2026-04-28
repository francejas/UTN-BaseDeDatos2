DROP DATABASE IF EXISTS tp_triggers;
CREATE DATABASE tp_triggers;
USE tp_triggers;

-- 1. TABLA CLIENTES 
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY, 
    Nombre VARCHAR(50), 
    Apellido VARCHAR(50), 
    Email VARCHAR(100), 
    Telefono VARCHAR(15) 
); 

-- 2. TABLA PRODUCTOS 
CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY, 
    NombreProducto VARCHAR(100), 
    Precio DECIMAL(10, 2), 
    Stock INT DEFAULT 100 
);

-- 3. TABLA PEDIDOS 
CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY, 
    FechaPedido DATE,
    ClienteID INT, 
    PrecioTotal DECIMAL(10,2) DEFAULT 0.00, 
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

-- 4. TABLA DETALLES PEDIDO 
CREATE TABLE DetallesPedido (
    DetalleID INT PRIMARY KEY, 
    PedidoID INT, 
    ProductoID INT,
    Cantidad INT, 
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID), 
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

-- 5. TABLA AUDITORÍA 
CREATE TABLE AuditoriaClientes (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT, 
    ClienteID INT, 
    Nombre VARCHAR(50), 
    Apellido VARCHAR(50), 
    Email VARCHAR(100), 
    Telefono VARCHAR(15), 
    FechaInsercion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- INSERCIÓN DE DATOS DE PRUEBA
-- ==========================================

-- Inserts Clientes 
INSERT INTO Clientes (ClienteID, Nombre, Apellido, Email, Telefono) VALUES 
(1, 'Juan', 'Pérez', 'juan@email.com', '123-456-7890'), 
(2, 'María', 'Gómez', 'maria@email.com', '987-654-3210'), 
(3, 'Carlos', 'López', 'carlos@email.com', '555-123-4567'); 

-- Inserts Productos 
INSERT INTO Productos (ProductoID, NombreProducto, Precio, Stock) VALUES 
(101, 'Producto 1', 10.99, 50),
(102, 'Producto 2', 19.99, 30), 
(103, 'Producto 3', 5.99, 100); 

-- Inserts Pedidos
INSERT INTO Pedidos (PedidoID, FechaPedido, ClienteID) VALUES 
(1001, '2023-10-15', 1), 
(1002, '2023-10-16', 2), 
(1003, '2023-10-17', 3), 
(1004, '2023-10-18', 1); 

-- Inserts DetallesPedido 
INSERT INTO DetallesPedido (DetalleID, PedidoID, ProductoID, Cantidad) VALUES
(2001, 1001, 101, 2),
(2002, 1001, 102, 1), 
(2003, 1002, 103, 3), 
(2004, 1003, 101, 1),
(2005, 1003, 103, 2), 
(2006, 1004, 102, 2); 