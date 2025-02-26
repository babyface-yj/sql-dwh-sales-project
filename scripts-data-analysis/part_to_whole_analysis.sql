/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?

WITH sales_category AS
(
SELECT 
p.category,
SUM(s.sales_amount) as total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p 
ON s.product_key = p.product_key
GROUP BY p.category
)
SELECT 
category,
total_sales,
SUM(total_sales) OVER() AS overrall_sales,
CONCAT(ROUND((CAST(total_sales AS float) / SUM(total_sales) OVER()) * 100, 2), '%')  as percent_sales
FROM sales_category
ORDER BY total_sales DESC




-- Which categories contribute the most to overall orders?

WITH sales_category AS
(
SELECT 
p.category,
COUNT(DISTINCT s.order_number) as total_order
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p 
ON s.product_key = p.product_key
GROUP BY p.category
)
SELECT 
category,
total_order,
SUM(total_order) OVER() AS overrall_order,
CONCAT(ROUND((CAST(total_order AS float) / SUM(total_order) OVER()) * 100, 2), '%')  as percent_order
FROM sales_category
ORDER BY total_order DESC
