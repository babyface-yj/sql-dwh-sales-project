/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

===============================================================================
*/
SELECT * FROM gold.fact_sales

-- Analyse sales performance over time
-- Quick Date Functions
SELECT 
YEAR(order_date) AS order_year, 
MONTH(order_date) AS order_month,
SUM(sales_amount) AS total_sales, 
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS quantity_sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)




