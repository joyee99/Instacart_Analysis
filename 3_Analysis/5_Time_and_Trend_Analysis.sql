-- 1. Peak ordering hours

select order_hour_of_day, count(distinct order_id) as total_orders
from orders
group by order_hour_of_day
order by 2 desc;

-- 1a. Peak ordering window with % share

with hourly as (
    select order_hour_of_day, count(distinct order_id) as total_orders
    from orders
    group by order_hour_of_day
),
overall as (
    select count(distinct order_id) as all_orders from orders
)
select 
    sum(case when h.order_hour_of_day between 9 and 16 then h.total_orders else 0 end) as peak_window_orders,
    o.all_orders,
    round(cast(sum(case when h.order_hour_of_day between 9 and 16 then h.total_orders else 0 end) as float) 
        / o.all_orders * 100, 2) as pct_in_peak_window,
    sum(case when h.order_hour_of_day between 0 and 5 then h.total_orders else 0 end) as overnight_orders,
    round(cast(sum(case when h.order_hour_of_day between 0 and 5 then h.total_orders else 0 end) as float) 
        / o.all_orders * 100, 2) as pct_overnight
from hourly h
cross join overall o
group by o.all_orders;



-- 2. Busiest Day of the week
with overall as(
	select count(distinct order_id) as overall_orders from orders
)
select order_dow,
case when order_dow=0 then 'Saturday'
	 when order_dow=1 then 'Sunday'
	 when order_dow=2 then 'Monday'
	 when order_dow=3 then 'Tuesday'
	 when order_dow=4 then 'Wednesday'
	 when order_dow=5 then 'Thursday'
	 when order_dow=6 then 'Friday'
end as day_name,
count(order_id) as total_orders,
round(cast(count(order_id) as float)/(select overall_orders from overall)*100,2) as weekday_order_pct
from orders 
group by order_dow 
order by 3 desc;



-- 3. AVG basket size by day of week
create index idx_order_products_order_id 
on order_products(order_id) include (product_id);

with basket as(
	select order_id, count(product_id) as basket_size
	from order_products
	group by order_id
)
select order_dow, 
case when order_dow=0 then 'Saturday'
	 when order_dow=1 then 'Sunday'
	 when order_dow=2 then 'Monday'
	 when order_dow=3 then 'Tuesday'
	 when order_dow=4 then 'Wednesday'
	 when order_dow=5 then 'Thursday'
	 when order_dow=6 then 'Friday'
end as day_name,
round(avg(cast(b.basket_size as float)),2) as avg_basket_size
from orders o join basket b
on o.order_id=b.order_id
group by order_dow 
order by 3 desc;
