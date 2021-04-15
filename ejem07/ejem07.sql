DO $$
DECLARE

BEGIN
    FOR n IN 1..5 LOOP
        RAISE NOTICE '%', n;
    END LOOP;
END;
$$ LANGUAGE plpgsql


DO $$
DECLARE

BEGIN
    FOR n IN 0..25 BY 5 LOOP
		IF (n > 0) THEN
			RAISE NOTICE '%', n;
		END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql



DO $$
DECLARE

BEGIN
    FOR n IN REVERSE 5..1 LOOP
        RAISE NOTICE '%', n;
    END LOOP;
END;
$$ LANGUAGE plpgsql


-- A ejecutar con la base de datos de climatologia


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

CREATE OR REPLACE PROCEDURE inserta_temperaturas_extremas_mensuales()
AS $$
DECLARE
	datos RECORD;
	cant INT;
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
            VALUES (datos.num_anio, datos.mes, datos.num_mes, datos.provincia, 'max', datos.maxima);

            INSERT INTO temperaturas_extremas_mensuales (anio, mes, nummes, provincia, tipo, temperatura)
            VALUES (datos.num_anio, datos.mes, datos.num_mes, datos.provincia, 'min', datos.minima);
        END IF;
	END LOOP;

END;
$$ LANGUAGE plpgsql;

CALL inserta_temperaturas_extremas_mensuales();

SELECT * FROM temperaturas_extremas_mensuales
ORDER BY anio, nummes, provincia;

DROP TABLE IF EXISTS temperaturas_extremas_mensuales;