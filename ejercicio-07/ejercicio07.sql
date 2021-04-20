CREATE TABLE hotel (
	id_hotel SERIAL PRIMARY KEY,
	nombre TEXT,
	ciudad TEXT,
	provincia TEXT
);

CREATE TABLE habitacion (
	id_habitacion SERIAL PRIMARY KEY,
	id_hotel INT REFERENCES hotel (id_hotel),
	num_habitacion SMALLINT,
	nombre TEXT,
	metros_cuadrados SMALLINT,
	tiene_vistas BOOLEAN,
	tipo TEXT CHECK (tipo IN ('Sencilla','Doble','Suite'))	
);

CREATE OR REPLACE FUNCTION aleatorio(int, int)
RETURNS int AS
$$
	select floor (random()*($2-$1+1)+$1)::int
$$ LANGUAGE sql;

SELECT aleatorio(1,20);

CREATE OR REPLACE FUNCTION aleatorio(int)
RETURNS int AS
$$
	SELECT aleatorio(1, $1);
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION aleatorio_v2(int)
RETURNS int AS
$$
DECLARE
	resultado INT;
BEGIN
	select aleatorio(1, $1) INTO resultado;
	-- resultado := aleatorio(1, $1);
	return resultado;
END;
$$ LANGUAGE plpgsql;
SELECT aleatorio_v2(10);


CREATE OR REPLACE PROCEDURE init_data
(num_hoteles int, num_habs int) AS $$
DECLARE
	lugares TEXT[] := '{"Úbeda/Jaén","Olvera/Cádiz","Frigiliana/Málaga", "San Martín de Trevejo/Cáceres", "Taramundi/Asturias", "Ribadeo/Lugo"}';
	nombres TEXT[] := '{"Barceló", "Eurostars", "NH", "Playa", "Diverhotel", "Meliá", "Riu"}';
	sufijos TEXT[] := '{"", "", "", "Inn", "Adults Only", "Vistamar", "Sierra", "Boutique"}';	
	tipos TEXT[] := '{"Sencilla", "Doble", "Suite"}';
	nombres_suites TEXT[] := '{"Suite Vip", "Imperial", "Alhambra", "Alcázar", "Presidencial", "Piso Patera"}';
	
	nom_ciudad TEXT;
	nom_provincia TEXT;
	nombre_hotel TEXT;	
	el_id_hotel INT;
	
	tipo_hab TEXT;
	nombre_hab TEXT DEFAULT NULL;
	metros_hab SMALLINT;
	vistas_hab BOOLEAN;
BEGIN
	FOR i IN 1..num_hoteles LOOP
		-- Ciudad y provincia
		nom_ciudad := lugares[aleatorio(array_length(lugares,1))];
		nom_provincia := split_part(nom_ciudad, '/', 2);
		nom_ciudad := split_part(nom_ciudad, '/', 1);
		nombre_hotel := trim(concat(nombres[aleatorio(array_length(nombres,1))], ' ', sufijos[aleatorio(array_length(sufijos,1))]));
		-- RAISE NOTICE '%, % -> %', ciudad, provincia, nombre_hotel;
		
		INSERT INTO hotel (nombre, ciudad, provincia)
		VALUES (nombre_hotel, nom_ciudad, nom_provincia)
		RETURNING id_hotel INTO el_id_hotel;
		
		FOR j IN 1..num_habs LOOP
			nombre_hab := NULL;
		
			tipo_hab := tipos[aleatorio(array_length(tipos,1))];
			
			IF (tipo_hab = 'Suite') THEN
				nombre_hab := nombres_suites[aleatorio(array_length(nombres_suites,1))];
			END IF;
			
			metros_hab := aleatorio(10, 40);
			
			vistas_hab := aleatorio(1,2) = 1;
		
			INSERT INTO habitacion
			VALUES (DEFAULT, el_id_hotel, j, nombre_hab, 
					metros_hab, vistas_hab, tipo_hab);		
		END LOOP;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

CALL init_data(10,10);

SELECT * FROM hotel JOIN habitacion USING (id_hotel);

DELETE FROM hotel;
DELETE FROM habitacion;


CREATE TABLE dummy(
	cod	SERIAL PRIMARY KEY,
	texto TEXT,
	fecha TIMESTAMP
);

CREATE OR REPLACE FUNCTION ejemplo()
RETURNS void AS $$
DECLARE
	fec TIMESTAMP;
	ser INT;
	fila dummy%ROWTYPE;
BEGIN
	INSERT INTO dummy 
	VALUES (DEFAULT, 'Hola Mundo', CURRENT_TIMESTAMP)
	RETURNING * INTO fila;
	
	RAISE NOTICE '% - % - %', fila.cod, fila.texto, fila.fecha;
	
END;	
$$ LANGUAGE plpgsql;


SELECT ejemplo();

SELECT * FROM dummy;
