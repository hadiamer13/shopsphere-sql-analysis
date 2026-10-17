with region_status_base as (
select 
c.region,
o.status,
o.order_id
from customers as c
join orders as o on c.customer_id = o.customer_id
)
select 
region,
count(order_id) as total_orders,
round(100.0 * count(order_id) filter (where status = 'cancelled') / count(order_id), 2) as cancel_rate_pct,
round(100.0 * count(order_id) filter (where status = 'returned') / count(order_id), 2) as return_rate_pct
from region_status_base
group by region
order by cancel_rate_pct desc