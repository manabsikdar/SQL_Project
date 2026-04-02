-- Creating database
 create dominos;
 -- Acessing the database 
use dominos;
-- Creating of Tables
 CREATE TABLE customers (
    custid INTEGER NOT NULL,
    first_name CHARACTER VARYING(8) NOT NULL,
    last_name CHARACTER VARYING(7) NOT NULL,
    email CHARACTER VARYING(19) NOT NULL,
    phone BIGINT NOT NULL,
    address CHARACTER VARYING(11) NOT NULL,
    city CHARACTER VARYING(5) NOT NULL,
    state CHARACTER VARYING(6) NOT NULL,
    postal_code INTEGER NOT NULL
);
SELECT 
    *
FROM
    customers;

CREATE TABLE order_details (
    order_details_id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    pizza_id CHARACTER VARYING(14) NOT NULL,
    quantity INTEGER NOT NULL
);
SELECT 
    *
FROM
    order_details;
    
CREATE TABLE orders (
    order_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    order_time CHARACTER VARYING(8) NOT NULL,
    custid INTEGER NOT NULL,
    status CHARACTER VARYING(9) NOT NULL
);
SELECT 
    *
FROM
    orders;
    
    CREATE TABLE pizza_types (
    pizza_type_id CHARACTER VARYING(50) NOT NULL,
    name CHARACTER VARYING(100) NOT NULL,
    category CHARACTER VARYING(50) NOT NULL,
    ingredients TEXT NOT NULL
);
SELECT 
    *
FROM
    pizza_types;

  CREATE TABLE pizzas (
    pizza_id CHARACTER VARYING(14) NOT NULL,
    pizza_type_id CHARACTER VARYING(12) NOT NULL,
    size CHARACTER VARYING(3) NOT NULL,
    price NUMERIC(5 , 2 ) NOT NULL
);

SELECT 
    *
FROM
    pizzas;

-- Question: 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id)
FROM
    orders;
    
-- Question: 2. Calculate the total revenue generated from pizza sales. 
SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS Total_Revenue
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id;
    
-- Question: 3. Identify the highest-priced pizza.
SELECT 
    pt.name, pt.category, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Question: 4. Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS Total_order
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY Total_order DESC
LIMIT 1;

-- Question: 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) Total_order
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY Total_order DESC
LIMIT 5;

-- Question: 6. Find the total quantity of each pizza category ordered.
  SELECT 
    pt.category, SUM(od.quantity) Total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY Total_quantity DESC
;

-- Question: 7. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(o.order_time) AS Hour,
    ROUND(SUM(p.price * od.quantity), 2) AS Total_order
FROM
    order_details od
        JOIN
    orders o ON o.order_id = od.order_id
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
GROUP BY Hour
ORDER BY Hour DESC;

-- Question: 8. Find the category-wise distribution of pizzas (Variety).
SELECT 
    category, COUNT(name) AS Variety_Count
FROM
    pizza_types
GROUP BY category; 

-- Question: 9. Calculate the average number of pizzas ordered per day. 
SELECT 
    ROUND(AVG(Total_order), 2) AS Avg_Pizza_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS Total_order
    FROM
        order_details od
    JOIN orders o ON od.order_id = o.order_id
    GROUP BY o.order_date) t;
    
--  Question: 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, ROUND(SUM(p.price * od.quantity), 2) AS Revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY Revenue DESC
LIMIT 3;

-- Question: 11. Calculate the percentage contribution of each pizza category to total revenue.
SELECT 
    pt.category,
    ROUND(SUM(p.price * od.quantity) / (SELECT 
                    SUM(p.price * od.quantity)
                FROM
                    order_details od
                        JOIN
                    pizzas p ON od.pizza_id = p.pizza_id) * 100,
            2) AS Percentage_revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY Percentage_revenue DESC;

-- Question: 12. Analyze the order status distribution (Success vs. Failed).
SELECT 
    status,
    COUNT(*) AS Total_order,
    ROUND(COUNT(*) * 100 / (SELECT 
                    COUNT(*)
                FROM
                    orders),
            2) AS percentage
FROM
    orders
GROUP BY status
ORDER BY percentage DESC;

-- Question: 13. Calculate the cumulative revenue generated over time (by date).
SELECT order_date,
       SUM(revenue) OVER(ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT o.order_date, SUM(od.quantity * p.price) AS revenue
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN orders o ON o.order_id = od.order_id
    GROUP BY o.order_date
) t;

-- Question: 14. Determine the top 3 most ordered pizza types based on revenue for each category.
SELECT category, name, revenue
FROM (
    SELECT category, name, revenue,
    RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rank_value
    FROM (
        SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
        FROM pizza_types pt
        JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN order_details od ON od.pizza_id = p.pizza_id
        GROUP BY pt.category, pt.name
    )a
)b
WHERE rank_value <= 3;

-- Question: 15. Identify the "Loyal Customers": List names of customers who spent the most.
SELECT 
    c.first_name,
    c.last_name,
    ROUND(SUM(od.quantity * p.price), 2) AS total_spent
FROM
    customers c
        JOIN
    orders o ON c.custid = o.custid
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY c.first_name , c.last_name
ORDER BY total_spent DESC
;

-- Question: 16. Calculate the Average Order Value (AOV).
SELECT 
    ROUND(SUM(od.quantity * p.price) / COUNT(DISTINCT od.order_id),
            2) AS avg_order_value
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

-- Question: 17. Determine the revenue generated by each city.
SELECT 
    c.city, ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM
    customers c
        JOIN
    orders o ON c.custid = o.custid
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY c.city
ORDER BY revenue DESC;

-- Question: 18. Monthly Revenue Trend Analysis.
SELECT 
    MONTH(order_date) AS month,
    MONTHNAME(order_date) AS month_name,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY month, month_name
ORDER BY month;

-- Question: 19. Identify the peak business days (Day of the Week).
SELECT 
    DAYNAME(o.order_date) AS Day_of_Week,
    COUNT(DISTINCT o.order_id) AS Total_order,
    ROUND(SUM(p.price * od.quantity), 2) AS Revenue
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
WHERE
    o.status IN ('success' , 'delivered')
GROUP BY Day_of_week
ORDER BY Revenue DESC;    

-- Question: 20. Find the most popular pizza size per category.
SELECT category, size, total_qty
FROM (
    SELECT pt.category, p.size, SUM(od.quantity) as total_qty,
           RANK() OVER(PARTITION BY pt.category ORDER BY SUM(od.quantity) DESC) as rnk
    FROM pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON p.pizza_id = od.pizza_id
    GROUP BY pt.category, p.size
) t WHERE rnk = 1;