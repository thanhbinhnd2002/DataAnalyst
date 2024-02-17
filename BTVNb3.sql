--Truy vấn trả về bảng kết quả danh sách nhân viên có giới tính Nam và thuộc phòng ban Engineering được hưởng base rate từ 30 đến 40
SELECT * FROM
DimEmployee 
JOIN FactSalesQuota ON FactSalesQuota.EmployeeKey = DimEmployee.EmployeeKey
JOIN DimDate ON DimDate.DateKey = FactSalesQuota.DateKey
JOIN FactFinance ON FactFinance.DateKey = DimDate.DateKey
JOIN DimDepartmentGroup ON DimDepartmentGroup.DepartmentGroupKey = FactFinance.DepartmentGroupKey
WHERE DimEmployee.Gender = 'M' 
AND DimDepartmentGroup.DepartmentGroupName = 'Engineering' 
AND DimEmployee.BaseRate BETWEEN 30 AND 40 ;

--Truy vấn trả về danh sách khách hàng là doanh nghiệp ( nằm trong bảng DimResller) đáp ứng một trong các điều kiện sau đây:
--Được thành lập vào thế kỉ 21, và có doanh số hàng năm lớn hơn hoặc bằng 3000000
--Được thành lập trước thế kỉ 21, và có doanh số bé hơn hoặc bằng 800000

SELECT * FROM DimReseller
WHERE (YearOpened BETWEEN 2001 AND 2100
AND AnnualSales >= 3000000)
OR (YearOpened < 2001 AND AnnualSales <= 800000);

--(Nâng cao) Truy vấn ra danh sách tất cả các sản phẩm có tên bắt đầu bằng chữ HL
SELECT * FROM DimProduct
WHERE DimProduct.EnglishProductName LIKE 'HL%'
OR DimProduct.SpanishProductName LIKE 'HL%'
OR DimProduct.FrenchProductName LIKE 'HL%';