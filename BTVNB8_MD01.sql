--Bài tập 1: Tính toán số lượng đơn hàng theo từng tỉnh của khách hàng online trong năm 2011 của các khách hàng nam mua các sản phẩm màu đen
SELECT  DimGeography.City, COUNT(Distinct SalesOrderNumber) as SoLuongDonHang
From FactInternetSales
JOIN DimCustomer ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
JOIN DimGeography ON DimCustomer.GeographyKey = DimGeography.GeographyKey
JOIN DimProduct ON FactInternetSales.ProductKey = DimProduct.ProductKey
WHERE Year(OrderDate) = 2011
AND DimCustomer.Gender = 'M'
AND DimProduct.Color = 'Black'
GROUP BY DimGeography.City
Order BY DimGeography.City

--Bài tập 2: Tính toán số lượng khách hàng trong năm 2012 của các khách hàng nữ online mua hàng màu đỏ
SELECT COUNT(Distinct FactInternetSales.CustomerKey) as SoLuongKhachHang
From FactInternetSales
JOIN DimCustomer ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
JOIN DimProduct ON FactInternetSales.ProductKey = DimProduct.ProductKey
WHERE Year(OrderDate) = 2012
AND DimCustomer.Gender = 'F'
AND DimProduct.Color = 'Red'


--Bài tập 3: Sử dụng UNION hoặc UNION ALL gộp dữ liệu thành một bảng khách hàng tổng có cả khách online và reseller. Bảng tổng có cấu trúc như sau:
--Mã khách hàng
--Tên khách hàng
--Cột phân loại là bản ghi của bảng internet hay reselle

SELECT CustomerKey, CONCAT_WS(FirstName,MiddleName,LastName ) AS FullName, 'Internet' as LoaiKhachHang
From DimCustomer
UNION 
SELECT ResellerKey, ResellerName, 'Reseller' as LoaiKhachHang
From DimReseller;

--Bài tập 4:
--Tiến hành trả về bảng kết quả có cấu trúc như dưới đây
--Phân loại	Tổng số đơn hàng	Tổng doanh số	Số lượng KH
--Internet			
--Reseller	

Select 'Internet' AS PhanLoai ,COUNT(Distinct SalesOrderNumber) as TongSoDonHang, SUM(SalesAmount) as TongDoanhSo, COUNT(Distinct CustomerKey) as SoLuongKH,SUM(SalesAmount)- SUM(TotalProductCost) as LoiNhuan
From FactInternetSales
GROUP BY YEAR(ShipDate)

UNION

Select 'Reseller' AS PhanLoai ,COUNT(Distinct SalesOrderNumber) as TongSoDonHang, SUM(SalesAmount) as TongDoanhSo, COUNT(Distinct ResellerKey) as SoLuongKH,SUM(SalesAmount)- SUM(TotalProductCost) as LoiNhuan
From FactResellerSales
GROUP BY YEAR(ShipDate);

----------------------------------------------------------------------------------------------
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
),CTE2 AS(
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
SUM(TongSoLuongKH) as TongSoLuongKH
FROM CTE2;


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