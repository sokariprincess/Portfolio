-- Data Cleaning & EDA
select * from superstore;

-- Checking missing values
select * from superstore where rowid is null OR orderdate is null OR shipdate is null OR customerid is null
;

select distinct * from superstore;

-- identifying duplicate values
select * from superstore
where (rowid, orderid, orderdate, shipdate,shipmode, customerid, customername,
	  segment,country,city,states,postalcode, region, productid,category, subcategory,
	  productname,sales)
In(
Select rowid, orderid, orderdate, shipdate,shipmode, customerid, customername,
	  segment,country,city,states,postalcode, region, productid,category, subcategory,
	  productname,sales
      from superstore
      group by rowid, orderid, orderdate, shipdate,shipmode, customerid, customername,
	  segment,country,city,states,postalcode, region, productid,category, subcategory,
	  productname,sales
      Having count(*)>1
)
order by rowid,orderid;

-- EDA
-- Total orders generated
select count(orderid) as total_orders from superstore;

-- Total sales
select round(sum(sales)) as total_sales from superstore;

-- Top category
select category,count(*) as Top_orders
from superstore
group by category
order by Top_orders desc;

-- most sold product
select productname, round(sum(sales)) as Most_soldproduct
from superstore
group by 1
order by 2 desc
limit 1;

-- Top 5 Customers based on purchase 
select customername, round(sum(sales)) as Top5customers
from superstore
group by 1
order by Top5customers desc
limit 5;

-- Sales over the years
select extract(YEAR from orderdate) as year, sum(sales) as YearlyRevenue
from superstore
group by year
order by year;

-- Top 5 Regional sales
select region, sum(sales) as regionsales
from superstore
group by region
order by regionsales desc
limit 5;

-- Create View for monthly_sales trend
create view Monthly_sales_trend as
select extract(YEAR from orderdate)as year, extract(MONTH from orderdate)as months, 
sum(sales) as totalsales
from superstore
group by year,months
order by year,months;

select * from monthly_sales_trend;

-- Customers with top orders
select customername, count(*) as totalorders, round(avg(sales),2) as average_value
from superstore
group by customername
having count(*)>=5
order by totalorders,average_value desc
limit 10;

-- Product category ranking
-- Rank()Over function typically used with order by clause is used to
-- assign a rank within a specified function
Select category, Round(SUM(sales)) as TotalSales,
 RANK() OVER (ORDER BY SUM(sales) desc) as CategoryRank
from superstore
group by category
order by TotalSales desc;