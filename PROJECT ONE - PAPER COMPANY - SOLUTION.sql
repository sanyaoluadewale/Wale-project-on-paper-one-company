SELECT *
FROM accountsnew

SELECT*
FROM ordersnew

SELECT *
FROM sales_repsnew

SELECT *
FROM web_eventsnew

/*Write a query to display for each order, the account ID, the total amount of the order, and the level of the order - ‘Large’ or ’Small’ 
depending on if the order is $3000 or more, or less than $3000*/

SELECT account_id,standard_qty, gloss_qty,poster_qty, total, ROUND(total_amt_usd, 0) AS Total_amount_usd,
	CASE
	WHEN total_amt_usd >= 3000 THEN 'Large'
	ELSE 'Small'
END AS Level_of_order
FROM ordersnew

/*Write a query to display the number of orders in each of three categories, based on the total number of items in each order.
The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'*/

--SOLUTION
SELECT 
CASE 
WHEN total >= 2000 THEN 'At Least 2000'
WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
ELSE 'Less than 1000' END AS order_category,
COUNT(total) AS order_count
FROM ordersnew
GROUP BY total

/*We would like to understand 3 different branches of customers based on the amount associated with their purchases. 
The top branch includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. The second
branch is between 200,000 and 100,000 usd. The lowest branch is anyone under 100,000 usd. 
Provide a table that includes the level associated with each account. You should provide the account name, the total sales of all orders for
the customer, and the level. Order with the top spending customers listed first*/

---SOLUTION---
SELECT name, SUM(total_amt_usd) AS total_sales_usd,
CASE
	WHEN SUM(total_amt_usd) > 200000 THEN 'BIGGER_BUYER'
	WHEN SUM(total_amt_usd) > 100000 THEN 'Moderate_buyer'
	ELSE 'Poor_buyer'
END AS Customers_level
FROM ordersnew
JOIN accountsnew
ON ordersnew.account_id =accountsnew.id
GROUP BY accountsnew.name
ORDER BY total_sales_usd DESC

SELECT a.name, SUM(total_amt_usd) total_spent, 
CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
ELSE 'low' END AS customer_level
FROM ordersnew o
JOIN accountsnew a
ON o.account_id = a.id 
GROUP BY a.name
ORDER BY 2 DESC;

/*We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by customers only in 2016 and 2017. 
Keep the same levels as in the previous question. Order with the top spending customers listed first*/

SELECT name, YEAR(occurred_at) AS Year,SUM(total_amt_usd) AS total_sales_usd,
CASE
	WHEN SUM(total_amt_usd) > 200000 THEN 'BIGGER_BUYER'
	WHEN SUM(total_amt_usd) > 100000 THEN 'Moderate_buyer'
	ELSE 'Poor_buyer'
END AS Customers_level
FROM ordersnew
JOIN accountsnew
ON ordersnew.account_id =accountsnew.id
WHERE YEAR(occurred_at) IN (2016, 2017)
GROUP BY accountsnew.name, occurred_at
ORDER BY total_sales_usd DESC

/*We would like to identify top-performing sales reps, which are sales reps associated with more than 200 orders. 
Create a table with the sales rep name, the total number of orders, and a column with top or not depending on if they have more than 200 orders. 
Place the top salespeople first in your final table. It is worth mentioning that this assumes each name is unique - 
which has been done a few times. We otherwise would want to break by the name and the id of the table*/

SELECT sales_repsnew.name, COUNT(total) AS Total_orders,
CASE
	WHEN COUNT(total) >=200 THEN 'Top_performing'
	ELSE 'Low_performing'
END AS Performance_status
FROM sales_repsnew
JOIN accountsnew ON accountsnew.sales_rep_id = sales_repsnew.id
JOIN ordersnew ON accountsnew.id = ordersnew.account_id
GROUP BY sales_repsnew.name
ORDER BY COUNT(total) DESC

/*The previous didn't account for the middle, nor the dollar amount associated with the sales. Management decides they want to see these characteristics
represented as well. We would like to identify top-performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in
total sales. The middle group has any rep with more than 150 orders or 500000 in sales. Create a table with the sales rep name, 
the total number of orders, total sales across all orders, and a column with top, middle, or low depending on these criteria. 
Place the top salespeople based on the dollar amount of sales first in your final table. You might see a few upset salespeople by this criteria*/

--SOLUTION--
SELECT sales_repsnew.name, COUNT(total) AS Total_order, SUM(total_amt_usd) AS Total_amount_usd,
CASE
	WHEN COUNT(total) >200 OR SUM(total_amt_usd) >750000 THEN 'Top_performing'
	WHEN COUNT(total) > 150 OR SUM(total_amt_usd) >=500000 THEN 'Middle_group'
	ELSE 'Low_performing'
END AS Performance_status
FROM sales_repsnew
JOIN accountsnew ON accountsnew.sales_rep_id = sales_repsnew.id
JOIN ordersnew ON accountsnew.id = ordersnew.account_id
GROUP BY sales_repsnew.name
ORDER BY Total_amount_usd DESC

--How many of the sales reps have more than 5 accounts that they manage--

SELECT sales_repsnew.name, COUNT(accountsnew.name) AS Total_account_managed
FROM accountsnew
JOIN sales_repsnew
ON accountsnew.sales_rep_id = sales_repsnew.id
GROUP BY sales_repsnew.name
HAVING COUNT(accountsnew.name)>5
ORDER BY Total_account_managed DESC

WITH WALE AS
(SELECT sales_repsnew.name, COUNT(accountsnew.name) AS Total_account_managed
FROM accountsnew
JOIN sales_repsnew
ON accountsnew.sales_rep_id = sales_repsnew.id
GROUP BY sales_repsnew.name)
SELECT * FROM WALE
WHERE Total_account_managed >5
ORDER BY Total_account_managed DESC

---How many accounts have more than 20 orders
SELECT accountsnew.name, COUNT(accountsnew.name) As Total_account_count
FROM accountsnew
JOIN ordersnew
ON accountsnew.id=ordersnew.account_id
GROUP BY accountsnew.name
HAVING COUNT(accountsnew.name) >20

---------------------------------------------

---How many accounts spent more than 30,000 usd total across all orders?

SELECT name, ROUND(SUM(total_amt_usd),0) AS Total_amount_usd_above30000
FROM accountsnew
JOIN ordersnew
ON accountsnew.id=ordersnew.account_id
WHERE total_amt_usd>=30000
GROUP BY name
ORDER BY Total_amount_usd_above30000 DESC

---Which accounts used facebook as a channel to contact customers more than 6 times?

SELECT accountsnew.name,COUNT(channel) AS Frequency
FROM accountsnew
JOIN web_eventsnew
ON accountsnew.id=web_eventsnew.account_id
WHERE channel = 'facebook'
GROUP BY accountsnew.name
HAVING COUNT(channel) >6
ORDER BY Frequency DESC

WITH WALE AS
(SELECT accountsnew.name,COUNT(channel) AS Frequency
FROM accountsnew
JOIN web_eventsnew
ON accountsnew.id=web_eventsnew.account_id
WHERE channel = 'facebook'
GROUP BY accountsnew.name)
SELECT * FROM WALE
WHERE Frequency > 6
ORDER BY Frequency DESC

/*Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least.
Do you notice any trends in the yearly sales totals*/

SELECT YEAR(occurred_at) AS New_date, ROUND(SUM(total_amt_usd), 0) AS Total_sales
FROM ordersnew
GROUP BY YEAR(occurred_at)
ORDER BY Total_sales DESC


/*Which month did the paper company have the greatest sales in terms of total dollars? 
Are all months evenly represented by the dataset? In order for this to be 'fair', we should remove the sales from 2013 and 2017. 
For the same reasons as discussed above*/

SELECT occurred_at, MAX(total_amt_usd) AS Maximum_sales
FROM ordersnew
GROUP BY occurred_at
ORDER BY Maximum_sales DESC

---.In which month of which year did Walmart spend the most on gloss paper in terms of dollars?

SELECT MONTH(occurred_at)AS MONTH, ROUND(SUM(gloss_amt_usd),0) AS Total_gloss_amt_usd
FROM accountsnew
JOIN ordersnew
ON accountsnew.id=ordersnew.account_id
WHERE accountsnew.name = 'Walmart'
GROUP BY MONTH(occurred_at)
ORDER BY Total_gloss_amt_usd DESC

---WALMART SPENT MOST IN MAY





