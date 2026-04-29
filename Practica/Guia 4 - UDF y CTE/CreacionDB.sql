CREATE DATABASE IF NOT EXISTS tp_bases_datos;
USE tp_bases_datos;

-- 1. CREACIÓN DE TABLAS
CREATE TABLE Clientes (
    cliente_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL
);

CREATE TABLE Departamentos (
    departamento_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_departamento VARCHAR(100) NOT NULL,
    jefe_id INT DEFAULT NULL
);

CREATE TABLE Empleados (
    empleado_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    departamento_id INT NOT NULL,
    fecha_contratacion DATE NOT NULL,
    salario DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_departamento_id FOREIGN KEY (departamento_id) REFERENCES Departamentos(departamento_id)
);

CREATE TABLE Ventas (
    venta_id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_cliente_id FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);

-- 2. INSERCIÓN DE DATOS DE PRUEBA

-- Clientes (Incluye un duplicado exacto para el Ejercicio 8 de CTE)
INSERT INTO Clientes (nombre, apellido) VALUES 
('Juan', 'Perez'),
('Maria', 'Gomez'),
('Carlos', 'Lopez'),
('Ana', 'Martinez'),
('Juan', 'Perez'), -- Duplicado intencional
('Luis', 'SinVentas'); -- Cliente para el Ejercicio 8 de UDF

-- Departamentos
INSERT INTO Departamentos (nombre_departamento, jefe_id) VALUES 
('Gerencia', NULL),        -- Depto 1
('Sistemas', 1),           -- Depto 2
('Ventas', 1),             -- Depto 3
('Recursos Humanos', 2);   -- Depto 4

-- Empleados (Incluye antigüedades > 5 años y salarios > 4000)
INSERT INTO Empleados (nombre, departamento_id, fecha_contratacion, salario) VALUES 
('Roberto Gerente', 1, '2015-03-01', 8500.00),
('Laura Sistemas', 2, '2018-06-15', 5200.00),
('Diego Desarrollador', 2, '2022-01-10', 3500.00),
('Sofia Ventas', 3, '2017-11-20', 4100.00),
('Martin Junior', 3, '2023-08-05', 2800.00),
('Elena RRHH', 4, '2020-02-14', 3100.00);

-- Ventas (Incluye ventas > 1000, múltiples compras de un cliente y fechas del mes actual)
INSERT INTO Ventas (cliente_id, fecha_venta, valor) VALUES 
(1, '2023-05-10', 1500.00),
(1, '2023-08-22', 450.00),
(1, '2024-01-15', 2100.00),
(1, CURDATE(), 500.00), -- Venta de este mes (para Ej. 10 de CTE)
(2, '2024-02-10', 800.00),
(3, '2023-11-05', 5500.00), -- Venta alta (> 5000 para Ej. 6 de CTE)
(3, CURDATE() - INTERVAL 10 DAY, 1200.00),
(4, '2024-03-20', 300.00);