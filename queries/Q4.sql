select 
region, segment,
count(*) as customer
from customers as c
group by region, segment   
order by region, customer desc