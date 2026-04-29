USE tp_triggers;

-- 1
DELIMITER $$

CREATE TRIGGER trg_audit_clientes_insert
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO AuditoriaClientes (ClienteID, Nombre, Apellido, Email, Telefono, FechaInsercion, Tipo_Operacion)
    VALUES (NEW.ClienteID, NEW.Nombre, NEW.Apellido, NEW.Email, NEW.Telefono, NOW(), 'INSERT');
END$$

DELIMITER ;

-- 2
DELIMITER $$
CREATE TRIGGER trg_auditarActualizacionClientes
AFTER UPDATE ON Clientes
FOR EACH ROW 
BEGIN
	INSERT INTO AuditoriaAcualizacionClientes (ClienteID, NombreAntiguo, NombreNuevo, FechaActualizacion, Tipo_Operacion)
    VALUES (OLD.ClienteID, OLD.Nombre, NEW.Nombre, NOW(),'UPDATE');
END$$

DELIMITER ; 

-- 3
DELIMITER $$
CREATE TRIGGER trg_auuditarEliminacionClientes
AFTER DELETE ON Clientes
FOR EACH ROW
BEGIN
	INSERT INTO AuditoriaEliminacionClientes (ClienteID, Nombre, Apellido, FechaEliminacion,Tipo_Operacion)
    VALUES (OLD.ClienteID, OLD.Nombre, OLD.Apellido, NOW(),'DELETE');
END$$

DELIMITER ;

-- 4
DELIMITER $$

CREATE TRIGGER trg_actualizarPrecioTotalPedido
AFTER INSERT ON DetallesPedido
FOR EACH ROW
BEGIN
    UPDATE Pedidos
    SET PrecioTotal = (
        SELECT SUM(dp.Cantidad * p.Precio)
        FROM Productos p 
        JOIN DetallesPedido dp ON p.ProductoID = dp.ProductoID
        WHERE dp.PedidoID = NEW.PedidoID
    )
    WHERE PedidoID = NEW.PedidoID;
END$$

DELIMITER ;

-- 5
DELIMITER $$

CREATE TRIGGER trg_validarCantidadProductos
BEFORE INSERT ON DetallesPedido
FOR EACH ROW
BEGIN
    IF NEW.Cantidad < 0 THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad de producto no puede ser negativa';
    END IF;
END$$

DELIMITER ;

-- 6 
DELIMITER $$
CREATE TRIGGER trg_actualizarPrecioProducto
BEFORE UPDATE ON Productos
FOR EACH ROW 
BEGIN
	IF NEW.Costo<>OLD.Costo THEN
    SET NEW.Precio=NEW.Costo*1.2;
	END IF;
END$$

DELIMITER ;

-- 7
DELIMITER $$

CREATE TRIGGER trg_auditInsertPedidos
AFTER INSERT ON Pedidos
FOR EACH ROW
BEGIN
	INSERT INTO AuditoriaPedidos (PedidoID, ClienteID, FechaPedido, FechaInsercion)
    VALUES (NEW.PedidoID, NEW.ClienteID, NEW.FechaPedido, NOW());
END$$

DELIMITER ;

-- 8
DELIMITER $$

CREATE TRIGGER trg_auditActualizacionPedidos
AFTER UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    INSERT INTO AuditoriaActualizacionPedidos (PedidoID, ClienteIDAntiguo, ClienteIDNuevo, FechaActualizacion)
    VALUES (OLD.PedidoID, OLD.ClienteID, NEW.ClienteID, NOW());
END$$

DELIMITER ;
	
-- 9 
DELIMITER $$

CREATE TRIGGER trg_auditEliminacionPedidos
AFTER DELETE ON Pedidos
FOR EACH ROW
BEGIN
	INSERT INTO AuditoriaEliminacionPedidos (PedidoID, ClienteID, FechaEliminacion)
    VALUES (OLD.PedidoID, OLD.ClienteID, NOW());
END$$

DELIMITER ;

-- 10
DELIMITER $$

CREATE TRIGGER trg_actualizarStockProducto
AFTER INSERT ON DetallesPedido
FOR EACH ROW 
BEGIN
	UPDATE Productos SET Stock=Stock-NEW.Cantidad
    WHERE ProductoID=NEW.ProductoID;
END$$

DELIMITER ;
    
-- 11
DELIMITER $$

CREATE TRIGGER trg_validarFormatoEmail
BEFORE INSERT ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.Email NOT LIKE '%_@_%.%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato invalido';
    END IF;
END$$

DELIMITER ;
    
-- 12
DELIMITER $$

CREATE TRIGGER trg_auditInsercionProductos
AFTER INSERT ON Productos
FOR EACH ROW
BEGIN
	INSERT INTO AuditoriaProductos (ProductoID, NombreProducto, Precio, FechaInsercion)
    VALUES (NEW.ProductoID, NEW.NombreProducto,NEW.Precio, NOW());
END$$

DELIMITER ;

-- 13
DELIMITER $$

CREATE TRIGGER trg_auditActualizarProductos
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    INSERT INTO AuditoriaActualizacionProductos(ProductoID, NombreProductoAntiguo, NombreProductoNuevo, FechaActualizacion)
    VALUES (OLD.ProductoID, OLD.NombreProducto, NEW.NombreProducto, NOW());
END$$

DELIMITER ;

-- 14
DELIMITER $$

CREATE TRIGGER trg_auditEliminarProducto
AFTER DELETE ON Productos
FOR EACH ROW
BEGIN
    INSERT INTO AuditoriaEliminacionProductos (ProductoID, NombreProducto, FechaEliminacion)
    VALUES (OLD.ProductoID, OLD.NombreProducto, NOW());
END$$

DELIMITER ;

-- 15
DELIMITER $$

CREATE TRIGGER trg_actualizarStockProductos
AFTER DELETE ON DetallesPedido
FOR EACH ROW
BEGIN
	UPDATE Productos SET Stock=Stock + OLD.Cantidad
    WHERE ProductoID=OLD.ProductoID;
END$$

DELIMITER ;


    
    
    
    
    