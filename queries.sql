                              1
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
                             2
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

                           3

select e.first_name ||' '|| e.last_name as seller, 
--объединение имени и фамилии продавца
to_char(s.sale_date,'day') as day_of_week,
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
;


