-- Házi feladat: Employees adatbázis elemzése
	
    use employees;

/*1. Feladat - 4pont
Kérdezd le az átlagos jövedelmént a férfi és női dolgozóknak minden részlegben (a lekérdezést nem, és dept_no alapján csoportosítst)*/

	select departments.dept_name as department, employees.gender, avg(salaries.salary) as avg_salary
	from employees 
    left join salaries using(emp_no)
    left join dept_emp using(emp_no)
	left join departments using(dept_no)
    group by departments.dept_name, employees.gender order by dept_name asc;
    
/*2. Feladat - 2 pont
Keresd meg a legalacsonyabb értékű részleg (department) számot a dept_emp táblában, majd a legmagasabbat is.*/
	
    select min(dept_no), max(dept_no) from dept_emp;
    
/*3. Feladat - 4 pont
Kérdezd le az alábbi mezők értékeit minden dolgozónak akinél a dolgozói szám (employee number) nem nagyobb mint 10040:
- Employee number
- A legalacsonyabb részleg szám azok közül amely részlegekben a dolgozó dolgozott 
(segítség: használj subquery-t ennek az értéknek a lekérdezéséhez, a dept_emp táblából)
- Egy manager oszlop aminek az értéke 110022 ha az employee number alacsonyabb vagy egyenlő 10020-al,
és 110039 abban az esetben ha az employee number 10021 és 10040 közé esik (ezeket is beleértve)*/

	select emp_no as employee_number, dept_no,
		case
			when emp_no <= 10020 then '110022'
			else '110039'
		end as manager_data
    from employees
    left join dept_emp using (emp_no)
	where emp_no < 10041;


/*4. Feladat - 2 pont
Készíts egy lekérdezést azokról a dolgozókról akik 2000-ben lettek felvéve*/
	select emp_no, concat(first_name, ' ', last_name) as name, hire_date from employees
    where hire_date between '2000-01-01' and '2000-12-31';
        
/*5. Feladat - 2 pont
Készíts egy listát minden dolgozóról akik a titles tábla alapján "engineer"-ek.
Készíts egy másik listát a senior engineer-ekről is.
⚠️  Hogy ne legyen túl lassú a lekérdezés, elég csak az első 10 eredményt kiíratni. (limit 10;)*/

-- a) using a simple query:
	select concat(first_name, ' ', last_name) as name, title
	from employees 
    left join titles using(emp_no)
	where title = 'engineer'
    order by name
    limit 10;

-- b) creating a stored procedure with input parameter using the simple query in a):
	drop procedure if exists emp_list_by_title;
    delimiter $$
	create procedure emp_list_by_title(in p_title varchar(50))
		begin
			select concat(first_name, ' ', last_name) as name, title
			from employees 
			left join titles using(emp_no)
			where title = p_title
			order by name
			limit 10;
		end$$
	delimiter ;

	call emp_list_by_title('engineer');
    call emp_list_by_title('senior engineer');
    
/*6. Feladat - 4 pont
Készíts egy procedúrát (last_dept) ami egy employee number alapján visszadja hogy az adott dolgozó melyik részlegen dolgozott utoljára. 
Hívd meg a procedúrát a 10010-es dolgozóra. 
Ha jól dolgoztál az eredmény az kell hogy legyen hogy a 10010-es dolgozó a "Quality Management" osztályon dolgozott (department number 6)*/
	
    drop procedure if exists last_dept;
    delimiter $$
	create procedure last_dept(in p_emp_id int)
		begin
			select emp_no, concat(first_name, ' ', last_name) as name, dept_name
			from employees 
			left join current_dept_emp using(emp_no)
            left join departments using(dept_no)
			where emp_no = p_emp_id;
		end$$
	delimiter ;

	call last_dept(10010);

/*7. Feladat - 5 pont
Hány szerződést regisztráltak a salaries táblában amelynek a hossza több volt mint egy év és az értéke több mint $100 000 ?
Tipp: Hasonlítsd össze a start és end date közötti különbségeket.*/

-- feltételezem, hogy csak a darabszámot kell megjeleníteni, a részleteket nem.

-- a) ha a jelenleg nyitott szerződéseket is ki kell listázni :
	select count(datediff(to_date, from_date )) as number_of_contracts from salaries
    where salary > 100000 and
    datediff(to_date, from_date ) > 365;

-- b) ha a nyitott szerződéseket nem kell listázni:

	select count(datediff(to_date, from_date )) as number_of_contracts from salaries
    where salary > 100000 and
    datediff(to_date, from_date ) > 365 and
    to_date < now();

/*8. Feladat - 5 pont
Készíts egy trigger-t ami ellenőrzi hogy egy dolgozó felvételének dátuma nagyobb e mint a jelenlegi dátum. Ha ez igaz, állítsd a felvétel dátumát a mai dátumra. Formázd a dátumot megfelelően (YY-mm-dd).
Ha a trigger elkészült futtasd az alábbi kódot hogy megnézd sikerült e a triggert elkészíteni:

use employees;
insert employees values('999904', '1970-01-31', 'John', 'Johnson', 'M', '2025-01-01');
select * from employees order by emp_no desc limit 10;*/

	delimiter $$
	create trigger before_employee_insert
	before insert on employees
	for each row
	begin
		if new.hire_date >curdate() then
			set new.hire_date = date_format(curdate(), '%Y-%m-%d');
		end if;
	end$$
	delimiter ;

-- test:
	insert employees values('999904', '1970-01-31', 'John', 'Johnson', 'M', '2025-01-01');
	select * from employees order by emp_no desc limit 10;

/*9. Feladat - 5 pont
Készíts egy függvényt ami a megkeresi a legmagasabb fizetését egy adott dolgozónak (employee no. alapján). Próbáld ki a függvényt a 11356-as számú dolgozón.
Készíts egy másik függvényt ami pedig a legalacsonyabb fizetést találja meg hasonlóan employee no. alapján. */
	
-- legmagasabb:

	drop function if exists f_emp_max_salary;
    
	delimiter $$
	create function f_emp_max_salary(p_emp_no integer) returns decimal(10,2)
		begin
			declare v_max_salary decimal(10,2);
			select max(salaries.salary) into v_max_salary
			from salaries 
			where emp_no = p_emp_no;
            return v_max_salary;
		end$$
	delimiter ; 

	select employees.f_emp_max_salary(11356) as max_salary;

-- legalacsonyabb:
	drop function if exists f_emp_min_salary;
    
	delimiter $$
	create function f_emp_min_salary(p_emp_no integer) returns decimal(10,2)
		begin
			declare v_min_salary decimal(10,2);
			select min(salaries.salary) into v_min_salary
			from salaries 
			where emp_no = p_emp_no;
            return v_min_salary;
		end$$
	delimiter ; 

	select employees.f_emp_min_salary(11356) as min_salary;
    
/*10. Feladat - 5 pont
Az előző feladat alapján készíts egy új függvényt amely egy második paramétert is felhasznál. 
Ez a paraméter egy karaktersorozat legyen. Ha a karaktersorozat értéke 'min', akkor a legalacsonyabb fizetést keresse, 
ha 'max' akkor a legmagasabbat. Ehhez a feladathoz használd fel a 9. feladatban készített függvény logikáját. 
Ha a függvény második paramétere nem 'min' és nem is 'max' akkor minden más esetben 
a függvény a legmagasabb és legalacsonyabb fizetés különbségét adja vissza.*/

	drop function if exists f_emp_minmax_salary;
    
	delimiter $$
	create function f_emp_minmax_salary(p_emp_no integer, p_query_method varchar(3)) returns decimal(10,2)
		begin
			declare v_minmax_salary decimal(10,2);
			if p_query_method = 'min' then
				select min(salaries.salary) into v_minmax_salary
                from salaries where emp_no = p_emp_no;
			elseif p_query_method = 'max' then
				select max(salaries.salary) into v_minmax_salary
                from salaries where emp_no = p_emp_no;
			else 
				select max(salaries.salary) - min(salaries.salary) into v_minmax_salary
				from salaries where emp_no = p_emp_no;
            end if;
			return v_minmax_salary;
		end$$
	delimiter ; 



	select employees.f_emp_minmax_salary(11356, 'max') as result;

