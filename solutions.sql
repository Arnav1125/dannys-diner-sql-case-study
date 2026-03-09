select * from sales
select * from members
select * from menu

-- What is the total amount each customer spent at the restaurant?
select s.customer_id,sum(m.price) as total_spend
from sales s
LEFT JOIN menu m
on m.product_id=s.product_id
group by s.customer_id

-- How many days has each customer visited the restaurant?
select customer_id, Count(Distinct order_date)
from sales
group by customer_id

-- What was the first item from the menu purchased by each customer?
SELECT s.customer_id, m.product_name
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
WHERE s.order_date = (
    SELECT MIN(order_date)
    FROM sales
    WHERE customer_id = s.customer_id
);

-- What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name, count(*) as purchase_count
from sales s 
JOIN menu m 
ON s.product_id = m.product_id
group by product_name
order by purchase_count DESC
limit 1;



-- Which item was the most popular for each customer?
SELECT customer_id, product_name, order_count
FROM (
    SELECT s.customer_id,
           m.product_name,
           COUNT(*) AS order_count,
           RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rnk
    FROM sales s
    JOIN menu m
    ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
) t
WHERE rnk = 1;

-- Which item was purchased first by the customer after they became a member?
SELECT customer_id, product_name
FROM (
    SELECT s.customer_id,
           m.product_name,
           s.order_date,
           RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
    FROM sales s
    JOIN members mem
    ON s.customer_id = mem.customer_id
    JOIN menu m
    ON s.product_id = m.product_id
    WHERE s.order_date >= mem.join_date
) t
WHERE rnk = 1;
-- Which item was purchased just before the customer became a member?
SELECT customer_id, product_name
FROM (
    SELECT s.customer_id,
           m.product_name,
           s.order_date,
           RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
    FROM sales s
    JOIN members mem
    ON s.customer_id = mem.customer_id
    JOIN menu m
    ON s.product_id = m.product_id
    WHERE s.order_date < mem.join_date
) t
WHERE rnk = 1;
-- What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id,
       COUNT(*) AS total_items,
       SUM(m.price) AS total_amount
FROM sales s
JOIN members mem
ON s.customer_id = mem.customer_id
JOIN menu m
ON s.product_id = m.product_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id,
       SUM(
           CASE
               WHEN m.product_name = 'sushi'
               THEN m.price * 20
               ELSE m.price * 10
           END
       ) AS total_points
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id;
-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT s.customer_id,
       SUM(
           CASE
               WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY)
               THEN m.price * 20
               WHEN m.product_name = 'sushi'
               THEN m.price * 20
               ELSE m.price * 10
           END
       ) AS points
FROM sales s
JOIN members mem
ON s.customer_id = mem.customer_id
JOIN menu m
ON s.product_id = m.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id;
