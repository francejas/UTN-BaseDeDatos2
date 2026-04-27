USE db_vistas_indices;

-- 1
CREATE VIEW clientes_por_ciudad AS
SELECT cliente_id, nombre, apellido, email, ciudad
FROM Clientes
WHERE ciudad = 'Madrid'
WITH CHECK OPTION;

-- 2
CREATE VIEW resumen_ventas_categoria AS
SELECT p.categoria, SUM(d.cantidad) AS total_ventas
FROM productos p
JOIN detalle_pedido d ON p.producto_id=d.producto_id
GROUP BY p.categoria;

-- 3
CREATE VIEW clientes_total_pedidos AS
SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo, 
    COUNT(p.pedido_id) AS total_pedidos
FROM Clientes c
JOIN Pedidos p ON c.cliente_id = p.cliente_id
GROUP BY c.cliente_id, c.nombre, c.apellido;

-- 4
CREATE VIEW productos_mas_vendidos_ciudad AS
SELECT c.ciudad, p.nombre_producto, SUM(d.cantidad) AS cantidad_total_vendida
FROM clientes c 
JOIN pedidos pe ON c.cliente_id = pe.cliente_id
JOIN detalle_pedido d ON d.pedido_id = pe.pedido_id
JOIN productos p ON p.producto_id = d.producto_id
GROUP BY c.ciudad, p.nombre_producto;

-- 5
CREATE VIEW ingresos_por_mes AS
SELECT 
    DATE_FORMAT(p.fecha_pedido, '%Y-%m') AS mes_anio, 
    SUM(pr.precio * dp.cantidad) AS total_ingresos
FROM Pedidos p
JOIN Detalle_Pedido dp ON p.pedido_id = dp.pedido_id
JOIN Productos pr ON pr.producto_id = dp.producto_id
GROUP BY DATE_FORMAT(p.fecha_pedido, '%Y-%m');

-- 6
CREATE VIEW productos_electronicos AS
SELECT * FROM Productos 
WHERE categoria = 'Electrónicos';

CREATE VIEW ventas_electronicos AS
SELECT 
    dp.detalle_id, 
    dp.pedido_id, 
    pe.producto_id, 
    pe.nombre_producto, 
    pe.categoria,
    dp.cantidad
FROM productos_electronicos pe
JOIN Detalle_Pedido dp ON dp.producto_id = pe.producto_id
WITH LOCAL CHECK OPTION;

-- 7
CREATE VIEW productos_electronicos AS
SELECT * FROM Productos 
WHERE categoria = 'Electrónicos';

CREATE VIEW ventas_electronicos AS
SELECT 
    dp.detalle_id, 
    dp.pedido_id, 
    pe.producto_id, 
    pe.nombre_producto, 
    pe.categoria,
    dp.cantidad
FROM productos_electronicos pe
JOIN Detalle_Pedido dp ON dp.producto_id = pe.producto_id
WITH CASCADED CHECK OPTION;

-- 8


