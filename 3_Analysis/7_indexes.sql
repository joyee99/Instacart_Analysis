-- Below query gives a complete list of all keys and indexes.

select 
    OBJECT_NAME(i.object_id) as table_name,
    i.name as index_name,
    i.type_desc as index_type
from sys.indexes i
where OBJECT_NAME(i.object_id) is not null
  and i.name is not null
  and OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
order by table_name, index_name;


-- Outcome

1. aisles  |	PK_aisles  |	CLUSTERED                                    -- Primary Key (aisle_id)
2. departments  |	PK_departments  |	CLUSTERED                            -- Primary Key (department_id)
3. filtered_products  |	idx_fp  |	NONCLUSTERED                           -- Nonclustered index on order_id and connects to order_products table
4. order_products  |	idx_order_products_order_id  |	NONCLUSTERED       -- Nonclusteres index on order_id column connects to filtered_products
5. order_products  |	idx_order_products_product_id  |	NONCLUSTERED     -- Nonclustered index on product_id column connects to popular_products
6. orders  |  PK_orders  |	CLUSTERED                                    -- Primary Key (order_id)
7. popular_products  |	idx_pp  |	NONCLUSTERED                           -- Nonclustered index on product_id and product_id connects to order_products table
8. products  |	idx_products_aisle_id  |	NONCLUSTERED                   -- Nonclustered index on aisle_id which connects to aisles table
9. products  |	idx_products_department_id  |  NONCLUSTERED              -- Nonclustered index on department_id which connects to departments table
10. products  |  PK_products  |	CLUSTERED                                -- Primary key (Product_id)
11. sysdiagrams  |	PK__sysdiagr__C2B05B61A2D9D87E  |	CLUSTERED          -- system's default keys
12. sysdiagrams  |	UK_principal_name  |	NONCLUSTERED                   -- system's default keys
