create schema dannys_dinner;

alter schema dannys_dinner
rename to dannys_diner;

Create table dannys_diner.sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO dannys_diner.sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);
  
Create table dannys_diner.menu (
  product_id INTEGER,
  product_name VARCHAR(80),
  price INTEGER
);


INSERT INTO dannys_diner.menu
  (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12),
  (4, 'pizza', 8),
  (5, 'burger', 6),
  (6, 'salad', 9),
  (7, 'sandwich', 7),
  (8, 'pasta', 12),
  (9, 'steak', 15),
  (10, 'soup', 5),
  (11, 'taco', 10),
  (12, 'fried chicken', 11),
  (13, 'sushi roll', 13),
  (14, 'fish and chips', 14),
  (15, 'veggie wrap', 10);

CREATE TABLE dannys_diner.members (
  customer_id VARCHAR(20),
  join_date DATE
);

INSERT INTO dannys_diner.members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09'),
  ('D', '2021-01-20'),
  ('E', '2021-01-25'),
  ('F', '2021-02-01'),
  ('G', '2021-02-05'),
  ('H', '2021-02-10'),
  ('I', '2021-02-15'),
  ('J', '2021-02-20'),
  ('K', '2021-02-25'),
  ('L', '2021-03-01'),
  ('M', '2021-03-05'),
  ('N', '2021-03-10'),
  ('O', '2021-03-15'),
  ('P', '2021-03-20');

 select * from dannys_diner.Menu;
 
 select s.Customer_id, sum(m.price) as total_spent
 from dannys_diner.sales s
 join dannys_diner.menu m on s.product_id=m.product_id
 group by s.customer_id
 order by s.customer_id asc;
 
select customer_id ,count(distinct order_date) as days_visited
from dannys_diner.sales
group by customer_id
order by customer_id asc;

select s.customer_id, m.product_name as first_order
from(
    Select customer_id, Min(order_date) as first_order_date
    from dannys_diner.sales
    group by customer_id) as first_orders
join dannys_diner.sales s on first_orders.customer_id=s.customer_id
and first_orders.first_order_date=s.order_date
join dannys_diner.menu m on s.product_id=m.product_id;

select* from dannys_diner.sales;

select m.product_name as most_purchased_item, count(*) as total_purchases
from dannys_diner.sales s
join dannys_diner. menu m  on s.product_id=m.product_id
group by m.product_name
order by total_purchases desc;

with ranked_items as(
    select  s.customer_id, m.product_name ,
	        row_number() over(partition by s.customer_id order by count(*) desc) as rank
    from dannys_diner.sales s
    join dannys_diner.menu m on s.product_id=m.product_id
    group by s.customer_id, m.product_name)
select customer_id, product_name as most_popular
from ranked_items
where rank =1;

select * from dannys_diner.members;

WITH first_purchase_after_join AS (
    SELECT s.customer_id, m.product_name, MIN(s.order_date) AS first_purchase_date
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m ON s.product_id = m.product_id
    JOIN dannys_diner.members mem ON s.customer_id = mem.customer_id
    WHERE s.order_date > mem.join_date
    GROUP BY s.customer_id, m.product_name
)
SELECT f.customer_id, f.product_name AS first_purchase_after_join
FROM first_purchase_after_join f
JOIN (
    SELECT customer_id, MIN(first_purchase_date) AS earliest_purchase_date
    FROM first_purchase_after_join
    GROUP BY customer_id
) AS min_dates ON f.customer_id = min_dates.customer_id AND f.first_purchase_date = min_dates.earliest_purchase_date;


WITH previous_purchases AS (
    SELECT
        s.customer_id,
        m.product_name,
        s.order_date AS purchase_date,
        LAG(s.order_date) OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS previous_purchase_date
    FROM
        dannys_diner.sales s
    JOIN
        dannys_diner.menu m ON s.product_id = m.product_id
    JOIN
        dannys_diner.members mem ON s.customer_id = mem.customer_id
    WHERE
        s.order_date < mem.join_date
)
SELECT
    customer_id,
    product_name AS last_purchase_before_joining
FROM
    previous_purchases
WHERE
    purchase_date = previous_purchase_date;
	

select mem.customer_id, count(s.product_id) as total_items, sum(m.price) as amount_spent
from dannys_diner.sales s
join dannys_diner.menu m on s.product_id=m.product_id
join dannys_diner.members mem on s.customer_id=mem.customer_id
where s.order_date < mem.join_date
group by mem.customer_id;

select s.customer_id, 
      sum(CASE
		      when m.product_name= 'sushi' then (m.price*2)*10
		      else m.price *10
		   End) as total_points
from dannys_diner.sales s
join dannys_diner.menu m on s.product_id=s.product_id
group by s.customer_id;


SELECT 
    s.customer_id,
    m.product_name,
    CASE 
        WHEN mem.customer_id IS NULL THEN NULL
        ELSE RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC)
    END AS product_rank
FROM 
    dannys_diner.sales s
JOIN 
    dannys_diner.menu m ON s.product_id = m.product_id
LEFT JOIN 
    dannys_diner.members mem ON s.customer_id = mem.customer_id
GROUP BY 
  s.customer_id,m.product_name,mem.customer_id;
  
