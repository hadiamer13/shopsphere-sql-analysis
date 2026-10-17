with monthly_rev as (
    select 
    date_trunc('month', o.order_date)::date as month,
    sum(oi.quantity * oi.unit_price) as monthly_revenue
    from orders as o
    join order_items as oi on o.order_id = oi.order_id
    where o.status in ('delivered', 'shipped', 'processing')
    group by date_trunc('month', o.order_date)
)
select 
month,
monthly_revenue,
round(avg(monthly_revenue) over(
    order by month 
    rows between 2 preceding and current row
), 2) as rolling_3m_avg,
count(*) over(
    order by month 
    rows between 2 preceding and current row
) as months_in_frame
from monthly_rev
order by month