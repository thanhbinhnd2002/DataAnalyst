-- 1.OverView 
-- Tổng doanh thu và lợi nhuận của từng năm theo từng hình thức bán hàng
WITH CTE AS(
Select 'Internet' AS PhanLoai,
YEAR(ShipDate) AS Nam,
COUNT(Distinct SalesOrderNumber) as TongSoDonHang,
SUM(SalesAmount) as TongDoanhSo,
COUNT(Distinct CustomerKey) as SoLuongKH,
SUM(SalesAmount)- SUM(TotalProductCost) as LoiNhuan
From FactInternetSales
JOIN DimSalesTerritory ON FactInternetSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY YEAR(ShipDate)

UNION

Select 'Reseller' AS PhanLoai,
YEAR(ShipDate) AS Nam ,
COUNT(Distinct SalesOrderNumber) as TongSoDonHang,
SUM(SalesAmount) as TongDoanhSo,
COUNT(Distinct ResellerKey) as SoLuongKH,SUM(SalesAmount)- SUM(TotalProductCost) as LoiNhuan
From FactResellerSales
JOIN DimSalesTerritory ON FactResellerSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY YEAR(ShipDate)
)
SELECT *
FROM CTE
ORDER BY Nam, PhanLoai;

----------------------------------------------------------------------------------------------------------------------
--total revenue và total profit

WITH CTE AS(
Select 'Internet' AS PhanLoai,
YEAR(ShipDate) AS Nam,
COUNT(Distinct SalesOrderNumber) as TongSoDonHang, 
SUM(SalesAmount) as TongDoanhSo, 
COUNT(Distinct CustomerKey) as SoLuongKH,
SUM(SalesAmount)- SUM(TotalProductCost) as LoiNhuan
From FactInternetSales
JOIN DimSalesTerritory ON FactInternetSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY YEAR(ShipDate)

UNION

Select 'Reseller' AS PhanLoai,
YEAR(ShipDate) AS Nam ,
COUNT(Distinct SalesOrderNumber) as TongSoDonHang, 
SUM(SalesAmount) as TongDoanhSo, 
COUNT(Distinct ResellerKey) as SoLuongKH,SUM(SalesAmount)- SUM(TotalProductCost) as LoiNhuan
From FactResellerSales
JOIN DimSalesTerritory ON FactResellerSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY YEAR(ShipDate)
)
,CTE2 AS(
SELECT Nam,
SUM(LoiNhuan) as TongLoiNhuan, 
SUM(TongDoanhSo) as TongDoanhSo, 
SUM(SoLuongKH) as TongSoLuongKH, 
SUM(TongSoDonHang) as TongSoDonHang
FROM CTE
GROUP BY  Nam
)
SELECT SUM(TongSoDonHang) as TongSoDonHang,
SUM(TongDoanhSo) as TongDoanhSo, 
SUM(TongSoLuongKH) as TongSoLuongKH,
SUM(TongLoiNhuan) as TongLoiNhuan
FROM CTE2;

----------------------------------------------------------------------------------------------------------------------

--Total profit và total revenue của từng năm

WITH CTE AS(
Select 'Internet' AS PhanLoai,
YEAR(ShipDate) AS Nam,
COUNT(Distinct SalesOrderNumber) as TongSoDonHang, 
SUM(SalesAmount) as TongDoanhSo, 
COUNT(Distinct CustomerKey) as SoLuongKH,
SUM(SalesAmount)- SUM(TotalProductCost) as LoiNhuan
From FactInternetSales
JOIN DimSalesTerritory ON FactInternetSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY YEAR(ShipDate)

UNION

Select 'Reseller' AS PhanLoai,
YEAR(ShipDate) AS Nam ,
COUNT(Distinct SalesOrderNumber) as TongSoDonHang, 
SUM(SalesAmount) as TongDoanhSo, 
COUNT(Distinct ResellerKey) as SoLuongKH,SUM(SalesAmount)- SUM(TotalProductCost) as LoiNhuan
From FactResellerSales
JOIN DimSalesTerritory ON FactResellerSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY YEAR(ShipDate)
)
SELECT Nam,
SUM(LoiNhuan) as TongLoiNhuan, 
SUM(TongDoanhSo) as TongDoanhSo, 
SUM(SoLuongKH) as TongSoLuongKH, 
SUM(TongSoDonHang) as TongSoDonHang
FROM CTE
GROUP BY  Nam;

--------------------------------------------------------------------------------------------------------------------
--Top 3 country có lơi nhuận cao nhất
With CTE AS(
Select 'Internet' AS PhanLoai,SalesTerritoryCountry, COUNT(Distinct SalesOrderNumber) as TongSoDonHang, SUM(SalesAmount) as TongDoanhSo, COUNT(Distinct CustomerKey) as SoLuongKH,SUM(SalesAmount)- SUM(TotalProductCost) as LoiNhuan
From FactInternetSales
JOIN DimSalesTerritory ON FactInternetSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY SalesTerritoryCountry

UNION

Select 'Reseller' AS PhanLoai ,SalesTerritoryCountry, COUNT(Distinct SalesOrderNumber) as TongSoDonHang, SUM(SalesAmount) as TongDoanhSo, COUNT(Distinct ResellerKey) as SoLuongKH,SUM(SalesAmount)- SUM(TotalProductCost) as LoiNhuan
From FactResellerSales
JOIN DimSalesTerritory ON FactResellerSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY SalesTerritoryCountry
)
,CTE2 AS(
SELECT 
SalesTerritoryCountry,
SUM(LoiNhuan) as TongLoiNhuan, 
SUM(TongDoanhSo) as TongDoanhSo, 
SUM(SoLuongKH) as TongSoLuongKH, 
SUM(TongSoDonHang) as TongSoDonHang
--DENSE_RANK() 
--OVER (PARTITION BY SalesTerritoryCountry ORDER BY SUM(LoiNhuan) DESC) as XepHang
FROM CTE
GROUP BY  SalesTerritoryCountry
)
Select Top 3 *
From CTE2
Order By TongLoiNhuan DESC

----------------------------------------------------------------------------------------------------------------------
-- Tỉ suất lợi nhuận
With CTE AS(
Select 'Internet' AS PhanLoai, 
SUM(SalesAmount) as DoanhSo,
SUM(SalesAmount)- SUM(TotalProductCost) as LoiNhuan
From FactInternetSales
Where Year(ShipDate) IN (2011,2012,2013)


UNION

Select 'Reseller' AS PhanLoai , 
SUM(SalesAmount) as DoanhSo, 
SUM(SalesAmount)- SUM(TotalProductCost) as LoiNhuan
From FactResellerSales
Where Year(ShipDate) IN (2011,2012,2013)
)
SELECT PhanLoai,(LoiNhuan/DoanhSo)*100 as TiSuatLoiNhuan
FROM CTE;


----------------------------------------------------------------------------------------------------------------------
--2. Channel Sales Analysis

--Internet/Reseller Number of Orders


Select 'Internet' AS PhanLoai,
COUNT(Distinct SalesOrderNumber) as SoDonHang,
COUNT(Distinct CustomerKey) as SoLuongKH
From FactInternetSales
Where Year(ShipDate) IN (2011,2012,2013)

UNION

Select 'Reseller' AS PhanLoai,
COUNT(Distinct SalesOrderNumber) as SoDonHang,
COUNT(Distinct ResellerKey) as SoLuongKH
From FactResellerSales
Where Year(ShipDate) IN (2011,2012,2013);

----------------------------------------------------------------------------------------------------------------------

--Revenue by Category/Color/Country
--Revenue by Color
WITH CTE AS(
SELECT 'Internet' AS PhanLoai,
Color,
SUM(SalesAmount) - SUM(TotalProductCost) as LoiNhuan
FROM FactInternetSales
JOIN DimProduct ON FactInternetSales.ProductKey = DimProduct.ProductKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY Color

UNION

SELECT 'Reseller' AS PhanLoai,
Color,
SUM(SalesAmount) - SUM(TotalProductCost) as LoiNhuan
FROM FactResellerSales
JOIN DimProduct ON FactResellerSales.ProductKey = DimProduct.ProductKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY Color
)
SELECT Color,
SUM(LoiNhuan) as TongLoiNhuan
FROM CTE
GROUP BY Color
ORDER BY TongLoiNhuan DESC;

--Revenue by Category
WITH CTE AS(
SELECT 'Internet' AS PhanLoai,
EnglishProductName as Category,
SUM(SalesAmount) - SUM(TotalProductCost) as LoiNhuan
FROM FactInternetSales
JOIN DimProduct ON FactInternetSales.ProductKey = DimProduct.ProductKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY EnglishProductName

UNION

SELECT 'Reseller' AS PhanLoai,
EnglishProductName as Category,
SUM(SalesAmount) - SUM(TotalProductCost) as LoiNhuan
FROM FactResellerSales
JOIN DimProduct ON FactResellerSales.ProductKey = DimProduct.ProductKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY EnglishProductName
)
SELECT Category,
SUM(LoiNhuan) as TongLoiNhuan
FROM CTE
GROUP BY Category
ORDER BY TongLoiNhuan DESC;

--Revenue by Country
With CTE AS(
SELECT 'Internet' AS PhanLoai,
SalesTerritoryCountry as Country,
SUM(SalesAmount) - SUM(TotalProductCost) as LoiNhuan
FROM FactInternetSales
JOIN DimSalesTerritory ON FactInternetSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY SalesTerritoryCountry

UNION

SELECT 'Reseller' AS PhanLoai,
SalesTerritoryCountry as Country,
SUM(SalesAmount) - SUM(TotalProductCost) as LoiNhuan
FROM FactResellerSales
JOIN DimSalesTerritory ON FactResellerSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY SalesTerritoryCountry
)
SELECT Country,
SUM(LoiNhuan) as TongLoiNhuan
FROM CTE
GROUP BY Country
ORDER BY TongLoiNhuan DESC;

----------------------------------------------------------------------------------------------------------------------
--3.Sellers Analysis - Reseller Sales

--Reseller Revenue by Business Type/Group management /ProductLine
--Reseller Revenue by Business Type
WITH CTE AS(
SELECT
BusinessType,
SUM(SalesAmount) - SUM(TotalProductCost) as LoiNhuan
FROM FactResellerSales
JOIN DimReseller ON FactResellerSales.ResellerKey = DimReseller.ResellerKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY BusinessType
)
SELECT *
FROM CTE;

--Reseller Revenue by Group management
WITH CTE AS(
GroupManagement,
SUM(SalesAmount) - SUM(TotalProductCost) as LoiNhuan
FROM FactResellerSales
JOIN DimReseller ON FactResellerSales.ResellerKey = DimReseller.ResellerKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY GroupManagement
)
SELECT *
FROM CTE;

--Reseller Revenue by ProductLine
WITH CTE AS(
SELECT ProductLine,
SUM(SalesAmount) - SUM(TotalProductCost) as LoiNhuan
FROM FactResellerSales
JOIN DimReseller ON FactResellerSales.ResellerKey = DimReseller.ResellerKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY ProductLine
)
SELECT *
FROM CTE;

--TOp 5 Reseller có doanh thu cao nhất
With CTE AS(
SELECT ResellerName,
SUM(SalesAmount) as TongDoanhSo
FROM FactResellerSales
JOIN DimReseller ON FactResellerSales.ResellerKey = DimReseller.ResellerKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY ResellerName
)
SELECT Top 5 *
FROM CTE
Order By TongDoanhSo DESC;


----------------------------------------------------------------------------------------------------------------------
--4. Product Analysis
--Internet Sales - Customer Analysis
--InternetTotal revenue by Income range/ Age group/ Country

--InternetTotal revenue by Income range
WITH CTE AS(
SELECT 
YearlyIncome as IncomeRange,
SUM(SalesAmount) - SUM(TotalProductCost) as LoiNhuan
FROM FactInternetSales
JOIN DimCustomer ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY YearlyIncome


)
SELECT *
FROM CTE
Order By IncomeRange DESC;


--InternetTotal revenue by Age group
WITH CTE AS(
SELECT
CASE 
    WHEN 2014 - YEAR(BirthDate) BETWEEN 18 AND 30 THEN '18-30'
    WHEN 2014 - YEAR(BirthDate) BETWEEN 31 AND 40 THEN '31-40'
    WHEN 2014 - YEAR(BirthDate) BETWEEN 41 AND 50 THEN '41-50'
    WHEN 2014 - YEAR(BirthDate) BETWEEN 51 AND 60 THEN '51-60'
    ELSE '60+' 
    END AgeGroup,
SUM(SalesAmount) - SUM(TotalProductCost) as LoiNhuan
FROM FactInternetSales
JOIN DimCustomer ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY 2014 - YEAR(BirthDate)
)
SELECT AgeGroup,SUM(LoiNhuan) as TongLoiNhuan
FROM CTE
GROUP BY AgeGroup
Order By AgeGroup DESC;



SELECT 2014 - YEAR(BirthDate)
FROM FactInternetSales
JOIN DimCustomer ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
Where Year(ShipDate) IN (2011,2012,2013)

--InternetTotal revenue by Country
WITH CTE AS(
SELECT
SalesTerritoryCountry as Country,
SUM(SalesAmount) - SUM(TotalProductCost) as LoiNhuan
FROM FactInternetSales
JOIN DimSalesTerritory ON FactInternetSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY SalesTerritoryCountry
)
SELECT *
FROM CTE
Order By LoiNhuan DESC;
