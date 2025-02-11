/*
===============================================
CREATE DATABASE AND SCHEMAS
===============================================
Script purpose:
  This script creates a new database named 'Datawarehouse' after checking if it exists.
  If the database exists, it is dropped and recreated. 
  Then the script sets up three schemas within the database: 'bronze', 'silver', 'gold'

WARNING:
  Running this script will drop the entire 'Datawarehouse' database if it exists
  All data in the database will be PERMANENTLY DELETED. Proceed with caution and ensure you have proper backups before running this script.
*/

use master;
Go

-- Drop and recreate the 'Datawarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Datawarehouse')
BEGIN
  ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE Datawarehouse
END;
GO

  
-- create database 
CREATE DATABASE DataWarehouse;
GO

use DataWareHouse

-- create schema
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
