select 
coalesce(promo_code,'No Promo') as promo_code,
count(order_date)  as orders,
round(100.0 * count(*) / sum(count(*)) over(),1) as pct_of_2025_orders
from orders 
where order_date between date '2025-01-01' and date'2025-12-31' 
group by promo_code
order by orders desc

