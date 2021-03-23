DROP FUNCTION IF EXISTS total_ventas_por_cliente_v1;
DROP FUNCTION IF EXISTS total_ventas_por_cliente_v2;
DROP FUNCTION IF EXISTS incrementar_precio_producto;
DROP TABLE IF EXISTS lineaventa;
DROP TABLE IF EXISTS venta;
DROP TABLE IF EXISTS producto CASCADE;

CREATE TABLE venta (
	id_venta	INTEGER,
	cliente		TEXT,
	fecha		TIMESTAMP DEFAULT current_timestamp,
	total		NUMERIC DEFAULT 0,
	CONSTRAINT pk_venta PRIMARY KEY (id_venta)
);

CREATE TABLE lineaventa (
	id_linea		SMALLINT,
	id_venta		INTEGER,
	cod_producto	INTEGER,
	precio			NUMERIC,
	cantidad		INTEGER,
	subtotal		NUMERIC GENERATED ALWAYS AS (precio * cantidad) STORED,
	CONSTRAINT pk_lineaventa PRIMARY KEY (id_venta, id_linea)
);

CREATE TABLE producto (
	cod_producto 	SERIAL,
	nombre			TEXT,
	precio			NUMERIC,
	CONSTRAINT pk_producto PRIMARY KEY (cod_producto)
);

ALTER TABLE lineaventa  
	ADD CONSTRAINT fk_lineaventa_venta FOREIGN KEY (id_venta) REFERENCES venta (id_venta) ON DELETE CASCADE,
	ADD CONSTRAINT fk_lineaventa_producto FOREIGN KEY (cod_producto) REFERENCES producto;
	
INSERT INTO producto (nombre, precio) VALUES
	('Pan 1kg', 2.0),
	('6 Huevos', 1.25),
	('Leche 1l ', 0.75),
	('Arroz 1kg', 2.35),
	('Helado 250gr', 1.80),
	('Tomates 1kg', 1.5);
	
	
INSERT INTO venta (id_venta, cliente)
VALUES (1, 'Ángel');


INSERT INTO lineaventa (id_linea, id_venta, cod_producto, precio, cantidad)
VALUES  (1, 1, 1, 2.0, 1),
		(2, 1, 2, 1.25, 1),
		(3, 1, 3, 0.75, 2);


INSERT INTO venta (id_venta, cliente)
VALUES (2, 'Ángel');


INSERT INTO lineaventa (id_linea, id_venta, cod_producto, precio, cantidad)
VALUES  (1, 2, 4, 2.35, 1),
		(2, 2, 5, 1.80, 2),
		(3, 2, 6, 1.5, 2);


UPDATE venta v1
SET total = (SELECT SUM(subtotal) FROM lineaventa WHERE lineaventa.id_venta = v1.id_venta);

CREATE FUNCTION total_ventas_por_cliente_v1(nomcliente varchar) 
RETURNS numeric AS
$$
	SELECT SUM(total)
	FROM venta
	WHERE cliente = nomcliente
	GROUP BY cliente;
	
$$ LANGUAGE sql;

-- El mismo ejemplo empleando enumeración de parámetros
CREATE FUNCTION total_ventas_por_cliente_v2(varchar) RETURNS numeric AS
$$
	SELECT SUM(total)
	FROM venta
	WHERE cliente = $1
	GROUP BY cliente;
$$ LANGUAGE sql;

SELECT * FROM total_ventas_por_cliente_v1('Ángel');
SELECT * FROM total_ventas_por_cliente_v2('Ángel');



CREATE FUNCTION incrementar_precio_producto(porcentaje NUMERIC, prod PRODUCTO) 
RETURNS numeric AS
$$
	UPDATE producto 
	SET precio = (1 + porcentaje) * precio 
	WHERE cod_producto = prod.cod_producto
	RETURNING precio;
$$ LANGUAGE sql;

SELECT cod_producto, nombre, precio, incrementar_precio_producto(0.05, producto.*)
FROM producto
WHERE cod_producto <= 3;

SELECT *
FROM producto;


CREATE FUNCTION mostrar_producto(integer)
RETURNS producto AS
$$
	SELECT * FROM producto WHERE cod_producto = $1
$$ LANGUAGE sql;

SELECT * FROM mostrar_producto(2);
SELECT (mostrar_producto(3)).nombre;


CREATE FUNCTION mostrar_productos_menorque(NUMERIC)
RETURNS SETOF producto AS
$$
	SELECT * FROM producto WHERE precio < $1;
$$ LANGUAGE sql;


SELECT * FROM mostrar_productos_menorque(1.5);


CREATE FUNCTION mostrar_cliente(TEXT)
RETURNS TABLE (nombre TEXT, 
			   total_ventas NUMERIC, 
			   cant_prods_total INT, 
			   num_prod_dif INT) AS
$$
	SELECT cliente, SUM(precio * cantidad), 
			SUM(cantidad)::int, COUNT(DISTINCT cod_producto)::int
	FROM venta JOIN lineaventa USING (id_venta)
	WHERE cliente = $1
	GROUP BY cliente;
$$ LANGUAGE sql;

SELECT * FROM mostrar_cliente('Ángel');
