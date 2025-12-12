                              1
select COUNT(*) as customers_count
from customers;
--считает общее количество покупателей из таблицы customers

                              2
/*Анализ отдела продаж
Первый отчет о десятке лучших продавцов*/

select e.first_name ||' '|| e.last_name as seller, 
--объединение имени и фамилии продавца
COUNT(s.sales_id) as operations, 
--подсчет количеста проведенных сделок
FLOOR(SUM(p.price*s.quantity)) as income
--расчет суммарной выручки продавца за все время и округление в меньшую сторону
from sales s
inner join employees e 
on s.sales_person_id = e.employee_id
inner join products p 
on s.product_id = p.product_id
group by seller
order by income desc
limit 10;
                             3
/*Анализ отдела продаж
Отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам*/

select e.first_name ||' '|| e.last_name as seller, 
--объединение имени и фамилии продавца
floor(AVG(p.price*s.quantity)) as average_income
--расчет средней выручки продавца и округление в меньшую сторону
from sales s
inner join employees e 
on s.sales_person_id = e.employee_id
inner join products p 
on s.product_id = p.product_id
group by seller
having floor(AVG(p.price*s.quantity))<(select FLOOR(AVG(p.price*s.quantity))
                                       from sales s
                                       inner join products p 
                                       on s.product_id = p.product_id)
--сравнение средней выручки за сделку с средней выручкой за сделку по всем продавцам
order by average_income ASC
;

                           4
/*Анализ отдела продаж
Отчет содержит информацию о выручке по дням недели*/

select e.first_name ||' '|| e.last_name as seller, 
--объединение имени и фамилии продавца
trim(to_char(s.sale_date,'day')) as day_of_week,
--преобразование даты в день недели
floor(SUM(p.price*s.quantity)) as income
--расчет суммы выручки продавца и округление в меньшую сторону
from sales s
inner join employees e 
on s.sales_person_id = e.employee_id
inner join products p 
on s.product_id = p.product_id
group by day_of_week,to_char(s.sale_date,'id'), seller
order by to_char(s.sale_date,'id'), seller ASC;

                         5
/* Aнализ покупателей
Первый отчет - количество покупателей в разных возрастных группах */

select case 
when age between 16 and 25 then '16-25'
when age between 26 and 40 then '26-40'
else '40+'
end as age_category,
--разбивка на возрастные группы
count(customer_id) as age_count
from customers c
group by age_category
order by age_category
;

                          6
/* Aнализ покупателей
Данные по количеству уникальных покупателей и выручке, которую они принесли */

select TO_CHAR(sale_date,'YYYY-MM') AS selling_month,
--преобразование даты в формат YYYY-MM
COUNT (distinct c.customer_id) as total_customers,
--подсчет уникальных клиентов
FLOOR(SUM(p.price*s.quantity)) as income
from sales s
inner join customers c 
on s.customer_id=c.customer_id 
inner join products p 
on s.product_id = p.product_id
group by selling_month
order by selling_month;

                          7
/* Aнализ покупателей
Покупатели, первая покупка которых была в ходе проведения акций */

with tab as (select c.first_name ||' '|| c.last_name as customer,
--объединение имени и фамилии клиента
s.sale_date as sale_date,
e.first_name ||' '|| e.last_name as seller, 
--объединение имени и фамилии продавца
dense_rank() over 
              (partition by c.customer_id 
              order by sale_date ASC) as dr,
--проставлена нумерация для покупок
p.price,
c.customer_id
from sales s
inner join customers c 
on s.customer_id=c.customer_id 
inner join products p 
on s.product_id = p.product_id
inner join employees e 
on s.sales_person_id = e.employee_id 
)

select customer, sale_date, seller
from tab
where dr=1 and price=0
/*выбраны покупки, которые были первыми для данного покупателя 
и цена которых равнялась 0 */
group by customer, sale_date, seller, customer_id
order by customer_id;