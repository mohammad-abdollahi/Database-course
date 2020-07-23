-- DATABASE DESIGN 1 3981 @ IUT
-- YOUR NAME:   mohammad abdollahi
-- YOUR STUDENT NUMBER:   9530153


---- Q10-a
select customer.first_name, customer.last_name, address.city_id
from customer
inner join address on customer.address_id = address.address_id where address.address_id in
   (select address_id from address where city_id in
       (select city_id from city where country_id in
           (select country_id from country where country.country='Iran')));





---- Q10-b
select first_name, last_name from actor where actor_id in (
   select actor_id from film_actor where  film_id in (
       select film_id from inventory where inventory_id in(
               select inventory_id from rental where customer_id in(
               select customer.customer_id
                   from customer
                       inner join address on customer.address_id = address.address_id where address.address_id in
                       (select address_id from address where city_id in
                           (select city_id from city where country_id in
                               (select country_id from country where country.country='Iran')))))));






---- Q10-c
select customer.first_name, customer.last_name, rental.return_date, rental.rental_date
from customer
inner join address on customer.address_id = address.address_id
inner join rental  on customer.customer_id = rental.customer_id
where address.address_id in
   (select address_id from address where city_id in
       (select city_id from city where country_id in
           (select country_id from country where country.country='Iran'))) and  exists(select rental.customer_id from rental where rental_date=return_date);






---- Q10-d
select first_name, last_name from actor where actor_id in
   (select actor_id from film_actor where film_id in
       (select film_id from film where length>100 or rental_rate>4.00));






---- Q10-e
select name from category inner join film_category fc on category.category_id = fc.category_id
where film_id in(
   select film_id from film where film_id in
                                  (select film_id from inventory where inventory_id=2) and rental_duration>9
                                   and film_id not in (select film_id from inventory where inventory_id=1));






---- Q10-f
select film.title from film where lower(title) like '%g' or lower(title) like '%s%s%';





---- Q10-g
select count(r.customer_id), r.staff_id from customer
inner join rental r on customer.customer_id = r.customer_id
inner join staff s on r.staff_id = s.staff_id
group by  customer.customer_id, r.staff_id;





---- Q10-h
create table category_rating(
   name character varying(25) NOT NULL,
   rental_rate numeric(4,2) DEFAULT 4.99 NOT NULL,
   length smallint,
   category_id smallint
);
insert into category_rating
select c.name, avg(rental_rate), max(length),c.category_id
from film
inner join film_category fc on film.film_id = fc.film_id
inner join category c on fc.category_id = c.category_id
group by (c.name, c.category_id)
order by avg(rental_rate) asc;



---- Q10-i
with counts as(
  select film.rating,count(film.rating) as counter,category.name as cname,category.category_id
  from film
  inner join film_category on (film_category.film_id = film.film_id)
  inner join category on (category.category_id = film_category.category_id)
  group by category.category_id,film.rating
),maxs as (
  select  cname,max(counter)as maxCount from counts group by cname
),maxReady as (
  select distinct on (maxs.cname) maxs.cname, counts.rating, counts.counter,category_id from counts
  inner join maxs on (maxs.cname = counts.cname and maxs.maxCount = counts.counter)
)
update category_rating
set age_group = (case
            when (select maxReady.rating from maxReady where maxReady.category_id = category_rating.category_id) = 'G' then 1
            when (select maxReady.rating from maxReady where maxReady.category_id = category_rating.category_id) = 'PG' then 2
            when (select maxReady.rating from maxReady where maxReady.category_id = category_rating.category_id) = 'PG-13' then 3
            else 4
            end
)


---- Q10-j
with categoryAvg as(
select avg(film.length) as len,category.name,category.category_id from film
inner join film_category on (film_category.film_id = film.film_id)
inner join category on (category.category_id = film_category.category_id)
group by category.name,category.category_id
),topThree as (
select * from category_rating order by category_rating.rental_rate desc limit 3
), averageTopThree as(
select avg(film.length) as len from film
inner join film_category on (film_category.film_id = film.film_id)
inner join category on (category.category_id = film_category.category_id)
inner join topThree on(topThree.category_id = category.category_id)
)

delete from category_rating using categoryAvg,averageTopThree where category_rating.category_id = categoryAvg.category_id
and averageTopThree.len < categoryAvg.len

