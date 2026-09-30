-- 1. View: Customer Summary.
create view VW_customer_segment as
select 
o.user_id,
avg(days_since_prior_order) as avg_days_gap,
max(days_since_prior_order) as max_days_gap,
sum(basket.item_count) as total_basket_size,
round(avg(cast(basket.item_count as float)),2) as avg_basket_size,
count(distinct o.order_id) as total_orders,
case when count(distinct o.order_id)=3 then 'minimum order buyer'
	 when count(distinct o.order_id) between 4 and 19 then 'occasional'
	 when count(distinct o.order_id) between 20 and 49 then 'regular'
	 when count(distinct o.order_id) between 50 and 99 then 'frequent'
	 when count(distinct o.order_id)=100 then 'star customer'
end as customer_segment,
case when max(days_since_prior_order)>=30 then 'high-risk'
	 when max(days_since_prior_order) between 15 and 29 then 'medium-risk'
	 else 'active'
end as churn_risk_label
from orders o join (
	select order_id, count(product_id) as item_count from order_products group by order_id
) basket on o.order_id=basket.order_id
group by o.user_id;

-- checks
select count(*) from VW_customer_segment;
select * from VW_customer_segment;



-- 2. View: Product Performance

create view VW_product_performance as 
select 
p.product_id, p.product_name,
d.department, a.aisle,
count(op.order_id) as total_orders,
sum(op.reordered) as total_reorders,
round(cast(sum(op.reordered) as float)*100/count(op.order_id),2) as reorder_pct,
round(avg(cast(op.add_to_cart_order as float)),2) as avg_cart_position
from order_products op join products p
on op.product_id=p.product_id
join departments d on d.department_id=p.department_id
join aisles a on a.aisle_id=p.aisle_id
group by p.product_id, p.product_name, d.department, a.aisle;

-- checks
select count(*) from VW_product_performance;
select * from VW_product_performance;


-- 3. View: Department Performance

create view VW_department_perforrmance as
select d.department_id, d.department,
count(op.order_id) as total_orders,
count(distinct op.product_id) as unique_products,
sum(op.reordered) as total_reordered,
round(cast(sum(op.reordered) as float)*100/count(op.order_id),2) as reorder_pct,
round(avg(cast(op.add_to_cart_order as float)),2) as avg_cart_posiiton
from departments d join products p 
on d.department_id=p.department_id
join order_products op 
on p.product_id=op.product_id
group by d.department, d.department_id;

-- checks
select count(*) from VW_department_perforrmance;
select * from VW_department_perforrmance;



-- 4. View: Aisle Performance

create view VW_aisle_performance as
select a.aisle_id, a.aisle, d.department,
count(op.order_id) as total_orders,
count(distinct op.product_id) as unique_products,
sum(op.reordered) as total_reordered,
round(cast(sum(op.reordered) as float)*100/count(op.order_id),2) as reorder_pct,
round(avg(cast(op.add_to_cart_order as float)),2) as avg_cart_posiiton
from departments d join products p 
on d.department_id=p.department_id
join aisles a 
on a.aisle_id=p.aisle_id
join order_products op 
on p.product_id=op.product_id
group by d.department, a.aisle_id, a.aisle;

-- checks
select count(*) from VW_aisle_performance;
select * from VW_aisle_performance;



-- 5. View: Trend by hour

create view VW_trend_by_hour as
select o.order_hour_of_day, 
case when o.order_hour_of_day between 5 and 11 then 'Morning'
	 when o.order_hour_of_day between 12 and 16 then 'Afternoon'
	 when o.order_hour_of_day between 17 and 20 then 'Evening'
	 else 'Night'
end as time_of_day,
count(distinct o.order_id) as total_orders,
round(avg(cast(basket.item_count as float)),2) as avg_basket_size
from orders o join (
	select order_id, count(product_id) as item_count from order_products group by order_id
) basket 
on basket.order_id=o.order_id
group by o.order_hour_of_day;

-- checks
select count(*) from VW_trend_by_hour;
select * from VW_trend_by_hour;



-- 6. View: Trend by day

create view VW_trend_by_day as
select o.order_dow,
case o.order_dow
	 when 0 then 'Saturday'
	 when 1 then 'Sunday'
	 when 2 then 'Monday'
	 when 3 then 'Tuesday'
	 when 4 then 'Wednesday'
	 when 5 then 'Thursday'
	 when 6 then 'Friday'
end as day_name,
count(distinct o.order_id) as total_orders,
round(avg(cast(basket.item_count as float)),2) as avg_basket_size,
round(avg(cast(o.days_since_prior_order as float)),2) as avg_day_gap
from orders o join(
	select order_id, count(product_id) as item_count from order_products group by order_id
) basket 
on basket.order_id=o.order_id
group by o.order_dow;

-- checks
select count(*) from VW_trend_by_day;
select * from VW_trend_by_day;



-- 7. View: Trend heatmap

create view VW_trend_heatmap as
select o.order_dow,
case o.order_dow
	 when 0 then 'Saturday'
	 when 1 then 'Sunday'
	 when 2 then 'Monday'
	 when 3 then 'Tuesday'
	 when 4 then 'Wednesday'
	 when 5 then 'Thursday'
	 when 6 then 'Friday'
end as day_name,
o.order_hour_of_day, 
count(distinct o.order_id) as total_orders
from orders o 
group by o.order_dow, o.order_hour_of_day;

-- checks
select count(*) from VW_trend_heatmap;
select * from VW_trend_heatmap;



-- 8. View: Reorder by cart Poisition

create view VW_reorder_by_cart_position as
select add_to_cart_order,
count(*) as total_orders,
sum(reordered) as total_reorders,
round(cast(sum(reordered) as float)*100/count(*),2) as reorder_rate
from order_products
where add_to_cart_order<=20
group by add_to_cart_order;

-- checks
select count(*) from VW_reorder_by_cart_position;
select * from VW_reorder_by_cart_position;



-- 9. View: Reorder by order number

create view VW_reorder_by_order_number as
select order_number,
count(*) as total_orders,
sum(reordered) as total_reorders,
round(cast(sum(reordered) as float)*100/count(*),2) as reorder_rate
from order_products op join orders o
on op.order_id=o.order_id
where order_number<=30
group by order_number;

-- checks
select count(*) from VW_reorder_by_order_number;
select * from VW_reorder_by_order_number;



-- 10. View: Reorder by dept and aisles

create view VW_reorder_by_dept_and_aisles as
select d.department_id, d.department, a.aisle_id, a.aisle,
count(*) as total_orders,
sum(reordered) as total_reorder,
round(cast(sum(reordered) as float)*100/count(*),2) as reorder_rate,
round(avg(cast(add_to_cart_order as float)),2) as avg_cart_position
from departments d join products p
on d.department_id=p.department_id
join aisles a on a.aisle_id=p.aisle_id
join order_products op on op.product_id=p.product_id
group by d.department_id, d.department, a.aisle_id, a.aisle;

-- checks
select count(*) from VW_reorder_by_dept_and_aisles;
select * from VW_reorder_by_dept_and_aisles;



-- 11. View: Churn Risk

create view VW_churn_risk as
select o.user_id,
count(*) as total_orders,
max(days_since_prior_order) as longest_day_gap,
round(avg(cast(days_since_prior_order as float)),2) as avg_day_gap,
round(avg(cast(basket.item_count as float)),2) as avg_basket_size,
case when count(o.order_id)=1 then 'One-time'
	 when max(days_since_prior_order)>=30 then 'Churn'
	 when max(days_since_prior_order) between 15 and 29 then 'At-risk'
	 else 'Active'
end as churn_status
from orders o join (
	select order_id, count(product_id) as item_count from order_products group by order_id
) basket on basket.order_id=o.order_id
group by o.user_id;

-- checks
select count(*) from VW_churn_risk;
select * from VW_churn_risk;



-- 12. View: Top Pairs

create view VW_top_pairs as
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
select top 100 product_1,product_2,buying_freq from pairs_with_names order by 3 desc;

select * from VW_top_pairs order by buying_freq desc;