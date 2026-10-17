select 
c.customer_id as id,
max(o.order_date) as new,
(date '2026-07-01' - max(o.order_date)) as not_order,  -- current date - last order means the time from last order
count(o.order_id) as life_Order
from customers as c
join orders as o ON c.customer_id = o.customer_id
group by id--,o.order_id
having (date '2026-07-01' - max(o.order_date)) > 90
order by new,not_order,id
