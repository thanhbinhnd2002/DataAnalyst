--Bài kiểm tra Module 1: SQL server (AdventureWorkDW)
--Câu 1: Từ bảng DimSalesTerritory, trả về tất cả các cột NGOẠI TRỪ cột SalesTerritoryAlternateKey, SalesTerritoryImage
SELECT SalesTerritoryKey, SalesTerritoryRegion, SalesTerritoryCountry, SalesTerritoryGroup
FROM DimSalesTerritory;

--Câu 2: Từ bảng DimPromotion, trả về đúng 2 cột PromotionKey và EnglishPromotionName
SELECT PromotionKey, EnglishPromotionName
FROM DimPromotion;

--Câu 3: Trả về tất cả các cột trong bảng FactSalesQuota, sắp xếp theo thứ tự từ lớn đến bé với SalesAmountQuota
SELECT *
FROM FactSalesQuota
ORDER BY SalesAmountQuota DESC;


--Câu 4: Trong bảng FactSalesQuota, trả về tất cả các bản ghi có date trong năm 2013 và SalesAmountQuota > 1tr. 
--Sắp xếp theo thứ tự từ lớn đến bé với SalesAmountQuota, và từ bé đến lớn với EmployeeKey
SELECT *
FROM FactSalesQuota
WHERE YEAR(Date) = 2013 AND SalesAmountQuota > 1000000
ORDER BY SalesAmountQuota DESC, EmployeeKey ASC;

--Câu 5: Trong bảng DimProduct, trả về cột ProductKey, Color và StartDate.
--Các bản ghi thỏa mãn một trong các điều kiện sau:
--StartDate trong năm 2012 và Class là M
--StartDate trong năm 2013 và có màu đen

SELECT ProductKey, Color, StartDate
FROM DimProduct
WHERE (YEAR(StartDate) = 2012 AND Class = 'M') 
OR (YEAR(StartDate) = 2013 AND Color = 'Black');

--Câu 6: Trong bảng DimReseller, trả về cột ResellerKey, AnnualRevenue, YearOpened. Các bản ghi thỏa mãn một trong các điều kiện sau:
--Annual Income nằm trong khoảng 20000 – 90000 và YearOpened trong khoảng 1972 – 1978
--Annual Income trong khoảng 100000 – 500000 và YearOpened trng khoảng 1989 – 2000
--Sắp xếp các bản ghi với AnnualRevenue, YearOpened theo chiều giảm dần

SELECT ResellerKey, AnnualRevenue, YearOpened
FROM DimReseller
WHERE (AnnualRevenue BETWEEN 20000 AND 90000 AND YearOpened BETWEEN 1972 AND 1978)
OR (AnnualRevenue BETWEEN 100000 AND 500000 AND YearOpened BETWEEN 1989 AND 2000)
ORDER BY AnnualRevenue DESC, YearOpened DESC;

--Câu 7: Trong bảng DimReseller, trả về các bản ghi có bank name thuộc một trong các giá trị sau International Security, 
--Primary International, United Security, Primary Bank & Reserve, có AnnualSales lớn hơn 1tr và có MinPaymentAmount.

SELECT *
FROM DimReseller
WHERE BankName IN ('International Security', 'Primary International', 'United Security', 'Primary Bank & Reserve')
AND AnnualSales > 1000000
AND MinPaymentAmount IS NOT NULL;

--Câu 8: Trả về TOP 3 công ty có AnnualSales lớn nhất được thành lập trong thế kỉ 21. Biết các công ty này phải thuộc ProductLine là Road
SELECT TOP 3 *
FROM DimReseller
WHERE YEAR(YearOpened) >= 2001 AND ProductLine = 'Road'
ORDER BY AnnualSales DESC;

--Câu 9: Trả về FullName, BaseRate ( dữ liệu trong bảng DimEmployee) của TOP 5 nhân viên có SalesQuotaAmount cao nhất trong năm 2012
SELECT TOP 5 CONCAT(FirstName,' ',MiddleName,' ',LastName) AS FullName, BaseRate
FROM DimEmployee
JOIN FactSalesQuota ON DimEmployee.EmployeeKey = FactSalesQuota.EmployeeKey
WHERE YEAR(StartDate) = 2012
ORDER BY SalesAmountQuota DESC;

--Câu 10: Trong bảng DimProduct, trả về ProductName và Productkey của tất cả các sản phẩm có EnglishProductSubcategoryName (bảng DimProductSubcategory) bắt đầu bằng chữ S
SELECT DimProduct.EnglishProductName, DimProduct.ProductKey
FROM DimProduct
JOIN DimProductSubcategory ON DimProduct.ProductSubcategoryKey = DimProductSubcategory.ProductSubcategoryKey
WHERE EnglishProductSubcategoryName LIKE 'S%';

--Câu 11: Trong bảng DimCustomer, trả về tất cả các cột kèm theo một cột phân loại với logic như sau
--Nếu EnglishCountryRegionName (trong bảng DimGeography) là France, Germany, United Kingdom, Australia thì trả về Europe
--Nếu EnglishCountryRegionName là United States, Canada thì trả về America
--Sắp xếp các bản ghi theo Yearly Income từ bé đến lớn

SELECT DimCustomer.*,
    CASE 
        WHEN EnglishCountryRegionName IN ('France', 'Germany', 'United Kingdom', 'Australia') THEN 'Europe'
        WHEN EnglishCountryRegionName IN ('United States', 'Canada') THEN 'America'
    END AS Region
FROM DimCustomer
JOIN DimGeography ON DimCustomer.GeographyKey = DimGeography.GeographyKey
ORDER BY YearlyIncome ASC;

--Câu 12: Tính tổng YearlyIncome (trong bảng DimCustomer), theo từng EnglishCountryRegionName (trong bảng DimGeography).
--Chỉ tính trên các khách hàng có EnglishEducation là Bachelors

SELECT EnglishCountryRegionName, SUM(YearlyIncome) AS TotalYearlyIncome
FROM DimCustomer
JOIN DimGeography ON DimCustomer.GeographyKey = DimGeography.GeographyKey
WHERE EnglishEducation = 'Bachelors'
GROUP BY EnglishCountryRegionName;

--Câu 13: Trả về ngày mua (OrderDate trong bảng FactInternetSales) gần nhất cho từng EnglishProductCategoryName (bảng DimProductCategory)
SELECT EnglishProductCategoryName, MAX(OrderDate) AS LastOrderDate
FROM FactInternetSales
JOIN DimProduct ON FactInternetSales.ProductKey = DimProduct.ProductKey
JOIN DimProductSubcategory ON DimProduct.ProductSubcategoryKey = DimProductSubcategory.ProductSubcategoryKey
JOIN DimProductCategory ON DimProductSubcategory.ProductCategoryKey = DimProductCategory.ProductCategoryKey
GROUP BY EnglishProductCategoryName;

--Câu 14: Trả về tổng doanh số trong năm 2011 của các khách hàng nam theo từng EnglishProductCategoryName (bảng DimProductCategory) 
--và SalesTerritoryCountry (trong bảng DimSalesTerritory). Chỉ trả về những bản ghi có tổng doanh số > 1000

SELECT EnglishProductCategoryName, SalesTerritoryCountry, SUM(SalesAmount) AS TotalSalesAmount
FROM FactInternetSales
JOIN DimProduct ON FactInternetSales.ProductKey = DimProduct.ProductKey
JOIN DimProductSubcategory ON DimProduct.ProductSubcategoryKey = DimProductSubcategory.ProductSubcategoryKey
JOIN DimProductCategory ON DimProductSubcategory.ProductCategoryKey = DimProductCategory.ProductCategoryKey
JOIN DimSalesTerritory ON FactInternetSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
JOIN DimCustomer ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
WHERE YEAR(OrderDate) = 2011 
AND Gender = 'M'
GROUP BY EnglishProductCategoryName, SalesTerritoryCountry
HAVING SUM(SalesAmount) > 1000;

--Câu 15: Trả về các bản ghi trong bảng FactFinance có các cột sau:
--FinanceKey
--Amount
--OrganizationName trong bảng DimOrganization
--DepartmentGroupName trong bảng DimDepartmentGroup
--ScenarioName trong bảng DimScenario
--AccountDescription, AccountType trong bảng DimAccount

Select FactFinance.FinanceKey, FactFinance.Amount, DimOrganization.OrganizationName, DimDepartmentGroup.DepartmentGroupName, DimScenario.ScenarioName, DimAccount.AccountDescription, DimAccount.AccountType
FROM FactFinance
JOIN DimOrganization ON FactFinance.OrganizationKey = DimOrganization.OrganizationKey
JOIN DimDepartmentGroup ON FactFinance.DepartmentGroupKey = DimDepartmentGroup.DepartmentGroupKey
JOIN DimScenario ON FactFinance.ScenarioKey = DimScenario.ScenarioKey
JOIN DimAccount ON FactFinance.AccountKey = DimAccount.AccountKey;


--Câu 16: Trả về một bảng với mẫu như dưới đây
--Phân loại	   Trung bình chi tiêu	  Trung bình số lượng đơn
--Reseller		
--Online		

SELECT 'Reseller' AS Category, AVG(SalesAmount) AS AverageSpending, AVG(OrderQuantity) AS AverageOrderQuantity
FROM FactResellerSales

UNION

SELECT 'Online' AS Category, AVG(SalesAmount) AS AverageSpending, AVG(OrderQuantity) AS AverageOrderQuantity
FROM FactInternetSales;


