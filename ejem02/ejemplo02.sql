DROP TABLE IF EXISTS lineacarrito;
DROP TABLE IF EXISTS carrito;
DROP TABLE IF EXISTS producto;
DROP FUNCTION IF EXISTS limpiar_carritos_caducados;

/*

Esta base de datos nos permite almacenar el carrito de la compra de una aplicación web,
de forma que aunque el usuario se desconecte y vuelva a conectar, el carrito se quede almacenado.
Cada cliente puede tener solamente un carrito activo.

Queremos implementar una función que, al invocarla, elimine aquellos carritos que lleven
3 días o más activos y cuya compra no ha finalizado

*/


CREATE TABLE carrito (
	id_carrito	SERIAL,
	cliente		TEXT,
	fecha		TIMESTAMP DEFAULT current_timestamp,
	CONSTRAINT pk_carrito PRIMARY KEY (id_carrito),
	CONSTRAINT uk_carrito_cliente UNIQUE (cliente)
);

CREATE TABLE lineacarrito (
	id_linea		SMALLINT,
	id_carrito		INTEGER,
	cod_producto	INTEGER,
	cantidad		INTEGER,
	CONSTRAINT pk_lineacarrito PRIMARY KEY (id_linea, id_carrito)
);

CREATE TABLE producto (
	cod_producto 	SERIAL,
	nombre			TEXT,
	precio			NUMERIC,
	CONSTRAINT pk_producto PRIMARY KEY (cod_producto)
);


ALTER TABLE lineacarrito  
	ADD CONSTRAINT fk_lineacarrito_carrito FOREIGN KEY (id_carrito) REFERENCES carrito (id_carrito) ON DELETE CASCADE,
	ADD CONSTRAINT fk_lineacarrito_producto FOREIGN KEY (cod_producto) REFERENCES producto;

INSERT INTO producto (nombre, precio) VALUES
	('Pan 1kg', 2.0),
	('6 Huevos', 1.25),
	('Leche 1l ', 0.75),
	('Arroz 1kg', 2.35),
	('Helado 250gr', 1.80),
	('Tomates 1kg', 1.5);
	

-- Insertamos algunos datos de ejemplo

INSERT INTO carrito (cliente, fecha) VALUES
	('Pepe', CURRENT_TIMESTAMP - INTERVAL '4 day'),
	('Ana', CURRENT_TIMESTAMP - INTERVAL '5 day'),
	('María', CURRENT_TIMESTAMP - INTERVAL '1 day');
	
INSERT INTO LINEACARRITO (id_linea, id_carrito, cod_producto, cantidad) VALUES
	(1, 1, 1, 1),
	(2, 1, 2, 1),
	(3, 1, 3, 2),
	(1, 2, 1, 1),
	(2, 2, 2, 2),
	(1, 3, 3, 1),
	(2, 3, 4, 2);
	

-- La función que sirve para limpiar los carritos no válidos

CREATE OR REPLACE FUNCTION limpiar_carritos_caducados()
RETURNS void AS
$$
	-- Como la política de borrado entre carrito y lineacarrito es borrado en cascada,
	-- borrando los carritos, borramos también las líneas
	DELETE FROM carrito WHERE fecha <= CURRENT_TIMESTAMP - INTERVAL '3 day';
$$ language sql;

-- Comprobamos que funciona

SELECT limpiar_carritos_caducados();

SELECT *
FROM carrito;






