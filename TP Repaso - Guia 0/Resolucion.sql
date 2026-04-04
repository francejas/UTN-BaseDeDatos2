USE repaso_sp;

/*
-- 1
DELIMITER //

CREATE PROCEDURE mostrarDatosMedicos (
	IN p_medico_id INT
)
BEGIN 
	SELECT 
		m.nombre AS Nombre,
        m.matricula AS Matricula,
        e.nombre AS Especialidad
	FROM 
		medicos m
	JOIN especialidades e
	ON m.especialidad_id = e.especialidad_id
	WHERE m.medico_id=p_medico_id;
END //
DELIMITER ;

CALL mostrarDatosMedicos (1);

DELIMITER //
CREATE PROCEDURE mostrarDatosMedicos (
	IN p_medico_id INT
)
BEGIN
	DECLARE v_nombre_medico VARCHAR(100);
    DECLARE v_matricula VARCHAR(100);
	DECLARE v_nombre_especialidad VARCHAR(100);
    
    SELECT
		m.nombre,
        m.matricula,
        e.nombre
	INTO 
		v_nombre_medico,
        v_matricula,
        v_nombre_especialidad
	FROM medicos m
    JOIN especialidades e
    ON m.especialidad_id=e.especialidad_id
	WHERE p_medico_id=m.medico_id;
    
    SELECT 
		v_nombre_medico AS Nombre,
        v_matricula AS Matricula,
        v_nombre_especialidad AS Especialidad;
	END //
    DELIMITER ; 
    CALL mostrarDatosMedicos(1);
    */
    
    
-- 2
/*
DELIMITER //

CREATE PROCEDURE obtenerNombreMedico (
	IN p_medico_id INT,               -- Coma en lugar de punto y coma
    OUT p_nombre VARCHAR(100),        -- Coma en lugar de punto y coma
    OUT p_especialidad VARCHAR(100)   -- Sin nada al final
)
BEGIN
	SELECT
		m.nombre,                     -- Coma agregada
		e.nombre                      -- Nombre correcto de la columna
	INTO
		p_nombre,                     -- Coma agregada
		p_especialidad
    FROM
		medicos m
	JOIN 
		especialidades e              -- Nombre correcto de la tabla
	ON
		m.especialidad_id = e.especialidad_id  -- Cruce correcto (m con e)
	WHERE
		m.medico_id = p_medico_id;
END //

DELIMITER ;
CALL obtenerNombreMedico(1, @nombre_medico, @especialidad_medico);
SELECT @nombre_medico AS Nombre, @especialidad_medico AS Especialidad;
*/

-- 3
/*
DELIMITER //

CREATE PROCEDURE verificarMedico (
	IN p_medico_id INT
) 
BEGIN
    -- 1. Declaramos la variable donde vamos a guardar el nombre
    DECLARE v_nombre VARCHAR(100);

    -- 2. Buscamos el nombre del médico y lo metemos en la variable
	SELECT
		nombre INTO v_nombre
	FROM
		medicos
	WHERE
		medico_id = p_medico_id;
        
    -- 3. Ahora sí, evaluamos la variable
	IF v_nombre IS NULL THEN 
		SELECT 'El medico solicitado no existe' AS Mensaje;
    ELSE 
		SELECT CONCAT('El medico existe. Su nombre es: ', v_nombre) AS Mensaje;
	END IF;

END //

DELIMITER ;


CALL verificarMedico(1); -- Debería decirte que existe y mostrar el nombre
CALL verificarMedico(99); -- Debería decirte que no existe
*/

-- 4 
/*
 DELIMITER //
 
CREATE PROCEDURE clasificarMedico (
	IN p_medico_id INT
)
BEGIN

	DECLARE v_nombre VARCHAR(100);
    DECLARE v_salario DECIMAL(10,2);
    DECLARE v_clasificacion VARCHAR(100);

    SELECT
    	m.nombre,    -- Faltaba esta coma
    	m.salario
    INTO
    	v_nombre,    -- Faltaba esta coma
    	v_salario
    FROM 
    	medicos m
    WHERE p_medico_id = m.medico_id; -- Faltaba este punto y coma

    CASE
    	WHEN v_salario < 200000 THEN SET v_clasificacion = 'Salario bajo'; -- Faltaba este punto y coma
    	WHEN v_salario BETWEEN 200000 AND 500000 THEN SET v_clasificacion = 'Salario medio'; -- Faltaba este punto y coma
    	WHEN v_salario > 500000 THEN SET v_clasificacion = 'Salario alto'; -- Faltaba este punto y coma
    ELSE
    	SET v_clasificacion = 'Sin clasificar'; -- Faltaba este punto y coma
    END CASE;

    SELECT
    	v_nombre AS Nombre,
        v_salario AS Salario,
        v_clasificacion AS Clasificacion; -- Faltaba este punto y coma

END //

DELIMITER ; 

CALL clasificarMedico(1);
CALL clasificarMedico(4);
*/

-- 5
/*
DELIMITER //

CREATE PROCEDURE registrarTurno (
	IN p_paciente_id INT,
    IN p_medico_id INT,
    IN p_fecha DATE,
    IN p_motivo VARCHAR(100),
    OUT p_turno_id INT
)
BEGIN
	DECLARE v_turno_id INT;
    
  INSERT INTO turnos (paciente_id, medico_id, fecha, motivo, estado) 
VALUES (p_paciente_id, p_medico_id, p_fecha, p_motivo, 'Pendiente'); 
    
    SET p_turno_id=LAST_INSERT_ID();
    
    SELECT CONCAT('Turno registrado con exito. El ID asignado es: ', p_turno_id);
    
END //

DELIMITER ;

-- Llamamos al SP para el paciente 1 y el médico 2. El último parámetro es nuestra variable vacía.
CALL registrarTurno(1, 2, '2026-04-15', 'Dolor de espalda', @id_del_nuevo_turno);

-- Si querés comprobar qué quedó guardado en la variable (además del mensaje que ya tira el SP):
SELECT @id_del_nuevo_turno AS ID_Generado;

DROP PROCEDURE registrarTurno;
*/


-- 6

DELIMITER //

CREATE PROCEDURE 
