-- 1. Overall reorder rates.

with reorder as(
	select
		count(order_id) as total_items,
		sum(reordered) as total_reordered,
		sum(case when reordered=0 then 1 end) as total_first_purchase
	from order_products
)
select *, 
round(cast(total_reordered as float)*100.0/total_items,2) as reordered_pct,
round(cast(total_first_purchase as float)*100.0/total_items,2) as first_purchase_pct
from reorder;



-- 2. Products with highest reorder rate
with reorder_pct as(
	select product_id, 
	round(cast(sum(reordered) as float)*100.0/count(*),2) as reorder_pct
	from order_products
	group by product_id having count(*)>=500
),
pct_rank as(
	select rp.product_id, p.product_name, reorder_pct,
	dense_rank() over(order by reorder_pct desc) as ranks
	from reorder_pct rp join products p 
	on rp.product_id=p.product_id
)
select product_id,product_name,reorder_pct from pct_rank where ranks<=20;



-- 3. Reorder rate by departments.
-- 3.1) Mostly reordered
with loyal_buyers as(
	select d.department_id, d.department,
		round(cast(sum(op.reordered) as float)*100.0/count(op.product_id),2) as reorder_rate
	from departments d join products p
	on d.department_id=p.department_id
	join order_products op
	on p.product_id=op.product_id
	group by d.department_id, d.department
)
select * from loyal_buyers where reorder_rate>=60.00 order by reorder_rate desc;

-- 3.2) Mostly One-time purchased.
with one_time_customer as(
	select d.department_id, d.department,
		round(cast(sum(case when op.reordered=0 then 1 end) as float)*100.0/count(op.product_id),2) as one_time_rate
	from departments d join products p
	on d.department_id=p.department_id
	join order_products op
	on p.product_id=op.product_id
	group by d.department_id, d.department
)
select * from one_time_customer where one_time_rate>=60.00 order by one_time_rate desc;



-- 4. Reorder rate by Cart Position. (is reorder rate high for cart position 1-3 than others?)
with reorder_cart as(
	select add_to_cart_order as cart_position, count(product_id) as total_items,
	sum(reordered) as total_reorders,
	round(cast(sum(reordered) as float)*100.0/count(product_id),2) as reordered_pct
	from order_products
	group by add_to_cart_order having count(product_id)>=500
),
cart_ranks as(
	select *, DENSE_RANK() over(order by reordered_pct desc) as ranks from reorder_cart
)
select * from cart_ranks where ranks<=20;
