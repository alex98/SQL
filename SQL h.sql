#Instructions
use sakila;

# 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select upper(CONCAT(first_name, ' ', last_name)) 
as "Actor Name" from actor; 


#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name = "joe";

#2b. Find all actors whose last name contain the letters GEN:
select * from actor where last_name like "%GEN%";


#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor where last_name like "%LI%"
order by last_name, first_name;


#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ("Afghanistan", "Bangladesh", "China");

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
Alter table actor 
add column description BLOB;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor drop column description;

#4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) from actor group by last_name;


#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name As 'Last Name', COUNT(*) AS 'Count'
FROM actor
GROUP BY last_name;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
WHEN first_name = 'HARPO' THEN 'GROUCHO';

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

SHOW CREATE TABLE address;




#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT S.first_name AS 'First Name', S.last_name AS 'Last Name', A.address AS 'Address' 
FROM staff S
	JOIN address A
	ON S.address_id = A.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT  S.first_name AS 'First Name', S.last_name As 'Last Name', SUM(P.amount) AS 'Total Amount'
FROM staff S
INNER JOIN payment P
ON S.staff_id = P.staff_id
WHERE (P.payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-09-01 00:00:00')
GROUP BY S.first_name, S.last_name;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT F.film_id As 'Film ID', F.title As 'Film Title', COUNT(A.actor_id) As 'Count of Actors'
FROM film F
INNER JOIN film_actor A
ON F.film_id = A.film_id
GROUP BY F.film_id;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT `Count of Actors` FROM 
(SELECT F.film_id As 'Film ID', F.title As 'Film Title', COUNT(A.actor_id) As 'Count of Actors'
FROM film F
INNER JOIN film_actor A
ON F.film_id = A.film_id
GROUP BY F.film_id) FILMS
WHERE `Film Title` = 'Hunchback Impossible';

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT C.customer_id, C.last_name, SUM(P.amount)
FROM customer C
JOIN payment P
GROUP BY C.customer_id
ORDER BY C.last_name;


#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT F.title FROM film F
WHERE LEFT(F.title,1) IN ('K','Q') AND F.language_id IN (SELECT language_id FROM language WHERE name='English');


#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT * FROM actor WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id IN (SELECT film_id FROM film WHERE title='Alone Trip'));

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select C.first_name, C.last_name, C.email, CT.city, CN.country 
FROM customer C
JOIN address A
ON C.address_id = A.address_id
	JOIN city CT
	ON A.city_id = CT.city_id

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT F.* 
FROM film F
JOIN film_category FC
ON F.film_id = FC.film_id
	JOIN category C
	ON FC.category_id = C.category_id
WHERE C.name = 'Family';


#7e. Display the most frequently rented movies in descending order.
SELECT * FROM film
ORDER BY rental_duration DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT S.store_id, SUM(P.amount) As 'Business($)'
FROM payment P
JOIN staff ST
ON P.staff_id = ST.staff_id
	JOIN store S
	ON ST.store_id = S.store_id
GROUP BY S.store_id;


#7g. Write a query to display for each store its store ID, city, and country.
SELECT S.store_id, CT.city, CN.country
FROM store S
JOIN address A
ON s.address_id = A.address_id
	JOIN city CT
	ON A.city_id = CT.city_id
		JOIN country CN
		ON CT.country_id = CN.country_id;

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT CG.category_id, CG.name, SUM(P.amount)
FROM category CG
JOIN film_category FC
ON CG.category_id = FC.category_id
	JOIN inventory I 

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres
AS (SELECT CG.category_id, CG.name, SUM(P.amount)
FROM category CG
JOIN film_category FC
ON CG.category_id = FC.category_id
	JOIN inventory I 
	ON FC.film_id = I.film_id

#8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;


#8c. You find that you no longer need the view top_five_genres. Write a query to delete it. */
DROP VIEW top_five_genres;