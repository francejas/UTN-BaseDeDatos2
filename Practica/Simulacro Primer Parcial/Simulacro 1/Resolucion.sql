USE simulacro1;

-- 1
DELIMITER //
CREATE PROCEDURE registrarPartido (
	IN p_equipoVisitanteID INT,
    IN p_equipoLocalID INT,
    IN p_torneoID INT,
    IN p_fechaPartido DATE
)
BEGIN
	DECLARE v_equipoVisitanteID INT;
	DECLARE v_equipoLocalID INT;
    DECLARE v_msj_error VARCHAR(200);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			ROLLBACK;
            SELECT v_msj_error AS msj_error;
		END;
	START TRANSACTION;
    SELECT equipoID INTO v_equipoVisitanteID FROM Equipos WHERE equipoID=p_equipoVisitanteID;
    SELECT equipoID INTO v_equipoLocalID FROM Equipos WHERE equipoID=p_equipoLocalID;
    
    IF v_equipoVisitanteID = 0 OR v_equipoLocalID = 0 THEN
		ROLLBACK;
        SET v_msj_error = 'Equipo visitante o equipo local no existen.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msj_error;
	ELSE
		INSERT INTO Partidos (torneoID, equipoLocalID, equipoVisitanteID, FechaPartido, Resultado)
        VALUES (p_torneoID,p_equipoLocalID,p_equipoVisitanteID, NOW(), '1-0');
        COMMIT;
        SELECT 'Operacion exitosa' AS msj;
	END IF;
END//
DELIMITER ;

-- 2
DELIMITER //
CREATE PROCEDURE registrarEstadisticasJugador (
	IN p_JugadorID INT,
    IN p_PartidoID INT,
    IN p_goles INT,
    IN p_asistencias INT,
    IN p_tarjetasAmarillas INT,
    IN p_tarjetasRojas INT
)
BEGIN
	DECLARE v_msj_error VARCHAR(200);
    DECLARE v_jugadorID INT;
    DECLARE v_partidoID INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			SELECT v_msj_error AS msj_error;
		END;
	SELECT JugadorID INTO v_jugadorID FROM Jugadores WHERE JugadorID=p_JugadorID;
	SELECT PartidoID INTO v_partidoID FROM Partidos WHERE PartidoID=p_PartidoID;
    
    IF v_jugadorID = 0 THEN
		SET v_msj_error = 'Jugador inexistente.';
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =v_msj_error;
	ELSE IF v_partidoID = 0 THEN
		SET v_msj_error = 'Partido inexistente.';
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =v_msj_error;
        ELSE 
			INSERT INTO EstadisticasJugador (JugadorID, PartidoID, Goles, Asistencias, TarjetasAmarillas, TarjetasRojas)
            VALUES (p_JugadorID,p_PartidoID, p_goles, p_asistencias,p_tarjetasAmarillas,p_tarjetasRojas );
            SELECT 'Operacion exitosa' AS msj;
            END IF;
		END IF;
	
END //

DELIMITER ;

-- 4 
DELIMITER $$
CREATE TRIGGER auditarInscripcionTorneo 
AFTER INSERT ON Torneos
FOR EACH ROW
BEGIN
	INSERT INTO AuditoriaInscripciones (TorneoID, NombreTorneo, FechaAuditoria)
    VALUES (NEW.TorneoID, NEW.NombreTorneo, NOW());
END$$

DELIMITER ;

-- 5
DELIMITER $$
CREATE TRIGGER auditarCambioResultado 
AFTER UPDATE ON Partidos
FOR EACH ROW
BEGIN
	IF OLD.Resultado<>NEW.Resultado THEN
		/* aca nose si es update o insert, supongo que es un update porque se actualiza el resultado de un partido en curso */
        UPDATE AuditoriaResultados SET ResultadoAnterior=OLD.Resultado, ResultadoNuevo=NEW.Resultado;
        /* creo que aca iria un where */
	END IF;
END$$

DELIMITER ;

-- 6

DELIMITER //
CREATE FUNCTION promedioGolesPorJugador (
	p_jugadorID INT
)
RETURNS DECIMAL (10,2)
DETERMINISTIC
BEGIN
	DECLARE v_promedio DECIMAL(10,2);
    DECLARE v_cantidad_partidos INT;
    DECLARE v_cantidad_goles INT;
    
    SELECT COUNT(ej.partidoID) INTO v_cantidad_partidos 
    FROM EstadisticasJugador ej
    WHERE ej.jugadorID=p_jugadorID;
    
    SELECT SUM(ej.goles) INTO v_cantidad_goles
    FROM EstadisticasJugador ej
    WHERE ej.jugadorID=p_jugadorID;
    
   SET v_promedio = v_cantidad_goles/v_cantidad_partidos;
    
    RETURN v_promedio;
END//

DELIMITER ;

-- 7

DELIMITER //
CREATE FUNCTION estadisticasJugador (
	p_jugadorID INT
)
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
	DECLARE v_nombre VARCHAR(100);
	DECLARE v_apellido VARCHAR(100);
	DECLARE v_goles INT;
	DECLARE v_asistencias INT;

	SELECT nombre, apellido INTO v_nombre, v_apellido FROM Jugadores WHERE jugadorID=p_jugadorID;
    SELECT COUNT(ej.goles) INTO v_goles FROM EstadisticasJugador WHERE jugadorID=p_jugadorID;
    SELECT COUNT(ej.Asistencias) INTO v_asistencias FROM EstadisticasJugador WHERE jugadorID=p_jugadorID;
    
    SELECT CONCAT(v_nombre,v_apellido,v_goles,v_asistencias) ;
END//

DELIMITER ;

-- 8

    