select
extract(year from c.signup_date)::int as signup_year,
count(*) as never_ordered
from customers as c
where not exists (select 1 from orders as o where o.customer_id = c.customer_id)
group by signup_year
order by signup_year