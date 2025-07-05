--Monday Coffee Data Analysis
select * from city;
select * from products;
select * from customers;
select * from sales;

--reports and data analysis
--Q1: How many people in each city are estimated to consume coffee, given that 25% of the population does?
select 
city_name,
round((population * 0.25)/1000000,2) as coffee_consumers_per_million, --per million
city_rank 
from city order by population desc;

--Q2: What is the total revenue generated from
--coffee sales across all cities in the last
--quarter of 2023?

select 
ci.city_name,
sum(s.total) as total_revenue
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id=c.city_id
where extract(year from s.sale_date)=2023
and extract(quarter from s.sale_date)=4
group by 1
order by 2 desc;

--Q3: How many units of each coffee product has been sold?
select 
p.product_name,
count(s.sale_id) as total_orders
from products as p
left join sales as s
on s.product_id=p.product_id
group by 1
order by total_orders desc;

--Q4: what is the average sales 
--amount per customer in each city?

select 
ci.city_name,
sum(s.total) as total_revenue,
count(distinct s.customer_id) as total_cx,
round(sum(s.total)::numeric/
count(distinct s.customer_id),2) 
as avg_sale_per_customer
from sales as s
join customers as c
on s.customer_id=c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 2 desc;

--Q5: Provide list of cities along with 
--their populations and estimated coffee consumers (25%).

SELECT 
    city_name,
    round(population/1000000,2) as population_in_millions,
    ROUND((population * 0.25)/1000000, 0) AS coffee_consumers_in_millions
FROM 
    city;

--Q6: what are the top 3 selling products in each city 
--based on sales volume?
select * from
(select
ci.city_name,
p.product_name,
count(s.sale_id) as total_orders,
dense_rank() over(partition by ci.city_name order by count(s.sale_id) desc) as rank
from sales as s
join products as p
on s.product_id = p.product_id
join customers as c
on c.customer_id=s.customer_id
join city as ci 
on ci.city_id=c.city_id
group by 1,2
--order by 1,3 desc
) as t1
where rank<=3;

--Q7: How many unique customers are there in each city who have purchased coffee products?
select * from products;

select ci.city_name,
count(distinct c.customer_id) as unique_cx
from city as ci left join
customers as c
on c.city_id=ci.city_id
join sales as s
on s.customer_id=c.customer_id
where 
s.product_id between 1 and 14
group by 1;

--Q8: Find each city and their average sale per customer
--avg rent per customer
with city_table
as
(select 
ci.city_name,
count(distinct s.customer_id) as total_cx,
round(sum(s.total)::numeric/
count(distinct s.customer_id),2) 
as avg_sale_per_customer


from sales as s
join customers as c
on s.customer_id=c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 2 desc
),
city_rent as
(select city_name,estimated_rent
from city)

select cr.city_name,
cr.estimated_rent,
ct.total_cx,
ct.avg_sale_per_customer,
round(cr.estimated_rent::numeric/ct.total_cx::numeric,2) as avg_rent_per_customer
from city_rent as cr
join city_table as ct
on cr.city_name=ct.city_name
order by 4 desc;








































