USE bdd2_integradores;

-- 1
DELIMITER //

DELIMITER //

CREATE PROCEDURE reponerStockProducto (
    IN p_producto_id INT,
    IN p_cantidad INT    
)
BEGIN
    DECLARE v_existe INT;
    DECLARE v_stock_actual INT;
    DECLARE v_msj_error VARCHAR(255);

    -- El HANDLER captura el error 45000, registra en auditoría y no relanza 
    DECLARE EXIT HANDLER FOR SQLSTATE '45000'
    BEGIN
        INSERT INTO Auditoria_Errores (procedimiento, operacion, mensaje_error, fecha_error)
        VALUES ('reponerStockProducto', 'Reposición de stock', v_msj_error, NOW());
        SELECT v_msj_error AS msj_error;
    END;
    
    SELECT COUNT(*) INTO v_existe FROM Productos WHERE producto_id = p_producto_id;
    
    IF v_existe = 0 THEN
        -- Si no existe, preparamos el mensaje y disparamos el error
        SET v_msj_error = CONCAT('El producto con ID ', p_producto_id, ' no existe.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msj_error;
    ELSE
        -- Si existe, obtenemos el stock actual
        SELECT stock INTO v_stock_actual FROM Productos WHERE producto_id = p_producto_id;
        UPDATE Productos 
        SET stock = calcularNuevoStock(v_stock_actual, p_cantidad) 
        WHERE producto_id = p_producto_id;
        SELECT 'Operación exitosa: stock actualizado correctamente.' AS msj;
    END IF;

END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION calcularNuevoStock(
    stockActual INT,
    cantidadNueva INT
)
RETURNS INT 
DETERMINISTIC
BEGIN
    DECLARE stockNuevo INT;
    SET stockNuevo = stockActual + cantidadNueva;
    RETURN stockNuevo;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER trg_Auditoria_Exito_Productos
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria_Errores (procedimiento, operacion, mensaje_error, fecha_error)
    VALUES ('TRIGGER', 'UPDATE en Productos', 'Actualización exitosa (No es un error)', NOW());
END //

DELIMITER ;



/* otras formas 
IF NOT EXISTS (SELECT 1 FROM Productos WHERE producto_id = p_producto_id) THEN
    -- El producto no existe, armás el error
ELSE
    -- El producto existe, hacés el update
END IF;

------------------------------------------------------------------------------------------
IF p_producto_id NOT IN (SELECT producto_id FROM Productos) THEN
    -- El producto no existe
ELSE
    -- El producto existe
END IF;
------------------------------------------------------------------------------------------

-- Declarás qué pasa si un SELECT INTO no encuentra nada
DECLARE CONTINUE HANDLER FOR NOT FOUND 
BEGIN
    SET v_msj_error = 'El producto no existe.';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msj_error;
END;

-- Vas directo a intentar sacar un dato del producto (ej: el stock)
SELECT stock INTO v_stock_actual FROM Productos WHERE producto_id = p_producto_id;

-- Si la consulta anterior falla porque el ID no existe, salta directo al Handler.
-- Si funciona, el código sigue de largo y hacés tu UPDATE.

*/


-- 2
DELIMITER //
CREATE FUNCTION calcularNuevoPrecio (
	precioActual DECIMAL(10,2),
    porcentaje INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE precioActualizado DECIMAL(10,2);
    SET precioActualizado = precioActual + (porcentaje*precioActual)/100;
    RETURN precioActualizado;
END//

DELIMITER ;
DELIMITER //

CREATE PROCEDURE actualizarPrecioProducto (
	IN p_producto_id INT,
    IN p_porcentaje INT    
)
BEGIN
	DECLARE v_msj_error VARCHAR(200);
    DECLARE v_precio_actual DECIMAL (10,2);
	DECLARE EXIT HANDLER FOR SQLSTATE '45000'
		BEGIN
			INSERT INTO Auditoria_errores (procedimiento, operacion, mensaje_error, fecha_error)
            VALUES ('actualizarPrecioProducto','Actualizar Precio', v_msj_error, NOW());
            SELECT v_msj_error AS msj_error;
		END;
	
    IF NOT EXISTS (SELECT 1 FROM Productos WHERE producto_id=p_producto_id) THEN
		SET v_msj_error = CONCAT('El producto con ID: ', p_producto_id,' no existe.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msj_error;
	ELSE
		SELECT precio INTO v_precio_actual FROM Productos WHERE producto_id=p_producto_id;
        UPDATE Productos SET precio = calcularNuevoPrecio(v_precio_actual, p_porcentaje) WHERE producto_id=p_producto_id;
        SELECT 'Operación exitosa: precio actualizado correctamente.' AS msj;
	END IF;
END //

DELIMITER ;


-- 3
CREATE VIEW vista_total_pedidos AS 
SELECT 
    dp.pedido_id,
    SUM(p.precio * dp.cantidad) AS total
FROM Productos p
JOIN Detalle_Pedido dp ON p.producto_id = dp.producto_id
GROUP BY dp.pedido_id;



DELIMITER //

/*
CREATE FUNCTION obtenerTotalPedido (
    p_pedido_id INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_totalPedido DECIMAL(10,2) DEFAULT 0;
    
    IF EXISTS (SELECT 1 FROM vista_total_pedidos WHERE pedido_id = p_pedido_id) THEN
        SELECT total INTO v_totalPedido FROM vista_total_pedidos WHERE pedido_id = p_pedido_id;
    END IF;
    
    RETURN v_totalPedido;
END//

DELIMITER ;
*/

DELIMITER //

CREATE FUNCTION obtenerTotalPedido (
    p_pedido_id INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_totalPedido DECIMAL(10,2);
    
    -- Si la subconsulta no encuentra nada devuelve NULL, y el IFNULL lo convierte a 0.
    SET v_totalPedido = IFNULL((SELECT total FROM vista_total_pedidos WHERE pedido_id = p_pedido_id), 0);
    
    RETURN v_totalPedido;
END//

DELIMITER ;




DELIMITER //

CREATE PROCEDURE mostrarInfoPedido (
    IN p_pedido_id INT
)
BEGIN 
    DECLARE v_msj_error VARCHAR(255);
    DECLARE v_total DECIMAL(10,2);
    
    DECLARE EXIT HANDLER FOR SQLSTATE '45000'
    BEGIN
        INSERT INTO Auditoria_Errores (procedimiento, operacion, mensaje_error, fecha_error)
        VALUES ('mostrarInfoPedido', 'Mostrar información pedido', v_msj_error, NOW());
        
        SELECT v_msj_error AS msj_error;
    END;
    

    IF NOT EXISTS (SELECT 1 FROM Pedidos WHERE pedido_id = p_pedido_id) THEN
        SET v_msj_error = CONCAT('El pedido con ID ', p_pedido_id, ' no existe.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msj_error;
    ELSE
        SET v_total = obtenerTotalPedido(p_pedido_id);
        
        SELECT 
            p.pedido_id, 
            p.fecha_pedido, 
            CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo, 
            v_total AS total_pedido
        FROM Pedidos p
        JOIN Clientes c ON p.cliente_id = c.cliente_id
        WHERE p.pedido_id = p_pedido_id;
    END IF;
    
END//

DELIMITER ;

-- 4
DELIMITER //
CREATE FUNCTION calcularStockRestante (stockActual INT, cantidadPedida INT)
RETURNS INT 
DETERMINISTIC
BEGIN
	DECLARE stockRestante INT;
    SET stockRestante = (stockActual-cantidadPedida);
    RETURN stockRestante;
END;
DELIMITER ;


DELIMITER //
CREATE PROCEDURE registrarDetallePedido (
	IN p_detalle_id INT,
    IN p_pedido_id INT,
    IN p_producto_id INT,
    IN p_cantidad INT
)
BEGIN
	DECLARE v_msj_error VARCHAR(200);
    DECLARE v_stock_producto INT;
    DECLARE EXIT HANDLER FOR SQLSTATE '45000'
		BEGIN
			INSERT INTO Auditoria_Errores (procedimiento, operacion, mensaje_error, fecha_error)
            VALUES ('registrarDetallePedido','Registrar detalles del pedido',v_msj_error,NOW());
            SELECT v_msj_error AS msj_error;
		END;
	
    IF NOT EXISTS (SELECT 1 FROM Pedidos WHERE pedido_id=p_pedido_id) OR NOT EXISTS (SELECT 1 FROM Productos WHERE producto_id=p_producto_id) THEN
		SET v_msj_error = CONCAT('El pedido o el producto no existen.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msj_error;
	ELSE
		SET v_stock_producto = (SELECT stock FROM Productos WHERE producto_id=p_producto_id);
        IF v_stock_producto >=p_cantidad THEN
			INSERT INTO Detalle_Pedido (detalle_id, pedido_id, producto_id, cantidad)
            VALUES (p_detalle_id, p_pedido_id, p_producto_id, p_cantidad);
            UPDATE Productos SET stock = calcularStockRestante(v_stock_producto, p_cantidad) WHERE producto_id=p_producto_id;
			SELECT 'Operacion exitosa' AS msj;
       ELSE
			SET v_msj_error = 'Producto sin stock.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msj_error;
            END IF;
	END IF;
END//

DELIMITER ;

-- 5


