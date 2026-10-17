with gaps as (
select
o.customer_id,
o.order_date - lag(o.order_date) over (partition by o.customer_id order by o.order_date, o.order_id) as days_since_prev
from orders as o
),
eligible as (
 select customer_id
from orders
group by customer_id
having count(*) >= 5
)
select
c.segment,
count(distinct g.customer_id) as customers,
count(g.days_since_prev) as gaps,
round(avg(g.days_since_prev), 1) as avg_gap_days,
percentile_cont(0.5) within group (order by g.days_since_prev) as median_gap_days
from gaps as g

join eligible as e on g.customer_id = e.customer_id
join customers as c on g.customer_id = c.customer_id
where g.days_since_prev is not null

group by c.segment
order by avg_gap_days