USE tp_base_datos;

-- 1 
DELIMITER //

CREATE FUNCTION obtenerNombreCompletoCliente (nombre VARCHAR(100), apellido VARCHAR(100))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    RETURN CONCAT(nombre, ' ', apellido);
END //

DELIMITER ;

-- 2
DELIMITER //
CREATE FUNCTION promedioVentasCliente (p_cliente_id INT)
RETURNS DECIMAL (10,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL (10,2);
    SELECT AVG(valor) INTO promedio 
    FROM Ventas 
    WHERE cliente_id = p_cliente_id;
    RETURN IFNULL(promedio, 0.00);
END //

DELIMITER ;

-- 3 
DELIMITER //

CREATE FUNCTION antiguedadEmpleado (p_empleado_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE anios_antiguedad INT;
    -- TIMESTAMPDIFF calcula la diferencia exacta en AÑOS (YEAR) entre dos fechas
    SELECT TIMESTAMPDIFF(YEAR, fecha_contratacion, CURDATE()) INTO anios_antiguedad
    FROM Empleados 
    WHERE empleado_id = p_empleado_id;
    RETURN anios_antiguedad;
END //

DELIMITER ;

-- 4 
DELIMITER //

CREATE FUNCTION comisionDel10 (p_cliente_id INT)
RETURNS DECIMAL (10,2)
READS SQL DATA
BEGIN
    DECLARE totalVentas DECIMAL (10,2);
    
    SELECT SUM(valor) INTO totalVentas 
    FROM Ventas 
    WHERE cliente_id = p_cliente_id;

    RETURN IFNULL(totalVentas, 0.00) * 0.10;
END //

DELIMITER ;

-- 5 
DELIMITER //

CREATE FUNCTION nombreJefeDepartamento (p_departamento_id INT)
RETURNS VARCHAR(200)
READS SQL DATA
BEGIN
    DECLARE nombreJefe VARCHAR(200);
    
    -- Usamos INTO para asignar el resultado del SELECT a la variable
    SELECT e.nombre INTO nombreJefe 
    FROM Empleados e 
    WHERE e.empleado_id = (
        SELECT d.jefe_id 
        FROM Departamentos d 
        WHERE d.departamento_id = p_departamento_id
    );
	
    -- Devolvemos el nombre, o un aviso si el resultado fue NULL
    RETURN IFNULL(nombreJefe, 'Sin jefe asignado');
END //

DELIMITER ;

-- 6
DELIMITER //

CREATE FUNCTION totalVentasPorRangoFechas (inicio DATE, final DATE)
RETURNS DECIMAL (10,2)
READS SQL DATA
BEGIN
    DECLARE totalVentas DECIMAL (10,2);
    
    SELECT SUM(valor) INTO totalVentas 
    FROM Ventas 
    WHERE fecha_venta BETWEEN inicio AND final;
    
    RETURN IFNULL(totalVentas, 0.00);
END //

DELIMITER ;

-- 7
DELIMITER //

CREATE FUNCTION PorcentajeSalarioDepartamento (p_empleado_id INT)
RETURNS DECIMAL(10,2)
READS SQL DATA -- (o DETERMINISTIC, si preferís seguir la línea de la cátedra)
BEGIN
    DECLARE v_salarioTotal DECIMAL (10,2);
    DECLARE v_salarioEmpleado DECIMAL (10,2);
    DECLARE v_departamento_id INT;
    DECLARE v_porcentaje DECIMAL(10,2);
    
    -- 1. Obtenemos el salario y el departamento del empleado en un solo paso
    SELECT salario, departamento_id INTO v_salarioEmpleado, v_departamento_id 
    FROM Empleados 
    WHERE empleado_id = p_empleado_id;
    
    -- 2. Sumamos los salarios SOLO de los empleados de ese mismo departamento
    SELECT SUM(salario) INTO v_salarioTotal 
    FROM Empleados 
    WHERE departamento_id = v_departamento_id;
    
    -- 3. Hacemos tu cálculo
    SET v_porcentaje = (v_salarioEmpleado * 100) / v_salarioTotal;
    
    RETURN v_porcentaje;
END //

DELIMITER ;

-- 8
DELIMITER //

CREATE FUNCTION clienteSinVentas(clienteID INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
RETURN NOT EXISTS (SELECT 1
FROM Ventas
WHERE cliente_id = clienteID);
END;

DELIMITER ;

-- 9 

DELIMITER //

CREATE FUNCTION numeroDeVentas (p_cliente_id INT)
RETURNS INT 
DETERMINISTIC
BEGIN
    DECLARE cantidad INT;
    
    SELECT COUNT(venta_id) INTO cantidad 
    FROM Ventas 
    WHERE cliente_id = p_cliente_id;
    
    RETURN cantidad;
END //

DELIMITER ;

-- 10
DELIMITER //

CREATE FUNCTION nombreDepartamentoEmpleado (p_empleado_id INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE v_nombre_depto VARCHAR(100);
    
    -- Tu lógica de JOIN es perfecta para este caso
    SELECT d.nombre_departamento INTO v_nombre_depto 
    FROM Departamentos d 
    JOIN Empleados e ON d.departamento_id = e.departamento_id
    WHERE e.empleado_id = p_empleado_id;
    
    RETURN v_nombre_depto;
END //

DELIMITER ;

-- 11
WITH VentasAltas AS (

SELECT * FROM ventas WHERE valor>1000

)

SELECT COUNT(venta_id) AS cantidad_ventas, AVG(valor) FROM VentasAltas;

-- 12
WITH PromedioDepartamento AS (
    SELECT 
        departamento_id, 
        AVG(salario) AS salario_promedio 
    FROM Empleados 
    GROUP BY departamento_id
)
SELECT departamento_id 
FROM PromedioDepartamento 
WHERE salario_promedio > 4000; 


-- 13
WITH AntiguedadEmpleados AS (
SELECT
empleado_id,
nombre,
DATEDIFF(CURDATE(), fecha_contratacion) AS DiasEnEmpresa
FROM Empleados
)
SELECT
empleado_id,
nombre,
DiasEnEmpresa
FROM AntiguedadEmpleados
WHERE DiasEnEmpresa > 5 * 365; 

-- 14
WITH VentasClientes AS (
    SELECT c.cliente_id, c.nombre, c.apellido, v.fecha_venta
    FROM clientes c
    JOIN ventas v ON c.cliente_id = v.cliente_id
    WHERE YEAR(v.fecha_venta) = YEAR(CURDATE())
)
SELECT 
    cliente_id, 
    nombre, 
    apellido, 
    COUNT(*) AS total_compras
FROM VentasClientes
GROUP BY cliente_id, nombre, apellido
HAVING total_compras > 3;

-- 15
WITH TopEmpleados AS (
    SELECT nombre, salario 
    FROM Empleados 
    ORDER BY salario DESC 
    LIMIT 10
)
SELECT nombre, salario 
FROM TopEmpleados;

-- 16
WITH VentasPorMes AS (
    SELECT 
        YEAR(fecha_venta) AS anio_venta, 
        MONTH(fecha_venta) AS mes_venta, 
        SUM(valor) AS total_ventas
    FROM Ventas
    GROUP BY anio_venta, mes_venta
)
SELECT 
    anio_venta,
    mes_venta, 
    total_ventas
FROM VentasPorMes 
WHERE total_ventas > 5000;

-- 17
WITH RECURSIVE JerarquiaDepartamental AS (
    -- PARTE 1: EL CASO BASE (El inicio de la cadena)
    -- Buscamos al departamento raíz (el que no tiene jefe)
    SELECT 
        departamento_id, 
        nombre_departamento, 
        jefe_id, 
        1 AS Nivel -- Arrancamos en el Nivel 1
    FROM Departamentos
    WHERE jefe_id IS NULL
    
    UNION ALL -- EL PEGAMENTO
    
    -- PARTE 2: LA RECURSIÓN (El bucle)
    -- Buscamos quiénes están abajo del departamento anterior
    SELECT 
        d.departamento_id, 
        d.nombre_departamento, 
        d.jefe_id, 
        jd.Nivel + 1 -- Le sumamos 1 al nivel en cada vuelta
    FROM Departamentos d
    -- ¡Acá está el truco! Hacemos JOIN con nuestra propia CTE (jd)
    JOIN JerarquiaDepartamental jd ON d.jefe_id = jd.departamento_id
)
-- PARTE 3: LA CONSULTA PRINCIPAL
-- Mostramos el árbol terminado, ordenado por nivel jerárquico
SELECT * FROM JerarquiaDepartamental
ORDER BY Nivel, departamento_id;

-- 18
WITH ClientesDuplicados AS (
    SELECT c.nombre, c.apellido, COUNT(*) AS total_duplicados
    FROM Clientes c
    GROUP BY c.nombre, c.apellido
    HAVING total_duplicados > 1
)
SELECT 
    nombre, 
    apellido, 
    total_duplicados 
FROM ClientesDuplicados;

-- 19
WITH TotalVentasPorCliente AS (
    -- 1. Calculamos el total de cada uno
    SELECT 
        c.nombre, 
        c.apellido, 
        SUM(v.valor) AS total_gastado
    FROM clientes c
    JOIN ventas v ON c.cliente_id = v.cliente_id
    GROUP BY c.cliente_id, c.nombre, c.apellido 
),
ClientesSuperiores AS (
    SELECT nombre, apellido, total_gastado
    FROM TotalVentasPorCliente
    WHERE total_gastado > 10000
)

SELECT * FROM ClientesSuperiores;

-- 20
WITH VentasUltimoMes AS (
    -- Filtramos trayendo las ventas que ocurrieron hace un mes o menos
    SELECT cliente_id, valor 
    FROM Ventas 
    WHERE fecha_venta >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
)
SELECT 
    c.nombre, 
    c.apellido, 
    SUM(v.valor) AS total_gastado 
FROM VentasUltimoMes v 
JOIN Clientes c ON v.cliente_id = c.cliente_id
GROUP BY c.cliente_id, c.nombre, c.apellido;
