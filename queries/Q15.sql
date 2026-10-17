with ltv as (
select
o.customer_id,
sum(oi.quantity * oi.unit_price) as lifetime_value
from orders as o
join order_items as oi on o.order_id = oi.order_id

where o.status in ('delivered', 'shipped', 'processing')
group by o.customer_id
),

ranked as (
select
c.region,
c.customer_id,
c.first_name || ' ' || c.last_name as customer_name,l.lifetime_value,
rank() over (partition by c.region order by l.lifetime_value desc) as region_rank,
round(100.0 * l.lifetime_value / sum(l.lifetime_value) over (partition by c.region), 2) as pct_of_region
from ltv as l
join customers as c on l.customer_id = c.customer_id
)
select region, region_rank,
customer_id, 
customer_name,
round(lifetime_value, 2) as lifetime_value, 
pct_of_region
from ranked
where region_rank <= 3
order by region, region_rank, customer_id