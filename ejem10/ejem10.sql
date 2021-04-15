
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