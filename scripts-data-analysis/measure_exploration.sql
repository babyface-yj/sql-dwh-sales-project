/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/
SELECT * FROM gold.fact_sales
SELECT * FROM gold.dim_products
SELECT * FROM gold.dim_customers


-- Find the Total Sales
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales

-- Find how many items are sold
SELECT SUM(quantity) AS total_quantity_sold
FROM gold.fact_sales

-- Find the average selling price
SELECT AVG(price) AS avg_price
FROM gold.fact_sales

-- Find the Total number of Orders
SELECT COUNT(order_number) AS total_num_order
FROM gold.fact_sales
SELECT COUNT(DISTINCT order_number) AS total_num_order
FROM gold.fact_sales
-- there are orders with same order number with various product, so need to use DISTINCT for COUNT

-- Find the total number of products
SELECT COUNT(product_key) AS total_number_of_products
FROM gold.dim_products

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_number_of_customers
FROM gold.dim_customers

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customer_with_order
FROM gold.fact_sales
-- same number as above, means all customer in the DB has placed at least an order

-- Generate a Report that shows all key metrics of the business

SELECT 'Total Sales' as measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION
SELECT 'Total Quantity Sold' as measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION
SELECT 'Average Price' as measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION
SELECT 'Total number of orders' as measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION
SELECT 'Total number of products' as measure_name, COUNT(product_key) AS measure_value FROM gold.dim_products
UNION
SELECT 'Total number of customers' as measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers
UNION
SELECT 'Total number of customers (placed order)' as measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM gold.fact_sales