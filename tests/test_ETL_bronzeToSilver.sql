/*
===============================================================================
Quality check for Bronze layer before ETL
===============================================================================
Script Purpose:
  This script performs various tests before ETL from bronze to silver

Usage Notes:
  - Run this script to prepare the transformation before data loading into silver layer
===============================================================================
*/


--===============================================================================
-- Check bronze.crm_cust_info
--===============================================================================

-- Check for Nulls or Duplicates in Primary key
-- Expecatation: no result
SELECT cst_id, COUNT(*) 
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
--found out there are duplicates and Null select one duplicate cst_id and query

SELECT * 
FROM bronze.crm_cust_info
WHERE cst_id = 29449
-- based on the cst_create_date, get the latest record for  transformation
-------------------------------------------------------------------------------

-- Check unwanted spaces
-- Expecatation: no result

SELECT cst_key
FROM bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key)

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

SELECT cst_marital_status
FROM bronze.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status)
-- Found out cst_firstname and cst_lastname has unwanted spaces, so Trim these two columns for transformation
-------------------------------------------------------------------------------

-- Data standardization & consistency

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info
-- Found out both gender and marital status don't have discrepancy 
-- they both use the initials, we update to full words for transformation
-- For Null values, using n/a instead for transformation
-------------------------------------------------------------------------------


--===============================================================================
-- Check bronze.crm_prd_info
--===============================================================================

-- Check for Nulls or Duplicates in Primary key
-- Expecatation: no result
SELECT prd_id, COUNT(*) 
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
-- result is as expected
-------------------------------------------------------------------------------

-- Check unwanted spaces
-- Expecatation: no result
SELECT prd_key
FROM bronze.crm_prd_info
WHERE prd_key != TRIM(prd_key)

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

SELECT prd_line
FROM bronze.crm_prd_info
WHERE prd_line != TRIM(prd_line)

-- result is as expected
-------------------------------------------------------------------------------

-- Check if cost is negative or null
-- Expecatation: no result

SELECT *
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL
-- found out there are null values for cost, we use 0 for transformation (after consult expert)
-------------------------------------------------------------------------------

-- Data standardization & consistency

SELECT DISTINCT prd_line
FROM bronze.crm_prd_info
-- Found out no discrepancy but with initials, we update to full words for transformation (after consult expert)
-- For Null values, using n/a instead for transformation
-------------------------------------------------------------------------------
-- check date format

SELECT prd_start_dt, prd_end_dt
FROM bronze.crm_prd_info
-- Found out we only need the date not datetime, so update to date format for trnaformation

-- Check for invalid date order
-- Expecatation: no result

SELECT * 
FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt
-- Found out lots of records end date is before the start date 
-- Select some product key and query the result 
SELECT * 
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')
-- Found out this is a product line historical data for different cost 
-- the end date should smaller than next timeseries record start date (after consult expert)
-------------------------------------------------------------------------------

-- For prd_key, it consists different info, we need to check and split 
SELECT prd_key
FROM bronze.crm_prd_info

SELECT REPLACE(SUBSTRING(prd_key,1,5),'-','_') as prd_key
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key,1,5),'-','_') not in (SELECT id
FROM bronze.erp_px_cat_g1v2)

SELECT SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key,7,LEN(prd_key)) in (SELECT sls_prd_key
FROM bronze.crm_sales_details)

-- found out the the first 5 characters of prd_key are matching the id in bronze.erp_px_cat_g1v2 table as category id
-- the rest characters of prd_key are matching sls_prd_key from bronze.crm_sales_details as product key
-- we split the prd_key into two columns (after consult expert)


--===============================================================================
-- Check bronze.crm_sales_details
--===============================================================================

-- Check unwanted spaces
-- Expecatation: no result
SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- result as expecated 
-------------------------------------------------------------------------------

-- check sls_prd_key and sls_cust_id can be connected as foriegn key with other tables
-- Expectation: no result
SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

SELECT *
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

--result as expected
-------------------------------------------------------------------------------

-- check date format
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_sales_details';
 
-- found out this columns are integer instead of date type
-- need to convert to DATE type for tranformation, need to check the values first

-- check if negative or zero value, out of range for date range, out of length for the value
SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt )!= 8 
OR sls_order_dt > 20250214
OR sls_order_dt < 19000101

-- found out for sls_order_dt, there are zero and weird (not date like info) values, need to change them to Null for transformation

SELECT sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LEN(sls_ship_dt )!= 8 
OR sls_ship_dt > 20250214
OR sls_ship_dt < 19000101

SELECT sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt )!= 8 
OR sls_due_dt > 20250214
OR sls_due_dt < 19000101
-- result as expected for sls_ship_dt, sls_due_dt so only need to tranform to date type (but apply the same logic as order date incase there are bad records in the future)

-- check if order date are bigger than ship date or due dt / if ship date bigger than due date
-- expecatation: no result
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt
OR sls_ship_dt > sls_due_dt
-- result as expecated 

-------------------------------------------------------------------------------

-- check for last three columns if any of those are negative or zero or if sls_sales != sls_quantity * sls_price
-- expecatation: no result

SELECT sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price
-- found out may records with either NULL value or negative value or not satisfy the equation
-- need to check with expert, who comes up with rules below for transformation (sls_quantity is good)
    -- IF sales <=0 or Null, derive using Quantity and Price
    -- IF Price is zero or null, calculate using Sales and Quantity 
    -- IF price < 0, convert to positive

-- come up with tranformation logic and test
SELECT sls_sales as old_sales, 
sls_price as old_price,
CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price) THEN ABS(sls_quantity * sls_price)
     ELSE sls_sales
END as sls_sales,
sls_quantity,
CASE WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity, 0)
     ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price
-------------------------------------------------------------------------------


--===============================================================================
-- Check bronze.erp_cust_az12
--===============================================================================


-- Check for Nulls or Duplicates in Primary key
-- Expecatation: no result
SELECT cid
FROM bronze.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL
-- result is as expected

-- since primariy key is the foreign key, check the connection

SELECT * FROM silver.crm_cust_info
-- choose one cst_id and check in the erp_cust_az12 table
SELECT * FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%'
-- found out there are prefix NAS which needs to be removed for transformation (check with expert)
-- check after removed if there is any id not in the crm_cust_info
SELECT cid,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
END AS cid
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
END NOT IN (SELECT cst_key FROM silver.crm_cust_info)
-- not result, so all good 
-------------------------------------------------------------------------------

-- check bdate if out of range
SELECT DISTINCT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1925-02-14' OR bdate > GETDATE()
-- found out there are many records out of range, need to check with expert then transform at least the upper records
-------------------------------------------------------------------------------

-- Date standardization and consistency for gender
SELECT DISTINCT gen
FROM bronze.erp_cust_az12

-- found out discrepency, need to use full meaningful names and change Null to N/A
select distinct gen,
CASE WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
     WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
     ELSE 'n/a'
END gen
FROM bronze.erp_cust_az12
-------------------------------------------------------------------------------


--===============================================================================
-- Check bronze.erp_loc_a101
--===============================================================================

-- Check for Nulls or Duplicates in Primary key
-- Expecatation: no result

SELECT cid
FROM bronze.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL
-- result as expected 

-- since primariy key is the foreign key, check the connection

SELECT cst_key FROM silver.crm_cust_info
SELECT cid FROM bronze.erp_loc_a101
-- found the formate is different, e.g. in crm_cust_info the cst_key = AW00011000, while in erp_loc_a101 cid = AW-00011000
-- need to remove the '-', check after remove
-- expecatation: no result 
SELECT REPLACE(cid, '-', '')  as cid FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-------------------------------------------------------------------------------
-- check data standardization and consistency

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
-- found out there are different representation of same coutry
-- use case to standardize them

SELECT DISTINCT cntry AS old_country,
CASE WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
     WHEN UPPER(TRIM(cntry)) IN ('USA','US') THEN 'United States'
     WHEN cntry = '' OR cntry IS NULL THEN 'n/a'
     ELSE TRIM(cntry)
END cntry
FROM bronze.erp_loc_a101
ORDER BY cntry


--===============================================================================
-- Check bronze.erp_px_cat_g1v2
--===============================================================================
-- Check for Nulls or Duplicates in Primary key
-- Expecatation: no result

SELECT id
FROM bronze.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL
-- result as expected 

-- since primariy key is the foreign key (cat_id in crm_prd_info), check the connection

SELECT id FROM bronze.erp_px_cat_g1v2 
WHERE id NOT IN (SELECT cat_id FROM silver.crm_prd_info)
-- found out almost all data matches exclude id with CO_PD
-- then check silver and bronze layer crm_prd_info table 

SELECT cat_id FROM silver.crm_prd_info WHERE cat_id LIKE '%CO_PD%'
SELECT prd_key FROM bronze.crm_prd_info WHERE prd_key LIKE '%CO_PD%'
-- found out even in bronze layer there is no record, this one need to check with source system expert

-------------------------------------------------------------------------------

-- check unwanted space
-- expecatations : no result 
SELECT *
FROM bronze.erp_px_cat_g1v2 
WHERE cat != TRIM(cat)
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance)

-- result as expected
-------------------------------------------------------------------------------

-- check data standardization and consistency
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2
--all looks good

-------------------------------------------------------------------------------
