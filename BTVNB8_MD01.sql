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
From DimReseller

--Bài tập 4:
--Tiến hành trả về bảng kết quả có cấu trúc như dưới đây
--Phân loại	Tổng số đơn hàng	Tổng doanh số	Số lượng KH
--Internet			
--Reseller	
Select 'Internet' AS PhanLoai, COUNT(Distinct SalesOrderNumber) as TongSoDonHang, SUM(SalesAmount) as TongDoanhSo, COUNT(Distinct CustomerKey) as SoLuongKH
From FactInternetSales
UNION
Select 'Reseller' AS PhanLoai, COUNT(Distinct SalesOrderNumber) as TongSoDonHang, SUM(SalesAmount) as TongDoanhSo, COUNT(Distinct ResellerKey) as SoLuongKH
From FactResellerSales