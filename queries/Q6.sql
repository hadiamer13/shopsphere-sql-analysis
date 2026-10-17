select 
distinct category,
count(*) as product,
Round(avg(unit_price),2) as avg_price
from products o
group by category
having avg(unit_price) > 30
order by avg_price desc
