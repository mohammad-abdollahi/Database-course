-- DATABASE DESIGN 1 3981 @ IUT
-- YOUR NAME:   Mohammad Abdollahi
-- YOUR STUDENT NUMBER:  9530153


---- Q4-A
create table country(
    id int primary key not null,
    name varchar(100) not null
);

create table state(
    id int primary key not null,
    name varchar(100) not null,
    country_id int references country(id)
);

create table city(
    id int primary key not null,
    name varchar(100) not null,
    state_id int references state(id)
);

create table airport(
    id varchar(3) primary key not null,
    name varchar(100) not null,
    city_id int references city(id),
    lat float,
    lan float
);

create table airline(
    id varchar(2) primary key not null,
    name varchar(100) not null
);

create table flight(
    id int primary key not null,
    start_date date not null,
    start_airport_id varchar(3) not null references airport(id),
    end_airport_id varchar(3) not null references airport(id),
    start_hour time,
    airline_id varchar(2) not null references airline(id),
    flight_number int,
    last_price int check(last_price > 0),
    last_capacity int check (last_capacity > 0)
);

create table price_capacity(
    flight_id int references flight(id),
    date timestamp,
    price int not null check(price > 0),
    capacity int not null check(capacity > 0),
    channel varchar(100) check(channel in('web service', 'airline system', 'phone')),
    primary key(flight_id, date)
);

create table passenger(
    id int primary key not null,
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    age int check(age > 0 AND age < 150),
    gender varchar(10) check(gender in('male', 'female'))
);

create table ticket(
    id int primary key not null,
    flight_id int not null references flight(id),
    passenger_id int references passenger(id),
    seat int not null check(seat > 0),
    price int not null check(price > 0)
);






---- Q4-B
with origin(id,date,origin_province) 
as (select flight_id,flight_date,province_name
	from flight join airport ON airport.airport_code = flight.originairport_code
				join city ON city.city_code = airport.city_code
				join province ON province.province_code = city.province_code)
,destination(id,date,dest_province) 
as (select flight_id,flight_date,province_name
	from flight join airport ON airport.airport_code = flight.destairport_code
				join city ON city.city_code = airport.city_code
				join province ON province.province_code = city.province_code)							  
,counter(date,CNT) as (select o.date, count(o.id)
					 from origin o,destination d
					 where o.id=d.id
					 group by o.date)
					 
select origin.origin_province,destination.dest_province,counter.date,c.CNT
from origin,destination,counter 
where  origin.date=counter.date and origin.id=destination.id


---- Q4-C
create view last_price_capacity as (
    WITH flight_date as (
        select flight_id, max(date) as date
        from price_capacity
        group by flight_id
    )

    select flight.id, price_capacity.date, price_capacity.price, flight.last_price, price_capacity.capacity, flight.last_capacity, price_capacity.channel
    from price_capacity
    inner join flight_date on price_capacity.flight_id = flight_date.flight_id AND price_capacity.date = flight_date.date
    inner join flight on price_capacity.flight_id = flight.id
);

select * from last_price_capacity;

create view conflict_price as (
    select * from last_price_capacity where price <> last_price
);

select * from conflict_price;


---- Q4-D
create view org_airport as(
    WITH airport_list(id, name, lat, lan, city_id, city_name) as(
        select airport.id, airport.name, airport.lat, airport.lan, airport.city_id, city.name as city_name
        from airport
        inner join city on city.id = airport.city_id
        where airport.id IN(
            select distinct(flight.start_airport_id) from flight
        )
    ), city_count as(
        select city_name, city_id, count(*) as no from airport_list group by city_name, city_id
    )

    select airport_list.id, airport_list.name, airport_list.lat, airport_list.lan, (NULL) as city_id , (NULL) as city_name
    from airport_list
    inner join city_count on city_count.city_id = airport_list.city_id
    where city_count.no = 1
    UNION
    select airport_list.id, airport_list.name, airport_list.lat, airport_list.lan, airport_list.city_id, airport_list.city_name
    from airport_list
    inner join city_count on city_count.city_id = airport_list.city_id
    where city_count.no > 1
);
select * from org_airport



---- Q4-E
create table flight_log(
    id int not null,
    start_date date not null,
    start_airport_id varchar(3) not null references airport(id),
    end_airport_id varchar(3) not null references airport(id),
    start_hour time,
    airline_id varchar(2) not null references airline(id),
    flight_number int,
    last_price int check(last_price > 0),
    last_capacity int check (last_capacity > 0),
    modified timestamp not null,
    primary key(id, modified)
);

CREATE OR REPLACE FUNCTION log_last_flight()
  RETURNS trigger AS
$BODY$
BEGIN
 IF NEW <> OLD THEN
 INSERT INTO flight_log
 VALUES(OLD.id,OLD.start_date, OLD.start_airport_id, OLD.end_airport_id, OLD.start_hour, OLD.airline_id, OLD.flight_number, OLD.last_price, OLD.last_capacity ,now());
 END IF;
 
 RETURN NEW;
END;
$BODY$

LANGUAGE plpgsql VOLATILE
COST 100;

CREATE TRIGGER flight_log_trigger BEFORE UPDATE ON flight
FOR EACH ROW EXECUTE PROCEDURE log_last_flight();


---- Q4-F
CREATE OR REPLACE FUNCTION update_flight_price()
  RETURNS trigger AS
$BODY$
BEGIN
 
 UPDATE flight set
    last_price = NEW.price,
    last_capacity = NEW.capacity
 where id = NEW.flight_id ;
 RETURN NEW;
END;
$BODY$

LANGUAGE plpgsql VOLATILE
COST 100;

CREATE TRIGGER update_flight_trigger AFTER INSERT ON price_capacity
FOR EACH ROW EXECUTE PROCEDURE update_flight_price();


---- Q4-G
BEGIN;
UPDATE flight set
last_price = 200000,
last_capacity = 20
where id = 1 ;
insert into price_capacity values (1, '2020-09-01T16:34:02', 200000, 20, 'airline system');
END;


---- Q4-H
CREATE FUNCTION check_flight_is_done(integer) RETURNS BOOLEAN AS $$
    select CAST(flight.start_date + flight.start_hour AS timestamp) < now() from flight where flight.id = $1
$$ LANGUAGE SQL;

create table flight_history(
    id int primary key not null,
    start_date date not null,
    start_airport_id varchar(3) not null references airport(id),
    end_airport_id varchar(3) not null references airport(id),
    start_hour time,
    airline_id varchar(2) not null references airline(id),
    flight_number int
);

CREATE OR REPLACE FUNCTION remove_flight() RETURNS void AS
$BODY$
    BEGIN
    insert into flight_history
        select id,start_date,start_airport_id,end_airport_id,start_hour,airline_id,flight_number from flight where check_flight_is_done(flight.id) = true;
        
    delete from price_capacity where check_flight_is_done(price_capacity.flight_id) = true; 
    delete from flight where check_flight_is_done(flight.id) = true;
    
    END;
$BODY$

LANGUAGE plpgsql VOLATILE
COST 100;




---- Q4-I
CREATE ROLE operator;
GRANT UPDATE ON flight TO operator;
GRANT INSERT ON flight TO operator;
GRANT DELETE ON flight TO operator;
GRANT SELECT ON flight TO operator;
GRANT UPDATE ON price_capacity TO operator;
GRANT INSERT ON price_capacity TO operator;
GRANT DELETE ON price_capacity TO operator;
GRANT SELECT ON price_capacity TO operator;
GRANT UPDATE ON passenger TO operator;
GRANT INSERT ON passenger TO operator;
GRANT DELETE ON passenger TO operator;
GRANT SELECT ON passenger TO operator;
GRANT UPDATE ON ticket TO operator;
GRANT INSERT ON ticket TO operator;
GRANT DELETE ON ticket TO operator;
GRANT SELECT ON ticket TO operator;
GRANT SELECT ON inter_State_flight_count TO operator;
GRANT SELECT ON last_price_capacity TO operator;
GRANT SELECT ON conflict_price TO operator;
GRANT SELECT ON org_airport TO operator;
GRANT SELECT ON flight_log TO operator;
GRANT SELECT ON flight_history TO operator;




---- Q5
create recursive view fact(col1, col2) as(
values(1,1)
union
select col1+1,(col2*(col1+1)) from fact where col1<=34);
select * from fact;


---- Q7-A
CREATE MATERIALIZED VIEW mymatview AS SELECT count(amount), category_id, i.store_id FROM payment
inner join rental r on payment.rental_id = r.rental_id
inner join inventory i on r.inventory_id = i.inventory_id
inner join film f on i.film_id = f.film_id
inner join staff s on payment.staff_id = s.staff_id
inner join film_category fc on f.film_id = fc.film_id
group by fc.category_id, category_id, i.store_id;


---- Q7-B
Alter table film add column tmp_rnt_dr integer;
Update film set tmp_rnt_dr = rental_duration -1
From language where language.language_id = film.language_id and language.name = 'English'




---- Q7-C




