/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO
CREATE VIEW gold.report_customers AS

WITH customers AS 
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
    (SELECT
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name,' ',c.last_name) as customer_name,
        ABS(DATEDIFF(YEAR, c.birthday, GETDATE())) as age,
        s.order_number,
        s.product_key,
        s.order_date,
        s.sales_amount,
        s.quantity
    FROM gold.fact_sales s 
    LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
    WHERE order_date IS NOT NULL)

, customer_segment AS
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarize key matrics at the customer level
---------------------------------------------------------------------------*/
    (SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) as last_order,
        ABS(DATEDIFF(MONTH, MIN(order_date), MAX(order_date))) AS lifespan_month
    FROM customers
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age)
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE WHEN age < 20 THEN 'Under 20'
         WHEN age BETWEEN 20 AND 29 THEN '20-29'
         WHEN age BETWEEN 30 AND 39 THEN '30-39'
         WHEN age BETWEEN 40 AND 49 THEN '40-49'
         WHEN age BETWEEN 50 AND 59 THEN '50-59'
         ELSE '60 and above'
    END as age_group,
    CASE WHEN lifespan_month >= 12 AND total_sales > 5000 THEN 'VIP'
            WHEN lifespan_month >= 12 AND total_sales <= 5000 THEN 'Regular'
            ELSE 'New'
    END as customer_type,
    last_order,
    ABS(DATEDIFF(MONTH, last_order, GETDATE())) as recency_month,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan_month,
    -- Compute average order value
    CASE WHEN total_orders = 0 THEN 0
         ELSE  ROUND(total_sales / total_orders,2)
    END  AS avg_order_value,
    -- Compute average monthly spend
    CASE WHEN lifespan_month = 0 THEN total_sales
         ELSE  ROUND(total_sales / lifespan_month,2)
    END  AS avg_monthly_spend
FROM customer_segment