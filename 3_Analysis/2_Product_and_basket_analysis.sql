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


