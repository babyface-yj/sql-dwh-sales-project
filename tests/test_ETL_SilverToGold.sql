/*
===============================================================================
Quality check for Silver layer before ETL to Gold layer
===============================================================================
Script Purpose:
  This script performs various tests before ETL from silver to gold

Usage Notes:
  - Run this script to prepare the transformation before data loading into gold layer
===============================================================================
*/


--===============================================================================
-- Check for customer tables (dimention) - silver layer
--===============================================================================

-- join all customer related table
SELECT 
    c1.cst_id,
    c1.cst_key,
    c1.cst_firstname,
    c1.cst_lastname,
    c1.cst_marital_status,
    c1.cst_gndr,
    c1.cst_create_date,
    c2.bdate,
    c2.gen,
    c3.cntry
FROM silver.crm_cust_info c1
LEFT JOIN silver.erp_cust_az12 c2
ON c1.cst_key = c2.cid
LEFT JOIN silver.erp_loc_a101 c3
ON c1.cst_key = c3.cid

-- check if duplicates
-- expecatation: no result
SELECT cst_id, COUNT(*) FROM
    (SELECT 
        c1.cst_id,
        c1.cst_key,
        c1.cst_firstname,
        c1.cst_lastname,
        c1.cst_marital_status,
        c1.cst_gndr,
        c1.cst_create_date,
        c2.bdate,
        c2.gen,
        c3.cntry
    FROM silver.crm_cust_info c1
    LEFT JOIN silver.erp_cust_az12 c2
    ON c1.cst_key = c2.cid
    LEFT JOIN silver.erp_loc_a101 c3
    ON c1.cst_key = c3.cid)T
GROUP BY cst_id
HAVING COUNT(*) > 1
-- result as expected
-------------------------------------------------------------------------------

-- there are two columns regarding gender, investigate first

SELECT DISTINCT
    c1.cst_gndr,
    c2.gen
FROM silver.crm_cust_info c1
LEFT JOIN silver.erp_cust_az12 c2
ON c1.cst_key = c2.cid
LEFT JOIN silver.erp_loc_a101 c3
ON c1.cst_key = c3.cid
ORDER BY 1, 2
-- some records are not aligned, easy to pick if only one record is missing
-- both missing will be n/a
-- one is Male and another is Female, then we need to check with expert to see which source system is master source (eg. CRM)

SELECT DISTINCT
    c1.cst_gndr,
    c2.gen,
CASE WHEN c1.cst_gndr != 'n/a' THEN c1.cst_gndr
     ELSE COALESCE(c2.gen, 'n/a')
END AS gender
FROM silver.crm_cust_info c1
LEFT JOIN silver.erp_cust_az12 c2
ON c1.cst_key = c2.cid
LEFT JOIN silver.erp_loc_a101 c3
ON c1.cst_key = c3.cid
ORDER BY 1, 2
-------------------------------------------------------------------------------

--===============================================================================
-- Check for Product tables (dimention) - silver layer
--===============================================================================

SELECT 
p1.prd_id,
p1.cat_id,
p1.prd_key,
p1.prd_nm,
p1.prd_cost,
p1.prd_line,
p1.prd_start_dt,
p1.prd_end_dt,
p2.cat,
p2.subcat,
p2.maintenance
FROM silver.crm_prd_info p1
LEFT JOIN silver.erp_px_cat_g1v2 p2
ON p1.cat_id = p2.id

--since the crm_prd_info has historical data, we filter out and keep the current data
--current data has prd_end_dt as Null

SELECT 
p1.prd_id,
p1.cat_id,
p1.prd_key,
p1.prd_nm,
p1.prd_cost,
p1.prd_line,
p1.prd_start_dt,
p2.cat,
p2.subcat,
p2.maintenance
FROM silver.crm_prd_info p1
LEFT JOIN silver.erp_px_cat_g1v2 p2
ON p1.cat_id = p2.id
WHERE p1.prd_end_dt IS NULL

-- check if duplicates
-- expecatation: no result
SELECT prd_key, COUNT(*)
FROM(
    SELECT 
    p1.prd_id,
    p1.cat_id,
    p1.prd_key,
    p1.prd_nm,
    p1.prd_cost,
    p1.prd_line,
    p1.prd_start_dt,
    p2.cat,
    p2.subcat,
    p2.maintenance
    FROM silver.crm_prd_info p1
    LEFT JOIN silver.erp_px_cat_g1v2 p2
    ON p1.cat_id = p2.id
    WHERE p1.prd_end_dt IS NULL
)t 
GROUP BY prd_key
HAVING COUNT(*)>1
-- result as expected


--===============================================================================
-- Check for sales tables (fact) - silver layer
--===============================================================================

-- connect with customer and product table using surrogate key

SELECT
s.sls_ord_num,
p.product_key,
c.customer_key,
s.sls_order_dt,
s.sls_ship_dt,
s.sls_due_dt,
s.sls_sales,
s.sls_quantity,
s.sls_price
FROM silver.crm_sales_details s
LEFT JOIN gold.dim_products p 
ON s.sls_prd_key = p.product_number
LEFT JOIN gold.dim_customers c 
ON s.sls_cust_id = c.customer_id

-- rearrange the order: dim keys - dates - measures and rename with friendly names 

SELECT
s.sls_ord_num AS order_number,
p.product_key,
c.customer_key,
s.sls_order_dt AS order_date,
s.sls_ship_dt AS shipping_date,
s.sls_due_dt AS due_date,
s.sls_sales AS sales_amount,
s.sls_quantity AS quantity,
s.sls_price AS price
FROM silver.crm_sales_details s
LEFT JOIN gold.dim_products p 
ON s.sls_prd_key = p.product_number
LEFT JOIN gold.dim_customers c 
ON s.sls_cust_id = c.customer_id
