/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products and percentage fall into each segment*/

WITH product_segment AS
(
SELECT 
cost_range,
COUNT(product_key) AS total_products
FROM 
    (SELECT 
    product_key,
    product_name,
    cost,
    CASE WHEN cost< 100 THEN 'Below 100'
        WHEN cost BETWEEN 100 AND 500 THEN '100-500'
        WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
        ELSE 'Above 1000'
    END as cost_range
    FROM gold.dim_products)t
GROUP BY cost_range
)
SELECT 
cost_range,
total_products,
CONCAT(ROUND((CAST(total_products AS FLOAT) / SUM(total_productS) OVER()) * 100, 2), '%') AS percentage_cost_range
FROM product_segment
ORDER BY total_products DESC



/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH customer_segment AS
(SELECT 
c.customer_key,
c.first_name,
c.last_name,
SUM(s.sales_amount) AS total_spending,
ABS(DATEDIFF(MONTH, MIN(s.order_date),MAX(s.order_date))) as life_span
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON c.customer_key = s.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name)

SELECT 
*,
CONCAT(ROUND((CAST(total_customers AS FLOAT) / SUM(total_customers) OVER())*100,2),'%') AS percentage_customers
FROM
    (SELECT 
    customer_type,
    COUNT(customer_key) as total_customers
    FROM
        (SELECT 
        customer_key,
        CASE WHEN life_span >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN life_span >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END as customer_type
        FROM customer_segment)t
    GROUP BY customer_type)t2
ORDER BY total_customers DESC