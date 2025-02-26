
/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- explore distinct country the customers from
SELECT DISTINCT country 
FROM gold.dim_customers
ORDER BY country;
-- found out there are 6 countries and some unknown


-- explore all categoreis 
SELECT DISTINCT 
    category, 
    subcategory, 
    product_name 
FROM gold.dim_products
ORDER BY category, subcategory, product_name;
-- can see the hierachy of the products


