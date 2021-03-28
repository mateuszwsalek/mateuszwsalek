--                                                    Mateusz Salek 
--                                                 Zadania Egzaminacyjne
-- Z.1
-- Z.1.A)=========================================================================================================================>
-- Ile dysków posiada napêdy Supra? 
-- Liczba dyskow Supra  to 5915
SELECT
sum(i.quantity_on_hand)
FROM

inventories i
join product_descriptions pd on i.product_id=pd.product_id
join product_information pi on i.product_id=pi.product_id
where category_id=13 and upper(translated_description) like upper('%SUPRA%');

--  Ile dysków posiada najnowszy napêd Supra 
--(najnowszy oznacza ten z najwy¿sz¹ wersj¹ oznaczon¹ numerem)?
-- Liczba dyskow Supra 9 to 2017
SELECT
sum(i.quantity_on_hand)
FROM

inventories i
join product_descriptions pd on i.product_id=pd.product_id
join product_information pi on i.product_id=pi.product_id
where category_id=13 and upper(translated_description) like upper('%SUPRA9%');

-- Z.1.B)===============================================>
-- Który z dostawców poczty wystêpuje najczêœciej w bazie maili wszystkich klientów? 
--Przyk³adowo: w mailu Ajay.Sen@TROGON.EXAMPLE.COM jako dostawcê proszê 
--potraktowaæ ci¹g znaków: TROGON.
-- ex-equo na 1 miejscu sa "Dunlin" oraz "Anhinga"
SELECT
count(replace(substr(CUST_EMAIL,(length(cust_first_name)+length(cust_last_name))+3,30),upper('.Example.com'),'')) as provider_count,
replace(substr(CUST_EMAIL,(length(cust_first_name)+length(cust_last_name))+3,30),upper('.Example.com'),'') as provider_name

FROM 
customers
group by (replace(substr(CUST_EMAIL,(length(cust_first_name)+length(cust_last_name))+3,30),upper('.Example.com'),''))
order by count(replace(substr(CUST_EMAIL,(length(cust_first_name)+length(cust_last_name))+3,30),upper('.Example.com'),''))desc;

-- Z.1.C)===============================================>
--roszê napisaæ zapytanie, które zwróci listê unikatowych kategorii przychodów 
--klientów (pole INCOME_LEVEL w tabeli CUSTOMERS) oraz 3 dodatkowe kolumny: 
--kategoria, poziom_min, poziom_max. Dla najni¿szego przedzia³u pole poziom_min 
--powinno zwracaæ NULL. Analogicznie pole poziom_max dla najwy¿szego przedzia³u. Ile 
--kategorii uzyskano?
SELECT
DISTINCT(income_level),
cast(income_level as varchar2(1)) as Unique_categories,
--cast(substr(income_level,3,8))as numeric)
replace(trim(substr(income_level,3,8)),'Below 3','Null')as Min,
replace(trim(substr(income_level,-7,8)),'d above','Null')as Max
FROM
Customers
order by cast(income_level as varchar2(1));

-- Z.2=======================================================================================================================================
-- Osoba która wykonala najwiecej zamowien
Alain Barkin
select
count(o.order_id),
c.CUST_FIRST_NAME||' '||c.CUST_LAST_NAME

from 
customers c
join orders o on c.CUSTOMER_ID= o.CUSTOMER_ID

group by (c.CUST_FIRST_NAME||' '||c.CUST_LAST_NAME)

order by count(o.order_id)desc
;
=============================
 

);
--Z.3==================================================================================================================================
-- Z.3.A)===============================================>

Select
round(avg(e.salary))as AVG_Salary,
d.department_name

from employees e
join departments d on  e.DEPARTMENT_ID=d.DEPARTMENT_ID
where d.department_name in ('Sales', 'Shipping', 'Finance')
group by d.department_name;

---- Z.3.B)===============================================>

Select
round(avg(e.salary))as AVG_Salary,
e.job_id

from employees e
join departments d on  e.DEPARTMENT_ID=d.DEPARTMENT_ID
group by e.job_id
having count(employee_id)>=5
order by round(avg(e.salary))desc;

---- Z.3.C)===============================================>

Select
e.JOB_id,
round(avg(e.salary))as AVG_Salary,
round(avg(e.salary))*1.1 as Wage_After_increse,
max(j.max_salary)as Max_Salary,
min(j.min_salary)as Min_Salary

from employees e
join departments d on  e.DEPARTMENT_ID=d.DEPARTMENT_ID
join jobs j on  e.JOB_ID=j.JOB_ID
group by (e.Job_id)
having (round(avg(e.salary))*1.1) < max(j.max_salary) and (round(avg(e.salary))*1.1) >min(j.min_salary) and count(employee_id)>=5
order by round(avg(e.salary))desc;

--Z.4==================================================================================================================================
-- Z.4.A)===============================================>
--a) okres obowi¹zywania promocji veryday low price - promocja 20% na wszystkie zamówienia online
SELECT

Min(trunc(o.order_date)) as First_date_of_Promotion,
Max(trunc(o.order_date)) as Last_date_of_Promotion,
round(months_between (Max(trunc(o.order_date)), Min(trunc(o.order_date)))) as Months_Of_Promotion,
Max(trunc(o.order_date))-Min(trunc(o.order_date)) as In_days

FROM
orders o
join promotions p on o.PROMOTION_ID=p.PROMO_ID
join customers c on o.customer_ID=c.customer_ID
where o.PROMOTION_ID= 1;

--a)  blowout sale – promocja 10% na ca³y asortyment
SELECT

Min(trunc(o.order_date)) as First_date_of_Promotion,
Max(trunc(o.order_date)) as Last_date_of_Promotion,
round(months_between (Max(trunc(o.order_date)), Min(trunc(o.order_date)))) as Months_Of_Promotion,
Max(trunc(o.order_date))-Min(trunc(o.order_date)) as In_days

FROM
orders o
join promotions p on o.PROMOTION_ID=p.PROMO_ID
join customers c on o.customer_ID=c.customer_ID
where o.PROMOTION_ID= 2;


-- Z.4.B)===============================================>
--b) ³¹czn¹ wartoœæ zamówieñ ka¿dego dnia promocji

SELECT
trunc(o.order_date) as Promotion_Date,
sum(ORDER_TOTAL) as Total_Order
FROM
orders o
join promotions p on o.PROMOTION_ID=p.PROMO_ID
group by trunc(o.order_date);

-- Z.4.C)===============================================>
--c) klienta, który zareagowa³ jako pierwszy na promocjê – z³o¿y³ pierwsze zamówienie w 
--trakcie jej obowi¹zywania
--Czy mamy jakis mapping dotyczacy statusu zamowienia wydaje mi sie ze gdzies na zajeciach to bylo ale nie moge znalesc w tablicach
SELECT
c.CUST_FIRST_NAME||' '||c.CUST_LAST_NAME,
o.order_date
FROM
orders o
join promotions p on o.PROMOTION_ID=p.PROMO_ID
join customers c on o.customer_ID=c.customer_ID
where rownum=1 and order_status not in (0,1,6)
group by o.order_date, c.CUST_FIRST_NAME||' '||c.CUST_LAST_NAME
order by o.order_date ;

-- Z.4.D)===============================================>
-- suma zamowien online w okresie promocji(od 18/07/01 do18/07/30) to 591822,8
-- suma zamowien stacjonarnych w okresie promocji(od 18/07/01 do18/07/31) to 275912,6
-- suma zamowien internetowych w podobnym okresie bez promocji(od 18/08/01 do18/08/30) to 424706,5
-- suma zamowien internetowych w podobnym okresie bez promocji(od 18/06/01 do18/06/30) to 388673,8
SELECT

Min(trunc(o.order_date)) as First_date_of_Promotion,
Max(trunc(o.order_date)) as Last_date_of_Promotion,
round(months_between (Max(trunc(o.order_date)), Min(trunc(o.order_date)))) as Months_Of_Promotion,
Max(trunc(o.order_date))-Min(trunc(o.order_date)) as In_days,
sum(ORDER_TOTAL)
FROM
orders o
left join promotions p on o.PROMOTION_ID=p.PROMO_ID
join customers c on o.customer_ID=c.customer_ID
where o.PROMOTION_ID= 1 and order_mode='online';


-- suma zamowien stacjonarnych w okresie promocji(od 18/07/01 do18/07/31) 
SELECT

--'18/07/31' as date,
to_date('18/07/31') - to_date('18/07/01') as Months_Without_Promotion,
--Max(trunc(o.order_date))-Min(trunc(o.order_date)) as In_days,
sum(ORDER_TOTAL)
FROM
orders o
left join promotions p on o.PROMOTION_ID=p.PROMO_ID
join customers c on o.customer_ID=c.customer_ID
where order_mode='direct' and order_date < to_date('18/07/31') and order_date > to_date('18/07/01')
 ;
-- suma zamowien internetowych w podobnym okresie bez promocji(od 18/08/01 do18/08/30) to 424706,5
SELECT
to_date('18/08/30') - to_date('18/08/01') as Months_Without_Promotion,
sum(ORDER_TOTAL)
FROM
orders o
left join promotions p on o.PROMOTION_ID=p.PROMO_ID
join customers c on o.customer_ID=c.customer_ID
where order_mode='online' and order_date < to_date('18/08/30') and order_date > to_date('18/08/01');
-- suma zamowien internetowych w podobnym okresie bez promocji(od 18/06/01 do18/06/30) to 388673,8
SELECT
to_date('18/06/30') - to_date('18/06/01') as Months_Without_Promotion,
sum(ORDER_TOTAL)
FROM
orders o
left join promotions p on o.PROMOTION_ID=p.PROMO_ID
join customers c on o.customer_ID=c.customer_ID
where order_mode='online' and order_date < to_date('18/06/30') and order_date > to_date('18/06/01');
