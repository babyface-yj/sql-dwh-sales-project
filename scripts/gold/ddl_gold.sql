/*
=====================================================================
DDL Script: Create Gold Views
=====================================================================
Script purpose
  This script creates views in the gold schema, dropping existing 
  views if they already exist.
  The gold layer represents the final dimention and fact tables (start schema)

  Each view performs transformation and combine data from silver layer
  to produce a clean enriched and business ready data

Usage
  - These views can be queried directly for analytics and reporting
=====================================================================

*/

-- create dimention: gold.dim_customers
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
  DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY c1.cst_id) AS customer_key,
    c1.cst_id AS customer_id,
    c1.cst_key AS customer_number,
    c1.cst_firstname AS first_name,
    c1.cst_lastname AS last_name,
    c3.cntry AS country,
    CASE WHEN c1.cst_gndr != 'n/a' THEN c1.cst_gndr -- CRM is the Master source
         ELSE COALESCE(c2.gen, 'n/a')
    END AS gender,
    c2.bdate AS birthday,
    c1.cst_marital_status as marital_status,
    c1.cst_create_date AS create_date
FROM silver.crm_cust_info c1
LEFT JOIN silver.erp_cust_az12 c2
ON c1.cst_key = c2.cid
LEFT JOIN silver.erp_loc_a101 c3
ON c1.cst_key = c3.cid


-- create dimention: gold.dim_products
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
  DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY p1.prd_start_dt, p1.prd_key) AS product_key,
    p1.prd_id AS product_id,
    p1.prd_key AS product_number,
    p1.prd_nm AS product_name,
    p1.cat_id AS category_id,
    p2.cat AS category,
    p2.subcat AS subcategory,
    p2.maintenance,
    p1.prd_line AS product_line,
    p1.prd_cost AS cost,
    p1.prd_start_dt AS start_date
FROM silver.crm_prd_info p1
LEFT JOIN silver.erp_px_cat_g1v2 p2
ON p1.cat_id = p2.id
WHERE p1.prd_end_dt IS NULL


-- create fact: gold.fact_sales
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
  DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
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
