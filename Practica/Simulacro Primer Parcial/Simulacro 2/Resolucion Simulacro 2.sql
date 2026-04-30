-- 1
DELIMITER //
CREATE FUNCTION calcular_descuento (precioOriginal DECIMAL(10,2), descuento INT)
RETURNS DECIMAL (10,2)
DETERMINISTIC
BEGIN
    DECLARE v_precioFinal DECIMAL (10,2);
    
    IF descuento < 0 OR descuento > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El descuento no puede ser menor a 0 ni mayor a 100.';
    ELSE
        SET v_precioFinal = precioOriginal - (descuento * precioOriginal) / 100;
        RETURN v_precioFinal;
    END IF;
END //
DELIMITER ;

-- 2
CREATE VIEW ReservasPorCliente AS
    SELECT c.cliente_id, c.nombre, COUNT(r.reserva_id) AS cantidad_reservas, MAX(r.fecha_reserva) AS ultima_reserva
    FROM Clientes c
    JOIN Reservas r ON c.cliente_id = r.cliente_id
    GROUP BY c.cliente_id, c.nombre;

-- 3
DELIMITER //
CREATE PROCEDURE registrar_reserva (
    IN p_cliente_id INT,
    IN p_paquete_id INT,
    IN p_fecha_viaje DATE
)
BEGIN
    DECLARE v_cliente_existe INT DEFAULT 0;
    DECLARE v_paquete_existe INT DEFAULT 0;
    
    -- Manejo de errores genérico para la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO logerrores (fecha_error, descripcion_error, cliente_id)
        VALUES (NOW(), 'Error inesperado al registrar reserva', p_cliente_id);
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_cliente_existe FROM clientes WHERE cliente_id = p_cliente_id;
    SELECT COUNT(*) INTO v_paquete_existe FROM paquetes WHERE paquete_id = p_paquete_id;
    
    IF v_cliente_existe = 0 OR v_paquete_existe = 0 THEN
        INSERT INTO logerrores (fecha_error, descripcion_error, cliente_id)
        VALUES (NOW(), 'Cliente o paquete no encontrado.', p_cliente_id);
        
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente o paquete no encontrado.';
    ELSE
        INSERT INTO reservas (cliente_id, paquete_id, fecha_reserva, fecha_viaje, estado, promocion_id)
        VALUES (p_cliente_id, p_paquete_id, CURDATE(), p_fecha_viaje, 'Pendiente', NULL);
        COMMIT;
    END IF;
END //
DELIMITER ;
	

-- 4

DELIMITER $$
CREATE TRIGGER validar_fecha_reserva 
BEFORE INSERT ON Reservas
FOR EACH ROW
BEGIN
	DECLARE v_msj_error VARCHAR(200);
	IF NEW.fecha_viaje < NEW.fecha_reserva THEN
		SET v_msj_error = 'La fecha de viaje NO puede ser anterior a la fecha de reserva.';
		INSERT INTO LogErrores (fecha_error, descripcion_error, cliente_id)
        VALUES (NOW(), v_msj_error, NEW.cliente_id);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msj_error;
	END IF;
END $$

DELIMITER ;

-- 5 
WITH destinos_populares AS (
    SELECT d.destino_id, d.nombre_destino, COUNT(r.reserva_id) AS total_reservas
    FROM Destinos d
    JOIN Paquetes p ON d.destino_id = p.destino_id
    JOIN Reservas r ON p.paquete_id = r.paquete_id
    GROUP BY d.destino_id, d.nombre_destino
    HAVING COUNT(r.reserva_id) > 3
)
SELECT destino_id, nombre_destino, total_reservas FROM destinos_populares;

/*
1.1. b
1.2. b
1.3. c

2.a. b
2.b. b

3.a. c
3.b. c

4.a. verdadero
4.b. verdadero
4.c. falso

5.1. d
5.2. a
5.3. b

6. a
7. no deterministica porque devuelve el valor de un numero multiplicado por un numero random
8. hay que poner un start transaction antes del if y un rollback antes del signal. 

	

        


	
	