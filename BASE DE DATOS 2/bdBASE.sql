CREATE DATABASE BDdos;

--RUBEN INGACION BAUTISTA APAZA CI 12765200
--GARY ADRIEL CARDOZO QUINTANILLA CI 6792475

CREATE TABLE eestudiante (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE calificacion (
    id SERIAL PRIMARY KEY,
    estudiante_id INT REFERENCES estudiante(id),
    nota INT CHECK(nota BETWEEN 0 AND 100)
);



INSERT INTO estudiante(nombre) VALUES 
('GARY ADRIEL CARDOZO QUINTANILLA'), ('RUBEN IGNACION BAUTISTA APAZA'), ('Maria'), ('Carlos'), ('Lucía');

INSERT INTO calificacion(estudiante_id, nota) VALUES
(1, 45), (1, 67), (2, 95), (2, 95), (3, 88), 
(4, 50), (5, 91), (5, 91), (5, 91);

CREATE OR REPLACE FUNCTION eestudiantes_reprobados()
RETURNS TABLE(nombre TEXT, nota INT) AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR 
        SELECT e.nombre, c.nota
        FROM estudiante e
        JOIN calificacion c ON e.id = c.estudiante_id
        WHERE c.nota < 51;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS tmp_reprobados (
        nombre TEXT,
        nota INT
    ) ON COMMIT DROP;
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        INSERT INTO tmp_reprobados(nombre, nota)
        VALUES (rec.nombre, rec.nota);
    END LOOP;

    CLOSE cur;
    RETURN QUERY SELECT * FROM tmp_reprobados;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION eestudiantes_excelentes()
RETURNS TABLE(nombre TEXT, nota INT) AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR 
        SELECT e.nombre, c.nota
        FROM estudiante e
        JOIN calificacion c ON e.id = c.estudiante_id
        WHERE c.nota > 90;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS tmp_excelentes (
        nombre TEXT,
        nota INT
    ) ON COMMIT DROP;
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        INSERT INTO tmp_excelentes(nombre, nota)
        VALUES (rec.nombre, rec.nota);
    END LOOP;
    CLOSE cur;
    RETURN QUERY SELECT * FROM tmp_excelentes;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION eestudiantes_repetidos()
RETURNS TABLE(nombre TEXT, nota INT, veces INT) AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR
        SELECT e.nombre, c.nota, COUNT(*) as veces
        FROM estudiante e
        JOIN calificacion c ON e.id = c.estudiante_id
        GROUP BY e.nombre, c.nota
        HAVING COUNT(*) > 1
        ORDER BY veces DESC;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS tmp_repetidos (
        nombre TEXT,
        nota INT,
        veces INT
    ) ON COMMIT DROP;
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        INSERT INTO tmp_repetidos(nombre, nota, veces)
        VALUES (rec.nombre, rec.nota, rec.veces);
    END LOOP;
    CLOSE cur;
	
    RETURN QUERY SELECT * FROM tmp_repetidos;
END;
$$ LANGUAGE plpgsql;


SELECT *from eestudiantes_reprobados();
SELECT *from eestudiantes_excelentes();
SELECT *from eestudiantes_repetidos();
