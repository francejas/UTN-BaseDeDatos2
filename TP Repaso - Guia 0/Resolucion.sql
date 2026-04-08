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
/*
DELIMITER //

CREATE PROCEDURE cancelarTurno (
	IN p_turno_id INT,
    OUT p_filas_afectadas INT
)
BEGIN
    -- Validamos si existe y si está pendiente usando EXISTS
    IF EXISTS (SELECT 1 FROM turnos WHERE turno_id = p_turno_id AND estado = 'Pendiente') THEN
		
        UPDATE turnos 
        SET estado = 'Cancelado' 
        WHERE turno_id = p_turno_id;
        
        -- Guardamos la cantidad de filas en tu parámetro OUT (ROW_COUNT va sin parámetros adentro)
        SET p_filas_afectadas = ROW_COUNT();
        
        -- Mostramos el mensaje
        SELECT CONCAT('Turno id: ', p_turno_id, ' CANCELADO. Filas afectadas: ', p_filas_afectadas) AS Mensaje;
        
	ELSE
		-- Si no existe o no estaba pendiente, no modificamos nada y avisamos
		SELECT 'Turno inexistente o con estado cancelado o confirmado' AS Mensaje;
        SET p_filas_afectadas = 0; -- Por las dudas, lo dejamos en 0
	END IF;

END //

DELIMITER ;
    
CALL cancelarTurno(1, @filas);
*/

-- 7
/*
DELIMITER //

CREATE PROCEDURE buscarTurnosPorMedico(
	IN p_medico_id INT,
	IN p_fecha_desde DATE,
	IN p_fecha_hasta DATE
)
BEGIN
    IF EXISTS (SELECT 1 FROM medicos WHERE medico_id = p_medico_id) THEN
	
        SELECT
            p.nombre AS NombrePaciente,
            t.fecha AS FechaTurno,
            t.motivo AS Motivo,
            DATEDIFF(t.fecha, CURDATE()) AS DiasRestantes 
        FROM turnos t
        INNER JOIN pacientes p
        ON t.paciente_id = p.paciente_id
        WHERE t.estado = 'Pendiente' 
          AND t.medico_id = p_medico_id 
          AND t.fecha BETWEEN p_fecha_desde AND p_fecha_hasta 
        ORDER BY t.fecha ASC; 
        
    ELSE

        SELECT 'Error: El médico ingresado no existe' AS Mensaje;
    END IF;

END //

DELIMITER ;


-- Prueba 1: Un médico que existe y tiene turnos en este mes (El Médico 1)
CALL buscarTurnosPorMedico(1, '2026-04-01', '2026-04-30');

-- Prueba 2: Un médico que existe, pero buscamos en un rango de fechas donde no tiene turnos (Ej: el mes que viene)
CALL buscarTurnosPorMedico(1, '2026-05-01', '2026-05-31');

-- Prueba 3: Un médico que directamente NO existe (Para probar que funcione tu IF/ELSE)
CALL buscarTurnosPorMedico(99, '2026-04-01', '2026-04-30');
    
*/

-- 8
/*
DELIMITER //

CREATE PROCEDURE resumenMedico(
	IN p_medico_id INT
)
BEGIN
    
	DECLARE v_total_turnos INT;
    DECLARE v_pendientes INT;
    DECLARE v_total_cancelados INT;
    DECLARE v_fecha_proximo_turno DATE;
	
    -- 2. Consulta y asignación
    SELECT
		COUNT(turno_id),
        SUM(IF(estado = 'Pendiente', 1, 0)),
        SUM(IF(estado = 'Cancelado', 1, 0)), 
        MIN(IF(estado = 'Pendiente' AND fecha >= CURDATE(), fecha, NULL)) 
    INTO 
        v_total_turnos,      
        v_pendientes,        
        v_total_cancelados,  
        v_fecha_proximo_turno
    FROM 
		turnos
	WHERE medico_id = p_medico_id; 
        
	
	IF v_total_turnos = 0 THEN
		SELECT 'El médico no tiene ningún turno registrado' AS Mensaje; 
	ELSE
		SELECT
			v_total_turnos AS Turnos_totales,
            v_pendientes AS Turnos_pendientes, 
            v_total_cancelados AS Turnos_totales_cancelados,
            IFNULL(v_fecha_proximo_turno, 'Sin turnos pendientes') AS Proximo_turno; 
	END IF;

END //

DELIMITER ;

-- Prueba 1: Un médico con turnos pendientes a futuro (Médico 1)
-- Debería mostrarte totales, pendientes y la fecha de su próximo turno.
CALL resumenMedico(1);

-- Prueba 2: Un médico que solo tiene turnos cancelados (Médico 4)
-- Debería mostrarte 1 total, 1 cancelado, 0 pendientes y decir 'Sin turnos pendientes'.
CALL resumenMedico(4);

-- Prueba 3: Un médico que solo tiene turnos ya atendidos en el pasado (Médico 3)
-- Debería mostrarte 1 total, 0 pendientes, 0 cancelados y decir 'Sin turnos pendientes'.
CALL resumenMedico(3);

-- Prueba 4: Un médico que directamente NO existe en los turnos (Ej: ID 99)
-- Debería caer en tu IF y mostrar el mensaje: 'El médico no tiene ningún turno registrado'.
CALL resumenMedico(99);

*/

-- 9
/*
DELIMITER //

CREATE PROCEDURE registrarTurnoCompleto(
	IN p_paciente_id INT,
    IN p_medico_id INT,
    IN p_fecha DATE,
    IN p_motivo VARCHAR(100),
    
    OUT p_turno_id INT,
    OUT p_mensaje VARCHAR(100)
)
BEGIN
	CASE
		WHEN NOT EXISTS (SELECT 1 FROM pacientes WHERE p_paciente_id = paciente_id) THEN 
            SET p_mensaje = 'El paciente no existe';
            
        WHEN NOT EXISTS (SELECT 1 FROM medicos WHERE p_medico_id = medico_id) THEN 
            SET p_mensaje = 'El medico no existe';
            
        WHEN (p_fecha < CURDATE()) THEN 
            SET p_mensaje = 'Error: fecha invalida';
            
        WHEN (SELECT COUNT(turno_id) FROM turnos WHERE medico_id = p_medico_id AND fecha = p_fecha AND estado = 'Pendiente') >= 1 THEN 
            SET p_mensaje = 'Ya tiene un turno pendiente para esa fecha';
            
        ELSE
			INSERT INTO turnos (paciente_id, medico_id, fecha, motivo, estado)
				VALUES (p_paciente_id, p_medico_id, p_fecha, IFNULL(p_motivo, 'Sin especificar'), 'Pendiente');
                
            SET p_turno_id = LAST_INSERT_ID();
            SET p_mensaje = CONCAT('Turno registrado con exito, ID: ', p_turno_id);
	END CASE;
        
	SELECT p_mensaje AS Mensaje;
	
END //
    
DELIMITER ;

-- Prueba 1: Falla porque el paciente no existe (ID 99)
CALL registrarTurnoCompleto(99, 1, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 'Consulta', @id, @msj);

-- Prueba 2: Falla porque el médico no existe (ID 99)
CALL registrarTurnoCompleto(1, 99, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 'Consulta', @id, @msj);

-- Prueba 3: Falla porque la fecha es en el pasado
CALL registrarTurnoCompleto(1, 1, '2020-01-01', 'Consulta', @id, @msj);

-- Prueba 4: ¡Éxito! Todo correcto y sin motivo (prueba el IFNULL)
-- Ponemos una fecha lejana para asegurarnos de que no choque con los datos iniciales
CALL registrarTurnoCompleto(1, 1, '2026-12-15', NULL, @id, @msj);

-- Prueba 5: Falla por límite de turnos. 
-- Le pasamos EXACTAMENTE el mismo médico y la misma fecha que en la Prueba 4.
CALL registrarTurnoCompleto(2, 1, '2026-12-15', 'Dolor de rodilla', @id, @msj);

*/

-- 10

DELIMITER // 

CREATE PROCEDURE gestionarPaciente(
	IN p_paciente_id INT,
    IN p_accion VARCHAR(100),
    IN p_nuevo_nombre VARCHAR(100),
    INOUT p_mensaje VARCHAR(200) 
)
BEGIN
	CASE
		WHEN NOT EXISTS (SELECT 1 FROM pacientes WHERE paciente_id = p_paciente_id) THEN 
			SET p_mensaje = CONCAT(p_mensaje, 'El paciente no existe.');
            
        WHEN p_accion = 'ACTUALIZAR' THEN 
			UPDATE pacientes 
			SET nombre = p_nuevo_nombre 
            WHERE paciente_id = p_paciente_id;
			
            SET p_mensaje = CONCAT(p_mensaje, 'Nombre del paciente actualizado a "', p_nuevo_nombre, '".');
		
        WHEN p_accion = 'ELIMINAR' THEN
			DELETE FROM pacientes
            WHERE paciente_id = p_paciente_id;
            
            SET p_mensaje = CONCAT(p_mensaje, 'Paciente ID ', p_paciente_id, ' eliminado. Filas afectadas: ', ROW_COUNT());
		
        ELSE
			SET p_mensaje = CONCAT(p_mensaje, 'Accion no reconocida.');
	END CASE;

    SELECT p_mensaje AS Mensaje;

END //

DELIMITER ;


-- 1. Probamos ACTUALIZAR (Paciente 1)
SET @mi_prefijo = 'Resultado: ';
CALL gestionarPaciente(1, 'ACTUALIZAR', 'Juan Perez Modificado', @mi_prefijo);

-- 2. Probamos ELIMINAR (Paciente 2). Le pasamos NULL al nombre porque no se usa.
SET @mi_prefijo = 'Atención: ';
CALL gestionarPaciente(2, 'ELIMINAR', NULL, @mi_prefijo);

-- 3. Probamos un error (Paciente 99 que no existe)
SET @mi_prefijo = 'Aviso del sistema - ';
CALL gestionarPaciente(99, 'ACTUALIZAR', 'Falso', @mi_prefijo);



