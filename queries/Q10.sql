with monthly as (
select 
date_trunc('month', o.order_date)::date as month,
sum(oi.quantity * oi.unit_price) as revenue
 from orders as o
join order_items as oi on o.order_id = oi.order_id
where o.status in ('delivered', 'shipped', 'processing')
 group by date_trunc('month', o.order_date)
)

select 
m.month, m.revenue,
prev.revenue as prev_month_revenue,
round(100.0 * (m.revenue - prev.revenue) / prev.revenue, 2) as mom_growth_pct
from monthly as m
left join monthly as prev on prev.month = m.month - interval '1 month'

order by m.month