+-- ==================================
-- FILTERS & AGGREGATION
-- ==================================

USE coffeeshop_db;


-- Q1) Compute total items per order.
--     Return (order_id, total_items) from order_items.

SELECT
	order_id,
  SUM(quantity) AS total_items
FROM order_items
GROUP BY order_id;

-- Q2) Compute total items per order for PAID orders only.
--     Return (order_id, total_items). Hint: order_id IN (SELECT ... FROM orders WHERE status='paid').

SELECT
	order_id,
  SUM(quantity) as total_items
FROM order_items
WHERE order_id IN (    
	SELECT
		order_id
	FROM orders 
	WHERE status = 'paid'
)
GROUP BY order_id;

-- or this? reusable but nested WHERE IN feels like the logic 'flows' differently than how WITH AS feels when using it.

WITH all_paid_orders AS (
	SELECT
		order_id
	FROM orders
    WHERE status = 'paid'
)

SELECT
	order_items.order_id,
  SUM(order_items.quantity) AS total_items
FROM order_items
JOIN all_paid_orders ON order_items.order_id = all_paid_orders.order_id
GROUP BY order_items.order_id;

-- Q3) How many orders were placed per day (all statuses)?
--     Return (order_date, orders_count) from orders.

SELECT
	DATE(order_datetime) AS order_day,
    COUNT(order_id)
FROM orders
GROUP BY DATE(order_datetime);

-- Q4) What is the average number of items per PAID order?
--     Use a subquery or CTE over order_items filtered by order_id IN (...).

WITH all_paid_orders AS (
	SELECT
		order_id
	FROM orders
    WHERE status = 'paid'
)
SELECT
	order_items.order_id,
    AVG( order_items.quantity) AS average_items
FROM order_items
JOIN all_paid_orders ON order_items.order_id = all_paid_orders.order_id
GROUP BY order_items.order_id;

-- Q5) Which products (by product_id) have sold the most units overall across all stores?
--     Return (product_id, total_units), sorted desc.

SELECT
	product_id,
    COUNT(quantity) as total
FROM order_items
GROUP BY product_id;

-- Q6) Among PAID orders only, which product_ids have the most units sold?
--     Return (product_id, total_units_paid), sorted desc.
--     Hint: order_id IN (SELECT order_id FROM orders WHERE status='paid').
SELECT
	product_id,
    COUNT(quantity) as total
FROM order_items
WHERE product_id IN(
	SELECT
		order_id
	FROM orders 
    WHERE status = 'paid'
)
GROUP BY product_id;


-- Q7) For each store, how many UNIQUE customers have placed a PAID order?
--     Return (store_id, unique_customers) using only the orders table.

SELECT
	store_id,
  COUNT( DISTINCT customer_id ) u_customers
FROM orders
WHERE status = 'paid'
GROUP BY store_id;

-- Q8) Which day of week has the highest number of PAID orders?
--     Return (day_name, orders_count). Hint: DAYNAME(order_datetime). Return ties if any.
WITH OrdersPerWeekday AS (
	SELECT
		DAYNAME(order_datetime) AS day_name,
		COUNT(order_datetime) AS orders_count
	FROM orders	
	WHERE status = 'paid'
	GROUP BY day_name
)
SELECT
	day_name,
  orders_count
FROM OrdersPerWeekday
WHERE orders_count = (SELECT MAX(orders_count) FROM OrdersPerWeekday);


-- Q9) Show the calendar days whose total orders (any status) exceed 3.
--     Use HAVING. Return (order_date, orders_count).

WITH OrdersPerWeekday AS (
	SELECT
		DAYNAME(order_datetime) AS day_name,
		COUNT(order_datetime) AS orders_count
	FROM orders	
	GROUP BY day_name
)
SELECT
	day_name,
    orders_count
FROM OrdersPerWeekday
WHERE orders_count > 3;

-- Q10) Per store, list payment_method and the number of PAID orders.
--      Return (store_id, payment_method, paid_orders_count).
WITH PaidOrdersPerStore AS (
	SELECT
		store_id,
    payment_method,
    COUNT(order_id) AS order_count
	FROM orders
    WHERE status = 'paid'
    GROUP BY store_id, payment_method
)
SELECT
	store_id,
  payment_method,
  order_count
FROM PaidOrdersPerStore;


-- Q11) Among PAID orders, what percent used 'app' as the payment_method?
--      Return a single row with pct_app_paid_orders (0–100).

SELECT
	SUM(
		CASE WHEN payment_method = 'app' THEN 1 ELSE 0 END
  ) / COUNT(*) * 100 AS pct_app_orders_paid
FROM orders
WHERE status = 'paid';

-- Q12) Busiest hour: for PAID orders, show (hour_of_day, orders_count) sorted desc.
WITH PaidOrdersHourly AS (
	SELECT
		HOUR( order_datetime ) AS hour_of_day,
    COUNT(*) AS orders_count
	FROM orders
    WHERE status = 'paid'
    GROUP BY hour_of_day
)
SELECT
	hour_of_day,
  orders_count
FROM PaidOrdersHourly
ORDER By orders_count DESC;

-- ================
