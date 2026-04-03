
CREATE DATABASE IF NOT EXISTS repaso_sp;
USE repaso_sp;

CREATE TABLE especialidades (
    especialidad_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    area VARCHAR(50)
);

CREATE TABLE medicos (
    medico_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    matricula VARCHAR(20),
    especialidad_id INT,
    salario DECIMAL(10,2),
    FOREIGN KEY (especialidad_id) REFERENCES especialidades (especialidad_id)
);

CREATE TABLE pacientes (
    paciente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    fecha_nacimiento DATE,
    obra_social VARCHAR(100)
);

CREATE TABLE turnos (
    turno_id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT,
    medico_id INT,
    fecha DATE,
    motivo VARCHAR(200),
    estado VARCHAR(20),
    FOREIGN KEY (paciente_id) REFERENCES pacientes (paciente_id),
    FOREIGN KEY (medico_id) REFERENCES medicos (medico_id)
);

-- 2. CARGA DE DATOS DE PRUEBA

-- Insertar Especialidades
INSERT INTO especialidades (nombre, area) VALUES
('Cardiología', 'Clínica'),
('Pediatría', 'Clínica'),
('Cirugía General', 'Quirúrgica'),
('Dermatología', 'Clínica'),
('Traumatología', 'Quirúrgica');

-- Insertar Médicos (Salarios variados para el Ejercicio 4)
INSERT INTO medicos (nombre, matricula, especialidad_id, salario) VALUES
('Dr. Roberto Gómez', 'MAT-1001', 1, 600000.00), -- Salario alto
('Dra. Laura Pérez', 'MAT-1002', 2, 350000.00),  -- Salario medio
('Dr. Carlos Ruiz', 'MAT-1003', 3, 750000.00),   -- Salario alto
('Dra. Ana Torres', 'MAT-1004', 4, 180000.00),   -- Salario bajo
('Dr. Miguel Silva', 'MAT-1005', 5, 420000.00);  -- Salario medio

-- Insertar Pacientes
INSERT INTO pacientes (nombre, fecha_nacimiento, obra_social) VALUES
('Juan Martínez', '1985-05-15', 'OSDE'),
('María Fernández', '1992-10-22', 'IOMA'),
('Lucas Giménez', '2005-03-10', 'Swiss Medical'),
('Sofía López', '1978-12-05', 'PAMI'),
('Diego Herrera', '1999-07-30', 'Galeno');

-- Insertar Turnos (Estados variados para los Ejercicios 6, 7 y 8)
INSERT INTO turnos (paciente_id, medico_id, fecha, motivo, estado) VALUES
(1, 1, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'Control de presión', 'Pendiente'),
(2, 2, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 'Chequeo anual', 'Pendiente'),
(3, 1, DATE_ADD(CURDATE(), INTERVAL 10 DAY), 'Estudios prequirúrgicos', 'Pendiente'),
(4, 3, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Operación programada', 'Atendido'),
(5, 4, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'Consulta por alergia', 'Cancelado'),
(1, 2, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'Vacunación', 'Pendiente'),
(2, 5, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Esguince', 'Atendido');
    