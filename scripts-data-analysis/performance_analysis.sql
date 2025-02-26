/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */


WITH yearly_sales AS 
(SELECT 
YEAR(s.order_date) as order_year,
p.product_name, 
SUM(s.sales_amount) as current_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p 
ON s.product_key = p .product_key
WHERE s.order_date IS NOT NULL
GROUP BY YEAR(s.order_date) , product_name)

SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) as diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Average'
     WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Average'
     ELSE 'Average'
END as Avg_change,
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) AS prev_year,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) as diff_prev,
CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) > 0 THEN 'Increase'
     WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) < 0 THEN 'Decrease'
     ELSE 'No change'
END AS prev_change
FROM yearly_sales
ORDER BY product_name, order_year