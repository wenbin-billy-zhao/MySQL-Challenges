use sakila;

-- question 1a
select first_name, last_name from actor;

-- question 1b
select concat(concat(substring(first_name, 1, 1), lower(substring(first_name, 2))), " ",
	   concat(substring(last_name, 1, 1), lower(substring(last_name, 2)))) as Name
from actor

-- question 2a
select actor_id, first_name, last_name
from actor
where first_name = 'Joe'

-- question 2b
select * 
from actor
where last_name like "%Gen%"

-- question 2c
select *
from actor
where last_name like "%Li%" 
order by last_name, first_name

-- question 2d
select country_id, country
from country
where country in ("Afghanistan", "Bangladesh", "China")

-- question 3a
alter table actor
add (Description blob)

-- question 3b
alter table actor
drop column description

-- question 4a
select count(last_name), last_name
from actor
group by last_name

-- question 4b
select count(last_name) sameName, last_name
from actor
group by last_name
having sameName >= 2

-- question 4c
update actor
set first_name = 'Harpo'
where first_name = 'Groucho'

-- question 4d
update actor
set first_name = 'Groucho'
where first_name = 'Harpo'

-- question 5a
show create table address

-- question 6a
select first_name, last_name, address 
from staff a
left join address b 
on a.address_id = b.address_id

-- question 6b
select last_name, first_name, sum(amount)
from staff a
left join payment b
on a.staff_id = b.staff_id

-- question 6c
select title, count(actor_id)
from film a
inner join film_actor b
on a.film_id = b.film_id
group by title

-- question 6d
select b.title, count(a.inventory_id) as Copies
from inventory a
join film b
on a.film_id = b.film_id
where b.title = 'Hunchback Impossible'

-- question 6e
select first_name, last_name, sum(amount)
from customer a
join payment b on a.customer_id = b.customer_id
group by first_name, last_name
order by last_name

-- question 7a
select 
from film
where 

-- question 7b
select first_name, last_name 
from actor a
join film_actor b
on a.actor_id = b.actor_id
where b.film_id = (select film_id from film where title = 'Alone Trip')

-- question 7c
select first_name, last_name, email, country
from customer a
join address b on a.address_id = b.address_id
join city c on b.city_id = c.city_id
join country d on c.country_id = d.country_id
where d.country = 'Canada'

-- question 7d - Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title, description, rating, release_year, name as 'type'
from film a
join film_category b on a.film_id = b.film_id
join category c on b.category_id = c.category_id
where c.name = 'Family'

-- question 7e - Display the most frequently rented movies in descending order.
select c.title, count(a.inventory_id) as rentalCount
from rental a
join inventory b on a.inventory_id = b.inventory_id
join film c on b.film_id = c.film_id
group by c.title
order by rentalcount desc

-- question 7f - Write a query to display how much business, in dollars, each store brought in
select c.store_id as StoreID, sum(a.amount)
from payment a
join staff b on a.staff_id = b.staff_id
join store c on b.store_id = c.store_id
group by c.store_id

-- question 7g - Write a query to display for each store its store ID, city, and country.
select a.store_id, c.city, d.country
from store a 
join address b on a.address_id = b.address_id
join city c on b.city_id = c.city_id
join country d on c.country_id = d.country_id

-- question 7h - List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select e.name as filmCategory, sum(a.amount) as totalRevenue
from payment a
join rental b on a.rental_id = b.rental_id
join inventory c on b.inventory_id = c.inventory_id
join film_category d on c.film_id = d.film_id
join category e on d.category_id = e.category_id
group by filmcategory
order by totalrevenue desc

-- question 8a - In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
-- reference: https://dev.mysql.com/doc/refman/8.0/en/create-view.html
create view v_top_five_genres
as (
	select e.name as filmCategory, sum(a.amount) as totalRevenue
	from payment a
	join rental b on a.rental_id = b.rental_id
	join inventory c on b.inventory_id = c.inventory_id
	join film_category d on c.film_id = d.film_id
	join category e on d.category_id = e.category_id
	group by filmcategory
	order by totalrevenue desc
	limit 5
)


-- 8b - How would you display the view that you created in 8a?
select * from v_top_five_genres

-- 8c - You find that you no longer need the view top_five_genres. Write a query to delete it.
-- https://dev.mysql.com/doc/refman/8.0/en/drop-view.html
drop view if exists v_top_five_genres