with product_rev as (
select
p.category,p.product_id,
p.product_name,
sum(oi.quantity * oi.unit_price) as revenue
from order_items as oi

join orders as o on oi.order_id = o.order_id
join products as p on oi.product_id = p.product_id
where o.status in ('delivered', 'shipped', 'processing')
group by p.category, p.product_id, p.product_name
)
select
category,
product_name,
dense_rank() over (partition by category order by revenue desc) as rank_in_category,
round(revenue, 2) as revenue,
round(100.0 * revenue / sum(revenue) over (partition by category), 1) as pct_of_category,

round(100.0 * sum(revenue) over (partition by category order by revenue desc, 
product_id rows between unbounded preceding and current row ) / sum(revenue) over (partition by category), 1) as cumulative_pct

from product_rev
order by category, rank_in_category