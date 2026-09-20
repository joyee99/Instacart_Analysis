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



-- 2. Loyalty tier comparison: highest vs. lowest order-frequency customers (Optimized with index idx_order_products_order_id)

with basket as (
    select order_id, count(product_id) as item_count
    from order_products
    group by order_id
),
customer_summary as (
    select
        o.user_id,
        count(distinct o.order_id) as total_orders,
        round(avg(cast(b.item_count as float)),2) as avg_basket_size,
        round(avg(cast(o.days_since_prior_order as float)),2) as avg_days_gap
    from orders o
    join basket b on o.order_id = b.order_id
    group by o.user_id
),
overall as(
    select count(distinct user_id) as all_customers from orders
)
select 
    case when total_orders = 100 then 'Top loyalty tier (100 orders)'
         when total_orders = 3 then 'Minimum order tier (3 orders)'
    end as loyalty_tier,
    count(*) as customer_count,
    round(cast(count(*) as float)*100/(select all_customers from overall),2) as customer_pct,
    round(avg(avg_basket_size),2) as avg_basket_size,
    round(avg(avg_days_gap),2) as avg_days_gap
from customer_summary
where total_orders in (100,3)
group by case when total_orders = 100 then 'Top loyalty tier (100 orders)'
              when total_orders = 3 then 'Minimum order tier (3 orders)'
         end;
