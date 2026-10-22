/* =====================================================================
   Superstore Profit Analysis - SQL Server analysis
   Database : SuperstoreDB      Table : dbo.CleanedOrders (9,994 rows)
   Source   : table loaded from the cleaned pandas DataFrame (see notebook, Stage 3)
   Run      : connect to your server (for example localhost\SQLEXPRESS), then run
              the sections one at a time (select a section and press F5).
   ===================================================================== */

USE SuperstoreDB;
GO

-- ---------------------------------------------------------------------
-- 0. Sanity checks: table loaded correctly?
-- ---------------------------------------------------------------------
SELECT TOP 5 * FROM dbo.CleanedOrders;                 -- preview the first rows

SELECT COUNT(*) AS TotalRows FROM dbo.CleanedOrders;   -- expected: 9994

-- ---------------------------------------------------------------------
-- Q1: Overall KPIs
-- Expected: 5009 orders, Sales 2,297,201, Profit 286,397, Margin 12.47%
-- ---------------------------------------------------------------------
SELECT
  COUNT(DISTINCT [Order ID])  AS Total_Orders,         -- distinct orders (one order has many lines)
  SUM(Sales)                  AS Total_Sales,
  SUM(Profit)                 AS Total_Profit,
  SUM(Profit) / SUM(Sales) * 100 AS Profit_Margin      -- weighted margin (total profit / total sales)
FROM dbo.CleanedOrders;

-- ---------------------------------------------------------------------
-- Q2: Category wise Sales and Profit
-- Finding: Furniture earns only ~18K profit on ~742K sales (margin 2.5%)
-- ---------------------------------------------------------------------
SELECT Category, SUM(Sales) AS Sales, SUM(Profit) AS Profit
FROM dbo.CleanedOrders
GROUP BY Category
ORDER BY Profit DESC;

-- ---------------------------------------------------------------------
-- Q3: Region wise Sales and Profit
-- Finding: West is best, Central has the lowest profit
-- ---------------------------------------------------------------------
SELECT Region, SUM(Sales) AS Sales, SUM(Profit) AS Profit
FROM dbo.CleanedOrders
GROUP BY Region
ORDER BY Profit DESC;

-- ---------------------------------------------------------------------
-- Q3B: 10 worst states by total profit (negative = net loss)
-- Finding: Texas, Ohio, Pennsylvania, Illinois lose the most
-- ---------------------------------------------------------------------
SELECT TOP 10 State, SUM(Profit) AS Profit
FROM dbo.CleanedOrders
GROUP BY State
ORDER BY Profit ASC;

-- ---------------------------------------------------------------------
-- Q4: Yearly trend of Sales and Profit
-- Finding: both grow from 2014 to 2017, so total profit is not falling
-- ---------------------------------------------------------------------
SELECT YEAR([Order Date]) AS [Year], SUM(Sales) AS Sales, SUM(Profit) AS Profit
FROM dbo.CleanedOrders
GROUP BY YEAR([Order Date])
ORDER BY [Year];

-- ---------------------------------------------------------------------
-- Q5: Discount effect by Sub-Category (highest average discount first)
-- Finding: Binders, Machines, Tables, Bookcases carry the heaviest discounts
-- ---------------------------------------------------------------------
SELECT [Sub-Category], AVG(Discount) AS Avg_Discount, SUM(Profit) AS Profit
FROM dbo.CleanedOrders
GROUP BY [Sub-Category]
ORDER BY Avg_Discount DESC;

-- ---------------------------------------------------------------------
-- Q6: Top 10 loss-making products (most negative total profit first)
-- Finding: Cubify CubeX 3D printers and Lexmark MX611dhe lead the list
-- ---------------------------------------------------------------------
SELECT TOP 10 [Product Name], SUM(Profit) AS Loss
FROM dbo.CleanedOrders
GROUP BY [Product Name]
ORDER BY Loss ASC;

-- ---------------------------------------------------------------------
-- Q7: Segment wise Sales, Profit and margin
-- Finding: Consumer earns the most profit but has the lowest margin (11.5%)
-- ---------------------------------------------------------------------
SELECT Segment,
       SUM(Sales)  AS Sales,
       SUM(Profit) AS Profit,
       SUM(Profit) / SUM(Sales) * 100 AS Profit_Margin
FROM dbo.CleanedOrders
GROUP BY Segment;

-- ---------------------------------------------------------------------
-- Q8: Discount bucket analysis (the root-cause query)
-- Finding: margin falls from 29.5% (0% discount) to -77.4% (40%+ discount);
--          every row above 40% discount loses money
-- ---------------------------------------------------------------------
SELECT Discount_Bucket,
       COUNT(*)                      AS Orders,
       SUM(Sales)                    AS Sales,
       SUM(Profit)                   AS Profit,
       SUM(Profit) * 100.0 / SUM(Sales) AS Margin_Pct,
       SUM(CASE WHEN Profit < 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Loss_Rows_Pct
FROM (
    SELECT *,
           CASE WHEN Discount = 0   THEN '0%'
                WHEN Discount <= 0.2 THEN '1-20%'
                WHEN Discount <= 0.4 THEN '21-40%'
                ELSE '40%+' END AS Discount_Bucket
    FROM dbo.CleanedOrders
) AS t
GROUP BY Discount_Bucket
ORDER BY MIN(Discount);                                -- 0% first, 40%+ last

-- ---------------------------------------------------------------------
-- Utility: find your server name (use it in the Python connection string)
-- ---------------------------------------------------------------------
SELECT @@SERVERNAME;
