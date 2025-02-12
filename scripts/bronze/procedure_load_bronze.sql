/*
========================================================================================================
Stored procedure: Load Bronze Layer (Source -> Bronze)
========================================================================================================
Script purpose:
  This stored procedure loads data from sources into bronze schema
  It performs the following actions:
  - Truncates the bronze tables before loading the data
  - Uses the 'BULK INSERT' command to load the data from csv files to bronze tables
    - Note: Mac users need to move the files to the docker root location by excuting below command 
      (in the same directory where file is) 
      docker cp cust_info.csv sql --- sql is the container name
Parameters:
  None
  This stored procedures does not accept any parameter or return any value

To excute: EXEC bronze.load_bronze
========================================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN

    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '=====================================';
        PRINT 'Loading Bronze Layer';
        PRINT '=====================================';

        PRINT '-------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-------------------------------------';
        PRINT ''

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info'
        TRUNCATE TABLE bronze.crm_cust_info

        PRINT '>> Inserting Data Into: bronze.crm_cust_info'
        BULK INSERT bronze.crm_cust_info
        FROM '/cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\r\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '-------------------'
        PRINT ''

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info'
        TRUNCATE TABLE bronze.crm_prd_info

        PRINT '>> Inserting Data Into: bronze.crm_prd_info'
        BULK INSERT bronze.crm_prd_info
        FROM '/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\r\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '-------------------'

        PRINT ''
        
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details'
        TRUNCATE TABLE bronze.crm_sales_details

        PRINT '>> Inserting Data Into: bronze.crm_sales_details'
        BULK INSERT bronze.crm_sales_details
        FROM '/sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\r\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '-------------------'

        PRINT ''
        PRINT '-------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '-------------------------------------';

        PRINT ''

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12'
        TRUNCATE TABLE bronze.erp_cust_az12

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12'
        BULK INSERT bronze.erp_cust_az12
        FROM '/CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\r\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '-------------------'

        PRINT ''

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101'
        TRUNCATE TABLE bronze.erp_loc_a101

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101'
        BULK INSERT bronze.erp_loc_a101
        FROM '/LOC_A101.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\r\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '-------------------'

        PRINT ''

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2'
        TRUNCATE TABLE bronze.erp_px_cat_g1v2

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2'
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\r\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '-------------------'
        SET @batch_end_time = GETDATE();
        PRINT '================================='
        PRINT 'Loading Bronze Layer is Completed!'
        PRINT '  - Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'
        PRINT '================================='
    END TRY
    BEGIN CATCH
        PRINT '=====================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER!'
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=====================================';
    END CATCH
END
