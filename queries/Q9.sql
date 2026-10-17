select 
p1.product_name as product_a,
p2.product_name as product_b,
count(distinct oi2.order_id) as orders_together
from order_items as oi1
join order_items as oi2 on oi1.order_id = oi2.order_id and oi1.product_id < oi2.product_id
join orders as o on oi1.order_id = o.order_id
join products as p1 on oi1.product_id = p1.product_id
join products as p2 on oi2.product_id = p2.product_id
where o.status in ('delivered', 'shipped', 'processing')
group by p1.product_name, p2.product_name
order by orders_together desc
limit 10