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
Importing excel file to Workbench, however, the Order_Date and Shipping_Date are not correctly imported as date type.
 
1. Add column order_date_modified
2. Change Order_date from String type to Date type and add to new Order_date_modified column
3. Drop column order_date, change the name of new order_date_modified to replace the original order_date.

*/

-- 1.

alter table sales_non_eu.orders
add column order_date_modified date;

-- 2. 

UPDATE sales_non_eu.orders 
SET 
    order_date_modified = str_to_date(CONCAT(SUBSTRING(Order_Date, 1, 2),'/',
                    SUBSTRING(Order_Date, 4, 2),'/',
                    SUBSTRING(Order_Date, 7, 4)),
            '%d/%m/%Y')
WHERE
    order_ID <> 0

-- 3.

alter table sales_non_eu.orders
drop column Order_Date;

alter table sales_non_eu.orders
change column order_date_modified Order_Date date;

/*
Do similarly for Shipping_date column

1. Add Shipping_date_modified column
2. Convert String to Date type, and add the data to new shipping_date_modified column
3. Drop column shipping_date, change the name of new shipping_date_modified to replace the original shippping_date column
*/

-- 1.

alter table sales_non_eu.orders
add column Shipping_Date_modified date; 

-- 2.

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

-- 3. 

alter table sales_non_eu.orders
drop column Shipping_Date;

alter table sales_non_eu.orders
change column Shipping_Date_modified Shipping_Date date;

;
```

## Data exploration

### 1. Sales and Profit by Country?

```sql

-- 1. Sales and Profit by Country

SELECT 
    c.Country,
    round(SUM(o.Sales), 2) AS total_sales,
    round(SUM(o.Profit),2) AS total_profit,
    concat(format(sum(o.Profit)/sum(o.Sales)*100,0),'%') as profit_margin_percentage
FROM
    sales_non_eu.orders o
        JOIN
    sales_non_eu.customers c ON o.Customer_ID = c.Customer_ID
GROUP BY Country
ORDER BY total_profit DESC
;

```

|Country|total_sales|total_profit|profit_margin_percentage|
|---    |---        |---         |---                     |
|Germany|  829066.72|	100477.25|                     12%|
|USA    |  904327.95|	    93866|                     10%|
|France |  918969.28|	 87871.23|                     10%|
|Italy  |  192105.24|	 20852.22|                     11%|

--> France is the market that generate highest sales, however Germany is the most profitable market, which generate the highest profit rate at 12%. Italy has smallest sales however ranked in 2nd in profit margin. 

### 2.  Sales & Profit by Category?

```sql
SELECT 
    p.Category,
    ROUND(SUM(o.Sales), 2) AS total_sales,
    ROUND(SUM(o.Profit), 2) AS total_profit,
    concat(round(sum(o.Profit)/sum(o.Sales)*100),'%') as profit_margin
FROM
    sales_non_eu.orders o
        JOIN
    sales_non_eu.products p ON o.Product_ID = p.Product_ID
        JOIN
    sales_non_eu.customers c ON o.Customer_ID = c.Customer_ID
GROUP BY 1 
ORDER BY total_sales desc
;
```
|Category| total_sales| total_profit| profit_margin|
|---|---|---|---|
|Furniture|	104222.25|	3515.62|	3%|
|Office| Supplies|	52840.15|	11446.79|	22%|
|Technology|	33519.78|	5545.85|	17%|


# Data visualization in Tableau

# Data visualization in PowerBI
