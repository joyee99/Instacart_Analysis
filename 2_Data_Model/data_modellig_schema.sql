-- 1. Data Types checked and Fixed
    -- 1.1 aisles
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'aisles'
ORDER BY ORDINAL_POSITION;

Alter table aisles DROP CONSTRAINT PK_aisles; -- drop constraint because MSSQL won't allow to change datatype if a column has Primary key constraint
Alter table aisles alter column aisle_id int not null; -- added not null to add Primary key constraint again.
Alter table aisles alter column aisle varchar(50);
alter table aisles add constraint PK_aisles primary key (aisle_id); -- Added primary key on aisle_id


    -- 1.2 departments
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'departments'
ORDER BY ORDINAL_POSITION;

Alter table departments DROP CONSTRAINT PK_departments;
Alter table departments alter column department_id int not null;
Alter table departments alter column department varchar(50);
alter table departments add constraint PK_departments primary key (department_id);


    -- 1.3 order_products
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'order_products'
ORDER BY ORDINAL_POSITION;

Alter table order_products alter column order_id int;
Alter table order_products alter column product_id int;
Alter table order_products alter column add_to_cart_order int;
Alter table order_products alter column reordered int;

    -- 1.4 orders
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders'
ORDER BY ORDINAL_POSITION;

Alter table orders alter column order_id int not null;
Alter table orders alter column order_number int;
Alter table orders alter column order_dow int;
Alter table orders alter column order_hour_of_day int;
Alter table orders alter column days_since_prior_order int;

    -- 1.5 products
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'products'
ORDER BY ORDINAL_POSITION;

Alter table products DROP CONSTRAINT PK_products;
Alter table products alter column product_id int not null;
ALTER TABLE products ADD CONSTRAINT PK_products PRIMARY KEY (product_id);
Alter table products alter column product_name varchar(300);
Alter table products alter column aisle_id int;
Alter table products alter column department_id int;


-- 2. Adding the product_id which are not in products but in order_products.
Insert into products (product_id, product_name, aisle_id, department_id)
select distinct product_id,'Unknown',null, null
from order_products 
where product_id not in (select product_id from products);

select count(distinct product_id) from products; /* 49688 */


-- 3. Foreign Key adds:
-- 3.1 Foreign keys for products.
alter table products 
add constraint FK_products
foreign key (aisle_id) references aisles(aisle_id);

alter table products 
add constraint FK_departments
foreign key (department_id) references departments(department_id);

-- 3.2 Foreign Keys for order_products.
alter table order_products 
add constraint FK_order_products
foreign key (order_id) references orders(order_id);

alter table order_products 
add constraint FK_order_products_products
foreign key (product_id) references products(product_id);

