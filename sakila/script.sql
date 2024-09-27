use sakila;

-- COSAS QUE APRENDÍ
-- Como actualizar valores usando una sub-tabla para filtrar
-- En general la estructura seria:

UPDATE tabla t
INNER JOIN (
    -- Subquery que trae alguna tabla con filas de t, y columnas c1,...,cn
) ON c1.attrib = t.attrib -- Condicion del join

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
) AS top_10 ON top_10.customer_id = c.customer_id
SET
    c.premium_customer = 'T'

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
) AS top_10 ON top_10.customer_id = c.customer_id
SET
    c.premium_customer = 'T'
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

SELECT COUNT(*), f.rating FROM film as f GROUP BY rating

-- 6.

SELECT MIN(paym.payment_date), MAX(paym.payment_date)
FROM sakila.payment AS paym

-- 7.
-- Calcule, por cada mes, el promedio de pagos (Hint: vea la manera de extraer el
-- nombre del mes de una fecha).

SELECT DATE_FORMAT(pay.payment_date, '%M') AS month_name, AVG(amount) AS avg_payment
FROM payment as pay
GROUP BY
    month_name
ORDER BY avg_payment;

-- 8.
-- Listar los 10 distritos que tuvieron mayor cantidad de alquileres (con la cantidad total
-- de alquileres).

SELECT * FROM rental

SELECT ad.district as district, COUNT(*) as n_by_dist
from address as ad
    INNER JOIN customer as cu ON cu.address_id = ad.address_id
    INNER JOIN rental as re ON re.customer_id = cu.customer_id
GROUP BY
    ad.district
ORDER BY n_by_dist DESC
LIMIT 10



-- 9.
-- Modifique la table `inventory_id` agregando una columna `stock` que sea un número
-- entero y representa la cantidad de copias de una misma película que tiene
-- determinada tienda. El número por defecto debería ser 5 copias.

ALTER TABLE inventory ADD COLUMN stock INTEGER DEFAULT 5

UPDATE inventory inv1
JOIN (
    SELECT store_id, film_id, COUNT(*) as stock_count
    FROM inventory
    GROUP BY
        store_id,
        film_id
) as inv2 ON inv1.store_id = inv2.store_id
AND inv1.film_id = inv2.film_id
SET
    inv1.stock = inv2.stock_count;

-- Subquery: Obtener cuantas de un film_id hay en una tienda
SELECT store_id, film_id, COUNT(*) as stock_count
FROM inventory
GROUP BY
    store_id,
    film_id

-- 10.
-- Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro a la
-- tabla rental, haga un update en la tabla `inventory` restando una copia al stock de la
-- película rentada (Hint: revisar que el rental no tiene información directa sobre la
-- tienda, sino sobre el cliente, que está asociado a una tienda en particular).

ALTER TABLE inventory 
ADD COLUMN stock int DEFAULT 0

CREATE TRIGGER malditotrigger AFTER INSERT ON
rental FOR EACH ROW
BEGIN
    UPDATE inventory SET stock = stock - 1 WHERE inventory.inventory_id = NEW.inventory_id;
END;

DROP TRIGGER malditotrigger

INSERT INTO
rental VALUES(0,'2005-5-11',1,1,'2005-11-11',1,'2005-11-11')

SELECT * FROM rental


SELECT * FROM inventory


INSERT INTO rental VALUES()


-- 11.
CREATE TABLE fines (
    rental_id int,
    amount DECIMAL(65, 2),
    FOREIGN KEY (rental_id) REFERENCES rental (rental_id)
);

-- 12.

DELIMITER //

CREATE PROCEDURE add_fine()
BEGIN
    INSERT INTO  fines (rental_id,amount)
    SELECT rental_id, 1.5*DATEDIFF(return_date,rental_date) FROM rental
    WHERE DATEDIFF(return_date,rental_date) >= 3 ;
END;
//

DROP PROCEDURE add_fine
CALL add_fine()

SELECT * FROM fines
where amount < 0
DELIMITER ;

-- 13.

CREATE ROLE employee

GRANT INSERT on rental TO employee
GRANT UPDATE on rental TO employee
GRANT DELETE on rental TO employee

-- 14.
REVOKE DELETE ON rental FROM employee

CREATE ROLE administrator

GRANT ALL ON sakila.* TO administrator

-- 15.

CREATE ROLE 'emp1','emp2'

GRANT 'employee' TO emp1

GRANT 'administrator' TO emp2