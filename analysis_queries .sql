CREATE DATABASE retail_analysis;
USE retail_analysis;
DROP TABLE sales;
CREATE TABLE sales (
    row_id INT,
    order_id VARCHAR(20),
    order_date VARCHAR(20),
    ship_date VARCHAR(20),
    ship_mode VARCHAR(20),

    customer_id VARCHAR(20),
    customer_name VARCHAR(50),
    segment VARCHAR(20),

    country VARCHAR(30),
    city VARCHAR(30),
    state VARCHAR(30),
    postal_code VARCHAR(10),
    region VARCHAR(20),

    product_id VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(30),
    product_name VARCHAR(100),

    sales DECIMAL(10,4)
);
DESCRIBE sales;

ALTER TABLE sales
ADD order_date_new DATE,
ADD ship_date_new DATE;

ALTER TABLE sales
ADD order_date_new DATE,
ADD ship_date_new DATE;

ALTER TABLE sales
DROP COLUMN order_date,
DROP COLUMN ship_date;

ALTER TABLE sales
CHANGE order_date_new order_date DATE,
CHANGE ship_date_new ship_date DATE;



SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
DESCRIBE sales;


TRUNCATE TABLE sales;
LOAD DATA LOCAL INFILE "C:\DataAnalytics\Retail_sales_Analysis\data\cleaned_data.csv"
INTO TABLE sales
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM sales;
SELECT product_name, sales FROM sales LIMIT 5;

SELECT COUNT(*) AS total_records
FROM sales;

SELECT 
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order
FROM sales;

--  Total sales
SELECT 
    ROUND(SUM(sales), 2) AS total_sales
FROM sales;

-- Monthly sales order 
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    ROUND(SUM(sales), 2) AS monthly_sales
FROM sales
GROUP BY order_month
ORDER BY order_month;
-- Sales by Category 
SELECT 
    category,
    SUM(sales) AS category_sales
FROM sales
GROUP BY category
ORDER BY category_sales DESC;

-- Sales by Sub-Category 
SELECT 
    sub_category,
    SUM(sales ) AS total_sales
FROM sales
GROUP BY sub_category
ORDER BY total_sales DESC;

-- Sales by Region
SELECT 
    region,
    ROUND(SUM(sales), 2) AS total_sales
FROM sales
GROUP BY region
ORDER BY total_sales DESC;

-- top states by sales 
SELECT 
    state,
    ROUND(SUM(sales), 2) AS total_sales
FROM sales
GROUP BY state
ORDER BY total_sales DESC
LIMIT 10;

-- Customer Segment Analysis
SELECT 
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(DISTINCT customer_id) AS total_customers
FROM sales
GROUP BY segment
ORDER BY total_sales DESC;


-- total sales on yearly basis  
SELECT 
    YEAR(order_date) AS order_year,
    ROUND(SUM(sales), 2) AS total_sales
FROM sales
GROUP BY order_year
ORDER BY order_year;

-- Average shipping days 
SELECT 
    ship_mode,
    AVG(DATEDIFF(ship_date, order_date)) AS avg_shipping_days
FROM sales
GROUP BY ship_mode
ORDER BY avg_shipping_days;

--  Top Customers by Total Sales
SELECT customer_name,
       SUM(sales) AS total_sales
FROM sales
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 10;

-- Top Products by Total Sales
SELECT product_name,
       SUM(sales) AS total_sales
FROM sales
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

-- Average Shipping Time by Ship Mode 
SELECT ship_mode,
       AVG(DATEDIFF(ship_date, order_date)) AS avg_shipping_days
FROM sales
WHERE ship_mode IS NOT NULL AND order_date IS NOT NULL AND ship_date IS NOT NULL
GROUP BY ship_mode
ORDER BY avg_shipping_days;

-- Monthly Sales and Growth
SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month,
       SUM(sales) AS monthly_sales
FROM sales
WHERE order_date IS NOT NULL
GROUP BY order_month
ORDER BY order_month;

-- Month-over-Month Growth
SELECT order_month,
       monthly_sales,
       (monthly_sales - LAG(monthly_sales) OVER (ORDER BY order_month)) /
       LAG(monthly_sales) OVER (ORDER BY order_month) * 100 AS growth_pct
FROM (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month,
           SUM(sales) AS monthly_sales
    FROM sales
    WHERE order_date IS NOT NULL
    GROUP BY order_month
) AS monthly_data
ORDER BY order_month

-- Average Order Value (AOV)
SELECT  ROUND(SUM(sales)/COUNT(DISTINCT order_id),2) AS avg_order_value
FROM sales
WHERE order_date IS NOT NULL;

-- Total Orders per Customer
SELECT customer_name,
       COUNT(order_id) AS total_orders
FROM sales
GROUP BY customer_name
ORDER BY total_orders DESC
LIMIT 10;

-- Total Sales per Year
SELECT YEAR(order_date) AS order_year,
       SUM(sales) AS total_sales
FROM sales
WHERE order_date IS NOT NULL
GROUP BY order_year
ORDER BY order_year;

-- Year-over-Year Growth
SELECT
    YEAR(order_date) AS order_year,
    SUM(sales) AS total_sales,
    (SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date))) /
    LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date)) * 100 AS yoy_growth_pct
FROM sales
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- Sales Contribution %
SELECT
    category,
    SUM(sales) AS category_sales,
    ROUND(SUM(sales)/ (SELECT SUM(sales) FROM sales) * 100, 2) AS sales_contribution_pct
FROM sales
GROUP BY category
ORDER BY sales_contribution_pct DESC;

-- Shipping Delay Analysis
SELECT
    ship_mode,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 2) AS avg_shipping_days,
    SUM(CASE WHEN DATEDIFF(ship_date, order_date) > 5 THEN 1 ELSE 0 END) AS delayed_orders
FROM sales
WHERE order_date IS NOT NULL AND ship_date IS NOT NULL
GROUP BY ship_mode
ORDER BY avg_shipping_days;
 

