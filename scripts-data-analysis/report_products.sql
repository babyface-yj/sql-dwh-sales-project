/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO
CREATE VIEW gold.report_products AS

WITH products AS 
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
    (SELECT 
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,
        s.order_number,
        s.order_date,
        s.sales_amount,
        s.quantity,
        s.customer_key
    FROM gold.fact_sales s 
    LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
    WHERE order_date IS NOT NULL)
, prodcut_segment AS
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
    (SELECT 
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) as total_orders,
        SUM(sales_amount) as total_sales,
        SUM(quantity) as total_quantity,
        COUNT(DISTINCT customer_key) as total_customers,
        MAX(order_date) as last_order_date,
        ABS(DATEDIFF(month, MIN(order_date),MAX(order_date))) as lifespan_month,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity,0)),2) as avg_price
    FROM products
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost)
/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_order_date,
    ABS(DATEDIFF(MONTH,last_order_date,GETDATE())) as recency_months,-- recency (months since last sale)
    CASE WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performers'
    END as sales_performance,
    total_sales,
    total_orders,
    total_quantity,
    total_customers,
    lifespan_month,
    avg_price,
    -- Calculate average order revenue (AOR)
    CASE WHEN total_orders = 0 THEN 0
        ELSE ROUND(CAST(total_sales AS FLOAT) / total_orders, 2)
    END as avg_order_revenue,
    -- Calculate average monthly revenue
    CASE WHEN lifespan_month = 0 THEN total_sales
        ELSE ROUND(CAST(total_sales AS FLOAT) / lifespan_month, 2)
    END as avg_monthly_revenue

FROM prodcut_segment


       
       
       