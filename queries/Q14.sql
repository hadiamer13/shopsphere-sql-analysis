with sold_items as (
select distinct
oi.product_id
from order_items as oi
 join orders as o on oi.order_id = o.order_id
where o.status in ('delivered', 'shipped', 'processing')
)
select 
p.product_id,
p.product_name,
 p.category
from products as p
where p.product_id not in (select product_id from sold_items)