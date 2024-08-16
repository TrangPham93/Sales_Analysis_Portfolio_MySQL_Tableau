# Data Porfolio: Sales_analysis using MySQL & Tableau.

This is an DEA on sales dataset. 

😎😎

(add emoji shortcut: window + '.')

# Table of content

- [Objective](#Objective)
- [Data source](#Data-source)
- [Data exploration in MySQL](#Data-exploration-in-MySQL)
    - [Data cleaning](#Data-cleaning)
    - [Data exploration](#Data-exploration)
- [Data visualization in Tableau](#Data-visualization-in-Tableau)
- [Data visualization in PowerBI](#Data-visualization-in-PowerBI)

# Objective

# Data source

# Data exploration in MySQL

## Data cleaning

```sql
/*
## Importing excel file to Workbench, however, the Order_Date and Shipping_Date are not correctly imported as date type.
 
## Add column order_date_modified
*/

alter table sales_non_eu.orders
add column order_date_modified date;

## Change Order_date from String type to Date type and add to new Order_date_modified column

UPDATE sales_non_eu.orders 
SET 
    order_date_modified = str_to_date(CONCAT(SUBSTRING(Order_Date, 1, 2),'/',
                    SUBSTRING(Order_Date, 4, 2),'/',
                    SUBSTRING(Order_Date, 7, 4)),
            '%d/%m/%Y')
WHERE
    order_ID <> 0

## Similarly, addi Shipping_date_modified column and convert String to Date type, and add the data to new shipping_date_modified column

alter table sales_non_eu.orders
add column Shipping_Date_modified date; 

UPDATE sales_non_eu.orders 
SET 
    Shipping_Date_modified = STR_TO_DATE(CONCAT(SUBSTRING(Shipping_Date, 1, 2),
                    '/',
                    SUBSTRING(Shipping_Date, 4, 2),
                    '/',
                    SUBSTRING(Shipping_Date, 7, 4)),
            '%d/%m/%Y')
WHERE
    Order_ID <> 0;

## Drop column order_date and shipping_date, change the name of new order_date_modified and shipping_date_modified to replace the original order_date and shippping_date column

alter table sales_non_eu.orders
drop column Order_Date;

alter table sales_non_eu.orders
change column order_date_modified Order_Date date;

alter table sales_non_eu.orders
drop column Shipping_Date;

alter table sales_non_eu.orders
change column Shipping_Date_modified Shipping_Date date;

;
```

## Data exploration

# Data visualization in Tableau

# Data visualization in PowerBI
