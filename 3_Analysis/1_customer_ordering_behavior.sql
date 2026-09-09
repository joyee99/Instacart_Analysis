-- 1. Order count per customer

with user_info as(
	select user_id,
		   count(order_id) as total_orders,
		   avg(days_since_prior_order) as avg_days_between_orders,
		   min(days_since_prior_order) as shortest_gap_days,
		   max(days_since_prior_order) as longest_gap_days
	from orders
	group by user_id
)
select count(distinct user_id) as total_customer,
	   min(total_orders) as min_order,
	   max(total_orders) as max_order,
	   round(cast(avg(total_orders*1.0) as float),2) as avg_order,
	   min(shortest_gap_days) as shortest_gap_days,
	   max(longest_gap_days) as longest_gap_days,
	   round(cast(avg(avg_days_between_orders*1.0) as float),2) as avg_days_between_orders
from user_info;


-- 2. order frequency distribution and customer segmentation

with counters as(
	select user_id, count(order_id) as order_count from orders group by user_id
),
tiered as(
	select case when order_count between 3 and 19 then '3-19 Low Freq'
				when order_count between 20 and 49 then '20-49 Mid Freq'
				else '50+ High Freq'
		   end as freq_tier
	from counters 
)
select freq_tier, count(*) as total_users, round(cast(count(*) as float)/sum(count(*)) over() * 100,2) AS pct_of_customers
from tiered group by freq_tier order by 2 desc;


-- 3. Customer Segmentation

with counters as(
	select user_id, count(order_id) as order_count from orders group by user_id
),
tier as(
	select 
		case when order_count=3 then 'Min order buyer (3 orders)'
			 when order_count between 4 and 19 then '4-19 occasional'
			 when order_count between 20 and 49 then '20-49 regular'
			 when order_count between 50 and 99 then '50-99 loyal'
			 when order_count=100 then 'Premium Buyers (100)'
		end as customer_segment
	from counters
)
select customer_segment, count(*) as total_users, round(cast(count(*) as float)/sum(count(*)) over() * 100,2) AS pct_of_customers
from tier group by customer_segment order by 2 desc;

		 
