-- 1
DELIMITER //
CREATE FUNCTION calcular_descuento (precioOriginal DECIMAL(10,2), descuento INT)
RETURNS DECIMAL (10,2)
DETERMINISTIC
BEGIN
	DECLARE v_precioFinal DECIMAL (10,2);
    DECLARE v_msj_error VARCHAR (200);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			SELECT v_msj_error AS msj_error;
		END;
	IF descuento < 0 OR descuento > 100 THEN
		SET v_msj_error = 'El descuento no puede ser menor a 0 ni mayor a 100.';
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msj_error;
	ELSE
		SET v_precioFinal = precioOriginal - (descuento*precioOriginal)/100;
        RETURN v_precioFinal;
	END IF;
END //

DELIMITER ;

-- 2
CREATE VIEW ReservasPorCliente AS
	SELECT cliente_id, nombre, COUNT(reserva_id) AS




	
	