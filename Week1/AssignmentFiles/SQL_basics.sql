USE coffeeshop_db;

-- =========================================================
-- BASICS PRACTICE
-- Instructions: Answer each prompt by writing a SELECT query
-- directly below it. Keep your work; you'll submit this file.
-- =========================================================

-- Q1) List all products (show product name and price), sorted by price descending.
SELECT name, price from products
order by price desc;

-- Q2) Show all customers who live in the city of 'Lihue'.
SELECT * FROM customers
WHERE city = 'Lihue';

-- Q3) Return the first 5 orders by earliest order_datetime (order_id, order_datetime).

select * 
from orders
order by order_datetime asc
limit 5;

-- Q4) Find all products with the word 'Latte' in the name.

SELECT *
FROM products
WHERE name LIKE '%latte%';

-- Q5) Show distinct payment methods used in the dataset.

SELECT payment_method, COUNT(*)
from orders
group by payment_method;

-- Q6) For each store, list its name and city/state (one row per store).

select name, city, state
from stores;

-- Q7) From orders, show order_id, status, and a computed column total_items
--     that counts how many items are in each order.

SELECT 
    orders.order_id, 
    orders.status, 
    SUM(order_items.quantity) AS total_items
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
GROUP BY orders.order_id, orders.status;

-- Q8) Show orders placed on '2025-09-04' (any time that day).

SELECT orders.order_datetime
FROM orders 
WHERE orders.order_datetime LIKE '2025-09-04%';

-- Q9) Return the top 3 most expensive products (price, name).

SELECT
    products.name,
	products.price
FROM products
ORDER BY price DESC
LIMIT 3;

-- Q10) Show customer full names as a single column 'customer_name'
--      in the format "Last, First".
SELECT concat(last_name, ', ', first_name) AS customer_name
FROM customers;
