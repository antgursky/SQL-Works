--HW_08

--1. Выведите в один общий список без повторений наименование
--производителей (Vendor) из двух таблиц.


SELECT DISTINCT vendor FROM table_1
UNION
SELECT DISTINCT vendor FROM table_2;


--2. В базе данных есть таблица BOOKS

--Выберите запросы, возвращающие всю информацию о книге,
--выпущенной издательствами “Азбука” или “Мысль”. В ответе напишите буквы
--правильных запросов.
--A. SELECT * FROM BOOKS WHERE PUBLISHER IN (‘Мысль’, ‘Азбука’);
--B. SELECT * FROM BOOKS WHERE PUBLISHER =‘Мысль’ or
--PUBLISHER = ‘Азбука’;
--C. SELECT * FROM BOOKS WHERE PUBLISHER =‘Мысль’ and
--PUBLISHER = ‘Азбука’;
--D. SELECT * FROM BOOKS WHERE PUBLISHER =‘Мысль’, PUBLISHER
--= ‘Азбука’;
--E. SELECT * FROM BOOKS WHERE PUBLISHER =‘Мысль’ UNION select
--* from BOOKS where PUBLISHER = ‘Азбука’;

--Верные 
--A: "IN" позволяет перебрать значения без "or" ;
--B: "or" использован уместно.



--3. Имеются 2 таблицы T1 и T2, содержащие колонки NUM типа
--NUMBER. Напишите запрос, отбирающий из таблицы T1 все уникальные
--числа NUM, отсутствующие в колонке NUM таблицы T2.
--a) Без использования LEFT JOIN
--b) С использованием LEFT JOIN


--a)
SELECT NUM FROM t_1
EXCEPT 
SELECT NUM FROM t_2;

--b)
SELECT DISTINCT NUM 
FROM t_1
LEFT JOIN 
     t_2
 ON t_1.NUM = t_2.NUM;
 
 
 
--4. В таблице T имеется одна колонка NUM типа NUMBER. Таблица
--заполнена некоторыми числами, которые могут повторяться. Написать
--оператор DELETE, удаляющий за один проход из таблицы T все записи
--дубликаты (остаться должны только неповторяющиеся числа).
 
DELETE FROM T
   WHERE NUM IN (SELECT NUM FROM t GROUP BY NUM 
  HAVING count(*) > 1);


--5. В таблице T1 хранятся данные по продажам и выполнению плана за
--последний отчетный период по каждому дополнительному офису. Определить
--3 лучших филиала по выполнению плана и вывести общую сумму продаж по
--каждому из них. Результаты необходимо представить в виде таблицы T2.

--Столбцы таблицы T1: 
--                  Fil, DO, Sales, "Plan, %"
CREATE TABLE T2 AS
SELECT fil,
       sum(Sales) AS total_sales,
       avg("Plan, %") AS total_plan    
   FROM t1 AS T1
  GROUP BY fil
  ORDER BY total_plan DESC
  LIMIT 3;


