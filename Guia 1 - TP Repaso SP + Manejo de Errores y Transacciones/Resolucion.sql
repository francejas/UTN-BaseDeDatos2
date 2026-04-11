USE tp_sp_manejadores;

-- 1
DELIMITER //

CREATE PROCEDURE insertarEnTablaInexistente ()
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			SELECT 'Error: tabla inexistente' AS Aviso;
		END;
	
    INSERT INTO tabla_no_existe (columna) VALUES ('valor');
    SELECT 'Insercion completada' AS Mensaje;
END //

DELIMITER ;

CALL insertarEnTablaInexistente();

-- 2
DELIMITER //

CREATE PROCEDURE crearTablaExistente ()
BEGIN
	DECLARE CONTINUE HANDLER FOR SQLWARNING
		BEGIN
			SELECT 'Advertencia: La tabla ya existe' AS Mensaje;
		END;
        
	CREATE TABLE IF NOT EXISTS ejemplo_tabla(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100)
);
    
    SELECT 'Creacion de la tabla completada' AS Mensaje;

END //

DELIMITER ;

DROP PROCEDURE IF EXISTS crearTablaExistente;

CALL crearTablaExistente();

-- 3

DELIMITER //

CREATE PROCEDURE seleccionarRegistroInexistente(
	IN p_id_socio INT
)
BEGIN
    DECLARE v_nombre VARCHAR(50);

	DECLARE EXIT HANDLER FOR NOT FOUND
    BEGIN
		SELECT 'El socio no existe' AS Mensaje;
	END;
    
    SELECT nombre INTO v_nombre 
    FROM socios 
    WHERE id_socio = p_id_socio;
    
    SELECT CONCAT('Éxito: Se encontró al socio ', v_nombre) AS Mensaje;
    
END //

DELIMITER ;

CALL seleccionarRegistroInexistente(99999999);

-- 4






    