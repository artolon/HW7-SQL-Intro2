-- 1.	Create a new column called “status” in the rental table that uses a case statement to indicate if a film was returned late, early, or on time. 

ALTER TABLE rental 
ADD COLUMN status varchar(10);

UPDATE rental -- update the rental table that we just altered 
-- edit the status column
SET status = 

-- add our case statement to determine whether something is early, on time, or late
CASE WHEN DATE_PART('day',rental.return_date-rental.rental_date) < film.rental_duration THEN 'Early'
		WHEN DATE_PART('day',rental.return_date-rental.rental_date) = film.rental_duration THEN 'On Time'
		ELSE 'Late' END
FROM inventory, film -- we need the inventory table to obtain film_id, so that we can join on the film table to get duration 
-- join the tables on the proper matching columns
WHERE rental.inventory_id=inventory.inventory_id 
AND inventory.film_id=film.film_id;

-- Select everything from rental to confirm the query worked properly
SELECT *
FROM rental;

------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2.	Show the total payment amounts for people who live in Kansas City or Saint Louis. 
-- Select the variables I need and alias the aggregate measure as 'total amount'
SELECT p.customer_id, SUM(p.amount) AS total_amount, 
	   c.first_name, c.last_name, cy.city
FROM payment p

JOIN customer c -- join customer table on customer_id to obtain address_id
ON p.customer_id = c.customer_id

JOIN address a -- join address table on address_id to obtain city_id
ON c.address_id=a.address_id

JOIN city cy -- Finally, join city table on city_id to obtain the city name
ON a.city_id=cy.city_id

WHERE city='Kansas City' OR city='Saint Louis' -- Filter by KC or STL
-- Group by customer_id to aggregate the total amount paid by KC or STL residents
GROUP BY p.customer_id, c.first_name, c.last_name, cy.city;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3.	How many films are in each category? Why do you think there is a table for category and a table for film category?
-- Select the variables I need and alias the aggregate measure as 'film count'
-- I need film_id to determine number of films and category_id/name to determine category
SELECT COUNT(f.film_id) AS film_count, f.category_id, c.name
FROM film_category f

JOIN category c -- Join category table in order to get the category name
ON f.category_id=c.category_id

GROUP BY f.category_id, c.name -- group by category_id
ORDER BY f.category_id; -- order by category_id

/* I believe the category and film_category tables are separate because it is possible that the total number of possible categories in the category_table would not
necessarily relate to one of the films. There might also be new categories overtime that get added to the category list. According to the data model, something in the 
category table does not HAVE to be in the film_category table. But all of the categories in film_category table must also be in the category table.*/

------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4.	Show a roster for the staff that includes their email, address, city, and country (not ids)
-- I need staff, address, city, and country tables
-- Select appropriate fields and alias accordingly 
SELECT s.first_name, s.last_name, s.email, a.address, c.city, c2.country
FROM staff s -- only 2 staff members??

JOIN address a -- join address by address_id in order to get the city_id
ON s.address_id=a.address_id

JOIN city c -- join city by city_id in order to get the country_id
ON a.city_id=c.city_id

JOIN country c2 -- join country by country_id
ON c.country_id=c2.country_id;

-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5.	Show the film_id, title, and length for the movies that were returned from May 15 to 31, 2005
-- Select the necessary variables
SELECT f.film_id, f.title, f.length
FROM rental r

JOIN inventory i -- Join inventory table on inventory_id to get film_id
ON r.inventory_id=i.inventory_id

JOIN film f -- Join film on film_id to get all other variables we need
ON i.film_id=f.film_id 

-- filter by return date between 5/15/05 and 5/31/05
WHERE r.return_date BETWEEN '2005-05-15 00:00:01' AND '2005-05-31 23:59:59'
ORDER BY r.return_date; -- order by return date

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 6.	Write a subquery to show which movies are rented below the average price for all movies. 
-- For this query, I will need to use the film table and utilize the 'rental_rate' column.
-- I'll take the average rental rate for all of the movies in the film table and use that
-- as my subquery. I'll nest the subquery in the WHERE clause so that I can filter the
-- film table by my subquery result.

SELECT film_id, title, rental_rate
FROM film 
WHERE rental_rate <
			(SELECT AVG(rental_rate) 
			FROM film) -- average rental rate is $2.98
ORDER BY rental_rate;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 7.	Write a join statement to show which movies are rented below the average price for all movies.
-- Again, I will need to use the film table and utilize the rental_rate column
-- I will join the table with itself through a cross join, so that I can compare the 
-- first instance of the table to an aggregation of the second table.

SELECT f1.film_id, f1.title, f1.rental_rate, AVG(f2.rental_rate)
FROM film f1
CROSS JOIN film f2
GROUP BY f1.film_id
-- filter with 'having' since where statement cannot use aggregate functions
HAVING f1.rental_rate < AVG(f2.rental_rate); 


-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 8.	Perform an explain plan on 6 and 7, and describe what you’re seeing and important ways they differ.

-- Explain plan for # 6:
EXPLAIN ANALYZE
SELECT film_id, title, rental_rate
FROM film 
WHERE rental_rate <
			(SELECT AVG(rental_rate) 
			FROM film); -- average rental rate is $2.98

/* The planner scanned the rows in the inner film table with an estimated cost of 133.01 and an  
actual time of 1.412. Next, the planner is filtering where the rental_rate is less than the 
average amount. 659 rows are removed through this process. The first init plan is returned.
Then, planner performs the aggregation with an estimated cost of 66.51 and an actual cost 
of 0.692. The planner scans on the outer film table. The planning time was 0.227 ms and the 
query took 1.472 ms to execute. There were 8 total steps.*/

-- Explain plan for #7:
EXPLAIN ANALYZE
SELECT f1.film_id, f1.title, f1.rental_rate, AVG(f2.rental_rate)
FROM film f1
CROSS JOIN film f2
GROUP BY f1.film_id
-- filter with 'having' since where statement cannot use aggregate functions
HAVING f1.rental_rate < AVG(f2.rental_rate); 

/*The planner performs a group aggregation with an estimated time of
17674.42 and an actual time of 949.737; The planner groups on f1.film_id and 
filters were rental rate on the first film table is less than the average rental
rate on the second film table. 659 rows are removed. There is a nested loop that takes 
465.360 to execute. The planner scans using the primary key of film on film, then 
scans the film2 table. Total planning time was 0.973 and execution time was 1009.067.
There were 10 total steps.*/

/*The join method took longer to execute and had a few more steps than the subquery. This might be due to the way the aggregation is being performed.
Typically, subqueries take more processing time. This subquery might have been more efficient due to how simple the query is and
due to this query having a few less steps to run through.*/


--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 9.	With a window function, write a query that shows the film, its duration, and what percentile the duration fits into. 
--This may help https://mode.com/sql-tutorial/sql-window-functions/#rank-and-dense_rank 

-- I selected the film_id, title, and rental_duration columns. 
-- I am also using the NTILE(100) function because I want to reach the 100th percentile.
-- I am doing with 'over' the entire table, and ordering by the rental duration, so that
-- my rental_duration is in the proper percentile. I am also giving the column and alias. 
SELECT film_id, title, rental_duration, 
	   NTILE(100) OVER(ORDER BY rental_duration) AS percentile
FROM film
ORDER BY rental_duration;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 10.	In under 100 words, explain what the difference is between set-based and procedural programming. Be sure to specify which sql and python are.
/* SQL is set-based programming, and python is procedural. Procedural programming is processed line by line. With procedural, we are telling the program
what to do to the data and how to do it. Constrastingly, set-based programming allows you to dictate what you do with the data, but not how. The 'how' is 
determined in the background, instead and the data engine determines the best and most efficient way to accomplish what you need. */

 
------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Bonus:
Find the relationship that is wrong in the data model. Explain why it’s wrong.*/

/*One relationship that seems to be wrong in the data model is between the 'staff' table and the 'store' table. The data model shows that every store would have to
be connected to a staff person. But a staff person doesn't necessarily need to be in the store table. This does not seem correct to me because I would imagine that
all staff need to work at at least one store location, and therefore, be in the store table. It seems it should have the 3 prongs instead, showing that one staff
person could work at multiple stores (and must work at at least one).   