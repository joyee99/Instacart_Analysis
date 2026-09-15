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
