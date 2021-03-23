
-- Borrado para que el script funcione
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS categorias;
DROP FUNCTION IF EXISTS insertar_categoria_v1;
DROP FUNCTION IF EXISTS insertar_categoria_v2;
DROP FUNCTION IF EXISTS insertar_categoria_v3;
DROP FUNCTION IF EXISTS insertar_producto;
DROP FUNCTION IF EXISTS concatenar;

-- 1ª Parte: parámetros de entrada
CREATE TABLE categorias (
	id_cat		INTEGER PRIMARY KEY,
	nombre		TEXT UNIQUE
);

CREATE OR REPLACE FUNCTION insertar_categoria_v1(categoria INTEGER, nom TEXT)
RETURNS TABLE (categoria INTEGER, nombre TEXT) AS
$$
	INSERT INTO categorias VALUES (categoria, nom)
	RETURNING categoria, nom;
$$ LANGUAGE sql;

SELECT * FROM insertar_categoria_v1(1, 'Bebidas');


CREATE OR REPLACE FUNCTION insertar_categoria_v2(categoria INTEGER, nombre TEXT)
RETURNS void AS
$$
	INSERT INTO categorias VALUES ($1, $2);
$$ LANGUAGE sql;

SELECT insertar_categoria_v2(2, 'Desayunos');


CREATE OR REPLACE FUNCTION insertar_categoria_v3(id_cat INTEGER, nombre TEXT)
RETURNS void AS
$$
	INSERT INTO categorias 
	VALUES (insertar_categoria_v3.id_cat, insertar_categoria_v3.nombre);
$$ LANGUAGE sql;

SELECT insertar_categoria_v3(3, 'Frutas y verduras');

SELECT * FROM categorias;


-- 2ª Parte: parámetros de salida

CREATE TABLE productos (
	cod_prod		SERIAL PRIMARY KEY,
	nom_prod		TEXT,
	precio			NUMERIC,
	categoria		INTEGER REFERENCES categorias
);


CREATE OR REPLACE FUNCTION 
insertar_producto(nomcat TEXT, nomprod TEXT, precio NUMERIC, OUT codigo INTEGER, OUT nombre TEXT) AS
$$
	INSERT INTO productos (nom_prod, precio, categoria) 
	VALUES ($2, $3, (SELECT id_cat FROM categorias WHERE nombre = $1))
	RETURNING cod_prod, nom_prod;
$$ LANGUAGE sql;


SELECT * FROM insertar_producto('Frutas y verduras', 'Lechuga', 1.5);


-- 3ª Parte: VARIADIC

CREATE FUNCTION concatenar(separador TEXT, VARIADIC argumentos TEXT[]) RETURNS TEXT AS
$$
	SELECT array_to_string($2, separador);
$$ LANGUAGE sql;


SELECT concatenar('', 'El', 'perro', 'de', 'San', 'Roque', 'no', 'tiene', 'rabo');
SELECT concatenar(' ', 'El', 'perro', 'de', 'San', 'Roque', 'no', 'tiene', 'rabo');

