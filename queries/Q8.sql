with order_totals as (
    select 
    o.order_id,
    o.customer_id,
    sum(oi.quantity * oi.unit_price) as order_value
    from orders as o
    join order_items as oi on o.order_id = oi.order_id
    where o.status in ('delivered', 'shipped', 'processing')
    group by o.order_id, o.customer_id
)
select 
c.segment,
count(ot.order_id) as orders,
round(sum(ot.order_value), 2) as revenue,
round(avg(ot.order_value), 2) as avg_order_value
from order_totals as ot
join customers as c on ot.customer_id = c.customer_id
group by c.segment
order by avg_order_value desc