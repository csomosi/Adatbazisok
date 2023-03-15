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
 
select
  case 
	when 
		count(last_name) group by last_name > 1 then 'X'
	else last_name
 end 
 as 'Number'
from actor;

-- ez adja vissza a darabszámot:
select count(last_name) from actor group by last_name;

-- ez valami:
select last_name,
  case 
	when last_name = 'allen' then 'X'
	else last_name
 end

from actor;

