with ordered as (
select
customer_id,
order_date,
row_number() over (partition by customer_id order by order_date, order_id) as seq,
lead(order_date) over (partition by customer_id order by order_date, order_id) as next_order_date
from orders
),

first_orders as (
select customer_id, 
order_date as first_order_date,
next_order_date
from ordered where seq = 1 and order_date < date '2026-04-01'
)

select
to_char(first_order_date, 'YYYY-"Q"Q') as cohort,
count(*) as new_customers,
count(*) filter (where next_order_date - first_order_date <= 90) as repeat_in_90,

round(100.0 * count(*) filter (where next_order_date - first_order_date <= 90) / count(*), 1) as repeat_rate_pct
from first_orders
group by cohort
order by cohort