-- 1. Department order-reach with % of total orders
create index idx_order_products_product_id 
on order_products(product_id) include (order_id);

create index idx_products_department_id 
on products(department_id) include (product_id);

with dept_orders as (
    select p.department_id, count(distinct op.order_id) as total_orders
    from order_products op
    join products p 
    on op.product_id = p.product_id
    group by p.department_id
),
overall as (
    select count(*) as all_orders from orders
),
dept_rnk as(
    select d.department, do.total_orders,
        round(cast(do.total_orders as float) / (select all_orders from overall) * 100, 1) as pct_dept,
        dense_rank() over(order by do.total_orders desc) as ranks
    from departments d
    join dept_orders do on d.department_id = do.department_id
)
select * from dept_rnk where ranks<=10;



