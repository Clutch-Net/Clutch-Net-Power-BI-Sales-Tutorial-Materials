/*
	Clutch.Net Second Order Within 90 days Source Confirmation 
	Tom Sampson © Clutch.Net 2023
	free to use under the MIT License. See project LICENSE for more details.
*/
WITH RankedOrders AS (
    SELECT OrderDate,
           CustomerKey,
           SalerderNumber AS OrderNumber,
           DENSE_RANK() OVER (PARTITION BY CustomerKey ORDER BY SalerderNumber) AS Rank
    FROM (
            SELECT DISTINCT OrderDate,
                            sa.CustomerKey,
                            sa.SalerderNumber
            FROM sandbox.dbo.Sales sa
         ) AS SalesCustOrderPivot
),

OrderDatePivotByCustomerKey AS (
    SELECT CustomerKey,
           [1] AS OrderDateForRank1,
           [2] AS OrderDateForRank2,
           [3] AS OrderDateForRank3
    FROM (
            SELECT OrderDate,
                   CustomerKey,
                   Rank
            FROM RankedOrders
            WHERE Rank IN (1, 2, 3)
         ) AS SourceTable
    PIVOT(MAX(OrderDate) FOR Rank IN ([1], [2], [3])) AS PivotTable
)

SELECT YEAR(OrderDateForRank1) AS YearOfFirstOrder,
       MONTH(OrderDateForRank1) AS MonthOfFirstOrder,
       COUNT(DISTINCT CustomerKey) AS DistinctCustomerCount,
       SUM(CASE 
               WHEN DATEDIFF(DAY, OrderDateForRank1, OrderDateForRank2) <= 90 THEN 1
               ELSE 0
           END) AS SecondOrderWithin90Days,
       CAST(SUM(CASE 
                    WHEN DATEDIFF(DAY, OrderDateForRank1, OrderDateForRank2) <= 90 THEN 1.0
                    ELSE 0
                END) / COUNT(DISTINCT CustomerKey) * 100 AS DECIMAL(5, 2)) AS Percentage
FROM OrderDatePivotByCustomerKey
GROUP BY YEAR(OrderDateForRank1),
         MONTH(OrderDateForRank1)
ORDER BY YearOfFirstOrder,
         MonthOfFirstOrder;
