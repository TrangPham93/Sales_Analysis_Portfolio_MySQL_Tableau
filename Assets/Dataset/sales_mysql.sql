### Importing excel file to Workbench, however, the Order_Date and Shipping_Date are not correctly imported as date type.
 
## Add column order_date

alter table sales_non_eu.orders
add column order_date_modified date;

## Change Order_date from string to Date and add to new Order_date column

UPDATE sales_non_eu.orders 
SET 
    order_date_modified = str_to_date(CONCAT(SUBSTRING(Order_Date, 1, 2),'/',
                    SUBSTRING(Order_Date, 4, 2),'/',
                    SUBSTRING(Order_Date, 7, 4)),
            '%d/%m/%Y')
WHERE
    order_ID <> 0

;

## Similar add new shipping date column and convert string to date and add the data to new shipping_date column

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

## Drop column order_data and shipping date, change the name of new order date and shipping date

alter table sales_non_eu.orders
drop column Order_Date;

alter table sales_non_eu.orders
change column order_date_modified Order_Date date;

alter table sales_non_eu.orders
drop column Shipping_Date;

alter table sales_non_eu.orders
change column Shipping_Date_modified Shipping_Date date;

##


SELECT 
    *
FROM
    sales_non_eu.orders;
    





### create a join table for all 3 tables

SELECT 
    o.Order_ID,
    o.Sales,
    o.Quantity,
    o.unit_price,
    o.Discount,
    o.Profit,
    o.Order_Date,
    o.Shipping_Date,
    o.Product_ID,
    p.Product_Name,
    p.Category,
    p.Sub_Category,
    o.Customer_ID,
    c.City,
    c.Country,
    c.Score
FROM
    sales_non_eu.orders o
        JOIN
    sales_non_eu.products p ON o.Product_ID = p.Product_ID
        JOIN
    sales_non_eu.customers c ON o.Customer_ID = c.Customer_ID
ORDER BY Profit DESC
;

## Sales group by Category and country
-- WHERE clause cannot be used after GROUP BY function, WHERE clause performs on the whole table before GROUP BY, 
-- so the alias name for aggregation function is not ready for use yet. 
-- HAVING is performed after GROUP BY, so alias name for aggregation can be called in HAVING
-- WHERE doesn' allow aggregation withing clause, HAVING allows. 

SELECT 
    p.Category,
    p.Sub_Category,
    c.Country,
    #c.City,
    round(SUM(o.Sales),2) as total_sales,
    SUM(o.Quantity) as total_quantity,
    round(SUM(o.Discount),2) as total_discount,
    round(SUM(o.Profit),2) as total_profit,
    round(avg(o.Unit_Price),2) as avg_unit_price
FROM
    sales_non_eu.orders o
        JOIN
    sales_non_eu.products p ON o.Product_ID = p.Product_ID
        JOIN
    sales_non_eu.customers c ON o.Customer_ID = c.Customer_ID
#where (o.Sales) >1000
GROUP BY p.Category , p.Sub_Category , c.Country 
having avg_unit_price>10
order by 1,3
;


## Exploratory Data Analysis

-- 1. Sales and Profit by Country

SELECT 
    c.Country,
    ROUND(SUM(o.Sales), 2) AS total_sales,
    ROUND(SUM(o.Profit), 2) AS total_profit
FROM
    sales_non_eu.orders o
        JOIN
    sales_non_eu.customers c ON o.Customer_ID = c.Customer_ID
GROUP BY Country
ORDER BY total_profit DESC
;

-- 2. Sales & Profit by Category: 

SELECT 
    p.Category,
    p.Sub_Category,
    ROUND(SUM(o.Sales), 2) AS total_sales,
    ROUND(SUM(o.Profit), 2) AS total_profit
FROM
    sales_non_eu.orders o
        JOIN
    sales_non_eu.products p ON o.Product_ID = p.Product_ID
        JOIN
    sales_non_eu.customers c ON o.Customer_ID = c.Customer_ID
GROUP BY 1 , 2
ORDER BY total_profit ASC
;


-- Tables has 18k of sales but produce no profit at all. 
SELECT 
    p.Category,
    p.Sub_Category,
    ROUND(SUM(o.Sales), 2) AS total_sales,
    ROUND(SUM(o.Profit), 2) AS total_profit
FROM
    sales_non_eu.orders o
        JOIN
    sales_non_eu.products p ON o.Product_ID = p.Product_ID
        JOIN
    sales_non_eu.customers c ON o.Customer_ID = c.Customer_ID
GROUP BY 1 , 2
HAVING total_profit < 0
ORDER BY total_profit ASC
;

-- In 3 of 4 countries, Office Supplies generates the highest profit. 

SELECT 
    p.Category,
    c.Country,
    ROUND(SUM(o.Sales), 2) AS total_sales,
    ROUND(SUM(o.Profit), 2) AS total_profit
FROM
    sales_non_eu.orders o
        JOIN
    sales_non_eu.products p ON o.Product_ID = p.Product_ID
        JOIN
    sales_non_eu.customers c ON o.Customer_ID = c.Customer_ID
GROUP BY 1 , 2
;

-- Highest Sales by Order, Product during period

SELECT 
    o.Order_ID,
    o.Sales,
    o.Quantity,
    o.Discount,
    o.Profit,
    o.Order_Date,
    o.Shipping_Date,
    o.Product_ID,
    p.Product_Name,
    p.Category,
    p.Sub_Category,
    c.Country,
    c.City,
    c.Score
FROM
    sales_non_eu.orders o
        JOIN
    sales_non_eu.products p ON o.Product_ID = p.Product_ID
        JOIN
    sales_non_eu.customers c ON o.Customer_ID = c.Customer_ID
GROUP BY 1 , 2
HAVING order_date between '2022-01-01' and '2023-01-01'
ORDER BY o.sales DESC
LIMIT 5
;

-- Products with negative profit

SELECT 
    o.Product_ID,
    p.Product_Name,
    SUM(o.Profit) AS profit,
    COUNT(*) AS product_amount
FROM
    sales_non_eu.orders o
        JOIN
    sales_non_eu.products p ON o.Product_ID = p.Product_ID
        JOIN
    sales_non_eu.customers c ON o.Customer_ID = c.Customer_ID
WHERE
    o.Profit < 0
GROUP BY 1 , 2
ORDER BY profit ASC
;


-- top selling product in each category
with RankedProducts as
(SELECT 
    p.Category,
    p.Product_Name, 
    SUM(o.Quantity) AS sold_quantity,
    RANK() over (partition by p.category order by sum(o.quantity) desc ) as product_rank
    
FROM
    sales_non_eu.orders o
        JOIN
    sales_non_eu.products p ON o.Product_ID = p.Product_ID
        JOIN
    sales_non_eu.customers c ON o.Customer_ID = c.Customer_ID
GROUP BY 1,2
order by sold_quantity desc)
SELECT 
    Category,
    Product_Name,
    sold_quantity
FROM
    RankedProducts
WHERE
    product_rank = 1
;



-- 3. Highest Sales by Order Year

SELECT 
    o.Order_ID,
    o.Sales,
    o.Quantity,
    o.Discount,
    o.Profit,
    o.Order_Date,
    o.Shipping_Date,
    o.Product_ID,
    p.Product_Name,
    p.Category,
    p.Sub_Category,
    c.Country,
    c.City,
    c.Score
FROM
    sales_non_eu.orders o
        JOIN
    sales_non_eu.products p ON o.Product_ID = p.Product_ID
        JOIN
    sales_non_eu.customers c ON o.Customer_ID = c.Customer_ID
GROUP BY 1 , 2
HAVING order_date > '2022-01-01'
ORDER BY o.sales DESC
LIMIT 5
;

-- 4. Distribution of customers by country

SELECT 
    Country,
    city,
    ROUND(AVG(score)) AS Average_score,
    COUNT(*) AS Customer_count,
    ROUND(COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    sales_non_eu.customers) * 100) AS Percentage
FROM
    sales_non_eu.customers
GROUP BY Country , city
ORDER BY customer_count DESC
;

-- 5. Distribution of customers by score
SELECT 
    MIN(score), MAX(Score)
FROM
    sales_non_eu.customers;
    
SELECT 
    CASE
        WHEN score < 20 THEN '<20'
        WHEN score BETWEEN 20 AND 39 THEN '20-39'
        WHEN score BETWEEN 40 AND 59 THEN '40-59'
        WHEN score BETWEEN 60 AND 79 THEN '60-79'
        ELSE '>=80'
    END AS score_group,
    COUNT(*) AS customer_count
FROM
    sales_non_eu.customers
GROUP BY score_group
;