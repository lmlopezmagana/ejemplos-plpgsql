
CREATE OR REPLACE FUNCTION mayor_de_3(int, int, int)
RETURNS int AS
$$
DECLARE
	mayor int := -999999999 ;
BEGIN
	IF ($1 > mayor) THEN
		mayor := $1;
	END IF;
	
	IF ($2 > mayor) THEN
		mayor := $2;
	END IF;
	
	IF ($3 > mayor) THEN
		mayor := $3;
	END IF;
	
	RETURN mayor;
	
END;
$$ LANGUAGE plpgsql;

SELECT mayor_de_3(-5,-3,-4);

CREATE TABLE cliente (
	cod_cliente			SERIAL PRIMARY KEY,
	nombre				TEXT,
	apellidos			TEXT,
	puntos				INTEGER DEFAULT 0
);

CREATE TABLE clientevip (
	cod_cliente			INTEGER PRIMARY KEY REFERENCES cliente,
	fecha_vip			DATE DEFAULT CURRENT_DATE
);


CREATE OR REPLACE FUNCTION inserta_cliente(
	nom text, ape text, esvip boolean
) RETURNS TABLE (
	cod_cliente integer, 
	nombre_completo text,
	puntos integer,
	es_vip boolean
) AS
$$
DECLARE
	cod_nuevo_cliente integer;
BEGIN



	IF (esvip) THEN
		INSERT INTO cliente (nombre, apellidos, puntos) 
		VALUES (nom, ape, 1000) RETURNING cliente.cod_cliente INTO cod_nuevo_cliente;
		
		INSERT INTO clientevip (cod_cliente)
		VALUES (cod_nuevo_cliente);
		
		RETURN QUERY
		SELECT cliente.cod_cliente, nombre || ' ' || apellidos, cliente.puntos, true
		FROM cliente
		WHERE cliente.cod_cliente = cod_nuevo_cliente;

	ELSE
		INSERT INTO cliente (nombre, apellidos)
		VALUES (nom, ape) RETURNING cliente.cod_cliente INTO cod_nuevo_cliente;
	
		RETURN QUERY
		SELECT cliente.cod_cliente, nombre || ' ' || apellidos, cliente.puntos, false
		FROM cliente 
		WHERE cliente.cod_cliente = cod_nuevo_cliente;
	END IF;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM inserta_cliente('Luismi', 'López', true);
SELECT * FROM inserta_cliente('Ángel', 'Naranjo', false);