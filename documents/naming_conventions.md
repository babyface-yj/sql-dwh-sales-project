# **Naming Conventions**

This document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the data warehouse.

## **General Principles**

- **Naming convention**: Use snake_case, with lowercase letters and underscore (`_`) to separate words 
- **Language**: Use English for all names
- **Avoid Reserved Words**: DO NOT use SQL reserved words as object names


## **Table Naming Conventions**

### **Bronze Rules**

- All names must start with source system names, and table names must match their original table names without renaming
- **`<sourcesystem>_<entity>`**
 - `<sourcesystem>`: Name of the source system (eg. `crm`, `erp`)
 - `<entity>`: Exact table name from the source system
 - Example: `crm_customer_info` -> customer information from CRM system

### **Silver Rules**

- All names must start with source system names, and table names must match their original table names without renaming
- **`<sourcesystem>_<entity>`**
 - `<sourcesystem>`: Name of the source system (eg. `crm`, `erp`)
 - `<entity>`: Exact table name from the source system
 - Example: `crm_customer_info` -> customer information from CRM system

### **Gold Rules**

- All names must use meaningful, business-aligned names for tables, starting with category prefix 
- **`<category>_<entity>`**
 - `<category>`: Describe the role of the table, eg. `dim` (dimension) or `fact` (fact table)
 - `<entity>`: Descriptive name of the table, aligned with business domain, (eg. `customers`, `products`, `sales`)
 - Example: 
  `dim_customer` -> dimension table for customer data
  `fact_sales` -> fact table contains transaction data


#### **Glossary of Category Patterns**

| Pattern     | Meaning                           | Example(s)                              |
|-------------|-----------------------------------|-----------------------------------------|
| `dim_`      | Dimension table                  | `dim_customer`, `dim_product`           |
| `fact_`     | Fact table                       | `fact_sales`                            |
| `agg_`      | Aggregated table                 | `agg_customers`, `agg_sales_monthly`    |


## **Column Naming Conventions**

### **Surrogate Keys**
- All primary keys in dimension tables must use the suffix _key 
- **`<table_name>_key`**
 - `<table_name>`: refers to the name of the table or entity the key belongs to
 - `_key`: suffix indicating this column is a surrogate key
 - Example: `customer_key` -> surrogate key in the dim_customers table

### **Technical Columns**
- All technical columns must start with prefix dwh_, followed by the descriptive name indicating the columns purpose
- **`dwh_<column_name>`**:
 - `dwh`: prefix exclusively for system-generated metadata
 - `<column_name>`: descriptive name indicating the purpose
 - Example: `dwh_load_date` -> system generated column used to store the date when data was loaded

## **Stored Procedure**

- All stored procedures used for loading data must follow the naming pattern:
- **`load_<layer>`**
 - `<layer>`: represents the layer being loaded such as `bronze`, `silver` or `gold`
 - Example: 
  - `load_bronze` -> stored procedure for loading data into bronze layer
