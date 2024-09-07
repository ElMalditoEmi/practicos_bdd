
-- Practico 2
-- Esquema
-- 1)
 
CREATE DATABASE `world`;
-- Borrar base de datos
-- DROP DATABASE world;
 
-- 2)
 
USE `world`;
 
CREATE TABLE `country` (
	`Code` VARCHAR(10) PRIMARY KEY NOT NULL,
	`Name` VARCHAR(200),
	`Continent` VARCHAR(200),
	`Region` VARCHAR(200),
	`SurfaceArea` DOUBLE,
	`IndepYear` INT,
	`Population` INT,
	`LifeExpectancy` INT,
	`GNP` INT,
	`GNPOld` INT,
	`LocalName` VARCHAR(200),
	`GovernmentForm`  VARCHAR(200),
	`HeadOfState` VARCHAR(200),
	`Capital` INT,
	`Code2` VARCHAR(10)
);
 
CREATE TABLE `city` (
	`ID` INT PRIMARY KEY NOT NULL,
	`Name` VARCHAR(200),
	`CountryCode` VARCHAR(10),
	`District` VARCHAR(200),
	`Population` INT,
	FOREIGN KEY (`CountryCode`) REFERENCES country(`Code`)
);
 
CREATE TABLE `countrylanguage` (
	`CountryCode` VARCHAR(10) NOT NULL,
	`Language` VARCHAR(200) NOT NULL,
	`IsOfficial` VARCHAR(200),
	`Percentage` DOUBLE,
	PRIMARY KEY (`CountryCode`, Language),
	FOREIGN KEY (`CountryCode`) REFERENCES country(`Code`)
);
 

 
-- -- LIMPIAR LAS TABLAS SIN BORRARLAS
-- TRUNCATE TABLE countrylanguage;
-- TRUNCATE TABLE city;
-- TRUNCATE TABLE country;
 
-- -- BORRAR LAS TABLAS
-- DROP TABLE countrylanguage;
-- DROP TABLE city;
-- DROP TABLE country;
 
-- 3) En el archivo word-data.sql
 
-- 4)
 
CREATE TABLE `continent` (
	`Name` VARCHAR(200) PRIMARY KEY NOT NULL,
	`Area` INT,
	`PercentTotalMass` DOUBLE,
	`MostPopulousCity` VARCHAR(200)
);
 
-- 5)
 
INSERT INTO `continent` (`Name`, `Area`, `PercentTotalMass`, `MostPopulousCity`) VALUES
('Africa', 30370000, 20.4, 'Cairo, Egypt'),
('Antarctica', 14000000, 9.2, 'McMurdo Station*'),
('Asia', 44579000, 29.5, 'Mumbai, India'),
('Europe', 10180000, 6.8, 'Instanbul, Turquia'),
('North America', 24709000, 16.5, 'Ciudad de México, Mexico'),
('Oceania', 8600000, 5.9, 'Sydney, Australia'),
('South America', 17840000, 12.0, 'São Paulo, Brazil');
 
-- Otra opcion es:
-- INSERT INTO `continent` VALUES ('Africa', 30370000, 20.4, 'Cairo, Egypt');
-- INSERT INTO `continent` VALUES ('Antarctica', 14000000, 9.2, 'McMurdo Station*');
-- INSERT INTO `continent` VALUES ('Asia', 44579000, 29.5, 'Mumbai, India');
-- INSERT INTO `continent` VALUES ('Europe', 10180000, 6.8, 'Instanbul, Turquia');
-- INSERT INTO `continent` VALUES ('North America', 24709000, 16.5, 'Ciudad de México, Mexico');
-- INSERT INTO `continent` VALUES ('Oceania', 8600000, 5.9, 'Sydney, Australia');
-- INSERT INTO `continent` VALUES ('South America', 17840000, 12.0, 'São Paulo, Brazil');
 
-- 6)
 
ALTER TABLE `country` ADD 
	FOREIGN KEY (`Continent`) REFERENCES continent(`Name`) ;
 
 
-- Practico 3
-- 1.
SELECT city.Name, country.Name, country.Region
from city
JOIN country where city.CountryCode = country.Code
order by city.Population DESC
LIMIT 10;
 
-- 2.
SELECT country.Name AS 'Country Name',
city.Name as 'Capital' from country 
LEFT JOIN city ON city.ID = country.Capital
order by country.Population ASC
LIMIT 10;
 
-- 3.
SELECT country.Name AS 'Country Name',
continent.Name AS 'Continent',
countrylanguage.Language AS 'Language'
FROM country
LEFT JOIN continent ON country.Continent = continent.Name
LEFT JOIN countrylanguage ON countrylanguage.IsOfficial = 'T' 
							AND countrylanguage.countryCode = country.Code;
 
-- 4.
SELECT country.Name AS 'Country Name',
city.Name as 'Capital' from country 
LEFT JOIN city ON city.ID = country.Capital
order by country.SurfaceArea DESC
LIMIT 10;
 
-- 5.
SELECT city.Name AS 'City Name',
countrylanguage.Language AS 'Language',
countrylanguage.Percentage AS 'Speakers'
FROM city
INNER JOIN countrylanguage ON countrylanguage.IsOfficial = 'T'
							AND countrylanguage.CountryCode = city.CountryCode
ORDER BY city.Population desc;
 

-- 6.
(SELECT country.Name AS 'Country Name'
FROM country
ORDER BY Population ASC
LIMIT 10)
UNION
(SELECT country.Name AS 'Country Name'
FROM country
ORDER BY Population DESC
LIMIT 10);

-- 7 
SELECT DISTINCT country.name AS 'Country Name'
FROM country 
INNER JOIN countrylanguage ON countrylanguage.IsOfficial = 'T'
							AND (countrylanguage.`Language` = "English"
								OR countrylanguage.`Language` = "French")
							AND countrylanguage.CountryCode = country.Code;

							
-- 8
(SELECT DISTINCT country.Name
FROM country
INNER JOIN countrylanguage ON countrylanguage.CountryCode = country.Code
						AND countrylanguage.`Language` = "English")
EXCEPT
(SELECT DISTINCT country.Name
FROM country
INNER JOIN countrylanguage ON countrylanguage.CountryCode = country.Code
						AND countrylanguage.`Language` = "Spanish")
						
					
						
						
-- Ejemplo de IN (Set Membership)
-- Todas las ciudades de Argentina que no son de Buenos Aires ni Mendoza
SELECT * FROM city WHERE 
CountryCode = 'ARG' AND District NOT IN ('Buenos Aires','Mendoza');

-- Ejemplo de ALL (Set comparison)
-- Obtener todas las ciudades de Argentina talque la población
-- es mas grande que cualquier ciudad de Noruega
SELECT * FROM city WHERE 
CountryCode = 'ARG' 
AND Population > ALL
	(SELECT Population FROM city 
	WHERE CountryCode = "NOR")

	
-- Todas las ciudades tales que su pais, tiene menos 
-- población que la ciudad. Por ejemplo
-- Está Gibraltar porque redondea el valor de su población mucho
SELECT * FROM city WHERE  
EXISTS (
	SELECT * FROM country
	WHERE country.Population < city.Population
	AND city.CountryCode = country.Code 
)

-- Paises, que no tienen una ciudad con mas de 1000 habitantes 
SELECT * FROM country WHERE  
NOT EXISTS (
	SELECT * FROM city
	WHERE city.Population > 1000
	AND city.CountryCode = country.Code 
)
	
-- Ejemplo de count
	-- Cuenta los paises que registran año de independencia (resultado = 192)
SELECT COUNT(IndepYear) FROM
country c

	-- Para corroborar, esta query trae todos los paises que tienen año de indep. (obtiene 192 filas)
SELECT * FROM 
country c WHERE c.IndepYear IS NOT NULL

-- Consulta escalar:
-- Puede aparecer en un SELECT,WHERE o HAVING

-- Una consulta escalar es una subconsulta donde se espera una expresión
-- siempre que la consulta retorne una fila con una sola columna. 
-- 
-- Ejemplo consulta escalar en el SELECT: Listar los paises y la cantidad de ciudades que registran
-- En este caso la expresión que usa COUNT trae solo una fila con una sola columna.
SELECT country.Name AS "Country Name",
	(SELECT COUNT(*) FROM
	city WHERE city.CountryCode = country.Code) AS "Num cities" 
FROM  country

-- Ejemplo de consulta escalar en el WHERE: Listar los paises con menos ciudades registradas que Argentina
SELECT country.Name AS "Country Name"
FROM  country
WHERE 
	(SELECT COUNT(*) FROM city 
	WHERE city.CountryCode = country.Code
	) > (SELECT COUNT(*) FROM city 
	WHERE city.CountryCode = "ARG"
	)
-- Common Table Expressions (CTE)
	-- WITH define una tabla temporaria para usar en la query

-- Ejemplo (Claramente horrible solo para probar el WITH) calcular el pais con mas ciudades
-- Veamos por partes:
-- Parte 1: Obtener la cantidad de ciudades de un pais
SELECT country.Code AS "Country Name",
	(SELECT COUNT(*) FROM
	city WHERE city.CountryCode = country.Code) AS "Num cities" 
FROM  country

-- Parte 2: Obtener el numero maximo de ciudades de entre todos los paises
SELECT MAX(country_num_cities.Num_cities) AS "City count from country with most cities"
FROM (
SELECT country.Code AS "Country Name",
	(SELECT COUNT(*) FROM
	city WHERE city.CountryCode = country.Code) AS "Num_cities" 
FROM  country
) AS country_num_cities

-- Parte 3: Con esa query matcheamos el pais

WITH
most_cities AS (
    SELECT 
        MAX(country_num_cities.Num_cities) AS max_value
    FROM (
        SELECT 
            country.Code AS "Country Code",
            (SELECT COUNT(*) 
             FROM city 
             WHERE city.CountryCode = country.Code) AS "Num_cities" 
        FROM  
            country
    ) AS country_num_cities
)
SELECT 
    country.*
FROM 
    country
JOIN 
    most_cities 
ON 
    (SELECT COUNT(*) 
     FROM city 
     WHERE city.CountryCode = country.Code) = most_cities.max_value;
    
-- Otro ejemplo de agregación
-- La media de población de las ciudades de un pais

SELECT 
    country.Name, 
    AVG(city.Population) AS "Average Population"
FROM 
    country
JOIN 
    city ON city.CountryCode = country.Code
GROUP BY -- Si no se especifica, la agregación es ambigüa
    country.Name;

-- Practico 4
-- 1. 
SELECT city.Name, country.Name 
FROM city, country
WHERE city.CountryCode = country.Code AND country.Code IN (
	SELECT country.Code FROM country
	WHERE country.Population < 10000
	)
	
-- 2.
SELECT * FROM city c 
WHERE c.Population > (SELECT AVG(Population) FROM city c2)
 
-- 3.
-- Obtener solo ciudades no asiaticas

SELECT c.Name,c.CountryCode FROM city c
LEFT JOIN country c2 
ON c2.Code = c.CountryCode
AND c2.Continent != 'Asia';

-- De la tabla de ciudades no asiaticas, ver que existe algún pais asiatico con población menor igual

SELECT * FROM city c
INNER JOIN country non_asians 
ON non_asians.Code = c.CountryCode
AND non_asians.Continent != 'Asia'
WHERE c.Population >= SOME 
	(SELECT Population FROM country asians
	WHERE asians.Continent = 'Asia')
;


-- 4. 
SELECT
	c.Name,
	langs.`Language`
FROM
	country c
INNER JOIN countrylanguage langs
ON
	langs.CountryCode = c.Code
	AND langs.IsOfficial != 'T'
WHERE
	langs.Percentage > ALL 
	(
	SELECT
		Percentage
	FROM
		countrylanguage
	WHERE
		countrylanguage.CountryCode = c.Code
		AND countrylanguage.IsOfficial = 'T'
	)
;

-- 5.
SELECT
	DISTINCT c.Region
FROM
	country c
WHERE
	c.SurfaceArea < 1000
	AND EXISTS
	(
	SELECT
		*
	FROM
		city c2
	WHERE
		c2.CountryCode = c.Code
		AND
		c2.Population > 100000
	);

-- Forma 2
SELECT 
	DISTINCT c.Region
FROM
	city c2
JOIN
	country c
ON
	c2.CountryCode = c.Code 
WHERE 
	c.SurfaceArea < 1000
	AND
	c2.Population > 100000
;

-- 6. 
SELECT 
	c.Name AS "Country",
	(SELECT MAX(Population)
	FROM city c2
	WHERE 
		c2.CountryCode = c.Code
	)
FROM country c 

-- 7.
SELECT c.Name, non_off_lang.`Language`
FROM country c
INNER JOIN countrylanguage non_off_lang
ON non_off_lang.CountryCode = c.Code 
AND non_off_lang.IsOfficial = 'F'
WHERE
	non_off_lang.Percentage >
	( -- Promedio de hablantes de lenguajes oficiales del pais
	SELECT AVG(off.Percentage)
	FROM countrylanguage off
	WHERE off.CountryCode = c.Code 
	AND off.IsOfficial = 'T'
	) 

-- 8.
-- Forma 1
SELECT c.Name, SUM(co.Population) AS "Population"
FROM continent c 
JOIN country co
ON co.Continent = c.Name
GROUP BY c.Name

-- Forma 2 (Solo agrupar)
SELECT co.Continent , SUM(co.Population)
FROM country co
GROUP BY co.Continent

-- 10.
SELECT
	co.Continent AS "Continent",
	AVG(co.Population) AS "Average",
	MAX(co.Population) AS "Max",
	MIN(co.Population) AS "Min"
FROM
	country co
GROUP BY
	co.Continent





