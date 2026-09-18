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



