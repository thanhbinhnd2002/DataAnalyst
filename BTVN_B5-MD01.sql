--Phần 1: GROUP BY
--Câu 1: Tổng annual revenue trên từng businesstype và ProductLine trong bảng DimReseller, chỉ trả về những bản ghi có tổng annual revenue lớn hơn 10 triệu
Select BusinessType, ProductLine, sum(AnnualRevenue) as TotalAnnualRevenue
FROM DimReseller
GROUP BY BusinessType, ProductLine
HAVING sum(AnnualRevenue) > 10000000

--Câu 2: Dựa vào bảng FactInternetSales hãy trả về bảng có 3 cột:
--Mã khách hàng
--Ngày gần nhất mà khách hàng mua
--Số lượng đơn khách mua (Tìm hiểu COUNT VÀ COUNT DISTINCT)
--Chỉ về các khách hàng có ngày mua gần nhất từ năm 2012 đổ về sau
Select CustomerKey, max(OrderDate) as LastPurchaseDate, count(distinct SalesOrderNumber) as NumberOfOrders
FROM FactInternetSales
GROUP BY CustomerKey
HAVING max(OrderDate) >= '2012-01-01'

--Câu 3: Doanh số bán hàng online theo từng năm ?
Select YEAR(OrderDate) as Year, sum(SalesAmount) as TotalSalesAmount
FROM FactInternetSales
GROUP BY YEAR(OrderDate)

--Phần 2: Truy vấn lồng với IN
--Câu 1: Trả về tất cả các đơn hàng trong bảng InternetSales mà có khách hàng là Nam và sinh sau năm 1970 và mua các sản phẩm màu đen
Select *
FROM FactInternetSales
WHERE CustomerKey IN (SELECT CustomerKey FROM DimCustomer WHERE Gender = 'M' AND YEAR(BirthDate) > 1970)
AND ProductKey IN (SELECT ProductKey FROM DimProduct WHERE Color = 'Black')

--Câu 2: Trả về thông tin của top 5 khách hàng nữ chi tiêu nhiều nhất 
--(Gợi ý: sử dụng truy vấn lồng kết hợp với GROUP BY vào bảng FactInternetSales để lọc các bản ghi trong bảng DimCustomer)
Select *
FROM DimCustomer
WHERE CustomerKey IN 
(SELECT TOP 5 CustomerKey FROM FactInternetSales WHERE CustomerKey IN 
    (SELECT CustomerKey FROM DimCustomer) GROUP BY CustomerKey ORDER BY sum(SalesAmount) DESC);

--Câu 3: Trả về thông tin của top 5 sản phẩm bán chạy nhất màu đỏ có ListPrice > 500

Select *
FROM DimProduct
WHERE ProductKey IN
    (SELECT TOP 5 ProductKey 
    FROM FactInternetSales 
    WHERE ProductKey IN 
        (SELECT ProductKey FROM DimProduct WHERE Color = 'Red' AND ListPrice > 500) 
    GROUP BY ProductKey ORDER BY sum(SalesAmount) DESC);

Select * 
From DimProduct
Where Color = 'Red' AND ListPrice > 500
AND ProductKey IN 
	(Select Top 5 ProductKey 
	From FactInternetSales 
	Group By ProductKey 
	Order By Sum(SalesAmount) DESC)

--Phần 3: Sử dụng truy vấn lồng với CTE
--Câu 1: Hãy viết câu truy vấn cho biết các thông tin sau:
--Trung bình một reseller chi tiêu bao nhiêu tiền ?
--Trung bình một reseller mua bao nhiêu đơn hàng ?
--Trung bình một khách hàng online chi tiêu bao nhiêu tiền ?
--Trung bình một khách hàng online mua bao nhiêu đơn ?

With CTE1 AS
(
    Select ResellerKey,sum(SalesAmount) as TotalResellerSalesAmount, count(distinct SalesOrderNumber) as TotalResellerSalesOrder
    FROM FactResellerSales
    GROUP BY ResellerKey
),
CTE2 AS
(
    Select CustomerKey,sum(SalesAmount) as TotalCustomerSalesAmount, count(distinct SalesOrderNumber) as TotalCustomerSalesOrder
    FROM FactInternetSales
    GROUP BY CustomerKey
)
Select 
AVG(TotalCustomerSalesAmount) as AverageResellerSalesAmount,
AVG(TotalResellerSalesOrder) as averageResellerNumberOrder,
AVG(TotalCustomerSalesAmount) as AverageCustomerSalesAmount,
AVG(TotalCustomerSalesOrder) as AverageCustomerNumberOrder
FROM CTE1, CTE2

--Nâng cao: hãy thể hiện yêu câu trên thành một bảng duy nhất như dưới đây (tham khảo UNION và UNION ALL)
--Phân loại	     Trung bình chi tiêu	 Trung bình số lượng đơn
--Reseller		
--Online		

With CTE1 AS
(
    Select 'Reseller' as 'Phân loại', AVG(TotalResellerSalesAmount) as 'Trung bình chi tiêu ', AVG(TotalResellerSalesOrder) as 'Trung bình số lượng đơn'
    FROM 
    (Select ResellerKey,sum(SalesAmount) as TotalResellerSalesAmount, count(distinct SalesOrderNumber) as TotalResellerSalesOrder
    FROM FactResellerSales
    GROUP BY ResellerKey) as T
),
CTE2 AS
(
    Select 'Online' as 'Phân loại', AVG(TotalCustomerSalesAmount) as 'Trung bình chi tiêu', AVG(TotalCustomerSalesOrder) as'Trung bình số lượng đơn'
    FROM 
    (Select CustomerKey,sum(SalesAmount) as TotalCustomerSalesAmount, count(distinct SalesOrderNumber) as TotalCustomerSalesOrder
    FROM FactInternetSales
    GROUP BY CustomerKey) as T
)
Select *
FROM CTE1
UNION ALL
SELECT *
FROM CTE2

--Câu 2: Trả về tên và tổng chi tiêu của top 5 khách hàng nữ sinh sau 1970, đồng thời thêm một cột Refund là bằng 10% tổng chi tiêu của các khách hàng đó
With ChiTieuKhachHang AS
(
    Select Top 5 Concat(FirstName ,' ',MiddleName,' ',LastName) AS FullName,Sum(SalesAmount) AS TotalAmount
    From FactInternetSales 
    JOIN DimCustomer ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
    Where Gender = 'F'
    AND YEAR(BirthDate) > 1970
    Group BY FirstName,MiddleName,LastName
)
Select FullName,TotalAmount,0.1*TotalAmount AS Refund
From ChiTieuKhachHang


--Phần 4: JOIN và các bài tập tổng hợp (không sử dụng IN trong các bài tập này)
--Câu 1: Trả về bảng kết quả chứa số đơn hàng của reseller, mã reseller, tên chương trình khuyễn mãi được hưởng. Lưu ý các dòng dữ liệu khi trả ra không được trùng nhau (Tham khảo SELECT DISTINCT)
--Thông tin ở bảng FactResellerSales và DimPromotion

Select DISTINCT ResellerKey, SalesOrderNumber, DimPromotion.PromotionKey
FROM FactResellerSales
JOIN DimPromotion ON FactResellerSales.PromotionKey = DimPromotion.PromotionKey
GROUP BY ResellerKey, DimPromotion.PromotionKey

--Câu 2: Trả về bảng kết quả chứa số đơn hàng, orderlinenumber, mã sản phẩm, số lượng mua, màu sắc, size, đơn giá, tên khách hàng, địa chỉ, giới tính
--Thông tin ở các bảng FactInternetSales, DimCustomer, DimProduct

Select SalesOrderNumber, SalesOrderLineNumber, FactInternetSales.ProductKey, OrderQuantity, Color, Size, ListPrice, Concat(FirstName,' ',MiddleName,' ',LastName) as FullName, AddressLine1,AddressLine2,Gender
From FactInternetSales
JOIN DimCustomer ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
JOIN DimProduct ON FactInternetSales.ProductKey = DimProduct.ProductKey

--Câu 3: Trả về bảng kết quả số lượng đơn hàng online trên mỗi Size sản phẩm

SELECT Size, COUNT(SalesOrderNumber) as NumberOfOrders
FROM FactInternetSales
JOIN DimProduct ON FactInternetSales.ProductKey = DimProduct.ProductKey
GROUP BY Size

--Câu 4: Trung bình số lượng mua trên mỗi Size của các khách hàng sinh sau 1980

SELECT Size, AVG(OrderQuantity) as AverageOrderQuantity
FROM FactInternetSales
JOIN DimCustomer ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
JOIN DimProduct ON FactInternetSales.ProductKey = DimProduct.ProductKey
WHERE YEAR(BirthDate) > 1980
GROUP BY Size

-- Câu 5: Trả về bảng kết quả thể hiện doanh số từ năm 2012 – 2014 theo từng năm và theo từng quốc gia đồng thời thêm một cột Bonus vùng tương đương 10% doanh số

SELECT YEAR(OrderDate) as Year, EnglishCountryRegionName, SUM(SalesAmount) as TotalSalesAmount, 0.1*SUM(SalesAmount) as Bonus
FROM FactInternetSales
JOIN DimCustomer ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
JOIN DimGeography ON DimCustomer.GeographyKey = DimGeography.GeographyKey
WHERE YEAR(OrderDate) BETWEEN 2012 AND 2014
GROUP BY YEAR(OrderDate), EnglishCountryRegionName
Order By Year, EnglishCountryRegionName

--Câu 6: Trả về mã đơn hàng online năm 2011 bởi khách hàng nữ sinh sau 1980, số orderline, mã khách hàng, mã sản phẩm, số lượng mua, và cột phân loại theo logic sau:
--Màu Black, Blue, Grey, Red được phân loại là DarkColor
--Silver, Silver/Black, White, Yellow được phân loại là BrightColor
--Các màu khác giữ nguyên

Select FIS.SalesOrderNumber, FIS.SalesOrderLineNumber, FIS.CustomerKey, FIS.ProductKey, FIS.OrderQuantity,
CASE 
    WHEN Color IN ('Black','Blue','Grey','Red') THEN 'DarkColor'
    WHEN Color IN ('Silver','Silver/Black','White','Yellow') THEN 'BrightColor'
    ELSE Color
END as ColorClassification
FROM FactInternetSales AS FIS
JOIN DimCustomer ON FIS.CustomerKey = DimCustomer.CustomerKey
JOIN DimProduct ON FIS.ProductKey = DimProduct.ProductKey
WHERE YEAR(OrderDate) = 2011


--Câu 7: Giống câu 6 nhưng hãy tính tổng số lượng mua theo từng phân loại màu sắc
With CTE AS
(
    Select FIS.SalesOrderNumber, FIS.SalesOrderLineNumber, FIS.CustomerKey, FIS.ProductKey, FIS.OrderQuantity,
    CASE 
        WHEN Color IN ('Black','Blue','Grey','Red') THEN 'DarkColor'
        WHEN Color IN ('Silver','Silver/Black','White','Yellow') THEN 'BrightColor'
        ELSE Color
    END as ColorClassification
    FROM FactInternetSales AS FIS
    JOIN DimCustomer ON FIS.CustomerKey = DimCustomer.CustomerKey
    JOIN DimProduct ON FIS.ProductKey = DimProduct.ProductKey
    WHERE YEAR(OrderDate) = 2011
)
Select ColorClassification, SUM(OrderQuantity) as TotalOrderQuantity
FROM CTE
GROUP BY ColorClassification
