use olympics

-- Parcial 1
-- 1.
ALTER TABLE person
ADD COLUMN total_medals INT DEFAULT 0

-- 2.
UPDATE person
INNER JOIN
(
SELECT 
    person.id,
    COUNT(IF(competitor_event.medal_id!=4,1,NULL)) as total_medals
FROM person
INNER JOIN games_competitor ON games_competitor.person_id = person.id
INNER JOIN competitor_event ON competitor_event.competitor_id = games_competitor.id
GROUP BY person.id
) as medals_by_person
ON medals_by_person.id = person.id
SET person.total_medals = medals_by_person.total_medals

-- 3.
SELECT DISTINCT person.full_name FROM person
INNER JOIN games_competitor ON games_competitor.person_id = person.id
INNER JOIN competitor_event ON competitor_event.competitor_id = games_competitor.id
INNER JOIN person_region ON person.id = person_region.person_id
INNER JOIN noc_region ON person_region.region_id = noc_region.id
WHERE medal_id != 4 AND noc_region.noc = 'ARG'

-- 4.
SELECT sport.sport_name ,COUNT(medal_id) FROM person
INNER JOIN games_competitor ON games_competitor.person_id = person.id
INNER JOIN competitor_event ON competitor_event.competitor_id = games_competitor.id
INNER JOIN person_region ON person.id = person_region.person_id
INNER JOIN noc_region ON person_region.region_id = noc_region.id
INNER JOIN `event` ON competitor_event.event_id = `event`.id
INNER JOIN sport ON sport.id = `event`.sport_id
WHERE noc_region.noc = 'ARG'
GROUP BY sport_id

-- 5. Listar el número total de medallas de oro, plata y bronce ganadas por cada país
-- (país representado en la tabla `noc_region`), agruparlas los resultados por pais.
SELECT
    region_name ,
    COUNT(IF(medal_id=1,1,NULL)) as oros,
    COUNT(IF(medal_id=2,1,NULL)) as platas,
    COUNT(IF(medal_id=3,1,NULL)) as bronces
FROM person
INNER JOIN games_competitor ON games_competitor.person_id = person.id
INNER JOIN competitor_event ON competitor_event.competitor_id = games_competitor.id
INNER JOIN person_region ON person.id = person_region.person_id
INNER JOIN noc_region ON person_region.region_id = noc_region.id
INNER JOIN `event` ON competitor_event.event_id = `event`.id
INNER JOIN sport ON sport.id = `event`.sport_id
GROUP BY noc_region.id

-- 6.
-- Obtener el total de medallas por pais
SELECT 
        noc_region.region_name, 
        COUNT(IF(medal_id != 4, 1, NULL)) AS total_medals
    FROM person
    INNER JOIN games_competitor ON games_competitor.person_id = person.id
    INNER JOIN competitor_event ON competitor_event.competitor_id = games_competitor.id
    INNER JOIN person_region ON person.id = person_region.person_id
    INNER JOIN noc_region ON person_region.region_id = noc_region.id
    INNER JOIN `event` ON competitor_event.event_id = `event`.id
    INNER JOIN sport ON sport.id = `event`.sport_id
    GROUP BY noc_region.id


WITH medal_counts
AS
    (SELECT 
        noc_region.region_name, 
        COUNT(IF(medal_id != 4, 1, NULL)) AS total_medals
    FROM person
    INNER JOIN games_competitor ON games_competitor.person_id = person.id
    INNER JOIN competitor_event ON competitor_event.competitor_id = games_competitor.id
    INNER JOIN person_region ON person.id = person_region.person_id
    INNER JOIN noc_region ON person_region.region_id = noc_region.id
    INNER JOIN `event` ON competitor_event.event_id = `event`.id
    INNER JOIN sport ON sport.id = `event`.sport_id
    GROUP BY noc_region.id)
SELECT 
    region_name, 
    total_medals
FROM
medal_counts
WHERE total_medals = (SELECT MAX(total_medals) FROM medal_counts AS max_medals)
OR total_medals = (SELECT MIN(total_medals) FROM medal_counts AS min_medals)


-- Recuperatorio 2023
SELECT city.city_name, games_year FROM olympics.games_city
LEFT JOIN city ON city.`ID` = games_city.city_id
INNER JOIN olympics.games ON games_city.games_id = games.id
WHERE games.season = 'Summer'
ORDER BY games_year DESC


-- 2. Obtener el ranking de los 10 países con más medallas de oro en fútbol (1.5p)
SELECT COUNT(ev.id),reg.region_name FROM noc_region as reg
INNER JOIN person_region as per_reg ON reg.id = per_reg.region_id
INNER JOIN person as per ON per.id = per_reg.person_id
INNER JOIN games_competitor as g_comp ON g_comp.person_id = per.id
INNER JOIN competitor_event as comp_ev ON comp_ev.competitor_id = g_comp.id
INNER JOIN medal as medal ON medal.id = comp_ev.medal_id
INNER JOIN event as ev ON ev.id = comp_ev.event_id
INNER JOIN sport as sp ON sp.id = ev.sport_id
WHERE medal.medal_name = 'Gold'
        AND sp.sport_name = 'Football'
GROUP BY reg.id
LIMIT 10

-- 3.
-- Listar con la misma query el país con más participaciones y el país con menos
-- participaciones en los juegos olímpicos (2p)

(SELECT COUNT(ev.id) as participaciones ,reg.region_name FROM noc_region as reg
INNER JOIN person_region as per_reg ON reg.id = per_reg.region_id
INNER JOIN person as per ON per.id = per_reg.person_id
INNER JOIN games_competitor as g_comp ON g_comp.person_id = per.id
INNER JOIN competitor_event as comp_ev ON comp_ev.competitor_id = g_comp.id
INNER JOIN medal as medal ON medal.id = comp_ev.medal_id
INNER JOIN event as ev ON ev.id = comp_ev.event_id
INNER JOIN sport as sp ON sp.id = ev.sport_id
GROUP BY reg.id
ORDER BY participaciones ASC
LIMIT 1)
UNION
(SELECT COUNT(ev.id) as participaciones ,reg.region_name FROM noc_region as reg
INNER JOIN person_region as per_reg ON reg.id = per_reg.region_id
INNER JOIN person as per ON per.id = per_reg.person_id
INNER JOIN games_competitor as g_comp ON g_comp.person_id = per.id
INNER JOIN competitor_event as comp_ev ON comp_ev.competitor_id = g_comp.id
INNER JOIN medal as medal ON medal.id = comp_ev.medal_id
INNER JOIN event as ev ON ev.id = comp_ev.event_id
INNER JOIN sport as sp ON sp.id = ev.sport_id
GROUP BY reg.id
ORDER BY participaciones DESC
LIMIT 1)


-- 4. Crear una vista en la que se muestren entradas del tipo (país, deporte, medallas de
-- oro, medallas de plata, medallas de bronce, participaciones sin medallas) para cada
-- país y deporte (2.5p)
CREATE VIEW medallas as
SELECT reg.region_name, sp.sport_name,
        COUNT(IF(medal.id = 1, 1, NULL)) as golds,
        COUNT(IF(medal.id = 2, 1, NULL)) as silvers,
        COUNT(IF(medal.id = 3, 1, NULL)) as bronzes,
        COUNT(IF(medal.id = 4, 1, NULL)) as participaciones_sin_medallas
FROM noc_region as reg
INNER JOIN person_region as per_reg ON reg.id = per_reg.region_id
INNER JOIN person as per ON per.id = per_reg.person_id
INNER JOIN games_competitor as g_comp ON g_comp.person_id = per.id
INNER JOIN competitor_event as comp_ev ON comp_ev.competitor_id = g_comp.id
INNER JOIN medal as medal ON medal.id = comp_ev.medal_id
INNER JOIN event as ev ON ev.id = comp_ev.event_id
INNER JOIN sport as sp ON sp.id = ev.sport_id
GROUP BY reg.id, sp.id


-- 5. Crear un procedimiento que reciba como parámetro el nombre de un país y
-- devuelva la cantidad total (sumando todos los deportes) de medallas de oro, plata y
-- bronce ganadas por ese país. Puede usar la vista creada en el punto anterior, va a
-- ser mucho más fácil. (1.5p)


SELECT * FROM medallas

DELIMITER |

DROP PROCEDURE IF EXISTS guillermo_el_proc

CREATE PROCEDURE p21(IN coun_name VARCHAR(1000),
                                    OUT cant_oros INT,
                                    OUT cant_platas INT,
                                    OUT cant_bronces INT
                                )
BEGIN
    SELECT SUM(golds),SUM(silvers),SUM(bronzes)
    INTO cant_oros,cant_platas,cant_bronces
    FROM medallas
    WHERE region_name = coun_name
    GROUP BY region_name; 
END;|

-- Para ver si anda
CALL p21('Iran',@a,@b,@c)

SELECT @a,@b,@c

DELIMITER ;
