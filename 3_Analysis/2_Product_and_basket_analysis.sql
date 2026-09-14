-- 1. Top 20 most ordered products

with top_ordered_products as(
	select op.product_id, p.product_name, count(op.product_id) as product_ordered,
	DENSE_RANK() over(order by count(op.product_id) desc) as ranks
	from products p join order_products op on p.product_id=op.product_id 
	group by op.product_id, p.product_name
)
select * from top_ordered_products where ranks<=20;

-- 1a. Organic share of top-20 volume + total percentage share for top 20 products.

with top_ordered_products as(
    select op.product_id, p.product_name, count(op.product_id) AS product_ordered,
    dense_rank() over(order by count(op.product_id) desc) as ranks
    from products p join order_products op on p.product_id = op.product_id 
    group by op.product_id, p.product_name
),
top20 as (
    select *,
        case when product_name LIKE '%Organic%' then 1 else 0 end as is_organic
    from top_ordered_products
    where ranks <= 20
),
total_items as(
    select count(*) as total_items from order_products
)
select
    sum(case when is_organic = 1 then product_ordered else 0 end) as organic_volume,
    sum(product_ordered) as top20_total_volume,
    round(cast(sum(case when is_organic = 1 then product_ordered else 0 end) as float) 
        / sum(product_ordered) * 100, 2) AS pct_organic_of_top20,
    round(cast(sum(product_ordered) as float)/(select total_items from total_items)*100,2) as overall_pct
from top20;



-- 2. first pick orders

with most_first_picked as(
	select op.product_id, p.product_name, count(op.product_id) as times_added_first,
	DENSE_RANK() over(order by count(op.product_id) desc) as ranks
	from products p join order_products op 
	on p.product_id=op.product_id
	where add_to_cart_order=1 
	group by op.product_id,p.product_name
)
select * from most_first_picked where ranks<=20;

-- 2a. Products in "first-added" top 20 but NOT in overall top-20 best-sellers

with top20 as (
    select product_id,
    dense_rank() over(order by count(product_id) desc) as ranks
    from order_products 
    group by product_id
),
first_pick_top20 as (
    select op.product_id, p.product_name, count(op.product_id) as times_added_first,
    dense_rank() over(order by count(op.product_id) desc) as ranks
    from products p join order_products op on p.product_id = op.product_id
    where op.add_to_cart_order = 1
    group by op.product_id, p.product_name
)
select product_id,product_name, times_added_first, ranks as first_pick_rank
from first_pick_top20
where ranks <= 20
  and product_id not in (select product_id from top20 where ranks <= 20)
order by ranks;

