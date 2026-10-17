select 
p.category,
 sum(oi.quantity * oi.unit_price) filter (where extract(quarter from o.order_date) = 1) as q1,
sum(oi.quantity * oi.unit_price) filter (where extract(quarter from o.order_date) = 2) as q2,
sum(oi.quantity * oi.unit_price) filter (where extract(quarter from o.order_date) = 3) as q3,
sum(oi.quantity * oi.unit_price) filter (where extract(quarter from o.order_date) = 4) as q4,
sum(oi.quantity * oi.unit_price) as total_2025

from orders as o
 join order_items as oi on o.order_id = oi.order_id
join products as p on oi.product_id = p.product_id
where o.order_date between date '2025-01-01' and date '2025-12-31' and o.status in ('delivered', 'shipped', 'processing')

group by p.category
order by total_2025 desc