select 
distinct status,
count(*) as order,
round(100.0 * COUNT(*) / (select count(*) from orders)  ,1) as per_of_orders
from orders as o
group by status
order by per_of_orders desc