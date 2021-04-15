-- A ejecutar sobre la base de datos de climatologia


CREATE OR REPLACE FUNCTION maximas_fecha_provincia_v2(fec date, prov varchar, min_maxima int)
RETURNS SETOF climatologia AS $$
BEGIN
    RETURN QUERY SELECT * FROM climatologia WHERE fecha = fec AND provincia = prov AND temperatura_maxima >= min_maxima;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No hay datos para la fecha %, en la provincia %, con temperaturas máximas por encima de %', fec, prov, min_maxima;
    END IF;

END;
$$ LANGUAGE plpgsql;


SELECT * FROM maximas_fecha_provincia_v2('2019-04-05', 'Sevilla', 20);