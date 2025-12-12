select COUNT(*) as customers_count
from customers;
--считает общее количество покупателей из таблицы customers;

/*Анализ отдела продаж
Первый отчет о десятке лучших продавцов*/

select
    e.first_name || ' ' || e.last_name as seller,
    --объединение имени и фамилии продавца
    COUNT(s.sales_id) as operations,
    --подсчет количеста проведенных сделок
    FLOOR(SUM(p.price * s.quantity)) as income
--расчет суммарной выручки продавца за все время и округление в меньшую сторону
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

/*Анализ отдела продаж
Отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам*/

select
    e.first_name || ' ' || e.last_name as seller,
    --объединение имени и фамилии продавца
    FLOOR(AVG(p.price * s.quantity)) as average_income
--расчет средней выручки продавца и округление в меньшую сторону
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by seller
having
    FLOOR(AVG(p.price * s.quantity)) < (
        select FLOOR(AVG(p.price * s.quantity))
        from sales as s
        inner join products as p
            on s.product_id = p.product_id
    )
--сравнение средней выручки за сделку с средней выручкой за сделку по всем продавцам
order by average_income asc;

/*Анализ отдела продаж
Отчет содержит информацию о выручке по дням недели*/

select
    e.first_name || ' ' || e.last_name as seller,
    --объединение имени и фамилии продавца
    TRIM(TO_CHAR(s.sale_date, 'day')) as day_of_week,
    --преобразование даты в день недели
    FLOOR(SUM(p.price * s.quantity)) as income
--расчет суммы выручки продавца и округление в меньшую сторону
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by day_of_week, TO_CHAR(s.sale_date, 'id'), seller
order by TO_CHAR(s.sale_date, 'id'), seller asc;

/* Aнализ покупателей
Первый отчет - количество покупателей в разных возрастных группах */

select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        else '40+'
    end as age_category,
    --разбивка на возрастные группы
    COUNT(customer_id) as age_count
from customers
group by age_category
order by age_category;

/* Aнализ покупателей
Данные по количеству уникальных покупателей и выручке, которую они принесли */

select
    TO_CHAR(sale_date, 'YYYY-MM') as selling_month,
    --преобразование даты в формат YYYY-MM
    COUNT(distinct c.customer_id) as total_customers,
    --подсчет уникальных клиентов
    FLOOR(SUM(p.price * s.quantity)) as income
from sales as s
inner join customers as c
    on s.customer_id = c.customer_id
inner join products as p
    on s.product_id = p.product_id
group by selling_month
order by selling_month;

/* Aнализ покупателей
Покупатели, первая покупка которых была в ходе проведения акций */

with tab as (
    select
        s.sale_date,
        --объединение имени и фамилии клиента
        p.price,
        c.customer_id,
        --объединение имени и фамилии продавца
        c.first_name || ' ' || c.last_name as customer,
        --проставлена нумерация для покупок
        e.first_name || ' ' || e.last_name as seller,
        DENSE_RANK()
            over
            (
                partition by c.customer_id
                order by sale_date asc
            ) as dr
    from sales as s
    inner join customers as c
        on s.customer_id = c.customer_id
    inner join products as p
        on s.product_id = p.product_id
    inner join employees as e
        on s.sales_person_id = e.employee_id
)

select
    customer,
    sale_date,
    seller
from tab
where dr = 1 and price = 0
/*выбраны покупки, которые были первыми для данного покупателя
и цена которых равнялась 0 */
group by customer, sale_date, seller, customer_id
order by customer_id;