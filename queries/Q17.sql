with gaps as (
select
 o.customer_id,
o.order_id,  -- current order date minus the previous order date of the same customer
o.order_date - lag(o.order_date) over (partition by o.customer_id order by o.order_date, o.order_id) as days_since_prev
from orders as o
)
select
customer_id,
count(*) as orders,                              
count(days_since_prev) as gaps,                  
round(avg(days_since_prev), 1) as avg_gap_days,  
max(days_since_prev) as longest_gap_days
from gaps
group by customer_id
having count(*) >= 5
order by avg_gap_days, customer_id