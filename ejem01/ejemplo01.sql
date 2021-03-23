DROP TABLE IF EXISTS lineaventa;
DROP TABLE IF EXISTS venta;
DROP TABLE IF EXISTS producto;


CREATE TABLE venta (
	id_venta	SERIAL,
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
	
DROP FUNCTION IF EXISTS crear_venta_con_una_linea;


CREATE OR REPLACE FUNCTION crear_venta_con_una_linea(nomcliente text, cod_prod integer, cant integer)
RETURNS numeric AS
$$
DECLARE
	id_nueva_venta integer;
	valor_subtotal numeric;
	val_total numeric;
BEGIN
	
	-- Creamos la venta
	INSERT INTO venta (cliente) VALUES ($1)
	RETURNING id_venta INTO id_nueva_venta;
	
	-- Creamos la linea de venta, rescatando los datos necesarios
	INSERT INTO lineaventa (id_linea, id_venta, cod_producto, precio, cantidad)
	VALUES (
		(SELECT COALESCE(MAX(id_linea)+1,1) FROM lineaventa WHERE id_venta = id_nueva_venta),
		id_nueva_venta,
		$2,
		(SELECT precio FROM producto WHERE cod_producto = $2),
		$3
	)
	RETURNING subtotal INTO valor_subtotal;
	
	UPDATE venta
	SET total = total + valor_subtotal
	WHERE id_venta = id_nueva_venta
	RETURNING total INTO val_total;
	
	RETURN val_total;
	
END;
$$ LANGUAGE plpgsql;


SELECT crear_venta_con_una_linea('Luismi', 4, 3);

SELECT *
FROM venta JOIN lineaventa USING (id_venta);