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
CREATE VIEW clientes_productos_favoritos AS
SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo, 
    (
        SELECT pr.nombre_producto 
        FROM Pedidos p
        JOIN Detalle_Pedido dp ON p.pedido_id = dp.pedido_id
        JOIN Productos pr ON pr.producto_id = dp.producto_id
        WHERE p.cliente_id = c.cliente_id 
        GROUP BY pr.producto_id, pr.nombre_producto
        ORDER BY SUM(dp.cantidad) DESC 
        LIMIT 1
    ) AS producto_favorito
FROM Clientes c;

-- 9 
CREATE VIEW clientes_pedidos_recientes AS
SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo,
    (
        SELECT p.fecha_pedido 
        FROM Pedidos p 
        WHERE p.cliente_id = c.cliente_id 
        ORDER BY p.fecha_pedido DESC 
        LIMIT 1
    ) AS fecha_pedido_mas_reciente
FROM Clientes c;

CREATE OR REPLACE VIEW clientes_pedidos_recientes AS
SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo,
    (
        SELECT p.fecha_pedido 
        FROM Pedidos p 
        WHERE p.cliente_id = c.cliente_id 
        ORDER BY p.fecha_pedido DESC 
        LIMIT 1
    ) AS fecha_pedido_mas_reciente,
    (
        SELECT pr.nombre_producto 
        FROM Pedidos p
        JOIN Detalle_Pedido dp ON p.pedido_id = dp.pedido_id
        JOIN Productos pr ON pr.producto_id = dp.producto_id
        WHERE p.cliente_id = c.cliente_id
        ORDER BY p.fecha_pedido DESC 
        LIMIT 1
    ) AS producto_mas_reciente
FROM Clientes c;


-- 10

EXPLAIN SELECT nombre, email 
FROM Clientes 
WHERE ciudad = 'Madrid';

CREATE INDEX idx_ciudad ON Clientes(ciudad);

-- 11

CREATE INDEX idx_cliente_fecha ON Pedidos(cliente_id, fecha_pedido);

EXPLAIN SELECT CONCAT(c.nombre," ",c.apellido), COUNT(p.pedido_id) AS total_pedidos
		FROM Clientes c
		JOIN Pedidos p ON c.cliente_id=p.cliente_id
        WHERE p.fecha_pedido BETWEEN '2025-01-01' AND '2025-12-31'
		GROUP BY c.cliente_id;
        
-- 12

CREATE UNIQUE INDEX idx_codigo_producto ON Productos(producto_id);

INSERT INTO Productos (producto_id, nombre_producto, categoria, precio) 
VALUES (1, 'Pilas', 'Electronico', 500);

-- 13

CREATE FULLTEXT INDEX idx_nombre_producto_descripcion ON Productos (nombre_producto, descripcion);

EXPLAIN SELECT * FROM Productos 
WHERE MATCH(nombre_producto, descripcion) AGAINST('portátil');

-- 14

CREATE INDEX idx_productoId_fechaVenta ON Ventas(producto_id, fecha_venta);

EXPLAIN SELECT p.nombre_producto, SUM(dp.cantidad) AS cantidad_vendida
FROM Productos p
JOIN Detalle_Pedido dp ON p.producto_id = dp.producto_id
JOIN Pedidos pe ON dp.pedido_id = pe.pedido_id
WHERE pe.fecha_pedido BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.nombre_producto;

-- 15
CREATE INDEX idx_email ON Clientes(email);

EXPLAIN SELECT * FROM Clientes 
WHERE email = 'ana.garcia@email.com';

-- 16
CREATE INDEX idx_precio_producto ON Productos(precio);

EXPLAIN SELECT * FROM Productos 
WHERE precio BETWEEN 100 AND 200;

