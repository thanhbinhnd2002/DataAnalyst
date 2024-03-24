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
SUM(SalesAmount) as DoanhThu
FROM FactInternetSales
JOIN DimProduct ON FactInternetSales.ProductKey = DimProduct.ProductKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY Color

UNION

SELECT 'Reseller' AS PhanLoai,
Color,
SUM(SalesAmount) as DoanhThu
FROM FactResellerSales
JOIN DimProduct ON FactResellerSales.ProductKey = DimProduct.ProductKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY Color
)
SELECT Color,
SUM(DoanhThu) as TongDoanhThu
FROM CTE
GROUP BY Color
ORDER BY TongDoanhThu DESC;

--Revenue by Category
WITH CTE AS(
SELECT 'Internet' AS PhanLoai,
EnglishProductName as Category,
SUM(SalesAmount) as DoanhThu
FROM FactInternetSales
JOIN DimProduct ON FactInternetSales.ProductKey = DimProduct.ProductKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY EnglishProductName

UNION

SELECT 'Reseller' AS PhanLoai,
EnglishProductName as Category,
SUM(SalesAmount) as DoanhThu
FROM FactResellerSales
JOIN DimProduct ON FactResellerSales.ProductKey = DimProduct.ProductKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY EnglishProductName
)
SELECT Category,
SUM(DoanhThu) as TongDoanhThu
FROM CTE
GROUP BY Category
ORDER BY TongDoanhThu DESC;

--Revenue by Country
With CTE AS(
SELECT 'Internet' AS PhanLoai,
SalesTerritoryCountry as Country,
SUM(SalesAmount)  as DoanhThu
FROM FactInternetSales
JOIN DimSalesTerritory ON FactInternetSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY SalesTerritoryCountry

UNION

SELECT 'Reseller' AS PhanLoai,
SalesTerritoryCountry as Country,
SUM(SalesAmount) as DoanhThu
FROM FactResellerSales
JOIN DimSalesTerritory ON FactResellerSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY SalesTerritoryCountry
)
SELECT Country,
SUM(DoanhThu) as TongDoanhThu
FROM CTE
GROUP BY Country
ORDER BY TongDoanhThu DESC;

----------------------------------------------------------------------------------------------------------------------
--3.Sellers Analysis - Reseller Sales

--Reseller Revenue by Business Type/Group management /ProductLine
--Reseller Revenue by Business Type
WITH CTE AS(
SELECT
BusinessType,
SUM(SalesAmount) as DoanhThu
FROM FactResellerSales
JOIN DimReseller ON FactResellerSales.ResellerKey = DimReseller.ResellerKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY BusinessType
)
SELECT *
FROM CTE
ORDER BY DoanhThu DESC;

--Reseller Revenue by Group management
WITH CTE AS(
Select SalesTerritoryGroup,
SUM(SalesAmount) as DoanhThu
From DimSalesTerritory 
JOIN FactResellerSales ON DimSalesTerritory.SalesTerritoryKey = FactResellerSales.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY SalesTerritoryGroup
)
SELECT *
FROM CTE
Order By DoanhThu DESC;

--Reseller Revenue by ProductLine
WITH CTE AS(
SELECT ProductLine,
SUM(SalesAmount)as DoanhThu
FROM FactResellerSales
JOIN DimReseller ON FactResellerSales.ResellerKey = DimReseller.ResellerKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY ProductLine
)
SELECT *
FROM CTE
Order By DoanhThu DESC;

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
SUM(SalesAmount) as DoanhThu
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
SUM(SalesAmount) as DoanhThu
FROM FactInternetSales
JOIN DimCustomer ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY 2014 - YEAR(BirthDate)
)
SELECT AgeGroup,SUM(DoanhThu) as TongDoanhThu
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
SUM(SalesAmount) as DoanhThu
FROM FactInternetSales
JOIN DimSalesTerritory ON FactInternetSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
Where Year(ShipDate) IN (2011,2012,2013)
GROUP BY SalesTerritoryCountry
)
SELECT *
FROM CTE
Order By DoanhThu DESC;


----------------------------------------------------------------------------------------------------------------------
-- mo hinh RFM cho khach hang
-- moneytary
With CTE AS(
SELECT CustomerKey,
SUM(SalesAmount) as DoanhThu,
PERCENT_RANK() OVER (ORDER BY SUM(SalesAmount) ) as Rank
FROM FactInternetSales
Where Year(ShipDate) IN (2011,2012,2013)
group by CustomerKey
)
,CTE2 AS(
SELECT 
CustomerKey,
DoanhThu,
CASE 
    WHEN Rank <= 0.2 THEN '1'
    WHEN Rank <= 0.4 THEN '2'
    WHEN Rank <= 0.6 THEN '3'
    When Rank <= 0.8 THEN '4'
    ELSE '5'
    END as Moneytary
FROM CTE
)
-- frequency
,CTE3 AS(
SELECT CustomerKey,
COUNT(Distinct SalesOrderNumber) as SoDonHang,
PERCENT_RANK() OVER (ORDER BY COUNT(Distinct SalesOrderNumber) ) as Rank
FROM FactInternetSales
Where Year(ShipDate) IN (2011,2012,2013)
group by CustomerKey
)
,CTE4 AS(
SELECT 
CustomerKey,
SoDonHang,
CASE 
    WHEN Rank <= 0.2 THEN '1'
    WHEN Rank <= 0.4 THEN '2'
    WHEN Rank <= 0.6 THEN '3'
    When Rank <= 0.8 THEN '4'
    ELSE '5'
    END as Frequency
FROM CTE3
)
-- Recency
,CTE5 AS(
SELECT CustomerKey,
DATEDIFF(DAY,MAX(OrderDate),'2014-01-01') as SoNgay,
PERCENT_RANK() OVER (ORDER BY DATEDIFF(DAY,MAX(OrderDate),'2014-01-01')) as Rank
From FactInternetSales
Where Year(ShipDate) IN (2011,2012,2013)
group by CustomerKey
)
,CTE6 AS(
SELECT CustomerKey,
SoNgay,
CASE 
    WHEN Rank <= 0.2 THEN '1'
    WHEN Rank <= 0.4 THEN '2'
    WHEN Rank <= 0.6 THEN '3'
    When Rank <= 0.8 THEN '4'
    ELSE '5'
    END as Recency
FROM CTE5
)
,CTE7 AS(
SELECT CTE2.CustomerKey,
CTE2.DoanhThu as DoanhThu,
Moneytary,
CTE4.SoDonHang as SoDonHang,
Frequency,
CTE6.SoNgay as SoNgay,
Recency,
CONCAT( Recency,Frequency,Moneytary) as RFM
FROM CTE2 
JOIN CTE4 ON CTE2.CustomerKey = CTE4.CustomerKey
JOIN CTE6 ON CTE2.CustomerKey = CTE6.CustomerKey
)
SELECT
*,
CASE
	WHEN RFM IN ('555','554', '544', '545', '454', '455','445' ) THEN 'Champions'
    When RFM IN ('543', '444', '435', '355', '344', '335', '354', '345') Then 'Loyal Customers'
    When RFM IN ('553', '551', '552', '541', '542', '533', '532', '531', '452', '451', '442', '441', '431', '453', '433', '432', '423', '353', '352', '351', '342', '341','333','323') Then 'PotentialLoyalist'
    when RFM IN ('512', '511', '422', '421', '412', '411', '311') THEN 'RecentCustomers'
    WHen RFM IN ('525','524','523', '522', '521', '515','514','513','425','424','413','414','415','315','314','313') THEN 'Promising'
    WHEN RFM IN ('535', '534', '443', '434', '343', '334', '325', '324') THEN  'CustomersNeedingAttention'
    WHEN RFM IN ('331','321','312','221','213') THEN 'AboutToSleep'
    When RFM IN ('255','254','245','244', '235',' 234','225', '224','153','152','145','143','134','133','125','124') THEN 'AtRisk'
    When RFM IN ('155','154','144', '214', '215', '115', '114','113') THEN 'Can’tLoseThem'
    WHen RFM IN ('332','322','231', '241', '251', '233', '232','223','222','132','123','122','212','211') THEN 'Hibernating'
    WHEN RFM IN ('111','112','121','131','141','142','151') THEN 'Lost'

END Cus_Category
FROM CTE7
order by RFM;


