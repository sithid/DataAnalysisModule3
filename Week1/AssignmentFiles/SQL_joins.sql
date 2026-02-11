USE coffeeshop_db;

-- =========================================================
-- JOINS & RELATIONSHIPS PRACTICE
-- =========================================================

-- Q1) Join products to categories: list product_name, category_name, price.

SELECT
	products.name,
    categories.name,
    products.price
FROM products
JOIN categories ON products.category_id = categories.category_id
GROUP BY categories.name, products.name;
	
-- Q2) For each order item, show: order_id, order_datetime, store_name,
--     product_name, quantity, line_total (= quantity * products.price).
--     Sort by order_datetime, then order_id.

-- todo: 
--   join tables: order_items, orders, stores, products
--   return: order_id, order_datetime, store_name, product_name, quantity, line_total ( quantity * products.price )
--   sort by: order_datetime, order_id
SELECT
	orders.order_id,
    orders.order_datetime,
    stores.name,
    products.name,
    order_items.quantity,
    ( order_items.quantity * products.price ) AS line_total
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
JOIN products ON order_items.product_id = products.product_id
JOIN stores on orders.store_id = stores.store_id
ORDER BY order_datetime, order_id;

-- Q3) Customer order history (PAID only):
--     For each order, show customer_name, store_name, order_datetime,
--     order_total (= SUM(quantity * products.price) per order).

-- todo:
--   orders x 
--   return
--   	customers.first_name
--	 	stores.name 
--	 	orders.order_datetime,
--		order_total = SUM( order_items.quantity * products.price ) as order_total
-- 	 group: order_id
--   questions: do they want first_name, last_name, or concated first_name + last_name

SELECT
	CONCAT( customers.first_name, ' ', customers.last_name ) AS customer_name,
    stores.name,
    orders.order_datetime,
    SUM( order_items.quantity * products.price ) AS order_total
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
JOIN customers ON orders.customer_id = customers.customer_id
JOIN stores ON orders.store_id = stores.store_id
JOIN products ON order_items.product_id = products.product_id
WHERE orders.status = 'paid'
GROUP BY orders.order_id, orders.order_datetime, CONCAT( customers.first_name, ' ', customers.last_name ), stores.name;
	

-- Q4) Left join to find customers who have never placed an order.
--     Return first_name, last_name, city, state.
-- todo:
-- 	return:
--		customers.first_name,
--      customers.last_name,
--      customers.city,
--      customers.state
-- condition: never placed an order

SELECT
	customers.first_name,
    customers.last_name,
    customers.city,
    customers.state
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE orders.order_id IS NULL;

-- Q5) For each store, list the top-selling product by units (PAID only).
--     Return store_name, product_name, total_units.
--     Hint: Use a window function (ROW_NUMBER PARTITION BY store) or a correlated subquery.
--     
--	   todo:
--          returns: stores.name, products.name, SUM(order_items.quantity) AS total
--            logic: my brain hurts...
--			 tables: stores, order_items, products, orders
--  	aggregation: total units sold for every product at every store
--		   GROUP BY: stores.name, products.name

WITH ProductSales AS (
	SELECT
		stores.name AS store_name,
		products.name AS product_name,
		SUM(order_items.quantity) AS units,
        ROW_NUMBER() OVER(
			PARTITION BY stores.name
            ORDER BY SUM(order_items.quantity) DESC
		) AS rank_id
	FROM orders
	JOIN order_items ON orders.order_id = order_items.order_id
	JOIN stores ON orders.store_id = stores.store_id
	JOIN products ON order_items.product_id = products.product_id
	WHERE status = 'paid'
	GROUP BY stores.name, products.name
)
SELECT store_name, product_name, units
FROM ProductSales
WHERE rank_id = 1;

-- Q6) Inventory check: show rows where on_hand < 12 in any store.
--     Return store_name, product_name, on_hand.
--  tables: stores, products, inventory
--  return: stores.name, products.name, on_hand
--  condition: on_hand < 12
--  notes: alias stores.name and products.name to avoid confusion

SELECT
	stores.name AS store_name,
    products.name AS product_name,
    inventory.on_hand AS on_hand
FROM inventory
JOIN stores ON inventory.store_id = stores.store_id
JOIN products ON inventory.product_id = products.product_id
WHERE on_hand < 12;

-- Q7) Manager roster: list each store's manager_name and hire_date.
--     (Assume title = 'Manager').
-- todo:
-- return: 
-- 	CONCAT(employees.first_name, ' ', employees.last_name ) AS manager_name
--  hire_date
--  store_name

WITH ManagerInfo AS (
	SELECT
		CONCAT( employees.first_name, ' ', employees.last_name ) AS manager_name,
		employees.hire_date AS hire_date,
		stores.name AS store_name
	FROM employees
    JOIN stores ON employees.store_id = stores.store_id
    WHERE title = 'Manager'
)
SELECT
	manager_name,
    hire_date,
    store_name
FROM ManagerInfo;


-- Q8) Using a subquery/CTE: list products whose total PAID revenue is above
--     the average PAID product revenue. Return product_name, total_revenue.
--  CTE
--  WITH ProductRevenue AS (
--	  SELECT
--		  products.name AS product_name,
--	  SUM(order_items.quantity * products.price) AS total_revenue
--	  FROM products
--      JOIN order_items ON products.product_id = order_items.product_id
--      GROUP BY product_name
--  )

WITH ProductRevenue AS (
  SELECT
	products.name AS product_name,
    SUM(order_items.quantity * products.price) AS total_revenue
  FROM products
  JOIN order_items ON products.product_id = order_items.product_id
  JOIN orders ON order_items.order_id = orders.order_id
  WHERE status = 'paid'
  GROUP BY product_name
)
SELECT
	product_name,
    total_revenue,
    (SELECT AVG(total_revenue) FROM ProductRevenue) AS avg_revenue
FROM ProductRevenue
WHERE total_revenue > (
	SELECT 
		AVG(total_revenue)
    FROM ProductRevenue
)
ORDER BY total_revenue DESC;



-- Q9) Churn-ish check: list customers with their last PAID order date.
--     If they have no PAID orders, show NULL.
--     Hint: Put the status filter in the LEFT JOIN's ON clause to preserve non-buyer rows.

-- Q10) Product mix report (PAID only):
--     For each store and category, show total units and total revenue (= SUM(quantity * products.price)).
