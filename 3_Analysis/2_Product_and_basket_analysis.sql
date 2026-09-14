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

-- 2b. percentage of top20 products according to overall items.

select 
    (select count(distinct order_id) from order_products) as total_orders,
    (select count(*) from (
        select order_id from order_products group by order_id having count(*) >= 20
    ) x) as large_orders_20plus,
    round(cast((select count(*) from (
        select order_id from order_products group by order_id having count(*) >= 20
    ) x) as float)/(select count(distinct order_id) from order_products),2) as pct;



-- 3. mostly bought together

Drop table if exists popular_products;

select top 300 
product_id, count(product_id) as repeated_times
into popular_products 
from order_products 
group by product_id 
order by 2 desc;

create index idx_pp on popular_products(product_id);


Drop table if exists filtered_products;

select distinct 
order_id, product_id into filtered_products
from order_products
where product_id in (select product_id from popular_products)
and order_id in (select order_id from order_products group by order_id having count(*)>=20);

create index idx_fp on filtered_products(order_id, product_id);


with frequently_bought_together as(
	select p1.product_id as product_1, p2.product_id as product_2, count(*) as buying_freq
	from filtered_products fp1 join filtered_products fp2 
	on fp1.order_id = fp2.order_id and fp1.product_id<fp2.product_id
	join products p1 on fp1.product_id=p1.product_id
	join products p2 on fp2.product_id=p2.product_id
	group by p1.product_id, p2.product_id
),
pairs_with_names as (
    select p1.product_name as product_1,
           p2.product_name as product_2,
           sum(fb.buying_freq) as buying_freq
    from frequently_bought_together fb join products p1 
    on fb.product_1=p1.product_id
    join products p2 
    on fb.product_2=p2.product_id
    where p1.product_name != 'unknown'
      and p2.product_name != 'unknown'
      and p1.product_name IS NOT NULL
      and p2.product_name IS NOT NULL
    group by p1.product_name, p2.product_name
)
select top 20 product_1,product_2,buying_freq from pairs_with_names order by 3 desc;



-- 5. products per department

select d.department_id, d.department, count(p.product_id) as total_items
from departments d join products p 
on d.department_id=p.department_id
group by d.department, d.department_id
order by 3 desc;
