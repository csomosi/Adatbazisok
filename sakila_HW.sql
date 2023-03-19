	use sakila;

/* 1. Feladat
Jelenítsd meg az összes színész vezetéknevét és keresztnevét */

	select first_name as "First name", last_name as "Last name" from actor;

/* 2. Feladat
a) Jelenítsd meg az összes színész teljes nevét csupa nagybetűkkel, egyetlen oszlopban.  az oszlop neve "Actor Name" legyen.
b) Jelenítsd meg az azonosító, vezetéknév, és keresztnév értékeit annak a színésznek akinek a keresztneve Joe
c) Találj meg minden színészt akinek a vezetéknéve tartalmazza a 'gen' szót!
d) Keress meg minden színészt akinek a vezetékneve tartalmazz az `li` szót, és rendezd a találatokat vezetéknév és keresztnév szerint. 
*/

-- a)
	select concat(first_name, " ", last_name) as "Actor Name" from actor;

-- b)
	select actor_id as ID, first_name as "First name", last_name as "Last name" from actor where first_name in ("Joe");

-- c)
	select actor_id as ID, first_name as "First name", last_name as "Last name" from actor where last_name like '%gen%';

-- d)
	select 
	actor_id as ID, 
	first_name as "First name", 
	last_name as "Last name" 
	from actor where last_name like '%li%'
	order by last_name asc, first_name asc;


/*3. Feladat
Mennyi különböző vezetéknevű színész van? */

	SELECT COUNT(DISTINCT last_name) FROM actor;

/*4. Feladat
 Melyik vezetéknév szerepel több mint egyszer?*/
 
	select last_name, count(last_name) as name_count
	from actor
	group by last_name
    having name_count > 1;
 
/*5. Feladat 
Jelenítsd meg az összes ország ID-t, és ország nevet, amelyik kína, afganisztán, vagy Izrael!*/

	select country_id, country from country 
    where country in ('china', 'afghanistan', 'israel');
    
/*6. Feladat 
Mennyi az átlagos hossza egy filmnek?*/

    select avg(length) as average_length
    from film;
    
 /*7. Feladat 
Jelenítsd meg az összes személyzet nevét, és címét.*/   
	
-- by using the existing view:
    select name, address, city from staff_list;

-- by my own query:
	select concat(first_name, ' ', last_name) as name, address, city 
    from staff
    left join address using (address_id)
    left join city using (city_id);
    
/*8. Feladat 
Jelenítsd meg az összes vevő nevét és a hozzájuk tartozó összegeket amiket fizettek (payment amount).
⚠️  Hogy ne legyen túl lassú a lekérdezés, elég csak az első 10 eredményt kiiratni. (limit 10;) */
    
	select concat(first_name, ' ', last_name) as name, amount as paid_amount 
    from customer
    left join payment using(customer_id)
    limit 10;
       
/*9. Feladat  
Jelenítsd meg az összes film címét és a benne szereplő színészek neveit.
⚠️  Hogy ne legyen túl lassú a lekérdezés, elég csak az első 20 eredményt kiiratni. (limit 20;)*/


-- by using the existing view:
    select title, actors from film_list
    limit 20;

-- by my own query:
	select title, group_concat(concat(first_name, ' ', last_name) separator ', ') as actor_names
    from film_actor
    left join film using (film_id)
    left join actor using(actor_id)
    group by title
    limit 20;
    
    
		