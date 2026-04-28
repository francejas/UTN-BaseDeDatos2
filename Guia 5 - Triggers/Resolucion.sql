USE tp_triggers;

-- 1
DELIMITER $$
CREATE TRIGGER trg_audit_clientes_insert
AFTER INSERT ON 