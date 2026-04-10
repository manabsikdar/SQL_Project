
-- creating of database

create database onlinebookstore;
use  onlinebookstore;

-- creating of Table for Books

CREATE TABLE Books (
    Book_ID int PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);

select * from books;

-- creating of Table for Customers

create table Customers (
Customer_ID int primary key,
Name varchar(100),
Email varchar(100),
Phone int,
City varchar(100),
Country varchar(100)
);

select * from Customers;

-- creating of Table for Orders

Create table Orders (
Order_ID int primary key,
Customer_ID int references customers(Customers_Id),
Book_ID int references Books(Book_Id),
Order_Date date,
Quantity int,
Total_Amount numeric(10,2)
);
select * from orders;


select * from Books;
select * from Customers;
select * from Orders;

-- Inserted of values in tables by import wizard method from local disk storage

-- Basic Questions:-
-- 1) Retrieve all books in the "Fiction" genre:
SELECT 
    *
FROM
    Books
WHERE
    Genre = 'Fiction';

-- 2) Find books published after the year 1950:
	SELECT 
    *
FROM
    Books
WHERE
    Published_Year > 1950;

-- 3) List all customers from the Canada:
	SELECT 
    *
FROM
    customers
WHERE
    Country = 'Canada';

-- 4) Show orders placed in November 2023:
	SELECT 
    *
FROM
    Orders
WHERE
    Order_Date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5) Retrieve the total stock of books available:
	SELECT 
    SUM(Stock) AS Total_Stock
FROM
    Books;    

-- 6) Find the details of the most expensive book:
	SELECT 
    *
FROM
    books
ORDER BY Price DESC
LIMIT 1;

-- 7) Show all customers who ordered more than 1 quantity of a book:
	SELECT 
    *
FROM
    orders
WHERE
    Quantity > 1;

-- 8) Retrieve all orders where the total amount exceeds $20:
	SELECT 
    *
FROM
    Orders
WHERE
    Total_Amount > 20;

-- 9) List all genres available in the Books table:
	SELECT DISTINCT
    (Genre)
FROM
    Books;

-- 10) Find the book with the lowest stock:
	SELECT 
    *
FROM
    Books
ORDER BY Stock ASC
LIMIT 1; 

-- 11) Calculate the total revenue generated from all orders:
	SELECT 
    SUM(Total_Amount) AS Total_Revenue
FROM
    orders;
-- Advance Questions : 

-- 1) Retrieve the total number of books sold for each genre:
	SELECT 
    b.genre, SUM(o.quantity) AS Total_books_sold
FROM
    books b
        JOIN
    orders o ON b.Book_ID = o.Book_ID
GROUP BY b. Genre;


-- 2) Find the average price of books in the "Fantasy" genre:
	SELECT 
    AVG(price) AS average_price_of_fantasy
FROM
    books
WHERE
    Genre = 'Fantasy';


-- 3) List customers who have placed at least 2 orders:
SELECT 
    o.Customer_Id, c.name, COUNT(o.Order_Id) AS Total_orders
FROM
    orders o
        JOIN
    customers c ON c.Customer_ID = o.Customer_ID
GROUP BY o.Customer_ID , c.name
HAVING COUNT(o.Order_ID) >= 2;

-- 4) Find the most frequently ordered book:
SELECT 
    b.Title, o.book_id, COUNT(o.Order_ID) AS Total_orders
FROM
    orders o
        JOIN
    books b ON b.Book_ID = o.Book_ID
GROUP BY o.Book_ID
ORDER BY Total_orders DESC
LIMIT 10; -- for the top 10 most frequently ordered books.

-- 5) Show the top 3 most expensive books of 'Fantasy' Genre :
SELECT 
    *
FROM
    books
WHERE
    genre = 'Fantasy'
ORDER BY price DESC
LIMIT 3;

-- 6) Retrieve the total quantity of books sold by each author:
SELECT 
    b.Title, b.Author, SUM(o.Quantity) AS Total_quantity_of_books
FROM
    books b
        JOIN
    orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Author , b.title;

-- 7) List the cities where customers who spent over $30 are located:
SELECT DISTINCT
    c.City, o.Total_Amount
FROM
    customers c
        JOIN
    orders o ON c.Customer_ID = o.Customer_ID
WHERE
    o.Total_Amount > 30;

-- 8) Find the customer who spent the most on orders:
SELECT 
    c.Customer_ID, c.Name, SUM(o.Total_Amount)as total_spend
FROM
    orders o
        JOIN
    customers c ON o.customer_id = c.customer_id
GROUP BY c.Customer_ID , c.Name
ORDER BY total_spend DESC
LIMIT 5;

-- 9) Calculate the stock remaining after fulfilling all orders:

SELECT 
    b.book_id,
    b.title,
    b.stock,
    COALESCE(SUM(o.Quantity), 0) AS ordered_quantity,
    b.Stock - COALESCE(SUM(o.Quantity), 0) AS remaining_stock
FROM
    books b
        LEFT JOIN
    orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID;