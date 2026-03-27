USE `mahendra`;

-- 1)Total Sales
SELECT 
    SUM(Price * `Quantity on Hand`) AS Total_Sales
FROM f_inventory_adjusted;


-- 2)Total Quantity
SELECT 
    SUM(`Quantity on Hand`) AS Total_Quantity
FROM f_inventory_adjusted;


-- 3)Total Sales by Product Family
SELECT 
    `Product Family`,
    SUM(Price * `Quantity on Hand`) AS Total_Sales
FROM f_inventory_adjusted
GROUP BY `Product Family`;



-- 4)Product wise quantity
SELECT
    `Product Name`,
    SUM(`Quantity on Hand`) AS Product_Total_Quantity
FROM f_inventory_adjusted
GROUP BY `Product Name`
ORDER BY Product_Total_Quantity DESC;


-- 5)Total Orders by Region
SELECT 
    st.`Store Region`,
    COUNT(s.`Order Number`) AS Total_Orders
FROM f_sales s
JOIN d_store st 
    ON s.`Store Key` = st.`Store Key`
GROUP BY st.`Store Region`
ORDER BY Total_Orders DESC;


-- 6)Orders by Region, State and City
SELECT 
    st.`Store Region`,
    st.`Store State`,
    st.`Store City`,
    COUNT(s.`Order Number`) AS Total_Orders
FROM f_sales s
JOIN d_store st 
    ON s.`Store Key` = st.`Store Key`
GROUP BY 
    st.`Store Region`,
    st.`Store State`,
    st.`Store City`
ORDER BY Total_Orders DESC;


-- 7)Average Orders per Customer
SELECT 
    AVG(order_count) AS Avg_Orders_Per_Customer
FROM (
    SELECT COUNT(`Order Number`) AS order_count
    FROM f_sales
    GROUP BY `Cust Key`
) AS sub;


-- 8)Percentage of Customer Distribution by Region
SELECT 
    `Cust Region`,
    COUNT(`Cust Key`) AS Total_Customers,
    ROUND((COUNT(`Cust Key`) / (SELECT COUNT(*) FROM customer)) * 100, 2) AS Percentage
FROM customer
GROUP BY `Cust Region`
ORDER BY Total_Customers DESC;


-- 9)Top 10 States by total Orders
SELECT 
    st.`Store State`,
    COUNT(f.`Order Number`) AS Total_Orders
FROM f_sales f
JOIN d_store st 
    ON f.`Store Key` = st.`Store Key`
GROUP BY st.`Store State`
ORDER BY Total_Orders DESC
Limit 10;



-- 10)Product-Wise Inventory Value
SELECT
    `Product Name`,
    SUM(`Price` * `Quantity on Hand`) AS Inventory_Value
FROM f_inventory_adjusted
GROUP BY `Product Name`
ORDER BY Inventory_Value DESC;


-- 11)Inventory Turnover Ratio
SELECT 
    SUM(i.`Cost Amount`) / SUM(i.`Quantity on Hand`) AS Inventory_Turnover
FROM f_inventory_adjusted i;


-- 12)Top 5 Store Wise Sales
SELECT 
    st.`Store Name`,
    COUNT(f.`Order Number`) AS Total_Orders
FROM f_sales f
JOIN d_store st 
    ON f.`Store Key` = st.`Store Key`
GROUP BY st.`Store Name`
ORDER BY Total_Orders DESC
LIMIT 5;


-- 13)Top 5 stores by rent efficiency
SELECT 
    st.`Store Name`,
    st.`Monthly Rent Cost`,
    COUNT(f.`Order Number`) AS Total_Orders,
    ROUND(COUNT(f.`Order Number`) / NULLIF(st.`Monthly Rent Cost`,0), 2) AS Rent_Efficiency
FROM f_sales f
JOIN d_store st
    ON f.`Store Key` = st.`Store Key`
GROUP BY st.`Store Name`, st.`Monthly Rent Cost`
ORDER BY Rent_Efficiency DESC
LIMIT 5;


-- 14)top 5 Stores with Highest Employees
SELECT 
    `Store Name`,
    `Number of Employees`
FROM d_store
ORDER BY `Number of Employees` DESC
LIMIT 5;


-- 15)Reorder Status
SELECT
    ROUND(
        (SUM(CASE WHEN `Quantity on Hand` < `Reorder_Level` THEN 1 ELSE 0 END) 
         / COUNT(*)) * 100, 2
    ) AS Reorder_Percentage
FROM f_inventory_adjusted;



-- 16)Overstock, Out-of-stock, Under-stock:
SELECT
    SUM(CASE WHEN `Quantity on Hand` = 0 THEN 1 ELSE 0 END) AS Out_of_Stock,
    SUM(CASE WHEN `Quantity on Hand` > 0 AND `Quantity on Hand` < 10 THEN 1 ELSE 0 END) AS Under_Stock,
    SUM(CASE WHEN `Quantity on Hand` >= 10 THEN 1 ELSE 0 END) AS In_Stock
FROM f_inventory_adjusted;


-- 17)Month-over-Month (MoM) Sales Growth (Order Count)
WITH MonthlyOrders AS (
    SELECT
        YEAR(Date) AS Year,
        MONTH(Date) AS Month,
        COUNT(`Order Number`) AS TotalOrders
    FROM f_sales
    GROUP BY YEAR(Date), MONTH(Date)
),
Growth AS (
    SELECT
        Year,
        Month,
        TotalOrders,
        LAG(TotalOrders) OVER (ORDER BY Year, Month) AS PrevMonthOrders
    FROM MonthlyOrders
)
SELECT
    Year,
    Month,
    TotalOrders,
    PrevMonthOrders,
    ROUND(((TotalOrders - PrevMonthOrders) / PrevMonthOrders) * 100, 2) AS MoM_Growth_Percentage
FROM Growth;


-- 18)Year-over-Year (YoY) Sales Growth (Order Count)
WITH YearlyOrders AS (
    SELECT
        YEAR(Date) AS Year,
        COUNT(`Order Number`) AS TotalOrders
    FROM f_sales
    GROUP BY YEAR(Date)
),
Growth AS (
    SELECT
        Year,
        TotalOrders,
        LAG(TotalOrders) OVER (ORDER BY Year) AS PrevYearOrders
    FROM YearlyOrders
)
SELECT
    Year,
    TotalOrders,
    PrevYearOrders,
    ROUND(((TotalOrders - PrevYearOrders) / PrevYearOrders) * 100, 2) AS YoY_Growth_Percentage
FROM Growth;


-- 19)Transaction Type–wise Orders
SELECT
    `Transaction Type`,
    COUNT(`Order Number`) AS Total_Orders
FROM f_sales
GROUP BY `Transaction Type`
ORDER BY Total_Orders DESC;


-- 20)Purchase Method Wise Sales
SELECT 
    f.`Purchase Method`,
    COUNT(f.`Order Number`) AS Total_Orders
FROM f_sales f
GROUP BY f.`Purchase Method`
ORDER BY Total_Orders DESC;


