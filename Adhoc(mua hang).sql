--Purchasing (mua hàng)

-- Top 5 nhà cung cấp công ty mua nhiều nhất ?
SELECT TOP 5 Vendor.Name, SUM(Purchasing.PurchaseOrderDetail.OrderQty) AS TotalOrderQty
FROM Purchasing.PurchaseOrderHeader
JOIN Purchasing.Vendor ON Purchasing.PurchaseOrderHeader.VendorID = Purchasing.Vendor.BusinessEntityID
Join Purchasing.PurchaseOrderDetail ON Purchasing.PurchaseOrderHeader.PurchaseOrderID = Purchasing.PurchaseOrderDetail.PurchaseOrderID
Group BY Vendor.Name
ORDER BY TotalOrderQty DESC

-- Top 5 loại sản phẩm được mua nhiều nhất ?
SELECT Top 5 Product.Name, SUM(Purchasing.PurchaseOrderDetail.OrderQty) AS TotalOrderQty
FROM Purchasing.PurchaseOrderDetail 
JOIN Production.Product ON Purchasing.PurchaseOrderDetail.ProductID = Production.Product.ProductID
GROUP BY Product.Name
ORDER BY TotalOrderQty DESC

--Top 5 subcategory mua nhiều nhất theo từng phương thức ship? Số lượng đơn và giá trị đơn theo trạng thái ? 
-- ví dụ : với hình thức ship A thì 5 sản phẩm mua nhiều nhất là gì, số lượng đơn là bao nhiêu, giá trị đơn là bao nhiêu ?,với hình thức ship B thì 5 sản phẩm mua nhiều nhất là gì, số lượng đơn là bao nhiêu, giá trị đơn là bao nhiêu ?
WITH TopSubcategories AS (
    SELECT 
        poh.ShipMethodID,
        poh.Status,
        psub.Name AS SubcategoryName,
        SUM(pod.OrderQty) AS TotalOrderQuantity,
        SUM(pod.LineTotal) AS TotalOrderValue
    FROM 
        Purchasing.PurchaseOrderHeader poh
    INNER JOIN 
        Purchasing.PurchaseOrderDetail pod ON poh.PurchaseOrderID = pod.PurchaseOrderID
    INNER JOIN 
        Production.Product prod ON pod.ProductID = prod.ProductID
    INNER JOIN 
        Production.ProductSubcategory psub ON prod.ProductSubcategoryID = psub.ProductSubcategoryID
    GROUP BY 
        poh.ShipMethodID, psub.Name,poh.Status
),
RankedSubcategories AS (
    SELECT 
        ShipMethodID,
        TopSubcategories.Status,
        SubcategoryName,
        TotalOrderQuantity,
        TotalOrderValue,
        ROW_NUMBER() OVER (PARTITION BY ShipMethodID ORDER BY TotalOrderQuantity DESC) AS RankByOrderQuantity,
        ROW_NUMBER() OVER (PARTITION BY ShipMethodID ORDER BY TotalOrderValue DESC) AS RankByTotalOrderValue
    FROM 
        TopSubcategories
)
SELECT 
    sm.Name AS ShipMethodName,
    rs.Status,
    rs.SubcategoryName,
    rs.TotalOrderQuantity,
    rs.TotalOrderValue
FROM 
    RankedSubcategories rs
INNER JOIN 
    Purchasing.ShipMethod sm ON rs.ShipMethodID = sm.ShipMethodID
WHERE 
    rs.RankByOrderQuantity <= 5
ORDER BY 
    sm.Name, rs.RankByOrderQuantity, rs.RankByTotalOrderValue;

--Các nhà cung cấp và loại hàng có % đơn chậm leadtime nhiều nhất ?(Giống cau bên trên)

-- SELECT *
-- From Purchasing.Vendor 
-- JOIN Purchasing.PurchaseOrderHeader ON Purchasing.Vendor.BusinessEntityID = Purchasing.PurchaseOrderHeader.VendorID
-- JOIN Purchasing.PurchaseOrderDetail ON Purchasing.PurchaseOrderHeader.PurchaseOrderID = Purchasing.PurchaseOrderDetail.PurchaseOrderID
-- JOIN Production.Product ON Purchasing.PurchaseOrderDetail.ProductID = Production.Product.ProductID
-- WHERE DATEDIFF(DAY, Purchasing.PurchaseOrderHeader.OrderDate, Purchasing.PurchaseOrderHeader.ShipDate) > 5


With LeadTime AS (
    SELECT 
        poh.VendorID
    From Purchasing.PurchaseOrderHeader poh
    JOIN Purchasing.PurchaseOrderDetail pod ON poh.PurchaseOrderID = pod.PurchaseOrderID
),
SELECT * 


select DATEDIFF(day,poh.OrderDate,ShipDate),poh.ModifiedDate
From Purchasing.PurchaseOrderHeader poh


-----------------------------------------------------------------------
--
