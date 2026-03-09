CREATE DATABASE dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
customer_id VARCHAR(1),
order_date DATE,
product_id INT
);

CREATE TABLE menu (
product_id INT,
product_name VARCHAR(10),
price INT
);

CREATE TABLE members (
customer_id VARCHAR(1),
join_date DATE
);
