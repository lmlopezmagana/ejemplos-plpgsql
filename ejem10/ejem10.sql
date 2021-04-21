
CREATE TABLE dummy (
    texto text PRIMARY KEY
);

CREATE OR REPLACE FUNCTION funcion_disparadora() RETURNS trigger AS
$$
BEGIN
    RAISE NOTICE 'Un disparador ha sido invocado';
    RETURN null;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_dummy
AFTER INSERT 
ON dummy
FOR EACH ROW
EXECUTE PROCEDURE funcion_disparadora();

INSERT INTO dummy VALUES ('Hola Mundo!');


CREATE TABLE dummy2 (
    ide SERIAL PRIMARY KEY,
    texto TEXT,
    fecha DATE DEFAULT CURRENT_DATE
);

CREATE OR REPLACE FUNCTION show_insert_info() RETURNS trigger AS
$$
BEGIN
	RAISE NOTICE 'Fila insertada';
    RAISE NOTICE 'ide: %, texto: %, fecha: %', NEW.ide, NEW.texto, NEW.fecha;
	RETURN null;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER show_insert_info_trg
AFTER INSERT
ON dummy2
FOR EACH ROW
EXECUTE PROCEDURE show_insert_info();

INSERT INTO dummy2 (texto) VALUES ('El perro de San Roque no tiene rabo');


CREATE OR REPLACE FUNCTION show_update_info() RETURNS trigger AS
$$
BEGIN
	RAISE NOTICE 'Fila actualizada';
    RAISE NOTICE 'Valores antiguos: ide: %, texto: %, fecha: %', OLD.ide, OLD.texto, OLD.fecha;
    RAISE NOTICE 'Valores nuevos: ide: %, texto: %, fecha: %', NEW.ide, NEW.texto, NEW.fecha;
    RETURN null;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER show_update_info_trg
AFTER UPDATE
ON dummy2
FOR EACH ROW
EXECUTE PROCEDURE show_update_info();

UPDATE dummy2
SET texto = 'Porque Ramón Ramírez se lo ha cortado',
	fecha = CURRENT_DATE + 1
WHERE texto = 'El perro de San Roque no tiene rabo';