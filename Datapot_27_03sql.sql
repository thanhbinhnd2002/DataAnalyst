--Cau 1: 
SELECT 
OrderDate,
SalesOrderNumber,
SalesOrderLineNumber,
ResellerName,
BusinessType,
SalesAmount
FROM FactResellerSales
JOIN DimReseller ON FactResellerSales.ResellerKey = DimReseller.ResellerKey
WHERE YEAR(OrderDate) = 2013
AND CarrierTrackingNumber LIKE '[A-Z][A-Z]____[CT]%[0-9][0-9]';

--Cau 2: 
SELECT
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    dr.BusinessType,
    COALESCE(SUM(SalesAmount), 0) AS ResellerSalesAmount,
    COUNT(DISTINCT SalesOrderNumber) AS NumberOfOrders
FROM FactResellerSales frs
INNER JOIN DimReseller dr ON frs.ResellerKey = dr.ResellerKey
INNER JOIN DimGeography dg ON dr.GeographyKey = dg.GeographyKey
WHERE dg.City = 'London'
GROUP BY YEAR(OrderDate), MONTH(OrderDate), dr.BusinessType
ORDER BY YEAR(OrderDate), MONTH(OrderDate), dr.BusinessType;

--Cau 3:
--a)
--Hãy truy vấn ra danh sách top 5 nhân viên có tổng doanh thu tháng (đặt tên là EmployeeMonthAmount) cao nhất trong hệ thống theo mỗi tháng. Kết quả trả về gồm các thông tin sau:
--Order Year
--OrderMonth
--EmployeeKey
--EmployeeFullName (kết hợp từ FirstName, MiddleName và LastName)
--EmployeeMonthAmount
With CTE AS(
Select 
Year(frs.OrderDate) AS OrderYear,
MONTH(frs.OrderDate) AS OrderMonth,
e.EmployeeKey, 
CONCAT_WS(' ',FirstName, e.MiddleName, e.LastName) as EmployeeFullName, 
SUM(frs.SalesAmount) as EmployeeMonthAmount,
ROW_NUMBER() OVER(PARTITION BY Year(frs.OrderDate), MONTH(frs.OrderDate) ORDER BY SUM(frs.SalesAmount) DESC) as Rank
FROM DimEmployee e
JOIN FactResellerSales frs ON e.EmployeeKey = frs.EmployeeKey
GROUP BY Year(frs.OrderDate), MONTH(frs.OrderDate), e.EmployeeKey, CONCAT_WS(' ',FirstName, e.MiddleName, e.LastName)
)
SELECT 
OrderYear, 
OrderMonth, 
EmployeeKey, 
EmployeeFullName, 
EmployeeMonthAmount
FROM CTE
WHERE Rank <= 5

--b)Mở rộng kết quả câu a, tính toán thêm thông tin về doanh thu cùng kỳ năm ngoái của các nhân viên này

With CTE AS(
Select
Year(frs.OrderDate) AS OrderYear,
MONTH(frs.OrderDate) AS OrderMonth,
e.EmployeeKey,
CONCAT_WS(' ',FirstName, e.MiddleName, e.LastName) as EmployeeFullName,
SUM(frs.SalesAmount) as EmployeeMonthAmount,
ROW_NUMBER() OVER(PARTITION BY Year(frs.OrderDate), MONTH(frs.OrderDate) ORDER BY SUM(frs.SalesAmount) DESC) as Rank
FROM DimEmployee e
JOIN FactResellerSales frs ON e.EmployeeKey = frs.EmployeeKey
GROUP BY Year(frs.OrderDate), MONTH(frs.OrderDate), e.EmployeeKey, CONCAT_WS(' ',FirstName, e.MiddleName, e.LastName)
),
CTE2 AS(
    SELECT YEAR(OrderDate)-1 AS OrderYear, 
    MONTH(OrderDate) AS OrderMonth, 
    e.EmployeeKey, 
    CONCAT_WS(' ',FirstName, MiddleName, LastName) as EmployeeFullName,
    SUM(SalesAmount) AS LastYearAmount
    FROM FactResellerSales
    JOIN DimEmployee e ON FactResellerSales.EmployeeKey = e.EmployeeKey
    GROUP BY YEAR(OrderDate)-1, MONTH(OrderDate), e.EmployeeKey, CONCAT_WS(' ',FirstName, MiddleName, LastName)
)
SELECT
CTE.OrderYear,
CTE.OrderMonth,
CTE.EmployeeKey,
CTE.EmployeeFullName,
EmployeeMonthAmount,
LastYearAmount
FROM CTE
Left JOIN CTE2 
ON CTE.OrderYear = CTE2.OrderYear 
AND CTE.OrderMonth = CTE2.OrderMonth
AND CTE.EmployeeKey = CTE2.EmployeeKey
AND CTE.EmployeeFullName = CTE2.EmployeeFullName
WHERE Rank <= 5;


--Cau 4 : 
Select 
p.ProductKey,
p.EnglishProductName,
CASE
    When SUM(fi.SalesAmount) IS NULL THEN 0
    ELSE SUM(fi.SalesAmount)
END as 'InternetTotalSalesAmount',
Case 
    When SUM(fr.SalesAmount) IS NULL THEN 0
    ELSE SUM(fr.SalesAmount)
END as 'ResellerTotalSalesAmount'

From DimProduct p
Left JOIN FactInternetSales fi ON p.ProductKey = fi.ProductKey
Left JOIN FactResellerSales fr ON p.ProductKey = fr.ProductKey
GROUP BY p.ProductKey, p.EnglishProductName;



