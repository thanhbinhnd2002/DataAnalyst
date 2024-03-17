--Cau 1
-- DENSE_RANK, RANK và ROW_NUMBER là các hàm phân loại cửa sổ trong SQL, thường được sử dụng để xếp hạng các bản ghi dựa trên các tiêu chí cụ thể. Dưới đây là sự khác nhau chính giữa chúng:

-- ROW_NUMBER():
-- ROW_NUMBER() là hàm phân loại cửa sổ trong SQL, được sử dụng để đánh số thứ tự duy nhất cho mỗi dòng trong một nhóm kết quả dựa trên một thứ tự cụ thể.
-- Nó không thể tạo ra các số hạng có cùng giá trị.
-- Ví dụ: Nếu bạn có ba bản ghi có cùng giá trị xếp hạng (ví dụ: 1, 1, 1), ROW_NUMBER() sẽ đưa ra các số hạng riêng biệt (1, 2, 3).

-- RANK():
-- RANK() cũng là một hàm phân loại cửa sổ trong SQL, nhưng nó có khả năng xếp hạng các giá trị theo thứ tự, nhưng có thể có các giá trị xếp hạng trùng lặp.
-- Khi có các giá trị giống nhau, RANK() sẽ cấp cho tất cả các giá trị đó cùng một xếp hạng, và xếp hạng kế tiếp sẽ bị bỏ qua.
-- Ví dụ: Nếu bạn có ba bản ghi có cùng giá trị xếp hạng (ví dụ: 1, 1, 1), RANK() sẽ đưa ra các số hạng giống nhau cho tất cả các bản ghi (1, 1, 1), và xếp hạng kế tiếp sẽ bị bỏ qua.

-- DENSE_RANK():
-- DENSE_RANK() cũng là một hàm phân loại cửa sổ trong SQL, tương tự như RANK(), nhưng nó không bỏ qua các xếp hạng khi có các giá trị trùng lặp.
-- Nó cung cấp các xếp hạng mà không có khoảng trống giữa chúng. Nghĩa là, nếu có giá trị trùng lặp, chúng sẽ nhận cùng một xếp hạng, nhưng xếp hạng tiếp theo sẽ không bị bỏ qua.
-- Ví dụ: Nếu bạn có ba bản ghi có cùng giá trị xếp hạng (ví dụ: 1, 1, 1), DENSE_RANK() sẽ đưa ra các số hạng giống nhau cho tất cả các bản ghi (1, 1, 1), và xếp hạng tiếp theo sẽ là 2.
-- Tóm lại, ROW_NUMBER() đưa ra các số hạng duy nhất cho mỗi dòng, trong khi RANK() và DENSE_RANK() cho phép các xếp hạng trùng lặp, nhưng DENSE_RANK() không tạo ra khoảng trống giữa các xếp hạng.


--Cau 2 : Xep hang nhan vien theo income voi tung departmentName

SELECT 
e.EmployeeKey,
e.BaseRate,
e.DepartmentName,
DENSE_RANK() 
OVER(PARTITION BY e.DepartmentName ORDER BY e.BaseRate DESC)  AS Rank
FROM DimEmployee e;


--Cau3 : tra ve top 3 khach hang co don nhieu theo tung hoc van (bang factInternetSales)
With CTE AS
(
SELECT DC.CustomerKey, DC.EnglishEducation, COUNT(Distinct FIS.SalesOrderNumber) AS TotalOrder,
DENSE_RANK() OVER(PARTITION BY DC.EnglishEducation ORDER BY COUNT(FIS.SalesOrderNumber) DESC) AS Rank
From FactInternetSales FIS
JOIN DimCustomer DC ON FIS.CustomerKey = DC.CustomerKey
GROUP BY DC.CustomerKey ,DC.EnglishEducation
)
SELECT *
FROM CTE 
WHERE Rank <= 3;

--Cau 4 : Tra ve top 3 sales co target cao nhat theo tung nam

With CTE AS
(
    SELECT a.SalesQuotaKey,a.CalendarYear, a.SalesAmountQuota,
    DENSE_RANK() OVER(PARTITION BY a.CalendarYear ORDER BY a.SalesAmountQuota DESC) AS Rank
    FROM FactSalesQuota a
    WHERE SalesAmountQuota IS NOT NULL
)
SELECT *
FROM CTE
WHERE Rank <= 3;