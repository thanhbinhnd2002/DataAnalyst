--Adhoc (nhân sự)

--Tỉ lệ nhân viên nghỉ việc theo từng năm ?
--Muc Tieu : Tỉ lệ nhân viên nghỉ việc theo từng năm cho biết mức độ ổn định của lực lượng lao động trong công ty theo thời gian.
--Thông qua việc phân tích tỉ lệ nhân viên nghỉ việc theo từng năm, 
--chúng ta có thể nhận biết các xu hướng và mô hình phát triển nhân sự trong công ty, 
--đồng thời đánh giá hiệu suất và sự ổn định của chính sách quản lý nhân sự,
--cho biết sự gắn kết của nhân viên với công ty nhằm đưa ra các biện pháp giữ chân nhân viên.
WITH CTE1 AS (
    SELECT YEAR(EDH.EndDate) AS Nam, COUNT(DISTINCT EDH.BusinessEntityID) AS SoNhanVienNghiViec
    FROM HumanResources.EmployeeDepartmentHistory AS EDH
    WHERE EDH.EndDate IS NOT NULL
    GROUP BY YEAR(EDH.EndDate)
),
CTE2 AS (
    SELECT YEAR(E.HireDate) AS Nam, COUNT(E.BusinessEntityID) AS TongSoNhanVienVaoLam
    FROM HumanResources.Employee AS E
    GROUP BY YEAR(E.HireDate) 
),
CTE3 AS (
    SELECT 
    CTE2.Nam,
    SUM(TongSoNhanVienVaoLam) OVER (ORDER BY CTE2.Nam) - SUM(SoNhanVienNghiViec) OVER (ORDER BY CTE1.Nam) AS TongSoNhanVien
    FROM CTE2
	Full JOIN CTE1 on CTE2.Nam = CTE1.Nam
)
SELECT 
    CTE1.Nam,
    CASE
        WHEN CTE2.TongSoNhanVienVaoLam = 0 THEN 0
        ELSE CAST(CTE1.SoNhanVienNghiViec AS FLOAT) * 100 / (CTE3.TongSoNhanVien/2)
    END AS TiLeNhanVienNghiViec
FROM 
    CTE1
JOIN CTE2 ON CTE1.Nam = CTE2.Nam
Join CTE3 ON CTE2.Nam = CTE3.Nam;

---------------------------------------------------------------------------------

--Nhân viên nghỉ việc tập trung chủ yếu ở cấp bậc, phòng ban nào ?
--Mục đích : Tìm ra nguyên nhân và đưa ra biện pháp giữ chân nhân viên
WITH CTE AS(
    SELECT D.Name AS PhongBan, E.OrganizationLevel AS CapBac, COUNT(*) AS SoNhanVienNghiViec
    FROM HumanResources.EmployeeDepartmentHistory AS EDH
    JOIN HumanResources.Employee AS E ON EDH.BusinessEntityID = E.BusinessEntityID
    JOIN HumanResources.Department AS D ON EDH.DepartmentID = D.DepartmentID
    WHERE EDH.EndDate IS NOT NULL
    GROUP BY D.Name, E.OrganizationLevel
)
SELECT 
PhongBan, 
CapBac,
SoNhanVienNghiViec,
CAST(SoNhanVienNghiViec * 100.0 / (SELECT SUM(SoNhanVienNghiViec) FROM CTE) AS decimal(5, 2)) AS Percentage 
FROM CTE;



---------------------------------------------------------------------------------

--Tổng chi phí trả lương theo thời gian ? % chi phí trả lương trên doanh số ?
-- MỤC ĐÍCH : Đánh giá chi phí trả lương và đưa ra biện pháp giảm hay tăng chi phí để phù hợp với doanh số

WITH EmployeeSalary AS (
    (SELECT
        EPH.BusinessEntityID,
        EPH.Rate,
        EPH.RateChangeDate AS StartDate,
        CASE
            When EDH.EndDate IS NOT NULL THEN LEAD(EPH.RateChangeDate, 1, EDH.EndDate) OVER (PARTITION BY EPH.BusinessEntityID ORDER BY EPH.RateChangeDate)
            ELSE LEAD(EPH.RateChangeDate, 1, '2014-01-01') OVER (PARTITION BY EPH.BusinessEntityID ORDER BY EPH.RateChangeDate)
        END AS EndDate
    FROM
        HumanResources.EmployeePayHistory AS EPH
    INNER JOIN
        HumanResources.EmployeeDepartmentHistory AS EDH ON EPH.BusinessEntityID = EDH.BusinessEntityID
    WHERE
        EDH.StartDate <= '2014-01-01'
        AND EDH.EndDate IS  NULL
    ) 
),BonusSalary AS(
    --Tính %chi phí trả lương trên doanh số
    SELECT SUM((SP.Bonus + SP.CommissionPct*SP.SalesYTD)*100)/SUM(SP.SalesYTD)  AS BonusPercentage
    FROM Sales.SalesPerson AS SP

)
SELECT
    BonusPercentage,
    SUM(Rate * 8 * DATEDIFF(day, StartDate, EndDate)) AS TotalSalary
FROM
    EmployeeSalary, BonusSalary
GROUP BY BonusPercentage;

--------------------------------------------------------------------------------------------

--Nhân sự chủ yếu đang ở độ tuổi nào ? Giới tính nào ? (giả tưởng năm hiện tại 2014)
-- Mục đích : Đánh giá độ tuổi và giới tính của nhân viên để đưa ra biện pháp tuyển dụng phù hợp
WITH CTE AS(
    SELECT E.BusinessEntityID,E.Gender,
    CASE
        WHEN YEAR(E.BirthDate) BETWEEN 1984 AND 1996 THEN '18-30'
        WHEN YEAR(E.BirthDate) BETWEEN 1974 AND 1983 THEN '31-40'
        WHEN YEAR(E.BirthDate) BETWEEN 1964 AND 1973 THEN '41-50'
        ELSE '51-60'
    END AS DoTuoi
    
From HumanResources.Employee AS E
JOIN HumanResources.EmployeeDepartmentHistory AS EH ON E.BusinessEntityID = EH.BusinessEntityID
WHERE EH.EndDate IS NULL


)
SELECT DoTuoi,
Gender,
COUNT(*) AS SoLuong,
CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM CTE) AS decimal(5, 2)) AS Percentage
FROM CTE
GROUP BY DoTuoi,Gender
Order BY DoTuoi,Gender;

---------------------------------------------------------------------------------

--Chi phí trả lương theo từng cấp bậc ? Tỉ lệ trên tổng thể ?
-- Mục đích : Đánh giá chi phí trả lương theo từng cấp bậc và đưa ra biện pháp điêu chỉnh lương

WITH CTE AS(
    SELECT E.OrganizationLevel, SUM(PA.Rate) AS TongLuong
    FROM HumanResources.Employee AS E
    JOIN HumanResources.EmployeePayHistory AS PA ON E.BusinessEntityID = PA.BusinessEntityID
    GROUP BY E.OrganizationLevel
)
SELECT 
OrganizationLevel,
TongLuong,
CAST(TongLuong * 100.0 / (SELECT SUM(TongLuong) FROM CTE) AS decimal(5, 2)) AS Percentage
FROM CTE;

-------------------------------------------------------------------------------

--Số lượng nhân viên và số lượng quản lý của từng phòng ban ?
--Phòng ban   | Số lượng nhân viên | Số lượng quản lý
-- Mục đích : Đánh giá số lượng nhân viên và quản lý của từng phòng ban để đưa ra biện pháp điều chỉnh nhân sự

WITH CTE AS(
    SELECT 
    D.Name AS PhongBan,EDH.BusinessEntityID,E.OrganizationLevel
    FROM HumanResources.EmployeeDepartmentHistory AS EDH
    JOIN HumanResources.Department AS D ON EDH.DepartmentID = D.DepartmentID
    JOIN HumanResources.Employee AS E ON EDH.BusinessEntityID = E.BusinessEntityID
    WHERE EDH.EndDate IS NULL
)
SELECT 
PhongBan,
SUM(
    Case
    WHEN OrganizationLevel IN (1,2) THEN 1
    ELSE 0 END
    ) AS SoLuongQuanLy,
SUM(
    CASE 
    WHEN OrganizationLevel IN (3,4) THEN 1 
    ELSE 0 END
    ) AS SoLuongNhanVien
FROM CTE
GROUP BY PhongBan;

--------------------------------------------------------------------------------------------------------------------------
-- Xay dung mo hinh RFM de phan loai khach hang
WITH CTE AS
(
SELECT
CustomerID,
SUM(SubTotal) AS TotalRev,
PERCENT_RANK() OVER(ORDER BY SUM(SubTotal) ASC) AS Percent_Rank
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
),
CTE2 AS
(
SELECT
CustomerID,
COUNT(*) AS Frequency,
PERCENT_RANK() OVER(ORDER BY COUNT(*) ASC) AS Percent_Rank
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
),
CTE3 AS
(
SELECT
CustomerID,
MAX(OrderDate) AS LastOrderDate,
GETDATE() AS CurrentDate,
DATEDIFF(DAY, MAX(OrderDate), GETDATE()) AS Recency,
Percent_Rank() OVER(ORDER BY DATEDIFF(DAY, MAX(OrderDate), GETDATE()) ASC) AS Percent_Rank
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
)
SELECT
CTE.CustomerID,
CTE.TotalRev,
    Case
    WHEN CTE.Percent_Rank <= 0.25 THEN 1
    WHEN CTE.Percent_Rank <= 0.5 THEN 2
    WHEN CTE.Percent_Rank <= 0.75 THEN 3
    ELSE 4
    END Monteary_Score,

CTE2.Frequency,
    Case
    WHEN CTE2.Percent_Rank <= 0.25 THEN 1
    WHEN CTE2.Percent_Rank <= 0.5 THEN 2
    WHEN CTE2.Percent_Rank <= 0.75 THEN 3
    ELSE 4
    END Frequency_Score,
CTE3.Recency,
    Case
    When CTE3.Percent_Rank <= 0.25 THEN 1
    WHEN CTE3.Percent_Rank <= 0.5 THEN 2
    WHEN CTE3.Percent_Rank <= 0.75 THEN 3
    ELSE 4
    END Recency_Score
FROM CTE
JOIN CTE2 ON CTE.CustomerID = CTE2.CustomerID
JOIN CTE3 ON CTE.CustomerID = CTE3.CustomerID
