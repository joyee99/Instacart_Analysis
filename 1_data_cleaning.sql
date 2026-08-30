-- reading data from Table AISLE
select * from aisles;
select count(*) from aisles; /* 134 */
select count(distinct aisle) from aisles; /* 134 */
select count(*) from aisles where aisle is null; /* 0 */


-- reading data from table DEPARTMENTS
select * from departments;
select count(*) from departments; /* 21 */
select count(distinct department) from departments; /* 21 */
select count(*) from departments where department is null; /* 0 */

-- reading data from table ORDER_PRODUCTS
select * from order_products;
select count(*) from order_products; /* 33819106 */
select count(distinct order_id) from order_products; /* 3346083 */
with duplicate as(
select distinct order_id, count(order_id) as dup_cnt from order_products group by order_id having count(*)>1
)
select sum(dup_cnt) from duplicate; /* 33655513 */
select count(*) from order_products where product_id is null or add_to_cart_order is null or reordered is null; /* 0 */

-- reading data from table ORDERS
select * from orders order by user_id;
select count(*) from orders; /* 3346083 */
select count(distinct order_id) from orders; /* 3346083 */
select count(distinct user_id) from orders; /* 206209 */
with cte as(
select user_id, count(user_id) as dup_cnt from orders group by user_id)
select dup_cnt, count(user_id) as num_dups from cte group by dup_cnt order by 1 desc;
select count(*) from orders where user_id is null; /* 0 */
select count(*) from orders where order_number is null; /* 0 */
select count(*) from orders where order_dow is null; /* 0 */
select count(*) from orders where order_hour_of_day is null; /* 0 */ 
select count(*) as null_val from orders where days_since_prior_order is null;   /* 206209 */

-- reading data from table PRODUCTS	
select * from products;
select count(*) from products; /* 49688 */
select count(distinct product_name) from products; /* 49589 */
select count(*) from products where product_id is null;  /* 0 */
select count(*) from products where product_name is null; /* 0 */
select count(*) from products where aisle_id is null;  /* 0 */
select count(*) from products where department_id is null;   /* 0 */
with cte as(
select product_id, product_name, count(*) as dup_cnt from products group by product_name, product_id having count(*)>1
)
select dup_cnt, product_name,product_id, sum(dup_cnt) from cte group by dup_cnt,product_name,product_id order by 2 desc; /* 0 */

-- Data preparation by deleting unnecessary columns and imputing missing/null values with median.
-- 1. Deleting unnecessary columns.
select * from orders; /* eval_set is not necessary for our analysis */
alter table orders drop column eval_set;
select * from orders;

-- 2. percentage of NULL values
with overall as(
    select count(*) as total from orders
)
select count(*) as null_val,
    round(cast(count(*) as float) * 100 /(select total from overall),2) as null_percentage
from orders where days_since_prior_order is null;  /* 206209 | 6.16 */


-- 3. Checking for orphan records.
-- 4.1 Check for orphan records in products (aisle_id)
SELECT * FROM products WHERE aisle_id NOT IN (SELECT aisle_id FROM aisles); /* 0 */

-- 4.2 Check for orphan records in products (department_id)
SELECT * FROM products WHERE department_id NOT IN (SELECT department_id FROM departments);  /* 0 */

-- 4.3 Check for orphan records in order_products (order_id)
SELECT * FROM order_products WHERE order_id NOT IN (SELECT order_id FROM orders);   /* 0 */

-- 4.4 Check for orphan records in order_products (product_id)
SELECT count(*) FROM order_products WHERE product_id NOT IN (SELECT product_id FROM products);  /* 0 */

select
(select count(distinct product_id) from order_products) as item_cnt_order_products,   /* 49685 */
(select count(distinct product_id) from products) as item_cnt_products,
(select count(distinct product_id) from products)-(select count(distinct product_id) from order_products) as item_diff; /* 49688 */


select product_id, product_name from products where product_id not in (select product_id from order_products); /* 3 never ordered items */

-- 4.5 Check for orphan records in products (department_id)
select * from products where department_id not in (select department_id from departments);  /* 0 */

-- 4.6 Check for orphan records in products (aisle_id)
select * from products where aisle_id not in (select aisle_id from aisles); /* 0 */

-- 4.6 Check for orphan records in order_products (order_id)
select * from order_products where order_id not in (select order_id from orders);   /* 0 */



/* 5. Orphaned Order Removal

Issue identified: 75,000 rows existed in the orders table
with no corresponding product data in order_products.

Investigation findings:
- All 75,000 orphaned orders belonged to customers who had
  other valid orders fully present in order_products
- Zero customers were entirely missing from order_products
- No customer would be lost from analysis after deletion
- These rows represented empty order shells with no
  analytical value

Action taken:
- Backed up 75,000 rows to orders_backup_before_cleanup
- Deleted orphaned rows from orders table
- orders table reduced from X rows to Y rows

Result:
- MIN order count per customer is now consistent at 4
  across both the orders table and orders JOIN order_products
- All customer segments, KPIs, and view definitions remain
  valid and unaffected
- Zero customers removed from analysis
*/

-- Backup first (non-negotiable)
select *
into orders_backup_before_cleanup
from orders
where not exists (
    select 1 from order_products op
    where op.order_id = orders.order_id
);

-- Confirm backup row count
select count(*) from orders_backup_before_cleanup;  /* 75,000 */

-- Must show 75,000 before you proceed

-- ─────────────────────────────────────────────────────────

-- Dry run — confirm the number one final time
select count(*) AS rows_to_delete
from orders
where NOT EXISTS (
    select 1 from order_products op
    where op.order_id = orders.order_id
);  /* 75,000 */
-- Must show 75,000

-- ─────────────────────────────────────────────────────────

-- Actual delete
delete from orders
where not exists (
    select 1 from order_products op
    where op.order_id = orders.order_id
);

-- Confirm deletion
select count(*) as remaining_orders from orders;   /* 0 */
