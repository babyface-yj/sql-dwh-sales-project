/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

SELECT * FROM gold.dim_customers
SELECT * FROM gold.fact_sales

-- explore the earliest and latest order
-- explore how many years/months of sales available
SELECT 
MIN(order_date) AS first_order_date, 
MAX(order_date) AS last_order_date,
DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_yrs,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_mths
FROM gold.fact_sales
-- found out the sales is from 2010 to 2014 


-- Find the youngest and oldest customer based on birthdate
SELECT
MIN(birthday) AS oldest_customer_birthday, 
DATEDIFF(year, MIN(birthday), GETDATE()) AS oldest_age,
MAX(birthday) AS youngest_customer_birthday,
DATEDIFF(year, MAX(birthday), GETDATE()) AS youngest_age
FROM gold.dim_customers;
-- found out our customer is from age 39-109