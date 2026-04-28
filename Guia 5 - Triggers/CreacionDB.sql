DROP DATABASE IF EXISTS tp_triggers;
CREATE DATABASE tp_triggers;
USE tp_triggers;

-- ==========================================
-- 1. TABLAS PRINCIPALES
-- ==========================================

CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY,
    Nombre VARCHAR(50),
    Apellido VARCHAR(50),
    Email VARCHAR(100),
    Telefono VARCHAR(15)
);

CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY,
    NombreProducto VARCHAR(100),
    Costo DECIMAL(10, 2), -- Agregado para el Ejercicio 6
    Precio DECIMAL(10, 2),
    Stock INT DEFAULT 100 -- Agregado para el Ejercicio 10 y 15
);

CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY,
    FechaPedido DATE,
    ClienteID INT,
    PrecioTotal DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

CREATE TABLE DetallesPedido (
    DetalleID INT PRIMARY KEY,
    PedidoID INT,
    ProductoID INT,
    Cantidad INT,
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

-- ==========================================
-- 2. TABLAS DE AUDITORÍA (Según la resolución)
-- ==========================================

-- Auditorías de Clientes
CREATE TABLE AuditoriaClientes (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    ClienteID INT,
    Nombre VARCHAR(50),
    Apellido VARCHAR(50),
    Email VARCHAR(100),
    Telefono VARCHAR(15),
    FechaInsercion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Tipo_Operacion VARCHAR(20)
);

CREATE TABLE AuditoriaActualizacionClientes (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    ClienteID INT,
    NombreAntiguo VARCHAR(50),
    NombreNuevo VARCHAR(50),
    FechaActualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Tipo_Operacion VARCHAR(20)
);

CREATE TABLE AuditoriaEliminacionClientes (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    ClienteID INT,
    Nombre VARCHAR(50),
    Apellido VARCHAR(50),
    FechaEliminacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Tipo_Operacion VARCHAR(20)
);

-- Auditorías de Pedidos
CREATE TABLE AuditoriaPedidos (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    PedidoID INT,
    ClienteID INT,
    FechaPedido DATE,
    FechaInsercion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE AuditoriaActualizacionPedidos (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    PedidoID INT,
    ClienteIDAntiguo INT,
    ClienteIDNuevo INT,
    FechaActualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE AuditoriaEliminacionPedidos (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    PedidoID INT,
    ClienteID INT,
    FechaEliminacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Auditorías de Productos
CREATE TABLE AuditoriaProductos (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    ProductoID INT,
    NombreProducto VARCHAR(100),
    Precio DECIMAL(10, 2),
    FechaInsercion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE AuditoriaActualizacionProductos (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    ProductoID INT,
    NombreProductoAntiguo VARCHAR(100),
    NombreProductoNuevo VARCHAR(100),
    FechaActualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE AuditoriaEliminacionProductos (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    ProductoID INT,
    NombreProducto VARCHAR(100),
    FechaEliminacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 3. INSERCIÓN DE DATOS DE PRUEBA
-- ==========================================

INSERT INTO Clientes (ClienteID, Nombre, Apellido, Email, Telefono) VALUES
(1, 'Juan', 'Pérez', 'juan@email.com', '123-456-7890'),
(2, 'María', 'Gómez', 'maria@email.com', '987-654-3210'),
(3, 'Carlos', 'López', 'carlos@email.com', '555-123-4567');

INSERT INTO Productos (ProductoID, NombreProducto, Costo, Precio, Stock) VALUES 
(101, 'Producto 1', 8.00, 10.99, 50),
(102, 'Producto 2', 15.00, 19.99, 30),
(103, 'Producto 3', 4.00, 5.99, 100);

INSERT INTO Pedidos (PedidoID, FechaPedido, ClienteID) VALUES
(1001, '2023-10-15', 1),
(1002, '2023-10-16', 2),
(1003, '2023-10-17', 3),
(1004, '2023-10-18', 1);

INSERT INTO DetallesPedido (DetalleID, PedidoID, ProductoID, Cantidad) VALUES
(2001, 1001, 101, 2),
(2002, 1001, 102, 1),
(2003, 1002, 103, 3),
(2004, 1003, 101, 1),
(2005, 1003, 103, 2),
(2006, 1004, 102, 2);