------------------------------------------------------------------------------------------
-- Some queries to try
------------------------------------------------------------------------------------------
-- 1. What are the names of employees in the Marketing Department?
SELECT EmployeeName 
FROM Employee
WHERE DepartmentName = 'Marketing'
ORDER BY EmployeeName;

-- 2. Find the items sold by the departments on the second floor.
SELECT ItemName, SaleQuantity, DepartmentName
FROM Sale
WHERE DepartmentName IN (
    SELECT DISTINCT DepartmentName 
    FROM Department
    WHERE DepartmentFloor = 2
)
ORDER BY DepartmentName, SaleQuantity DESC, ItemName;

-- Avoid the nested subquery
SELECT DISTINCT S.ItemName
FROM Sale AS S
LEFT JOIN Department AS D
    ON S.DepartmentName = D.DepartmentName
WHERE D.DepartmentFloor = 2
ORDER BY S.ItemName;

-- Use natural join 
SELECT DISTINCT ItemName
FROM (Sale NATURAL JOIN Department)
WHERE Department.DepartmentFloor = 2
ORDER BY ItemName;

-- User join - Notice different results
SELECT DISTINCT ItemName
FROM (Sale JOIN Department)
WHERE Department.DepartmentFloor = 2
ORDER BY ItemName;

-- 3. Identify by floor the items available on floors other than the second floor
SELECT S.*, D.DepartmentFloor
FROM Sale AS S
LEFT JOIN Department AS D
    ON S.DepartmentName = D.DepartmentName
WHERE D.DepartmentFloor != 2
ORDER BY D.DepartmentFloor, S.DepartmentName, S.SaleQuantity DESC;

-- 4. Find the average salary of the employees in the Clothes department
SELECT AVG(EmployeeSalary) AS avg_salary
FROM Employee
WHERE DepartmentName = 'Clothes';

-- 5. Find, for each department, the average salary of the employees in that department and report
-- by descending salary.
SELECT DepartmentName, ROUND(AVG(EmployeeSalary), 2) AS avg_salary 
FROM Employee
GROUP BY DepartmentName
ORDER BY avg_salary DESC;

-- 6. List the items delivered by exactly one supplier (i.e. the items always delivered by the same
-- supplier).
SELECT ItemName, COUNT(DISTINCT SupplierNumber) AS n_distinct_suppliers
FROM Delivery
GROUP BY ItemName
HAVING n_distinct_suppliers = 1
ORDER BY ItemName;

-- 7. List the suppliers that deliver at least 10 items
SELECT D.SupplierNumber, S.SupplierName,SUM(D.DeliveryQuantity) AS total_n_items_delivered
FROM Delivery AS D
LEFT JOIN Supplier AS S
    ON D.SupplierNumber = S.SupplierNumber
GROUP BY D.SupplierNumber, S.SupplierName
HAVING total_n_items_delivered >= 10
ORDER BY total_n_items_delivered DESC, S.SupplierName;

-- 8. Count the number of direct employees of each manager
SELECT * FROM Employee;

SELECT E1.BossNumber, E2.EmployeeName AS BossName, COUNT(E1.EmployeeName) as n_direct_employees
FROM Employee AS E1
LEFT JOIN Employee AS E2
    ON E1.BossNumber = E2.EmployeeNumber
WHERE E1.BossNumber != 0
GROUP BY E1.BossNumber, E2.EmployeeName
ORDER BY n_direct_employees DESC;

-- 9. Find, for each department that sells items of type 'E' the average salary of the employees.
SELECT DepartmentName, ROUND(AVG(EmployeeSalary), 2) AS avg_salary
FROM Employee
WHERE DepartmentName IN (
    -- Department names that sell items of type 'E'
    SELECT DISTINCT DepartmentName
    FROM Sale
    WHERE ItemName IN (
        SELECT DISTINCT ItemName FROM Item
        WHERE ItemType = 'E'
    )
)
GROUP BY DepartmentName
ORDER BY avg_salary DESC;

-- 10. Find the total number of items of type 'E' sold by departments on the second floor
SELECT SUM(S.SaleQuantity) AS total_n_items_sold -- S.*, I.ItemType, D.DepartmentFloor
FROM Sale AS S
LEFT JOIN Item AS I
    ON S.ItemName = I.ItemName
LEFT JOIN Department AS D
    ON S.DepartmentName = D.DepartmentName
WHERE I.ItemType = 'E' 
    AND D.DepartmentFloor = 2;

-- 11. What is the average delivery quantity of items of type 'N' delivered by each company?
SELECT S.SupplierName, AVG(D.DeliveryQuantity) AS avg_delivery_quantity 
FROM Delivery AS D
LEFT JOIN Item AS I
    ON D.ItemName = I.ItemName
LEFT JOIN Supplier AS S
    ON D.SupplierNumber = S.SupplierNumber
WHERE I.ItemType = 'N'
GROUP BY S.SupplierName
ORDER BY avg_delivery_quantity DESC;

------------------------------------------------------------------------------------------
-- Nested Queries
------------------------------------------------------------------------------------------
-- 1. What are the names of items sold by departments on the second floor? This was previously
-- solved in the preceding section by the use of a join. However, it could be more efficiently
-- solved by using an inner query

SELECT DISTINCT ItemName
FROM Sale
WHERE DepartmentName IN (
    SELECT DISTINCT DepartmentName
    FROM Department
    WHERE DepartmentFloor = 2
)
ORDER BY 1;

-- 2. Find the salary of Clare's manager.
SELECT * FROM Employee LIMIT 5;

SELECT EmployeeSalary, EmployeeName
FROM Employee
WHERE EmployeeNumber = (
    SELECT BossNumber
    FROM Employee
    WHERE EmployeeName = 'Clare'
);

-- 4. List the names of the employees who earn more than any employee in the Marketing
-- department
SELECT EmployeeSalary, EmployeeName
FROM Employee
WHERE EmployeeSalary > (
    SELECT MAX(EmployeeSalary)
    FROM Employee
    WHERE DepartmentName = 'Marketing'
)
ORDER BY EmployeeSalary DESC, EmployeeName;

-- 5. Among all the departments with a total salary greater than £25000, 
-- find the departments that sell Sextant
SELECT DISTINCT DepartmentName
FROM Sale
WHERE ItemName = 'Sextant'
AND DepartmentName IN (
    SELECT DepartmentName
    FROM Employee
    GROUP BY DepartmentName
    HAVING SUM(EmployeeSalary) > 25000
)
ORDER BY 1;

-- 6. Find the suppliers that deliver compasses and at least one other kind of item
SELECT DISTINCT DepartmentName
FROM Sale
WHERE DepartmentName IN (
    SELECT DepartmentName
    FROM Sale
    GROUP BY DepartmentName
    HAVING COUNT(DISTINCT ItemName) >= 3
) AND DepartmentName IN ( 
    SELECT DISTINCT DepartmentName
    FROM Sale
    WHERE ItemName = 'Compass'
)
ORDER BY DepartmentName
;

-- 7. Find the suppliers that deliver compasses and at least three other kinds of item
SELECT DISTINCT D.SupplierNumber, S.SupplierName
FROM Delivery AS D
LEFT JOIN Supplier AS S
    ON D.SupplierNumber = S.SupplierNumber
WHERE D.SupplierNumber IN (
    SELECT DISTINCT SupplierNumber
    FROM Delivery
    WHERE ItemName = 'Compass'
) 
AND D.SupplierNumber IN (
    SELECT SupplierNumber
    FROM Delivery
    GROUP BY SupplierNumber
    HAVING COUNT(DISTINCT ItemName) >= 4
)
ORDER BY S.SupplierName;

-- 8. List the departments for which each item delivered to the department is delivered to some
-- other department as well
SELECT DISTINCT DepartmentName
FROM Delivery
WHERE ItemName IN (
    SELECT ItemName
    FROM Delivery
    GROUP BY ItemName
    HAVING COUNT(DISTINCT DepartmentName) >= 2
)
ORDER BY DepartmentName;
