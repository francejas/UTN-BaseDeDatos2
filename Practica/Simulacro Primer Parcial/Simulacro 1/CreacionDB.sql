DROP DATABASE IF EXISTS simulacro1;
CREATE DATABASE simulacro1;
USE simulacro1;

-- 1. Creación de Tabla Equipos
CREATE TABLE Equipos (
    EquipoID INT PRIMARY KEY AUTO_INCREMENT,
    NombreEquipo VARCHAR(100),
    Ciudad VARCHAR(100),
    FechaFundacion DATE
);

INSERT INTO Equipos (NombreEquipo, Ciudad, FechaFundacion) VALUES
('Tigres FC', 'Buenos Aires', '1985-03-21'),
('Águilas Doradas', 'Mendoza', '1990-07-15'),
('Leones Negros', 'Cordoba', '1978-11-05');

-- 2. Creación de Tabla Jugadores
CREATE TABLE Jugadores (
    JugadorID INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    FechaNacimiento DATE,
    EquipoID INT,
    FOREIGN KEY (EquipoID) REFERENCES Equipos (EquipoID)
);

INSERT INTO Jugadores (Nombre, Apellido, FechaNacimiento, EquipoID) VALUES
('Lucas', 'González', '1995-04-12', 1),
('Matías', 'Rodríguez', '1993-09-23', 2),
('Diego', 'Fernández', '1990-01-15', 3);

-- 3. Creación de Tabla Torneos
CREATE TABLE Torneos (
    TorneoID INT PRIMARY KEY AUTO_INCREMENT,
    NombreTorneo VARCHAR(100),
    FechaInicio DATE,
    FechaFin DATE,
    Ubicacion VARCHAR(100)
);

INSERT INTO Torneos (NombreTorneo, FechaInicio, FechaFin, Ubicacion) VALUES
('Torneo Apertura', '2025-04-01', '2025-04-30', 'Buenos Aires'),
('Torneo Clausura', '2025-05-01', '2025-05-31', 'Cordoba');

-- 4. Creación de Tabla Partidos
CREATE TABLE Partidos (
    PartidoID INT PRIMARY KEY AUTO_INCREMENT,
    TorneoID INT,
    EquipoLocalID INT,
    EquipoVisitanteID INT,
    FechaPartido DATE,
    Resultado VARCHAR(50),
    FOREIGN KEY (TorneoID) REFERENCES Torneos (TorneoID),
    FOREIGN KEY (EquipoLocalID) REFERENCES Equipos (EquipoID),
    FOREIGN KEY (EquipoVisitanteID) REFERENCES Equipos (EquipoID)
);

INSERT INTO Partidos (TorneoID, EquipoLocalID, EquipoVisitanteID, FechaPartido, Resultado) VALUES
(1, 1, 2, '2025-04-10', '2-1'),
(1, 2, 3, '2025-04-15', '0-0');

-- 5. Creación de Tabla EstadisticasJugador (del diagrama)
CREATE TABLE EstadisticasJugador (
    EstadisticaID INT PRIMARY KEY AUTO_INCREMENT,
    JugadorID INT,
    PartidoID INT,
    Goles INT,
    Asistencias INT,
    TarjetasAmarillas INT,
    TarjetasRojas INT,
    FOREIGN KEY (JugadorID) REFERENCES Jugadores(JugadorID),
    FOREIGN KEY (PartidoID) REFERENCES Partidos(PartidoID)
);

-- 6. Tablas de Auditoría (necesarias para los Triggers 4 y 5)
CREATE TABLE AuditoriaInscripciones (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    TorneoID INT,
    NombreTorneo VARCHAR(100),
    FechaAuditoria TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE AuditoriaResultados (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    PartidoID INT,
    ResultadoAnterior VARCHAR(50),
    ResultadoNuevo VARCHAR(50),
    FechaAuditoria TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

	
	