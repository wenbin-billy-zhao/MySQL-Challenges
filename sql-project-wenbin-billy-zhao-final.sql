USE sakila;

-- question 1a - Display the first and last names of all actors FROM the table actor
SELECT first_name, last_name FROM actor;

-- question 1b - Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
SELECT concat(upper(first_name), ' ', upper(last_name)) as 'Full Name'
FROM actor

-- question 1b bonus - I used the following function to normalize (proper) full name to show its proper form
-- good to write up a function for future use
SELECT concat(concat(substring(first_name, 1, 1), lower(substring(first_name, 2))), " ",
	   concat(substring(last_name, 1, 1), lower(substring(last_name, 2)))) as Name
FROM actor;

-- question 2a - You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- question 2b - Find all actors whose last name contain the letters GEN:
SELECT * 
FROM actor
WHERE last_name LIKE "%Gen%";

-- question 2c - Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE "%Li%" 
ORDER BY last_name, first_name;

-- question 2d -  Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- question 3a -  You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER table actor
add (Description BLOB);

-- question 3b - Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER table actor
DROP column description;

-- question 4a - List the last names of actors, as well as how many actors have that last name.
SELECT count(last_name) as nameCount, last_name
FROM actor
GROUP BY last_name;

-- question 4b - List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT COUNT(last_name) sameName, last_name
FROM actor
GROUP BY last_name
HAVING sameName >= 2;

-- question 4c - The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'Harpo'
WHERE first_name = 'Groucho';

-- question 4d - Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'Groucho'
WHERE first_name = 'Harpo';

-- question 5a - You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

## alternative to describe a table as Explain or Describe
EXPLAIN address;

-- question 6a - Use JOIN to display the first and last names, as well as the address, 
-- of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address 
FROM staff a
left JOIN address b 
on a.address_id = b.address_id;

-- question 6b - Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT a.last_name, a.first_name, sum(b.amount)
FROM staff a
left JOIN payment b
on a.staff_id = b.staff_id
WHERE (b.payment_date BETWEEN '2005-08-01' AND '2005-09-01')
GROUP BY a.last_name;

-- question 6c - List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, count(actor_id)
FROM film a
inner JOIN film_actor b
on a.film_id = b.film_id
GROUP BY title;

-- question 6d - How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT b.title, count(a.inventory_id) as Copies
FROM inventory a
JOIN film b
on a.film_id = b.film_id
WHERE b.title = 'Hunchback Impossible';

-- question 6e - Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. List the customers alphabetically by last name:
SELECT first_name, last_name, sum(amount)
FROM customer a
JOIN payment b on a.customer_id = b.customer_id
GROUP BY first_name, last_name
ORDER BY last_name;

-- question 7a - The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies 
-- starting with the letters K and Q whose language is English.
SELECT title
FROM film a
WHERE title like 'K%'or title like 'Q%'
and a.language_id = (
	SELECT language_id FROM `language` WHERE name = 'English'
);

-- question 7b - Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN (
	SELECT actor_id FROM film_actor 
	WHERE film_id = (
		SELECT film_id FROM film WHERE title = 'Alone Trip'
	)
);

-- question 7c - You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email, country
FROM customer a
JOIN address b on a.address_id = b.address_id
JOIN city c on b.city_id = c.city_id
JOIN country d on c.country_id = d.country_id
WHERE d.country = 'Canada';

-- alternatively, writing the 7c query above in nested subqueries
SELECT first_name, last_name, email 
FROM customer
WHERE address_id in (
	SELECT address_id FROM address
	WHERE city_id in (
		SELECT city_id FROM city
		WHERE country_id = (
			SELECT country_id FROM country
			WHERE country = 'Canada'
		)
	)
);


-- question 7d - Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- comment: no wonder the sales are lagging. The data set is bad. NC-17 and R rated movies were marked as family movies.
SELECT title, description, rating, release_year, name as 'type'
FROM film a
JOIN film_category b on a.film_id = b.film_id
JOIN category c on b.category_id = c.category_id
WHERE c.name = 'Family';

-- question 7e - Display the most frequently rented movies in descending order.
SELECT c.title, COUNT(a.inventory_id) as rentalCount
FROM rental a
JOIN inventory b on a.inventory_id = b.inventory_id
JOIN film c on b.film_id = c.film_id
GROUP BY c.title
ORDER BY rentalcount DESC;

-- question 7f - Write a query to display how much business, in dollars, each store brought in
-- alternatively, you can join payment -> rental -> inventory - this will produce a slightly different result
SELECT c.store_id as StoreID, SUM(a.amount)
FROM payment a
JOIN staff b on a.staff_id = b.staff_id
JOIN store c on b.store_id = c.store_id
GROUP BY c.store_id;

-- question 7g - Write a query to display for each store its store ID, city, and country.
SELECT a.store_id, c.city, d.country
FROM store a 
JOIN address b on a.address_id = b.address_id
JOIN city c on b.city_id = c.city_id
JOIN country d on c.country_id = d.country_id;

-- question 7h - List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT e.name as filmCategory, SUM(a.amount) as totalRevenue
FROM payment a
JOIN rental b on a.rental_id = b.rental_id
JOIN inventory c on b.inventory_id = c.inventory_id
JOIN film_category d on c.film_id = d.film_id
JOIN category e on d.category_id = e.category_id
GROUP BY filmcategory
ORDER BY totalrevenue DESC
LIMIT 5;

-- question 8a - In your new role as an executive, you would like to have an easy way of VIEWing the Top five genres by gross revenue. 
-- Use the solution FROM the problem above to CREATE a VIEW. If you haven't solved 7h, you can substitute another query to CREATE a VIEW.
-- reference: https://dev.mysql.com/doc/refman/8.0/en/CREATE-VIEW.html
CREATE VIEW v_top_five_genres
AS (
	SELECT e.name AS filmCategory, sum(a.amount) as totalRevenue
	FROM payment a
	JOIN rental b ON a.rental_id = b.rental_id
	JOIN inventory c on b.inventory_id = c.inventory_id
	JOIN film_category d on c.film_id = d.film_id
	JOIN category e on d.category_id = e.category_id
	GROUP BY filmcategory
	ORDER BY totalrevenue desc
	LIMIT 5
);

-- 8b - How would you display the VIEW that you CREATEd in 8a?
SELECT * FROM v_top_five_genres;

-- 8c - You find that you no longer need the VIEW top_five_genres. Write a query to delete it.
-- https://dev.mysql.com/doc/refman/8.0/en/DROP-VIEW.html
DROP VIEW IF EXISTS v_top_five_genres;


