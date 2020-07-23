-- DATABASE DESIGN 1 3981 @ IUT
-- YOUR NAME: Mohammad Abdollahi  ................
-- YOUR STUDENT NUMBER: 9530153  .................


---- Q4-a
create table city(
    name varchar(20) not null ,
    code varchar(20) not null primary key
);

create table employee(
    personnel_code varchar(10) NOT NULL primary key ,
    name varchar(20),
    family varchar(20),
    city_code varchar(20) references city(code) not null
);

create table branches(
    branch_code varchar(10) not null primary key ,
    branch_name varchar(20) not null,
    branch_city_code varchar(20) references city(code) not null
);

create table city_employee(
    personnel_code varchar(10) references employee(personnel_code) not null,
    branch_code varchar(10) references branches(branch_code) not null,
    salary integer not null,
    primary key (personnel_code, branch_code)
);

create table group_manager(
    personnel_code varchar(10) references employee(personnel_code) not null,
    manager_code varchar(10) not null,
    primary key (personnel_code, manager_code)
);




---- Q4-b
with s(city, branch) as (select employee.city_code, city_employee.branch_code from employee
    join city_employee on employee.personnel_code=city_employee.personnel_code
    join group_manager  on employee.personnel_code = group_manager.personnel_code)
select employee.name, employee.family from employee,s
join  city_employee on personnel_code = city_employee.personnel_code
where employee.city_code = s.city and city_employee.branch_code=s.branch;




---- Q4-c
select count(city_employee.personnel_code), sum(city_employee.salary), branches.branch_city_code from city_employee
join branches on city_employee.branch_code = branches.branch_code
group by (branches.branch_city_code);



---- Q4-d
select employee.name, employee.family from employee
join city_employee on employee.personnel_code = city_employee.personnel_code
join branches on city_employee.branch_code = branches.branch_code
where branches.branch_name != 'Main Branch';



---- Q4-e
select employee.name, employee.family, city_employee.salary from employee
join city_employee on employee.personnel_code = city_employee.personnel_code
where city_employee.salary < all (select city_employee.salary from city_employee
                                    join branches on city_employee.branch_code = branches.branch_code
                                    where branch_name='Main Branch');



---- Q4-f
with a(av, name) as (select avg(city_employee.salary), branches.branch_name
                from employee
                join city_employee on employee.personnel_code = city_employee.personnel_code
                join branches on city_employee.branch_code = branches.branch_code
                group by (branches.branch_name))
select employee.name, employee.family, branches.branch_name, a.av
from employee, a
join city_employee on personnel_code = city_employee.personnel_code
join branches on city_employee.branch_code = branches.branch_code
where a.name=branches.branch_name and  a.av > (select avg(city_employee.salary) from city_employee
                                        join branches on city_employee.branch_code = branches.branch_code
                                            where branches.branch_name='Main Branch'
                                    );





---- Q4-g
update city_employee
set salary =
    case
        when salary*1.05>3000000 then salary*1.02
        else salary*1.05
    end
where personnel_code in (select personnel_code from group_manager
                            join city_employee on group_manager.personnel_code = city_employee.personnel_code
                            join branches on city_employee.branch_code = branches.branch_code
                            where branch_name='Main Branch');




---- Q5-a
with c(actor_id, c, store) as (select film_actor.actor_id, count(film_actor.actor_id), inventory.store_id
from film_actor
inner join film on film_actor.film_id = film.film_id
inner join inventory on film.film_id = inventory.film_id
group by inventory.store_id, film_actor.actor_id)
select max(c.c), store from c
group by store;



---- Q5-b
select c3.country, c2.city, sum(amount), count(rental_id) from payment
inner join customer c on payment.customer_id = c.customer_id
inner join address a on c.address_id = a.address_id
inner join city c2 on a.city_id = c2.city_id
inner join country c3 on c2.country_id = c3.country_id
group by rollup (c3.country, c2.city);


---- Q5-c
Select title, rental_rate,film.length, ntile(6) over(order by rental_rate desc) from film;


---- Q5-d
select count(film.film_id), rating, c2.country_id from film
inner join inventory i on film.film_id = i.film_id
inner join rental r on i.inventory_id = r.inventory_id
inner join customer c on r.customer_id = c.customer_id
inner join address a on c.address_id = a.address_id
inner join city c2 on a.city_id = c2.city_id
group by rating, c2.country_id;
