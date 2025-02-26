/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month 
-- and the running total of sales over time 

SELECT order_date,
total_sales,
SUM(total_sales) over(ORDER BY order_date ASC) as running_total_sales,
AVG(avg_price) over(ORDER BY order_date ASC) as moving_avg_price
FROM
(SELECT 
SUBSTRING(CAST(order_date AS varchar), 1, 7) as order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY SUBSTRING(CAST(order_date AS varchar), 1, 7)
)t
-- as I'm using Mac Azure SQL doesnt support CLR integration, otherwise can use DATETRUNC() or FORMAT()