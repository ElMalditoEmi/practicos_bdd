CREATE TABLE directors(
	director_first_name varchar(1022),
	director_last_name varchar(1003),
	num_pelis int
	actor_id int PRIMARY KEY
)

-- 1.

-- Obtener los id del top_5 en cantidad de pelis
(SELECT fa.actor_id, COUNT(*) as filmcount
FROM film_actor fa
GROUP BY fa.actor_id
ORDER BY COUNT(*) DESC
LIMIT 5)

 -- Insertar en la tabla de directors

INSERT
	INTO
	directors
SELECT
	first_name,
	last_name,
	top_5.filmcount,
	a.actor_id
FROM
	actor a
INNER JOIN (
	SELECT
		fa.actor_id,
		COUNT(*) as filmcount
	FROM
		film_actor fa
	GROUP BY
		fa.actor_id
	ORDER BY
		COUNT(*) DESC
	LIMIT 5) as top_5
ON
	top_5.actor_id = a.actor_id

-- 3. 
	
ALTER TABLE customer 
ADD COLUMN premium_customer char(1) NOT NULL DEFAULT 'F'

-- 4.
UPDATE customer c
SET c.premium_customer='T'
FROM customer.ce

USING (
SELECT p.customer_id, SUM(amount) as total_spent FROM payment p
GROUP BY
p.customer_id
ORDER BY total_spent DESC
LIMIT 10-- Cuanto gasto cada customer
) AS top_10



    (SELECT p.customer_id, SUM(amount) as total_spent FROM payment p
	GROUP BY
	p.customer_id
	ORDER BY total_spent DESC
	LIMIT 10-- Cuanto gasto cada customer
	)
	

WITH top AS (
	SELECT
		p.customer_id,
		SUM(amount) as total_spent
	FROM
		payment p
	GROUP BY
		p.customer_id
	ORDER BY
		total_spent DESC
	LIMIT 10
	)
SELECT
	customer c
WHERE
	c.customer_id in top





-- 5. 

