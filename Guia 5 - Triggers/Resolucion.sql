USE tp_triggers;

-- 1
DELIMITER $$
CREATE TRIGGER trg_audit_clientes_insert
AFTER INSERT ON clientes FOR EACH ROW
BEGIN
	INSERT INTO auditoriaclientes (ClienteID, Nombre, Apellido, Email, Telefono)
    VALUES (NEW.ClienteID, NEW.Nombre, NEW.Apellido, NEW.Email, NEW.Telefono);
END$$

DELIMITER ; 