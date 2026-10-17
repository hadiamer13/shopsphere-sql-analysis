with customer_spend as (
select 
o.customer_id,
  sum(oi.quantity * oi.unit_price) as lifetime_spend
  from orders as o
 join order_items as oi on o.order_id = oi.order_id
 where o.status in ('delivered', 'shipped', 'processing')
  group by o.customer_id
),
metrics as (
  select  (select count(*) from customer_spend) as paying_customers,
 (select avg(lifetime_spend) from customer_spend) as avg_spend,
 (select sum(lifetime_spend) from customer_spend) as total_revenue
),

above_avg as (
select cs.lifetime_spend
from customer_spend as cs
cross join metrics as m
where cs.lifetime_spend > m.avg_spend
)
select 
(select count(*) from above_avg) as customers_above_avg,
m.paying_customers,
round(m.avg_spend, 2) as avg_spend,
round(100.0 * (select sum(lifetime_spend) from above_avg) / m.total_revenue, 1) as pct_of_revenue
from metrics as m