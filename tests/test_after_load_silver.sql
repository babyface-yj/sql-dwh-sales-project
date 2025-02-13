/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
  This script performs quality checks for data consistency, accuracy and standardization in silver layer:
    - Null or duplicate primary key
    - Unwanted spaces
    - Data standardization and consistency
    - Invalid date ranges, orders, format
    - Data consistency between tables / related fields 

Usage Notes:
    - Run these checks after data loading silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

--===============================================================================
-- Check silver.crm_cust_info
--===============================================================================

-- Check for Nulls or Duplicates in Primary key
-- Expecatation: no result
SELECT cst_id, COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
-------------------------------------------------------------------------------

-- Check unwanted spaces
-- Expecatation: no result

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)
-------------------------------------------------------------------------------

-- Data standardization & consistency

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info
-------------------------------------------------------------------------------

--===============================================================================
-- Check silver.crm_prd_info
--===============================================================================


-- Check for Nulls or Duplicates in Primary key
-- Expecatation: no result
SELECT prd_id, COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
-------------------------------------------------------------------------------

-- Check unwanted spaces
-- Expecatation: no result
SELECT prd_key
FROM silver.crm_prd_info
WHERE prd_key != TRIM(prd_key)

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

SELECT prd_line
FROM silver.crm_prd_info
WHERE prd_line != TRIM(prd_line)


-- Check if cost is negative or null
-- Expecatation: no result

SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL
-------------------------------------------------------------------------------

-- Data standardization & consistency

SELECT DISTINCT prd_line
FROM silver.crm_prd_info
-------------------------------------------------------------------------------
-- check date format

SELECT prd_start_dt, prd_end_dt
FROM silver.crm_prd_info

-- Check for invalid date order
-- Expecatation: no result
SELECT * 
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt
-------------------------------------------------------------------------------

--===============================================================================
-- Check silver.crm_sales_details
--===============================================================================


-- Check unwanted spaces
-- Expecatation: no result
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- result as expecated 
-------------------------------------------------------------------------------

-- check sls_prd_key and sls_cust_id can be connected as foriegn key with other tables
-- Expectation: no result
SELECT *
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

SELECT *
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

--result as expected
-------------------------------------------------------------------------------

-- check date format
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_sales_details';

-- check if order date are bigger than ship date or due dt / if ship date bigger than due date
-- expecatation: no result
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt
OR sls_ship_dt > sls_due_dt
-- result as expecated 

-------------------------------------------------------------------------------

-- check for last three columns if any of those are negative or zero or if sls_sales != sls_quantity * sls_price
-- expecatation: no result
SELECT sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price

-------------------------------------------------------------------------------

--===============================================================================
-- Check silver.erp_cust_az12
--===============================================================================

-- Check for Nulls or Duplicates in Primary key
-- Expecatation: no result
SELECT cid
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL
-- result is as expected

-- since primariy key is the foreign key, check the connection
-- expecatation: no result
SELECT cid
FROM silver.erp_cust_az12
WHERE
cid NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-------------------------------------------------------------------------------

-- check bdate if out of range
-- expecatation: no result
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE()

-------------------------------------------------------------------------------

-- Date standardization and consistency for gender
SELECT DISTINCT gen
FROM silver.erp_cust_az12

-------------------------------------------------------------------------------

--===============================================================================
-- Check silver.erp_loc_a101
--===============================================================================

-- Check for Nulls or Duplicates in Primary key
-- Expecatation: no result

SELECT cid
FROM silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL
-- result as expected 

-- since primariy key is the foreign key, check the connection
-- expecatation: no reulst
SELECT cid FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-------------------------------------------------------------------------------
-- check data standardization and consistency

SELECT DISTINCT cntry
FROM silver.erp_loc_a101
-------------------------------------------------------------------------------

--===============================================================================
-- Check silver.erp_px_cat_g1v2
--===============================================================================
-- Check for Nulls or Duplicates in Primary key
-- Expecatation: no result

SELECT id
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL
-- result as expected 

-------------------------------------------------------------------------------

-- check unwanted space
-- expecatations : no result 
SELECT *
FROM silver.erp_px_cat_g1v2 
WHERE cat != TRIM(cat)
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance)

-- result as expected
-------------------------------------------------------------------------------

-- check data standardization and consistency
SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2
--all looks good

-------------------------------------------------------------------------------
