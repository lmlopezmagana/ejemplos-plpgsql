-- A ejecutar en la base de datos de climatología

DROP TABLE IF EXISTS temperaturas_extremas_mensuales;

CREATE TABLE temperaturas_extremas_mensuales (
	anio smallint,
	mes  varchar(20),
	nummes smallint,
	tipo varchar(3) CHECK (tipo IN ('max', 'min')),
	provincia varchar(50),
	temperatura numeric,
	CONSTRAINT PK_temperaturas_extremas_mensuales PRIMARY KEY (anio, mes, provincia, tipo)
);

CREATE OR REPLACE FUNCTION inserta_temperaturas_extremas_mensuales_v2()
RETURNS SETOF temperaturas_extremas_mensuales
AS $$
DECLARE
	datos RECORD;
	cant INT;
    fila temperaturas_extremas_mensuales%ROWTYPE;
BEGIN
	FOR datos IN SELECT EXTRACT(year from fecha) as num_anio, TO_CHAR(fecha, 'TMMonth') as mes, 
					EXTRACT(month from fecha) as num_mes , provincia,
						MAX(temperatura_maxima) as maxima, MIN(temperatura_minima) as minima
						FROM climatologia
						GROUP BY EXTRACT(year from fecha), TO_CHAR(fecha, 'TMMonth'), EXTRACT(month from fecha), provincia
					LOOP
	
		cant := (SELECT COUNT(*)::int FROM temperaturas_extremas_mensuales 
                 WHERE anio = datos.num_anio AND nummes = datos.num_mes AND provincia = datos.provincia);

        IF (cant > 0) THEN
            RAISE NOTICE 'Ya hay datos de resumen para %-%-%', datos.num_anio, datos.num_mes, datos.provincia;
		ELSE
            INSERT INTO temperaturas_extremas_mensuales (anio, mes, nummes, provincia, tipo, temperatura)
            VALUES (datos.num_anio, datos.mes, datos.num_mes, datos.provincia, 'max', datos.maxima)
            RETURNING * INTO fila;

            RETURN NEXT fila;

            INSERT INTO temperaturas_extremas_mensuales (anio, mes, nummes, provincia, tipo, temperatura)
            VALUES (datos.num_anio, datos.mes, datos.num_mes, datos.provincia, 'min', datos.minima)
            RETURNING * INTO fila;

            RETURN NEXT fila;


        END IF;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Devuelve todos porque la tabla inicialmente estaba vacía
SELECT * FROM inserta_temperaturas_extremas_mensuales_v2();

-- Probamos añadiendo un dato más:

INSERT INTO climatologia (fecha, estacion, provincia, temperatura_maxima, hora_temperatura_maxima, temperatura_minima, hora_temperatura_minima)
VALUES ('2021-04-15'::date, 'Triana', 'Sevilla', 25.5, '14:15', 12.0, '06:00');

-- Volvemos a ejecutar
SELECT * FROM inserta_temperaturas_extremas_mensuales_v2();

-- Como resultado, solamente aparecen las temperaturas que acabamos de añadir (no hay más datos para Abril/2021)
-- Con todo, la tabla tiene los datos anteriores y los añadidos

SELECT *
FROM temperaturas_extremas_mensuales;


DROP TABLE IF EXISTS temperaturas_extremas_mensuales CASCADE;


-------------------------
-- EJEMPLO RETURN QUERY
-------------------------

CREATE OR REPLACE FUNCTION maximas_fecha_provincia(fec date, prov varchar, min_maxima int)
RETURNS SETOF climatologia AS $$
BEGIN
    RETURN QUERY SELECT * FROM climatologia WHERE fecha = fec AND provincia = prov AND temperatura_maxima >= min_maxima;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM maximas_fecha_provincia('2019-04-05', 'Sevilla', 10);