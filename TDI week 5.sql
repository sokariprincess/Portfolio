-- Inner Join
select ot.customerID,ct.name,ot.totalamount from Orders_Table as ot
join customer_Table  as ct on ot.customerID = ct.customerID;

select pt.productname,od.orderID,od.quantity from Order_Details as od
join products_table as pt on od.productID = pt.productID;

Select pt.productname, od.quantity, ct.email 
from Order_details as od 
join products_table as pt on od.productID = pt.ProductID 
join (
      select od.productid, ct.customerid, ct.Email 
      from Customer_table as ct
	  join orders_table as ot on ct.customerid = ot.customerid
	  join order_details as od on ot.orderid = od.orderid)
as ct on pt.productid = ct.productid;

select ot.customerid, ct.name, sum(ot.totalamount) as totalamount_spent
from orders_table as ot
join customer_table as ct on ot.customerid = ct.customerid
group by ot.customerid, ct.name;

-- Right join
select pt.productid, pt.productname,od.orderid, od.quantity
from products_table as pt
right join order_details as od on pt.productid = od.productid;

select ct.name, coalesce(sum(ot.totalamount),0) as totalamountspent
from customer_table as ct
right join orders_table as ot on ct.customerid = ot.customerid
group by ct.name;

select od.orderid, pt.productname,od.quantity 
from order_details as od
right join products_table  pt on od.productid = pt.productid;


select pt.productname, od.quantity
from products_table pt
right join order_details as od on pt.productid = od.productid;

-- Left join
select ct.*, ot.*
from customer_table ct
left join orders_table ot on ct.customerid = ot.customerid;

select ct.name, coalesce(sum(ot.totalamount), 0) as total_amount_spent
from customer_table as ct
left join orders_table as ot on ct.customerID = ot.customerID
group by ct.name;

select od.orderid,od.productID,pt.productname, od.quantity
from order_details as od
left join products_table as pt on od.productid = pt.productid;

select pt.productname, coalesce(od.quantity, 0) as quantity_ordered
from products_table as pt
left join order_details as od on pt.productID = od.productID;

-- Full outer join
select ct.name, ot.orderID, ot.orderdate, ot.totalamount
from orders_table as ot
full outer join customer_table as ct on ot.customerID = ct.customerID;

select od.orderid,od.quantity, pt.productname
from order_details  od
full outer join products_table  pt on od.productid = pt.productid;

select ct.name, coalesce(sum(ot.totalamount),0) as total_amount_spent
from customer_table as ct
full outer join orders_table  ot on ct.customerid = ot.customerid
group by ct.name;

select ot.orderid, od.productid, pt.productname, od.quantity
from orders_table as ot
full outer join order_details as od on ot.orderid = od.orderid
full outer join products_table as pt on od.productid = pt.productid;