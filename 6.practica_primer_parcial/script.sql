use classicmodels;

-- 1.
SELECT ofis.*
FROM classicmodels.offices as ofis
    INNER JOIN (
        SELECT COUNT(*) as n_emp, officeCode
        FROM classicmodels.employees
        GROUP BY
            officeCode
    ) as ofis_by_n_emp ON ofis.officeCode = ofis_by_n_emp.officeCode
ORDER BY n_emp DESC
LIMIT 1;

-- 2.
-- Rastrear una oficina desde una orden

--  Numero de compras por cliente
SELECT
    salesRepEmployeeNumber,
    num_buys
FROM classicmodels.customers as cust
    INNER JOIN (
        SELECT COUNT(*) as num_buys, customerNumber
        FROM classicmodels.orders
        GROUP BY
            customerNumber
    ) as cust_numb_buys ON cust_numb_buys.customerNumber = cust.customerNumber
    -- Numero de ventas por un empleado
SELECT num_buys, officeCode
FROM classicmodels.employees as emp
    INNER JOIN (
        SELECT
            salesRepEmployeeNumber, num_buys
        FROM classicmodels.customers as cust
            INNER JOIN (
                SELECT COUNT(*) as num_buys, customerNumber
                FROM classicmodels.orders
                GROUP BY
                    customerNumber
            ) as cust_numb_buys ON cust_numb_buys.customerNumber = cust.customerNumber
    ) as custs ON custs.salesRepEmployeeNumber = emp.employeeNumber
    -- Numero de ventas por codigo de oficina
    (
        SELECT SUM(num_buys) as office_buys, officeCode
        FROM (
                SELECT num_buys, officeCode
                FROM classicmodels.employees as emp
                    INNER JOIN (
                        SELECT
                            salesRepEmployeeNumber, num_buys
                        FROM classicmodels.customers as cust
                            INNER JOIN (
                                SELECT COUNT(*) as num_buys, customerNumber
                                FROM classicmodels.orders
                                GROUP BY
                                    customerNumber
                            ) as cust_numb_buys ON cust_numb_buys.customerNumber = cust.customerNumber
                    ) as custs ON custs.salesRepEmployeeNumber = emp.employeeNumber
            ) as emps_sales
        GROUP BY
            officeCode
    )
    -- La oficina que mas productos vendio
SELECT offi.*, office_sales
FROM
    classicmodels.offices as offi
    INNER JOIN (
        (
            SELECT SUM(num_buys) as office_sales, officeCode
            FROM (
                    SELECT num_buys, officeCode
                    FROM classicmodels.employees as emp
                        INNER JOIN (
                            SELECT
                                salesRepEmployeeNumber, num_buys
                            FROM classicmodels.customers as cust
                                INNER JOIN (
                                    SELECT COUNT(*) as num_buys, customerNumber
                                    FROM classicmodels.orders
                                    GROUP BY
                                        customerNumber
                                ) as cust_numb_buys ON cust_numb_buys.customerNumber = cust.customerNumber
                        ) as custs ON custs.salesRepEmployeeNumber = emp.employeeNumber
                ) as emps_sales
            GROUP BY
                officeCode
        )
    ) as num_sales_by_off_code ON num_sales_by_off_code.officeCode = offi.officeCode
ORDER BY office_sales DESC
LIMIT 1

-- 5.
-- Obtener el precio completo de una orden
SELECT (
        SUM(
            ordsDet.quantityOrdered * ordsDet.priceEach
        )
    ) as order_total, orderNumber
FROM classicmodels.orderdetails as ordsDet
GROUP BY
    orderNumber

-- Agregamos el numero de cliente joineando, con la tabla orders

SELECT (
        SUM(
            ordsDet.quantityOrdered * ordsDet.priceEach
        )
    ) as order_total
    ,ords.customerNumber
FROM classicmodels.orderdetails as ordsDet
JOIN classicmodels.orders as ords
ON ords.orderNumber = ordsDet.orderNumber
GROUP BY
    ordsDet.orderNumber

-- Ahora sumamos todas las ordenes de cada cliente
WITH ordertotals_w_clients
AS
(SELECT (
        SUM(
            ordsDet.quantityOrdered * ordsDet.priceEach
        )
    ) as order_total
    ,ords.customerNumber
FROM classicmodels.orderdetails as ordsDet
JOIN classicmodels.orders as ords
ON ords.orderNumber = ordsDet.orderNumber
GROUP BY
    ordsDet.orderNumber)
SELECT SUM(order_total) as total_spent
,customerNumber
FROM ordertotals_w_clients
GROUP BY customerNumber
ORDER BY total_spent DESC
LIMIT 10

-- Ahora creamos una tabla con esas entradas de cliente


(WITH ordertotals_w_clients
AS
(SELECT (
        SUM(
            ordsDet.quantityOrdered * ordsDet.priceEach
        )
    ) as order_total
    ,ords.customerNumber
    ,customerName
    ,city
FROM classicmodels.orderdetails as ordsDet
JOIN classicmodels.orders as ords
JOIN classicmodels.customers as cust
ON ords.orderNumber = ordsDet.orderNumber
    AND cust.customerNumber = ords.customerNumber
GROUP BY
    ordsDet.orderNumber)
SELECT SUM(order_total) as total_spent
,customerNumber
,customerName
,city
FROM ordertotals_w_clients
GROUP BY customerNumber
ORDER BY total_spent DESC
LIMIT 10)


CREATE VIEW `Premium Customer`
AS
SELECT customerName, city, total_spent
FROM 
(WITH ordertotals_w_clients
AS
(SELECT (
        SUM(
            ordsDet.quantityOrdered * ordsDet.priceEach
        )
    ) as order_total
    ,ords.customerNumber
    ,customerName
    ,city
FROM classicmodels.orderdetails as ordsDet
JOIN classicmodels.orders as ords
JOIN classicmodels.customers as cust
ON ords.orderNumber = ordsDet.orderNumber
    AND cust.customerNumber = ords.customerNumber
GROUP BY
    ordsDet.orderNumber)
SELECT SUM(order_total) as total_spent
,customerNumber
,customerName
,city
FROM ordertotals_w_clients
GROUP BY customerNumber
ORDER BY total_spent DESC
LIMIT 10) as premiums

SELECT * FROM `Premium Customer`


-- Otra forma
-- Obtener el costo total de cada orden, con numeros de cliente
SELECT SUM(quantityOrdered*priceEach),
        ords.orderNumber,
        customerNumber
 FROM
orders as ords
JOIN orderdetails as ordDet
ON ordDet.orderNumber = ords.orderNumber
GROUP BY ords.orderNumber

--

SELECT customerName,
    city,
    (SELECT SUM(spent) FROM
        (SELECT SUM(quantityOrdered*priceEach) as spent,
                ords.orderNumber,
                customerNumber
        FROM
        orders as ords
        JOIN orderdetails as ordDet
        ON ordDet.orderNumber = ords.orderNumber
        GROUP BY ords.orderNumber) as order_costs
    WHERE customerNumber = cus1.customerNumber) as total_spent
FROM classicmodels.customers cus1
ORDER BY total_spent DESC
LIMIT 10

-- 6. EMPLOYEE OF THE MONT
DELIMITER //
 
DROP FUNCTION IF EXISTS employee_of_the_month
 
CREATE FUNCTION employee_of_the_month (mes INT, anio INT)
RETURNS VARCHAR(10000) DETERMINISTIC
BEGIN
    DECLARE emp_of_the_month_ID INT;
 
    SELECT `salesRepEmployeeNumber`
    INTO emp_of_the_month_ID
    FROM (SELECT COUNT(*) as num_sales, custs.`salesRepEmployeeNumber`
    FROM
        orders as ords
        INNER JOIN customers as custs ON custs.`customerNumber` = ords.`customerNumber`
    WHERE
        MONTH(`orderDate`) = mes
        AND YEAR(`orderDate`) = anio
    GROUP BY
        custs.`salesRepEmployeeNumber`
    ORDER BY num_sales DESC
    LIMIT 1) as query_emp_of_the_mont
    ;
 
    RETURN (SELECT CONCAT(employees.`firstName`,employees.`lastName`) FROM employees WHERE `employeeNumber` = emp_of_the_month_ID);
END;
 
//
 
 
set @a = employee_of_the_month(2,2004)
 
SELECT @a
 
DELIMITER ;
 
 
-- 7. 
--Crear una nueva tabla "Product Refillment". Deberá tener una relación varios a uno con "products" y los campos: `refillmentID`, `productCode`, `orderDate`, `quantity`.
 
CREATE TABLE product_refillment(
    refillementID INT NOT NULL,
    productCode VARCHAR(15),
    orderDate DATE,
    quantity INT,
    PRIMARY KEY (refillementID),
    FOREIGN KEY (productCode) REFERENCES products(productCode)
)
 
-- 8. Definir un trigger "Restock Product" que esté pendiente de los cambios efectuados en `orderdetails` 
-- y cada vez que se agregue una nueva orden revise la cantidad de productos pedidos (`quantityOrdered`) 
-- y compare con la cantidad en stock (`quantityInStock`) y si es menor a 10 genere un pedido en la tabla "Product Refillment" por 10 nuevos productos.
DELIMITER |
 
CREATE TRIGGER restock_prod AFTER INSERT ON orderdetails
FOR EACH ROW
BEGIN
    DECLARE ord_date DATE;
    DECLARE q_in_stock DATE;
    SELECT orderDate INTO ord_date FROM orders WHERE `orderNumber` = new.orderNumber;
 
    SELECT quantityInStock INTO q_in_stock FROM products WHERE `productCode` = new.`productCode`;
 
    IF (new.quantityOrdered > q_in_stock -- Si se ordeno mas productos de los que se tiene
            OR q_in_stock < 10) 
    THEN
        INSERT INTO product_refillment(productCode) VALUES (NEW.productCode);
    END IF;
 
END;|
 
DELIMITER ;
 
-- 9.
CREATE ROLE Empleado 
 
GRANT SELECT ON * TO Empleado
 
GRANT CREATE VIEW ON * TO Empleado
 
USE ROLE Empleado
 
-- add1
-- Encontrar, para cada cliente de aquellas ciudades que comienzan por 'N', la menor y la mayor diferencia 
-- en días entre las fechas de sus pagos. No mostrar el id del cliente, sino su nombre y el de su contacto.
 
WITH mindiff_pay_dates
AS
(
    SELECT MIN(DATEDIFF(p2.paymentDate,p1.paymentDate)) as date_diff ,p1.`customerNumber` FROM payments p1, payments p2
    WHERE p1.paymentDate < p2.paymentDate
    AND p1.`customerNumber` = p2.`customerNumber`
    GROUP BY p1.`customerNumber`
),
max_date_diff
AS
(
    SELECT MAX(DATEDIFF(p2.paymentDate,p1.paymentDate)) as date_diff ,p1.`customerNumber` FROM payments p1, payments p2
    WHERE p1.paymentDate < p2.paymentDate
    AND p1.`customerNumber` = p2.`customerNumber`
    GROUP BY p1.`customerNumber`
)
SELECT cust.`customerName`, cust.`contactFirstName`, mindiff_pay_dates.date_diff, max_date_diff.date_diff FROM customers as cust
JOIN mindiff_pay_dates ON cust.`customerNumber` = mindiff_pay_dates.`customerNumber`
JOIN max_date_diff ON cust.`customerNumber` = max_date_diff.`customerNumber`
WHERE cust.city LIKE 'N%'