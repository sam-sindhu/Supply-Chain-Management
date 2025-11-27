/* MTD, QTD AND YTD (1st kpi) */

WITH LatestDate AS (
    SELECT MAX(STR_TO_DATE(`Date`, '%Y-%m-%d')) AS MaxDate
    FROM f_sales
)
SELECT
    SUM(CASE 
            WHEN DATE_FORMAT(STR_TO_DATE(s.`Date`, '%Y-%m-%d'), '%Y-%m') = DATE_FORMAT(ld.MaxDate, '%Y-%m')
            THEN p.`Sales Amount` ELSE 0 
        END) AS Sales_MTD,
    SUM(CASE 
            WHEN QUARTER(STR_TO_DATE(s.`Date`, '%Y-%m-%d')) = QUARTER(ld.MaxDate)
                 AND YEAR(STR_TO_DATE(s.`Date`, '%Y-%m-%d')) = YEAR(ld.MaxDate)
            THEN p.`Sales Amount` ELSE 0 
        END) AS Sales_QTD,
    SUM(CASE 
            WHEN YEAR(STR_TO_DATE(s.`Date`, '%Y-%m-%d')) = YEAR(ld.MaxDate)
            THEN p.`Sales Amount` ELSE 0 
        END) AS Sales_YTD
FROM f_point_of_sale p
JOIN f_sales s ON p.`Order Number` = s.`Order Number`
CROSS JOIN LatestDate ld;


/* Product Wise Sales (2nd kpi ) */

SELECT dp.`Product Name`, SUM(ps.`Sales Amount`) AS Total_Sales FROM f_point_of_sale ps JOIN d_product dp ON ps.`Product Key` = dp.`Product Key`
GROUP BY dp.`Product Name` ORDER BY Total_Sales DESC ;

/* Daily Sales Trend  (3rd kpi)    */

SELECT DATE(s.`Date`) AS Sales_Date, SUM(p.`Sales Amount`) AS Daily_Sales FROM f_sales s JOIN f_point_of_sale p ON s.`Order Number` = p.`Order Number`
GROUP BY DATE(s.`Date`) ORDER BY Sales_Date;


/* Sales Growth (Month-over-Month) (4th kpi) */

SELECT DATE_FORMAT(s.`Date`, '%Y-%m') AS Month, SUM(p.`Sales Amount`) AS Sales, LAG(SUM(p.`Sales Amount`)) OVER (ORDER BY DATE_FORMAT(s.`Date`, '%Y-%m')) AS Previous_Month_Sales,
ROUND(((SUM(p.`Sales Amount`) - LAG(SUM(p.`Sales Amount`)) OVER (ORDER BY DATE_FORMAT(s.`Date`, '%Y-%m'))) / 
LAG(SUM(p.`Sales Amount`)) OVER (ORDER BY DATE_FORMAT(s.`Date`, '%Y-%m'))) * 100, 2) AS Growth_Percentage
FROM f_sales s JOIN f_point_of_sale p ON s.`Order Number` = p.`Order Number` GROUP BY Month ORDER BY Month;

/* State Wise Sales (5th kpi)*/
-- State Wise
SELECT st.`Store State` AS Store_State, SUM(p.`Sales Amount`) AS Total_Sales
FROM f_sales s JOIN f_point_of_sale p ON s.`Order Number` = p.`Order Number` JOIN d_store st ON s.`Store Key` = st.`Store Key`
GROUP BY st.`Store State` ORDER BY Total_Sales DESC;

/* Top 5 stores By sales (6th kpi) */
SELECT st.`Store Name` AS Store_Name, SUM(p.`Sales Amount`) AS Total_Sales FROM f_sales s
JOIN f_point_of_sale p ON s.`Order Number` = p.`Order Number`
JOIN d_store st ON s.`Store Key` = st.`Store Key`
GROUP BY st.`Store Name` ORDER BY Total_Sales DESC LIMIT 5;


/* Region Wise Sales (7th kpi)*/
-- Region Wise

SELECT st.`Store Region` AS Store_Region, SUM(p.`Sales Amount`) AS Total_Sales
FROM f_sales s JOIN f_point_of_sale p ON s.`Order Number` = p.`Order Number` JOIN d_store st ON s.`Store Key` = st.`Store Key`
GROUP BY st.`Store Region` ORDER BY Total_Sales DESC;

/*Total Inventory (8th kpi)*/

SELECT SUM(`Quantity on Hand`) AS Total_Inventory_Unit FROM f_inventory_adjusted;

/* Inventory Value (9th kpi)*/

SELECT SUM(`Quantity on Hand` * `Price`) AS Inventory_Value FROM f_inventory_adjusted;

/* Stock Categorization: In-Stock, Out-of-Stock, Under-stock (10th kpi) */

SELECT
    SUM(CASE WHEN `Quantity on Hand` >= 1 THEN 1 ELSE 0 END) AS In_Stock,  
    SUM(CASE WHEN `Quantity on Hand` = 0 THEN 1 ELSE 0 END) AS Out_of_Stock,
    SUM(CASE WHEN `Quantity on Hand` < 3 AND `Quantity on Hand` < 3 THEN 1 ELSE 0 END) AS Under_Stock
FROM f_inventory_adjusted;

/*Purchase Method wise sales (11th kpi)*/

SELECT s.`Purchase Method`, SUM(p.`Sales Amount`) AS Total_Sales, SUM(p.`Sales Quantity`) AS Total_Quantity
FROM f_sales s JOIN f_point_of_sale p ON s.`Order Number` = p.`Order Number` GROUP BY s.`Purchase Method` ORDER BY Total_Sales DESC;

