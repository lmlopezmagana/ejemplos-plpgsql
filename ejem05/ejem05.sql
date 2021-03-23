DROP FUNCTION IF EXISTS sumar;
DROP FUNCTION IF EXISTS incrementar_precio_producto;
DROP TABLE IF EXISTS producto;


CREATE OR REPLACE FUNCTION sumar(int, int)
RETURNS INT AS
$$
BEGIN
	RETURN $1 + $2;
END;
$$ LANGUAGE plpgsql;


SELECT sumar(3,2);



CREATE TABLE producto (
	cod_producto 	SERIAL,
	nombre			TEXT,
	precio			NUMERIC,
	CONSTRAINT pk_producto PRIMARY KEY (cod_producto)
);

INSERT INTO producto (nombre, precio) VALUES
	('Pan 1kg', 2.0),
	('6 Huevos', 1.25),
	('Leche 1l ', 0.75),
	('Arroz 1kg', 2.35),
	('Helado 250gr', 1.80),
	('Tomates 1kg', 1.5);
	


CREATE OR REPLACE FUNCTION incrementar_precio_producto(id integer, porcentaje numeric) 
RETURNS numeric AS
$$
<<principal>>
DECLARE
	incremento numeric := (SELECT precio FROM producto WHERE cod_producto = $1) * porcentaje;
	precio_final numeric;
BEGIN
	RAISE NOTICE 'El incremento del precio será de % euros', incremento;
	-- Muestra el incremento en un %
	<<excepcional>>
	DECLARE
		incremento numeric := (SELECT precio FROM producto WHERE cod_producto = $1) * (porcentaje + 0.2);
	BEGIN
		RAISE NOTICE 'El incremento especial del precio será de % euros', incremento; -- Muestra el incremento en un porcentaje + 20%
		RAISE NOTICE 'El incremento del precio será de % euros', principal.incremento; -- Muestra el incremento en un porcentaje %
	END;
	SELECT precio + incremento INTO precio_final FROM producto WHERE cod_producto = $1;
	RAISE NOTICE 'El precio después del incremento será de % euros', precio_final;
	RETURN incremento;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM incrementar_precio_producto(1, 0.2);


CREATE TYPE producto_precio AS (nomproducto varchar, precio numeric);

CREATE OR REPLACE FUNCTION mostrar_producto_precio(int)
RETURNS producto_precio AS
$$
DECLARE
	resultado producto_precio;
BEGIN
	SELECT INTO resultado.nomproducto, resultado.precio
	nombre, precio
	FROM PRODUCTO
	WHERE cod_producto = $1;
	RETURN resultado;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM mostrar_producto_precio(1);


CREATE OR REPLACE FUNCTION mostrar_producto_precio_v2(int)
RETURNS record AS
$$
DECLARE
	resultado record;
BEGIN
	SELECT nombre, precio INTO resultado
	FROM producto
	WHERE cod_producto = $1;
	
	RETURN resultado;

END;
$$ LANGUAGE plpgsql;


SELECT nombre, precio FROM mostrar_producto_precio_v2(2) as (nombre text, precio numeric);


CREATE FUNCTION mostrar_producto_v3(integer) RETURNS producto AS
$$
DECLARE
	id ALIAS FOR $1;
	resultado producto%rowtype;
BEGIN
	SELECT * into resultado FROM producto WHERE cod_producto = id;
	RETURN resultado;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM mostrar_producto_v3(1);



CREATE OR REPLACE FUNCTION borrar_tabla(varchar)
RETURNS void AS
$$
BEGIN
	EXECUTE 'DROP TABLE IF EXISTS ' || $1 || ' CASCADE';
	RAISE NOTICE 'Se ha borrado la tabla %', $1;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE dummy (
	texto	text
);

SELECT borrar_tabla('dummy');


