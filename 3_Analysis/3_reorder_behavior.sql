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



