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

DELIMITER //

CREATE PROCEDURE manejoCombinado()
BEGIN
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error atrapado: Quisiste insertar en una tabla inexistente' AS Aviso_1;
	END;
    
	DECLARE CONTINUE HANDLER FOR SQLWARNING
    BEGIN
		SELECT 'Advertencia atrapada: La tabla ya existe' AS Aviso_2;
	END;
	
    INSERT INTO tabla_no_existe (columna) VALUES ('valor');
    SELECT 'Paso 1 ejecutado' AS Mensaje_1; 
    
    CREATE TABLE IF NOT EXISTS ejemplo_tabla(
        id INT AUTO_INCREMENT PRIMARY KEY,
        nombre VARCHAR(100)
    );
    SELECT 'Paso 2 ejecutado. Fin del SP.' AS Mensaje_2;

END //

DELIMITER ;


-- 5

DELIMITER //

CREATE PROCEDURE insertarActividad(
	IN p_id_socio INT,
    IN p_id_plan INT,
    IN p_actividad VARCHAR(50)
)
BEGIN 
   
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error: El socio o el plan ingresado no existen.' AS Aviso;
    END;
	
    -- Intentamos hacer el insert directamente
    INSERT INTO actividades (id_socio, id_plan, actividad) 
    VALUES (p_id_socio, p_id_plan, CURDATE(), p_actividad);
    
    
    SELECT 'Operacion exitosa.' AS Aviso;
END //

DELIMITER ;

-- PRUEBA DE ÉXITO: 
-- Usamos el socio 1 y el plan 1 (que sabemos que existen en la base de datos)
CALL insertarActividad(1, 1, 'Yoga');

-- PRUEBA DE FALLA (ID SOCIO INEXISTENTE): 
-- Usamos el socio 99 (que NO existe). El motor de MySQL choca con la clave foránea y salta tu Handler.
CALL insertarActividad(99, 1, 'Crossfit');

-- PRUEBA DE FALLA (ID PLAN INEXISTENTE): 
-- Usamos el socio 1 (existe) pero el plan 88 (que NO existe). También salta el Handler.
CALL insertarActividad(1, 999,'Pilates');
	
-- 6

DELIMITER //

CREATE PROCEDURE seleccionarSocio(
	IN p_id_socio INT
)
BEGIN
	DECLARE v_nombre VARCHAR(100);
    
	DECLARE EXIT HANDLER FOR NOT FOUND
		BEGIN
			SELECT 'Error: socio no encontrado.' AS Aviso;
		END;
	
    
    SELECT nombre INTO v_nombre FROM socios WHERE id_socio = p_id_socio;
    
    
    SELECT CONCAT('Se encontro al socio ', v_nombre) AS Mensaje;

END //

DELIMITER ;
    
CALL seleccionarSocio(1);
CALL seleccionarSocio(99);

-- 7
DELIMITER //

CREATE PROCEDURE registrarSocioConPlan(
	IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_fecha_nacimiento DATE,
    IN p_direccion VARCHAR(100),
    IN p_telefono VARCHAR(20),  
    IN p_id_plan INT,
    IN p_actividad VARCHAR(50)
)
BEGIN
    DECLARE v_nuevo_socio INT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error inesperado: operacion cancelada.' AS Aviso;
    END;
	
    START TRANSACTION;
	
   
    INSERT INTO socios (nombre, apellido, fecha_nacimiento, direccion, telefono) 
    VALUES (p_nombre, p_apellido, p_fecha_nacimiento, p_direccion, p_telefono);
    
    SET v_nuevo_socio = LAST_INSERT_ID();
    
    INSERT INTO actividades (id_socio, id_plan, fecha, actividad) 
    VALUES (v_nuevo_socio, p_id_plan, CURDATE(), p_actividad);
    
    COMMIT;
    
    SELECT 'Socio y actividad registrados con exito.' AS Aviso;

END //

DELIMITER ;
	

-- 8

DELIMITER //

CREATE PROCEDURE actualizarPlanYRegistrarActividad(
	IN p_id_plan INT,
    IN p_nuevo_precio DECIMAL(10,2), 
    IN p_id_socio INT, 
    IN p_actividad VARCHAR(50)
)
BEGIN
	DECLARE v_id_plan INT;
    DECLARE v_id_socio INT;
    
	DECLARE EXIT HANDLER FOR NOT FOUND
    BEGIN
        ROLLBACK;
        SELECT 'Error: socio o plan no encontrado.' AS Aviso;
    END;
	
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: ocurrio un error en la operacion.' AS Aviso;
    END;

    START TRANSACTION;

    SELECT id_plan INTO v_id_plan FROM planes WHERE id_plan = p_id_plan;
    SELECT id_socio INTO v_id_socio FROM socios WHERE id_socio = p_id_socio;
    
    UPDATE planes SET precio = p_nuevo_precio WHERE id_plan = v_id_plan;
    
    INSERT INTO actividades (id_socio, id_plan, fecha, actividad) 
    VALUES (v_id_socio, v_id_plan, CURDATE(), p_actividad);

    COMMIT;
    SELECT 'Operacion exitosa.' AS Aviso;

END //

DELIMITER ;
		
CALL actualizarPlanYRegistrarActividad(1, 75.50, 1, 'Spinning');		
CALL actualizarPlanYRegistrarActividad(1, 80.00, 99, 'Natación');
    
 
-- 9

DELIMITER //

CREATE PROCEDURE eliminarSocioYActividades(
	IN p_id_socio INT
)
BEGIN
    DECLARE v_existe INT;

    DECLARE EXIT HANDLER FOR NOT FOUND
    BEGIN
        ROLLBACK;
        SELECT 'Error: El socio no existe.' AS Aviso;
    END;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error inesperado durante la eliminacion.' AS Aviso;
    END;
	
    START TRANSACTION;

    SELECT id_socio INTO v_existe FROM socios WHERE id_socio = p_id_socio;

    DELETE FROM actividades WHERE id_socio = p_id_socio;
    DELETE FROM socios WHERE id_socio = p_id_socio;
    
    COMMIT;
    SELECT 'Operacion exitosa. Socio y actividades eliminados.' AS Aviso;

END //

DELIMITER ;

-- Falla porque el socio 999 no existe (Atrapa el NOT FOUND)
CALL eliminarSocioYActividades(999);

-- Éxito total. Borra a María (Socio 2) y sus actividades.
CALL eliminarSocioYActividades(2); 

-- Si tirás estos SELECT, vas a ver que el socio 2 desapareció de ambos lados
SELECT * FROM socios;
SELECT * FROM actividades;	
    




    