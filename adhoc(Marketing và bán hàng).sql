--adhoc(Marketing và bán hàng)

--Độ biến thiên của chi phí sản phẩm và giá sản phẩm ? Đâu là các sản phẩm có độ biến thiên cao nhất

SELECT productID,
STDEV(ListPrice) as 'Độ biến thiên giá sản phẩm'
FROM Production.ProductListPriceHistory
GROUP BY productID

--Xây dưng mô hình RFM để phân loại khách hàng

--B1 tính giá trị chi tiêu của từng khách hàng
WITH CTE AS 
(SELECT
CustomerID,
SUM(Subtotal) TotalRev,
PERCENT_RANK() OVER(ORDER BY SUM(Subtotal) ASC) AS Percent_Rank
FROM Sales.SalesOrderHeader
GROUP BY CustomerID)

SELECT *,
CASE
	WHEN Percent_Rank <= 0.25 THEN 1
	WHEN Percent_Rank <= 0.5 THEN 2
	WHEN Percent_Rank <= 0.75 THEN 3
	ELSE 4
END Monteary_Score
FROM CTE