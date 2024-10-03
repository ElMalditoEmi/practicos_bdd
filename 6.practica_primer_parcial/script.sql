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

