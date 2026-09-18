-- 1. Peak ordering hours

select order_hour_of_day, count(distinct order_id) as total_orders
from orders
group by order_hour_of_day
order by 2 desc;
