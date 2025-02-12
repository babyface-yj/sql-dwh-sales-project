/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks for data completeness in bronze layer:
    - Any mis-matched content with the titles
    - Any missing data 

Usage Notes:
    - Run these checks after data loading bronze Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

SELECT * FROM bronze.crm_cust_info;
SELECT COUNT(*) FROM bronze.crm_cust_info;

SELECT * FROM bronze.crm_prd_info;
SELECT COUNT(*) FROM bronze.crm_prd_info;

SELECT * FROM bronze.crm_sales_details;
SELECT COUNT(*) FROM bronze.crm_sales_details;

SELECT  * FROM bronze.erp_cust_az12
SELECT COUNT(*) FROM bronze.erp_cust_az12;

SELECT * FROM bronze.erp_loc_a101
SELECT COUNT(*) FROM bronze.erp_loc_a101;

SELECT * FROM bronze.erp_px_cat_g1v2
SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2;
