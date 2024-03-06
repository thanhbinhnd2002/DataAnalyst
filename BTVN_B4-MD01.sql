--Bài tập về IN
--Câu hỏi 1: Truy vấn ra bảng kết quả bao gồm những khách hàng có học vấn là Partial High School hoặc High School hoặc Graduate Degree
SELECT * 
From DimCustomer
Where EnglishEducation IN ('Partial High School', 'High School', 'Graduate Degree');

--Câu hỏi 2: Truy vấn ra bảng kết quả bao gồm những khách hàng có học vấn là Partial High School hoặc High School hoặc Graduate Degree và đáp ứng một trong các điều kiện sau
--Có nghề là Professional và khoảng cách là 10+ Miles
--Có nghề là Clerical và khoảng cách là 0-1 Miles

Select *
From DimCustomer
Where EnglishEducation IN ('Partial High School', 'High School', 'Graduate Degree')
AND ((EnglishOccupation = 'Professional' AND  CommuteDistance = '10+ Miles') OR (EnglishOccupation = 'Clerical' AND CommuteDistance = '0-1 Miles'));


--Bài tập về NULL và IS NOT NULL
--Câu hỏi 1: Truy vấn tất cả các nhân viên đã nghỉ việc

Select * 
From DimEmployee
Where EndDate IS NOT NULL;

--Câu hỏi 2: Truy vấn tất cả các nhân viên đã nghỉ việc sau năm 2011 và có nghề nghiệp là Purchasing hoặc Executive.

Select *
From DimEmployee
Where Year(EndDate) > 2011 
AND ( DepartmentName = 'Purchasing' OR DepartmentName = 'Executive');

-- Bài tập về ORDER BY và TOP
--Câu hỏi 1: TOP 5 sản phẩm hiện tại vẫn đang bán mà có ListPrice lớn nhất thỏa mãn một trong các điều kiện sau
--Reorder point > 300 và Safety Stock > 400
--ListPrice nằm trong khoảng từ 100 - 300

Select TOP 5 * 
From DimProduct
Where EndDate IS NULL
AND status = 'Current'
AND ((ReorderPoint > 300 AND SafetyStockLevel > 400) OR (ListPrice BETWEEN 100 AND 300))
ORDER BY ListPrice DESC;

--Câu hỏi 2: (Nâng cao) trả về bảng kết quả thông tin của TOP 5 khách hàng chi tiêu nhiều nhất

SELECT Top 5 DC.CustomerKey, CONCAT_WS(FirstName, ' ', LastName) AS FullName, SUM(FIS.SalesAmount)  AS TotalSalesAmount
FROM DimCustomer AS DC
JOIN FactInternetSales AS FIS ON DC.CustomerKey = FIS.CustomerKey
GROUP BY DC.CustomerKey, FirstName, LastName,FIS.SalesAmount
ORDER BY SalesAmount DESC;

--Câu hỏi 1: Trả về bảng kết quả có mẫu như dưới đây và sắp xếp từ lớn xuống bé đối với Gap Price. Biết Gap Price là sự khác biệt giữa DealerPrice và ListPrice nhân thêm 10% thuế. Chỉ tính GapPrice trên những sản phẩm có Color

SELECT ProductKey, DealerPrice - ListPrice*1.1 AS GapPrice
FROM DimProduct
WHERE Color NOT LIKE 'NA'
ORDER BY GapPrice DESC;

--Câu hỏi 2: Đối với các đơn hàng giao đúng hạn được đặt vào năm 2012, 2013 của khách hàng doanh nghiệp tiến hành tính toán các chỉ số sau:
--Chi phí vận chuyển trên một đơn vị sản phẩm
--Tổng số tiền khách phải trả (SalesAmount + TaxAmt + Freight)
--% thuế trên tổng số tiền khách phải trả
--Lợi nhuận

SELECT ProductKey, Freight/OrderQuantity AS ShippingCostPerUnit, SalesAmount + TaxAmt + Freight AS TotalAmount, TaxAmt/(SalesAmount + TaxAmt + Freight)*100 AS TaxPercentage, SalesAmount - TotalProductCost AS Profit
FROM FactResellerSales
WHERE ShipDate BETWEEN OrderDate AND DueDate
AND Year(ShipDate) IN (2012, 2013)

--Bài tập xử lý chuỗi
--Câu hỏi 1: Lấy ra tền miền email của từng nhân viên phòng marketing

SELECT EmailAddress, SUBSTRING(EmailAddress, CHARINDEX('@', EmailAddress) + 1, LEN(EmailAddress) - CHARINDEX('@', EmailAddress)) AS Domain,LEN(EmailAddress) - CHARINDEX('@', EmailAddress) AS LengthDomain
FROM DimEmployee
WHERE DepartmentName = 'Marketing';

--Câu hỏi 2: Thay thế tên miền email của từng nhân viên phòng production thành production.com
SELECT EmailAddress, REPLACE(EmailAddress, SUBSTRING(EmailAddress, CHARINDEX('@', EmailAddress) + 1, LEN(EmailAddress) - CHARINDEX('@', EmailAddress)), 'production.com') AS NewEmail
From DimEmployee
Where DepartmentName = 'Production';

--Câu hỏi 3: Danh sách các sản phẩm áo dài tay để bán cho mùa lạnh, biết mã thay thế các sản phẩm này (ProductAlternateKey) bắt đầu bằng chữ LJ

Select ProductKey, ProductAlternateKey, EnglishProductName
From DimProduct
Where ProductAlternateKey LIKE 'LJ%'
AND EnglishProductName LIKE '%Long Sleeve%';

--Câu 4: Sử dụng LIKE tìm các sản phẩm có ProductAlternateKey có kí tự đầu là chữ F, kí tự thứ 7 là chữ S và kí tự cuối cùng là số 6

Select ProductKey, ProductAlternateKey, EnglishProductName
From DimProduct
Where ProductAlternateKey LIKE 'F_____S%6';

--Bài tập xử lý dạng ngày tháng
--Câu hỏi 1: Truy vấn các thông tin nhân viên đã nghỉ việc kèm theo cột số tháng họ đã làm ở công ty

SELECT EmployeeKey, FirstName, LastName, StartDate, EndDate, DATEDIFF(MONTH, StartDate, EndDate) AS TotalMonth
FROM DimEmployee
WHERE EndDate IS NOT NULL;

--Nâng cao: trung bình nhân viên sẽ gắn bó ở công ty bao lâu, viết truy vấn trả về ?
SELECT AVG(DATEDIFF(MONTH, StartDate, EndDate)) AS AverageMonth
FROM DimEmployee
WHERE EndDate IS NOT NULL;

--Câu hỏi 2: Đối với các đơn hàng trong tháng 12 năm 2013 đến từ khách hàng doanh nghiệp, thêm một cột PlanShipDate là cộng thêm 15 ngày vào OrderDate

SELECT OrderDate, DueDate, DATEADD(DAY, 15, OrderDate) AS PlanShipDate
FROM FactResellerSales
WHERE Year(OrderDate) = 2013 
AND Month(OrderDate) = 12;

--Bài tập luyện tập hàm Logic
--Câu hỏi 1: Thêm một cột phân loại tuổi khách hàng mua hàng qua internet, giả định thời điểm hiện tại là 2013-10-15.
-- Cột đó sẽ có giá trị và logic tương ứng là <18, 18 – 35, 36-50, >50

Select CustomerKey, 
    DATEDIFF(YEAR, BirthDate, '2013-10-15') AS AGE,
    Case 
        When DATEDIFF(YEAR, BirthDate, '2013-10-15') < 18 Then '<18'
        When DATEDIFF(YEAR, BirthDate, '2013-10-15') BETWEEN 18 AND 35 Then '18-35'
        When DATEDIFF(YEAR, BirthDate, '2013-10-15') BETWEEN 36 AND 50 Then '36-50'
        Else '>50'
    End AS AgeGroup
From DimCustomer;

-- Câu hỏi 2: Thêm một cột trong bảng Product theo logic:
--Nếu có Color thì lấy phần trước dấu –
--Nếu không có Color thì lấy phần sau dấu –

SELECT ProductKey,Color, ProductAlternateKey,
    CASE 
        WHEN Color <> 'NA' THEN SUBSTRING(ProductAlternateKey, 1, CHARINDEX('-', ProductAlternateKey) - 1)
        ELSE SUBSTRING(ProductAlternateKey, CHARINDEX('-', ProductAlternateKey) + 1, LEN(ProductAlternateKey) - CHARINDEX('-', ProductAlternateKey))
    END AS ProductName
FROM DimProduct;

--Câu hỏi 3: (Nâng cao) Thêm một cột chuẩn hóa lại Size của sản phẩm
-- Nếu không có Size thì là NULL
-- Size bằng chữ thì vẫn giữ nguyên
-- Nếu Size bằng số thì theo logic như sau
-- < 45 thì là S
-- 45 – 50 thì là M
-- 51 – 55 thì là L
-- Còn lại là XL

Select ProductKey, Size, 
    CASE 
        WHEN Size IS NULL THEN NULL
        WHEN Size NOT LIKE '%[0-9]%' THEN Size
        WHEN CAST(Size AS INT) < 45 THEN 'S'
        WHEN CAST(Size AS INT) BETWEEN 45 AND 50 THEN 'M'
        WHEN CAST(Size AS INT) BETWEEN 51 AND 55 THEN 'L'
        ELSE 'XL'
    END AS StandardSize
FROM DimProduct;


