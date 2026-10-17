with base as (
select
o.customer_id,
date '2026-07-01' - max(o.order_date) as recency_days,
count(distinct o.order_id) as frequency,
sum(oi.quantity * oi.unit_price) as monetary
from orders as o
join order_items as oi on o.order_id = oi.order_id
where o.status in ('delivered', 'shipped', 'processing')
group by o.customer_id
),

scored as (
select
customer_id, recency_days, frequency, monetary,
ntile(4) over (order by recency_days desc) as r_score, 
ntile(4) over (order by frequency) as f_score,
ntile(4) over (order by monetary) as m_score
from base
),
labelled as (
select *,
case
 when r_score = 4 and f_score >= 3 and m_score >= 3 then '1 Champions'
 when r_score >= 3 and f_score >= 3 then '2 Loyal'
 when r_score >= 3 then '3 Potential Loyalists'
when f_score >= 3 then '4 At Risk'
 when r_score = 2 then '5 Hibernating'
 else '6 Lost'
end as rfm_segment
from scored
)
select
rfm_segment,
count(*) as customers,
round(avg(recency_days), 0) as avg_recency_days,
round(avg(frequency), 1) as avg_orders,
round(avg(monetary), 0) as avg_spend,
round(100.0 * sum(monetary) / sum(sum(monetary)) over (), 1) as pct_of_revenue
from labelled
group by rfm_segment
order by rfm_segment