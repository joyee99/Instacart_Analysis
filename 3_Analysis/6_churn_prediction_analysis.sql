-- 1. Churn Risk Classification.

with order_gap as(
	select user_id, count(order_id) as total_orders,
	max(days_since_prior_order) as longest_gap
	from orders
	group by user_id
),
classified as(
select *,
case when total_orders=1 then 'One-time'
	 when longest_gap>=30 then 'Churned'
	 when longest_gap>=15 then 'At-risk'
	 else 'Active'
end as churn_status
from order_gap
)
select churn_status, count(*) as total_customer,
    round(cast(count(*) as float)*100/sum(count(*)) over(),2) as pct_of_customers
from classified
group by churn_status
order by 2 desc;
