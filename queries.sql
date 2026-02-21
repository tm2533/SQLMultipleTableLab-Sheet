-- Some queries to try
-- 1. What are the names of employees in the Marketing Department?
SELECT DISTINCT DepartmentName FROM Employee;

SELECT EmployeeName FROM Employee
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
SELECT *
FROM Employee;

-- 9. Find, for each department that sells items of type 'E' the average salary of the employees.

-- 10. Find the total number of items of type 'E' sold by departments on the second floor

-- 11. What is the average delivery quantity of items of type 'N' delivered by each company?
