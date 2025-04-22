-- Create a New Database
CREATE DATABASE IF NOT EXISTS ecommerce_insights;
USE ecommerce_insights;

-- Customers Table
CREATE TABLE IF NOT EXISTS customer_info (
    cust_id INT AUTO_INCREMENT PRIMARY KEY,
    cust_name VARCHAR(100),
    cust_email VARCHAR(100),
    cust_city VARCHAR(100),
    reg_date DATE
);

-- Products Table
CREATE TABLE IF NOT EXISTS product_catalog (
    prod_id INT AUTO_INCREMENT PRIMARY KEY,
    prod_name VARCHAR(200),
    prod_category VARCHAR(100),
    prod_price DECIMAL(10,2)
);

-- Sales Table
CREATE TABLE IF NOT EXISTS sales_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    cust_id INT,
    prod_id INT,
    trans_date DATE,
    prod_quantity INT,
    sale_amount DECIMAL(10,2),
    FOREIGN KEY (cust_id) REFERENCES customer_info(cust_id),
    FOREIGN KEY (prod_id) REFERENCES product_catalog(prod_id)
);

-- Insert Updated Customer Data
INSERT INTO customer_info (cust_name, cust_email, cust_city, reg_date) VALUES
('Keshav Kumar', 'keshav.kumar@example.com', 'New York', '2023-01-15'),
('Jahnavi Raj', 'jahnavi.raj@example.com', 'Los Angeles', '2023-02-20'),
('Rama Chandra', 'rama.chandra@example.com', 'Chicago', '2023-03-10');

-- Insert Product Data
INSERT INTO product_catalog (prod_name, prod_category, prod_price) VALUES
('Laptop', 'Electronics', 1200.00),
('Smartphone', 'Electronics', 800.00),
('Headphones', 'Electronics', 150.00),
('Running Shoes', 'Sportswear', 120.00);

-- Insert Sales Transactions
INSERT INTO sales_transactions (cust_id, prod_id, trans_date, prod_quantity, sale_amount) VALUES
(1, 1, '2023-04-01', 1, 1200.00),
(1, 3, '2023-04-01', 2, 300.00),
(2, 2, '2023-04-15', 1, 800.00),
(3, 4, '2023-04-20', 1, 120.00),
(1, 2, '2023-05-05', 1, 800.00);

-- --------------------------------------
-- Analysis Queries
-- --------------------------------------

-- 1. Category-Wise Total Sales Overview
WITH category_sales AS (
    SELECT 
        pc.prod_category AS category,
        COUNT(st.transaction_id) AS sales_count,
        SUM(st.sale_amount) AS total_revenue,
        ROUND(AVG(st.sale_amount), 2) AS avg_sale_value
    FROM sales_transactions st
    INNER JOIN product_catalog pc ON st.prod_id = pc.prod_id
    GROUP BY pc.prod_category
)
SELECT * FROM category_sales
ORDER BY total_revenue DESC;

-- 2. Customer Purchase Patterns
SELECT 
    ci.cust_name AS customer_name,
    COUNT(st.transaction_id) AS purchases_made,
    FORMAT(SUM(st.sale_amount), 2) AS total_spent_usd,
    MAX(st.trans_date) AS latest_purchase
FROM customer_info ci
LEFT JOIN sales_transactions st ON ci.cust_id = st.cust_id
GROUP BY ci.cust_id
ORDER BY total_spent_usd DESC;

-- 3. Monthly Revenue and Sales Analysis
SELECT 
    EXTRACT(YEAR FROM trans_date) AS year_of_sale,
    LPAD(EXTRACT(MONTH FROM trans_date), 2, '0') AS month_of_sale,
    COUNT(transaction_id) AS total_sales,
    ROUND(SUM(sale_amount), 2) AS revenue_generated
FROM sales_transactions
GROUP BY year_of_sale, month_of_sale
ORDER BY year_of_sale, month_of_sale;

-- 4. Best Selling Products Report
SELECT 
    pc.prod_name AS product_name,
    SUM(st.prod_quantity) AS quantity_sold,
    FORMAT(SUM(st.sale_amount), 2) AS revenue_collected
FROM sales_transactions st
JOIN product_catalog pc ON st.prod_id = pc.prod_id
GROUP BY pc.prod_id
ORDER BY quantity_sold DESC;

-- 5. Highest Spending Customer
SELECT 
    ci.cust_name AS customer_name,
    SUM(st.sale_amount) AS total_spent
FROM customer_info ci
JOIN sales_transactions st ON ci.cust_id = st.cust_id
GROUP BY ci.cust_name
ORDER BY total_spent DESC
LIMIT 1;

-- 6. Most Popular Product Category
SELECT 
    pc.prod_category AS category,
    COUNT(st.transaction_id) AS times_sold
FROM product_catalog pc
JOIN sales_transactions st ON pc.prod_id = st.prod_id
GROUP BY pc.prod_category
ORDER BY times_sold DESC
LIMIT 1;

-- 7. Average Purchase Value Per Customer
SELECT 
    ci.cust_name,
    ROUND(SUM(st.sale_amount) / COUNT(st.transaction_id), 2) AS avg_purchase_value
FROM customer_info ci
JOIN sales_transactions st ON ci.cust_id = st.cust_id
GROUP BY ci.cust_id
ORDER BY avg_purchase_value DESC;

-- 8. Repeat Customers vs. One-Time Customers
SELECT 
    CASE 
        WHEN COUNT(st.transaction_id) > 1 THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS customer_type,
    COUNT(DISTINCT ci.cust_id) AS customer_count
FROM customer_info ci
LEFT JOIN sales_transactions st ON ci.cust_id = st.cust_id
GROUP BY customer_type;

-- 9. Revenue Contribution by Each City
SELECT 
    ci.cust_city,
    ROUND(SUM(st.sale_amount), 2) AS city_revenue
FROM customer_info ci
JOIN sales_transactions st ON ci.cust_id = st.cust_id
GROUP BY ci.cust_city
ORDER BY city_revenue DESC;
