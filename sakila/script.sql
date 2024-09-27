use sakila;

-- COSAS QUE APRENDÍ
-- Como actualizar valores usando una sub-tabla para filtrar
-- En general la estructura seria:

UPDATE tabla t
	INNER JOIN (
		-- Subquery que trae alguna tabla con filas de t, y columnas c1,...,cn
	)
	ON c1.attrib = t.attrib -- Condicion del join

	SET -- columnas a setear de t
	WHERE -- Condición de UPDATE


UPDATE customer c 
    INNER JOIN (
        SELECT p.customer_id, SUM(amount) as total_spent
        FROM payment p
        GROUP BY
            p.customer_id
        ORDER BY total_spent DESC
        LIMIT 10
    ) AS top_10
	ON top_10.customer_id = c.customer_id
SET c.premium_customer = 'T'


CREATE TABLE directors (
    director_first_name varchar(1022),
    director_last_name varchar(1003),
    num_pelis int,
    actor_id int PRIMARY KEY
)
-- 1.

-- Obtener los id del top_5 en cantidad de pelis
(
    SELECT fa.actor_id, COUNT(*) as filmcount
    FROM film_actor fa
    GROUP BY
        fa.actor_id
    ORDER BY COUNT(*) DESC
    LIMIT 5
)
-- Insertar en la tabla de directors
INSERT INTO
    directors
SELECT first_name, last_name, top_5.filmcount, a.actor_id
FROM actor a
    INNER JOIN (
        SELECT fa.actor_id, COUNT(*) as filmcount
        FROM film_actor fa
        GROUP BY
            fa.actor_id
        ORDER BY COUNT(*) DESC
        LIMIT 5
    ) as top_5 ON top_5.actor_id = a.actor_id
-- 3.
ALTER TABLE customer
ADD COLUMN premium_customer char(1) NOT NULL DEFAULT 'F'

-- 4.

UPDATE customer c 
    INNER JOIN (
        SELECT p.customer_id, SUM(amount) as total_spent
        FROM payment p
        GROUP BY
            p.customer_id
        ORDER BY total_spent DESC
        LIMIT 10
    ) AS top_10
	ON top_10.customer_id = c.customer_id
SET c.premium_customer = 'T'

-- Subquery: Obtener el top 10 de los que mas gastaron
SELECT p.customer_id, SUM(amount) as total_spent
FROM payment p
GROUP BY
    p.customer_id
ORDER BY total_spent DESC
LIMIT 10 -- Cuanto gasto cada customer

-- 5.
-- Listar, ordenados por cantidad de películas (de mayor a menor), los distintos ratings
-- de las películas existentes (Hint: rating se refiere en este caso a la clasificación
-- según edad: G, PG, R, etc).

SELECT COUNT(*),f.rating FROM film as f
GROUP BY rating


-- 6.

SELECT MIN(paym.payment_date), MAX(paym.payment_date)
FROM sakila.payment AS paym


-- 7.
-- Calcule, por cada mes, el promedio de pagos (Hint: vea la manera de extraer el
-- nombre del mes de una fecha).

SELECT 
    DATE_FORMAT(pay.payment_date, '%M') AS month_name,
    AVG(amount) AS avg_payment
FROM 
    payment as pay
GROUP BY 
    month_name;


-- 8.
-- Listar los 10 distritos que tuvieron mayor cantidad de alquileres (con la cantidad total
-- de alquileres).

SELECT * from address

SELECT COUNT(*) as n_by_dist
,ad.district as district
from address as ad
INNER JOIN customer as cu
ON cu.address_id = ad.address_id
WHERE cu.customer_id = SOME (
    SELECT customer_id FROM rental
)
GROUP BY ad.district
ORDER BY n_by_dist DESC
LIMIT 10
