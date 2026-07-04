-- customers
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id   INTEGER PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(150),
    city          VARCHAR(80)
);
drop table customers;


-- ------------------------------------------------------------
-- products
-- ------------------------------------------------------------
CREATE TABLE products (
    product_id    INTEGER PRIMARY KEY,
    product_name  VARCHAR(120) NOT NULL,
    category      VARCHAR(60),
    price         NUMERIC(12,2)
);

-- ------------------------------------------------------------
-- orders  (customer_id NOT enforced as FK on purpose)
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER,          -- may be NULL or point to a non-existent customer
    order_date    DATE,
    total_amount  NUMERIC(12,2)
);

-- ------------------------------------------------------------
-- order_items (order_id / product_id NOT enforced as FK on purpose)
-- ------------------------------------------------------------
CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id      INTEGER,          -- may point to a non-existent order
    product_id    INTEGER,          -- may be NULL or point to a non-existent product
    quantity      INTEGER,
    unit_price    NUMERIC(12,2)
);

INSERT INTO customers (customer_id, name, email, city) VALUES
(1,  'Chinedu Okeke',      'chinedu.okeke@gmail.com',   'Lagos'),
(2,  'Amaka Eze',          'amaka.eze@yahoo.com',       'Enugu'),
(3,  'Tunde Bakare',       'tunde.bakare@gmail.com',    'Ibadan'),
(4,  'Ngozi Madu',         'ngozi.madu@outlook.com',    'Port Harcourt'),
(5,  'Ibrahim Sani',       'ibrahim.sani@gmail.com',    'Kano'),
(6,  'Funke Adeyemi',      'funke.adeyemi@gmail.com',   'Abeokuta'),
(7,  'Emeka Nwosu',        'emeka.nwosu@gmail.com',     'Onitsha'),
(8,  'Halima Bello',       'halima.bello@yahoo.com',    'Kaduna'),
-- customers 9 & 10 will have NO orders (for Q5)
(9,  'Olu Fadeyi',         'olu.fadeyi@gmail.com',      'Akure'),
(10, 'Zainab Yusuf',       'zainab.yusuf@gmail.com',    'Maiduguri');


INSERT INTO products (product_id, product_name, category, price) VALUES
(101, 'Tecno Spark 20',        'Electronics',   145000.00),
(102, 'Itel Power Bank 20000', 'Electronics',    18500.00),
(103, 'HP Pavilion Laptop',    'Electronics',   650000.00),
(104, 'Ankara Fabric (6 yds)', 'Fashion',        12000.00),
(105, 'Leather Sandals',       'Fashion',        15500.00),
(106, 'Golden Penny Semovita', 'Groceries',       8500.00),
(107, 'Peak Milk Tin (carton)','Groceries',      14000.00),
(108, 'Office Swivel Chair',   'Furniture',      45000.00),
-- products 109 & 110 will be NEVER ordered (for Q6)
(109, 'Standing Desk',         'Furniture',     120000.00),
(110, 'Ceramic Dinner Set',    'Home',           22000.00);

-- ---------------- orders ----------------
-- Valid orders (customer exists)
INSERT INTO orders (order_id, customer_id, order_date, total_amount) VALUES
(1001, 1, '2025-01-05', 163500.00),
(1002, 1, '2025-02-11', 650000.00),
(1003, 2, '2025-01-20',  27500.00),
(1004, 3, '2025-03-02', 145000.00),
(1005, 4, '2025-03-15',  22500.00),
(1006, 5, '2025-04-01',  59000.00),
(1007, 6, '2025-04-10',  14000.00),
(1008, 7, '2025-05-05',  31000.00),
(1009, 8, '2025-05-18',  45000.00),
-- INTENTIONAL ANOMALY: customer_id 999 does not exist (orphan order) — for Q3, Q4, Q7
(1010, 999, '2025-05-22', 18500.00),
-- INTENTIONAL ANOMALY: customer_id IS NULL (missing reference) — for Q3, Q4, Q7
(1011, NULL, '2025-05-25', 90000.00);

-- ---------------- order_items ----------------
-- Valid order_items (order + product both exist)
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1001, 101, 1, 145000.00),   -- Tecno Spark
(2, 1001, 102, 1,  18500.00),   -- Power Bank
(3, 1002, 103, 1, 650000.00),   -- HP Laptop
(4, 1003, 104, 1,  12000.00),   -- Ankara
(5, 1003, 105, 1,  15500.00),   -- Sandals
(6, 1004, 101, 1, 145000.00),   -- Tecno Spark
(7, 1005, 105, 1,  15500.00),   -- Sandals (Fashion) for Ngozi
(8, 1006, 108, 1,  45000.00),   -- Swivel Chair
(9, 1006, 102, 1,  18500.00),   -- Power Bank (NOTE qty/price create reconciliation diff for Q17)
(10,1007, 107, 1,  14000.00),   -- Peak Milk
(11,1008, 105, 2,  15500.00),   -- Sandals x2
(12,1009, 108, 1,  45000.00),   -- Swivel Chair
-- Electronics + other category for Chinedu (cust 1) already: order 1001 Electronics, need a non-Electronics too
(13,1002, 106, 2,   8500.00),   -- Semovita on order 1002 -> cust 1 now has Electronics + Groceries (Q18)
-- INTENTIONAL ANOMALY: order_id 8888 does not exist (orphan item) — for Q14, Q15
(14, 8888, 101, 1, 145000.00),
-- INTENTIONAL ANOMALY: product_id 7777 does not exist (invalid product) — for Q10, Q14, Q15
(15, 1004, 7777, 3, 10000.00),
-- INTENTIONAL ANOMALY: product_id IS NULL (missing product) — for Q10, Q14
(16, 1007, NULL, 1, 5000.00);

select * from customers 

select * from orders

select * from order_items

select * from products

-- Question 1: Customer Orders
-- List customer names along with their order IDs and order dates. 
-- Only include customers who have placed at least one order.

select c.name AS customer_name, o.order_id,o.order_date
from customers c
join orders o on c.customer_id=c.customer_id
order by c.name,o.order_date desc;

-- Question 2: Complete Customer List
-- Display all customers with their names and emails, 
-- and include any associated order ID and date if available, 
-- even if the customer hasn't placed any orders.
select c.name AS customer_name,c.email, o.order_id,o.order_date
from customers c
 left join orders o on c.customer_id=c.customer_id
order by c.name,o.order_date desc;

-- Question 3: Complete Order List
-- Show all orders with their IDs, dates, and total amounts,
-- alongside the customer name if the order references a valid customer. 
-- Include all orders even if the customer reference is invalid or missing.
select 
 o.order_id,
 o.order_date,
 c.name AS
 customer_name
from orders o
left join customers c 
 ON o.customer_id=c.customer_id
 order by o.order_date desc;
-- select * from orders limit 1

 -- Question 4: Complete Relationship View
-- Create a comprehensive view of customer-to-order relationships 
-- showing all customers and orders,
-- including customers without orders and orders without valid customer references
select c.name AS customer_name
,o.order_id,
o.order_date,
from customers c
    full outer join orders o on c.customer_id=o.customer_id
order by c.name,o.order_date desc;

-- Question 5: Customers Without Orders
-- Identify customers who have not placed any orders. 
-- Display their names, emails, and cities.
select
c.name,
c.email, 
c.city
from customers c
left join orders o
   on c.customer_id=o.customer_id
 where o.order_id is NULL

 -- Question 6: Products Never Ordered
-- Find products that have never been included in any order, 
-- showing product name, category, and price.
select p.product_name, p.category, p.price
 from products p
    left join order_items oi on p.product_id =oi.product_id
 where oi.order_id is NULL


-- Question 7: Orders Missing Customer Data
-- Retrieve orders that have invalid or missing customer references, 
-- including order ID, customer ID, order date, and total amount.
select o.order_id,o.customer_id,o.order_date,o.total_amount
from orders o
left join customers c on o.customer_id=c.customer_id
where c.customer_id is NULL
order by o.order_date desc;

-- Question 8: Valid Purchases Only
-- Show customer name, order date, 
-- and product name for all transactions where the customer, order, 
-- and product all exist. Exclude any orphaned or invalid records.
select c.name AS customer_name,o.order_date,p.product_name
from customers c
INNER JOIN orders o ON c.customer_id =o.customer_id
INNER JOIN order_items  oi ON o.order_id=oi.order_id
INNER JOIN products p ON oi.product_id=p.product_id
order by o.order_date desc,c.name;

-- Question 9: All Customers with Valid Products
-- Display all customers and their order info, 
-- but only include records with valid products.
-- Show customer name, order date, product name, and quantity.
select c.name AS customer_name,o.order_date,product_name,oi.quantity
from customers c
left join orders o ON c.customer_id=o.customer_id
left JOIN order_items  oi ON o.order_id=oi.order_id
left JOIN products p ON oi.product_id=p.product_id
order by c.name,o.order_date desc;

-- Question 10: Complete Order Details with Missing Data Handling
-- List customer name, order date, product name, category,
-- quantity, and unit price for all order items.
-- For orphaned or invalid references, substitute
-- "Unknown Customer" or "Unknown Product" accordingly.
select
coalesce(c.customer_name, 'Unknown customer') AS customer_name,
o.order_date,
coalesce(p.product_name,'Unknown customer') AS product_name,
p.category,
oi.quantity,
oi.unit_price
from order_items oi
left join orders o
    on oi.order_id=o.order_id
left join customers c
   on o.customer_id=c.customer_id
 left join products p
     on oi.product_id=p.product_id
-- select * from customers
select column_name
from information_schema.columns
where table_name='customers'

-- Question 11: Customer Order Statistics
-- For each customer, including those with no orders, show:
-- Customer name
-- Number of orders placed
-- Total amount spent
-- Use zero for customers without orders.

select 
c.customer_name
count(distinct o.order_id) AS number_of_orders,
coalesce(sum(oi.quantity * oi.unit_price),0) AS total_amount_spent
from customers c


-- Question 12: Product Sales Summary
-- Summarize sales for each product, including those never sold, with:
-- Product name and category
-- Total quantity sold (0 if none)
-- Total revenue generated (0 if none)
select 
p.product_name,
p.category,
coalesce (sum(oi.quantity), 0) as total_quantity_sold,
coalesce (sum(oi.quantity * oi. unit_price), 0) as total_revenue_generated
from products p
left join order_items oi
on p.product_id =oi.product_id
group by 
  p.product_id,
  p.product_name,
  p.category
  order by 
  p.product_name


-- Question 13: Category Performance Analysis
-- For each product category, identify:
-- Total number of products in the category
-- Number of products sold from that category
-- Number of unsold products from that category

select
category,
count(distinct product_name) total_products_per_category,
count(distinct quantity)total_products_sold_per_category,
count(distinct case
  when quantity is null then p.product_id
  end) total_products_unsold_per_category
from products p
 natural left join order_items oi
 group by category
 order by category

-- Question 14: Orphaned Records Report
-- Produce a report showing:
-- Number of orders without valid customers
-- Number of order items without valid orders
-- Number of order items without valid products

select
count(distinct o.order_id) filter(
  where c.customer_id is null
  ) orders_without_valid_customers,

count(distinct oi.order_item_id) filter(
     where o.order_id is null
	) order_item_without_valid_orders,

count(distinct oi.order_item_id) filter(
  where p.product_id is null
  ) order_items_without_valid_products
  from orders o
natural full join customers c
natural full join order_items oi
natural full join products p

-- Question 15: Complete Data Integrity Check
-- Create a combined report that labels all problematic relationships, such as:
-- Customers with no orders
-- Orders without customers
-- Products with no sales
-- Order items with invalid orders or products

select 'customer with no orders' as issue_type, count(*) as count 
from customers c
natural left join orders o
where o.customer_id is null

union all

select 'order without customers' as issue_type,count(*) as count
from orders o
natural left join customers c
where c.customer_id is null

union all

select 'products with no sales' as issue_type,count (*) as count
from products p
natural left join order_items oi
where oi.product_id is null

union all 

select 'order items with invalid orders' as issue_type,count(*) as count
from order_items oi
natural left join orders o
where o.order_id is null

union all

select 'order items with invalid products' as issue_type, count(*) as count
from order_items oi
natural left join products p
where p.product_id is null


-- Question 16: Customer Purchase Diversity
-- Find customers who have placed orders and, for each, determine:
-- Customer name
-- Count of distinct product categories purchased from
-- List of categories as a comma-separated string

select name,
count(distinct category) category_count,
string_agg(distinct category,',')categories
from customers
natural join orders
natural  join order_items
natural  join products
group by name
order by name

-- Question 17: Revenue Reconciliation
-- Compare each order's total amount (from the order table) with the sum of (quantity × unit_price) from
-- associated order items. Show order ID, stated total, calculated total, and 
-- the difference. Only include valid customer orders with at least one order item.

select
order_id,
total_amount,
sum(quantity * unit_price) calculated_total,
abs(total_amount-sum(quantity * unit_price)) difference
from orders
natural join order_items
natural  join products
group by order_id
order by order_id

-- Question 18: Complex Relationship Analysis
-- Identify customers who have:
-- Placed at least one order
-- Ordered products from the 'Electronics' category
-- Also ordered products from at least one other category
-- For qualifying customers, list their name and all categories they ordered from.

select 
customer_id,
name,
string_agg(distinct category,',')categories
from customers
natural join orders
natural  join order_items
natural  join products
group by customer_id, name
having

count (case when category='Electronics' then 1 end) > 0
and count (case when category <> 'Electronics'then 1 end)>0








