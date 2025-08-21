--HW_06

--Источник данных - таблица TEST_SQL

--Задание 1.

--1.2 (1 балл) Для каждого месяца указать сумму выдач за предыдущий месяц,
----посчитать % изменения суммы выдач текущего месяца к предыдущему.

--Создадим таблицу
DROP TABLE IF exists user_26.home_work_table;
CREATE TABLE user_26.test_sql(
    ST_ORD varchar -- статус заявки
   ,TYPE_PRODUCT_NAME varchar -- тип заявки
   ,PRODUCT_INFOSOURCE1 varchar -- источник
   ,CREATE_DATE date --дата создания заявки
   ,INDEX_LEAD int4
--индикатор заявки. Флаг 0/1 определяет регистрацию лида в системе
   ,INDEX_ISSUE int4
--индикатор выдачи. Флаг 0/1 определяет наличие выдачи по заявке
   ,INDEX_SUM int4--сумма по продукту
  );
  
ALTER TABLE user_26.test_sql RENAME TO home_work_table; -- Переименовали таблицу
-- наполнили данными
INSERT INTO user_26.home_work_table (
ST_ORD, TYPE_PRODUCT_NAME, PRODUCT_INFOSOURCE1, CREATE_DATE, INDEX_LEAD, INDEX_ISSUE, INDEX_SUM) 
VALUES 
('Согласие', 'Обычная заявка', 'source1', '2017-11-30', 1, 0, 1600000),
('Согласие', 'Обычная заявка', 'source2', '2018-02-05', 1, 1, 2376000),
('Согласие', 'Обычная заявка', 'source3', '2017-12-27', 0, 1, 4860000),
('Согласие', 'Обычная заявка', 'source4', '2018-03-07', 1, 0, 1500000),
('Не подходит по критериям', 'Обычная заявка', 'source4', '2018-03-29', 0, 0, 3500000),
('Согласие', 'Заявка не для обработки', 'source4', '2018-06-26', 1, 1, 1800000),
('Согласие', 'Заявка не для обработки', 'source3', '2018-06-06', 0, 1, 3200000),
('Не подходит по критериям', 'Заявка не для обработки', 'source3', '2018-06-21', 0, 0, 3375900),
('Согласие', 'Заявка не для обработки', 'source5', '2018-06-19', 1, 0, 1700000),
('Согласие', 'Обычная заявка', 'source5', '2018-07-26', 1, 1, 1288000),
('Согласие', 'Обычная заявку', 'source5', '2018-07-31', 0, 0, 1600000),
('Согласие', 'Обычная заявка', 'source5', '2018-07-23', 1, 0, 1275400),
('Не подходит по критериям', 'Обычная заявка', 'source5', '2018-09-30', 1, 1, 1764000),
('Согласие', 'Обычная заявка', 'source6', '2018-08-03', 0, 1, 4000000),
('Согласие', 'Обычная заявка', 'source5', '2018-07-26', 1, 0, 1450000),
('Отказ', 'Обычная заявка', 'source5', '2018-09-06', 0, 0, 2363960),
('Согласие', 'Обычная заявка', 'source5', '2018-08-27', 1, 1, 2486939),
('Согласие', 'Обычная заявка', 'source5', '2018-08-28', 1, 0, 2576693),
('Согласие', 'Обычная заявка', 'source6', '2018-10-08', 1, 1, 1604125),
('Согласие', 'Обычная заявка', 'source6', '2018-07-30', 0, 0, 940000),
('Согласие', 'Заявка не для обработки', 'source4', '2018-07-09', 1, 1, 5000000);

--1.1 (1 балл) Сгруппировать по месяцам количество заявок, 
--сумму выдач, вычислить долю выдач.

SELECT 
    TO_CHAR(create_date, 'month')  AS "month",
    COUNT(*) AS total_requests, -- Общее количество заявок
    SUM(CASE WHEN thw.INDEX_ISSUE = 1 THEN 1 ELSE 0 END) AS total_issues,  -- Сумма выдач
    SUM(CASE WHEN thw.INDEX_ISSUE = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS issue_ratio  -- Доля выдач
FROM user_26.home_work_table AS thw 
GROUP BY "month"
ORDER BY "month"
  ;
  
  --1.2 (1 балл) Для каждого месяца указать сумму выдач за предыдущий месяц,
----посчитать % изменения суммы выдач текущего месяца к предыдущему.


WITH monthly_data AS (
    SELECT
        DATE_TRUNC('month', create_date)::date AS month_tb,  -- Обрезаем дату до первого числа месяца
        SUM(CASE WHEN INDEX_ISSUE = 1 THEN 1 ELSE 0 END) AS total_issues,  -- Сумма выдач
        SUM(INDEX_SUM) AS total_index_sum  -- Сумма всех значений 
    FROM 
        user_26.home_work_table
    GROUP BY 
        month_tb
)
SELECT 
    month_tb,
    total_issues,
    total_index_sum,  -- Сумма за месяц
    LAG(total_index_sum) OVER (ORDER BY month_tb) AS previous_month_index_sum,  -- Сумма за предыдущий месяц
    COALESCE(
        round((total_index_sum - LAG(total_index_sum) OVER (ORDER BY month_tb)) * 100.0 / 
        NULLIF(LAG(total_index_sum) OVER (ORDER BY month_tb), 0), 
        0), 2) AS percent_change  -- % изменения сумм 
FROM 
    monthly_data
ORDER BY 
    month_tb;


--Задание 2. (1 балл) 
--Добавить индикатор, который будет выделять следующие значения:
--• Если сумма по заявке больше 2000000 и дата создания заявки «март 2020» - 1
--• Если сумма по заявке больше 1000000, но меньше 2000000 и дата создания заявки
--«март 2020» - 2
--• Все остальные заявки не должны попасть в результат выполнения запроса.

WITH monthly_data AS (
    SELECT
        create_date AS month_tb,
        SUM(CASE WHEN INDEX_ISSUE = 1 THEN 1 ELSE 0 END) AS total_issues,  -- Сумма выдач
        SUM(INDEX_SUM) AS total_index_sum  -- Сумма всех значений 
    FROM 
        user_26.home_work_table
    GROUP BY 
        create_date
)
SELECT 
    month_tb::date ,
    total_issues,
    total_index_sum,  -- Сумма за месяц
    -- Добавим индикатор:
    CASE WHEN month_tb > '2018-03-01' AND month_tb < '2018-04-01' AND total_index_sum >2000000 THEN 1 ELSE 2 END AS INDICATOR_tb,
    --LAG(total_index_sum) OVER (ORDER BY month_tb) AS previous_month_index_sum,  -- Сумма за предыдущий месяц
    COALESCE(
        round((total_index_sum - LAG(total_index_sum) OVER (ORDER BY month_tb)) * 100.0 / 
        NULLIF(LAG(total_index_sum) OVER (ORDER BY month_tb), 0), 
        0), 2) AS percent_change  -- % изменения сумм 
FROM 
    monthly_data
WHERE 1=1 -- Берем за март 2018 года (2020 отсутствует в данных)
  AND month_tb > '2018-03-01' AND month_tb < '2018-04-01'
  AND total_index_sum > 1000000
ORDER BY 
    month_tb;

--Задание 3. (1 балл) Показать источник, через который пришло наибольшее число
--заявок.


SELECT    
     product_infosource1,
     SUM(INDEX_SUM) AS total_sum
 FROM user_26.home_work_table AS thw 
GROUP BY product_infosource1
 ORDER BY total_sum DESC
 LIMIT 1
 ;

--Задание 4. (1 балл) Для каждого источника и каждого месяца в 2018 году вывести сумму
--выдач на конец месяца.
--Если по источнику не было выдач за месяц, выводить 0. Предполагаем, что в БД есть
--таблица со всеми календарными датами.

SELECT 
    product_infosource1,
    TO_CHAR(create_date, 'yyyy-mm')  AS date_tb,
    SUM(INDEX_SUM) AS total_sum
 FROM user_26.home_work_table AS thw 
 WHERE create_date > '2017-12-31'
GROUP BY product_infosource1, date_tb
 ORDER BY product_infosource1, date_tb, total_sum DESC;


--Задание 5.
--5.1 (1 балл) Напишите, какую аналитику можно сделать на основании данных в таблице
--TEST_SQL?

-- Анализ статусов заявок:
--   - Общее количество заявок по статусам.
--   - Процентное соотношение статусов.
--
--Анализ типов заявок:
--   - Наиболее распространенные типы.
--   - Средняя сумма по типам.
--
--Анализ источников заявок:
--   - Эффективность источников по выдачам.
--   - Успешность источников по количеству.
--
--Тенденции по времени:
--   - Количество заявок по месяцам.
--   - Успешные заявки по месяцам.
--
--Анализ по суммам заявок:
--   - Средняя, максимальная и минимальная сумма.
--   - Количество высоких сумм и их сведение к выдачам.


--5.2 (1 балл) Предположим, что в вашем распоряжении имеются таблицы с любыми
--дополнительными данными по заявкам. Чем бы вы дообогатили таблицу TEST_SQL с
--целью получить инсайты по процессам, задействующим создание и одобрение заявок?

--Информация о клиенте: демографические данные, доход.  
--Данные о кредитной истории: индекс, предыдущие заявки, задолженности.  
--Время обработки: время заявки, дата одобрения.  
--Информация о сотрудниках: идентификатор, имя, производительность.    
--Ошибки и отклонения: причины отказов, статус обработки ошибок.  
--Сравнение одобренных и отклоненных заявок: причины отказов.  
--Маркетинговые каналы: информация о каналах, затраты, конверсия.  
--Удовлетворенность клиентов: оценки клиентов.  


--Задание 6. (1 балл) 
--Исправьте ошибки в SQL запросах
--1)
--SELECT s.PRODUCT_INFOSOURCE1
--,CASE
--WHEN st_ord = NULL THEN nd
--WHEN st_ord LIKE ‘% % %’ THEN '1'
--WHEN product_infosource1 = 'source1' THEN '2'
--END
--FROM test_sql s
--;
--2)
--SELECT d.MOBPHONE, d1.*, 1
--FROM table1@prod d1
--LEFT JOIN table2 d ON d.ACCT_NUMBER = d1.ACC_4017_NUMBER
--WHERE ACC_4017_NUMBER IN ('4081456878065343693')
--;
--3)
--SELECT max(create_date)
--FROM(SELECT *, max(create_date) as max_date
--FROM(SELECT cust_id, product_id, create_date FROM
--table1)
--;

-->>>> Исправление ошибок:
 
--В первом запросе:
--Использование NULL вместо IS NULL. 
--Вложенный `CASE` необходимо завершить END.

SELECT s.PRODUCT_INFOSOURCE1,
       CASE
           WHEN st_ord IS NULL THEN 'nd'
           WHEN st_ord LIKE '% % %' THEN '1'
           WHEN product_infosource1 = 'source1' THEN '2'
       END
FROM test_sql s;

--Во втором запросе:
--Отсутствие пробела между d1 и LEFT JOIN. 
--В условии WHERE нет явного указания, к какой таблице принадлежит `ACC_4017_NUMBER`. 
--Этот столбец должен быть явно указан (d1.ACC_4017_NUMBER).

SELECT d.MOBPHONE, d1.*, 1
  FROM table1@prod d1
LEFT JOIN table2 d ON d.ACCT_NUMBER = d1.ACC_4017_NUMBER
 WHERE d1.ACC_4017_NUMBER IN ('4081456878065343693');
 
--В третьем запросе:
--Rогда используются агрегатные функции, необходимо указывать остальные столбцы в GROUP BY.
--Ошибка местоположения max(create_date) в подзапросе: 
--оно не должно быть в SELECT, если не используется в GROUP BY.
 
 SELECT max(create_date)
FROM (SELECT cust_id, product_id, create_date, max(create_date) as max_date
      FROM table1
      GROUP BY cust_id, product_id, create_date);
 
 
-- Задание 7. (1 балл)
--В вашей схеме создана таблица numbers. Напишите запрос, который заполнит её 20
--строками с целыми числами в диапазоне от -100 до 100.
 
INSERT INTO user_26.numbers
SELECT FLOOR(RANDOM() * 201) - 100
FROM generate_series(1, 20);

SELECT *
  FROM user_26.numbers
  ORDER BY numbers;
  
--Задание 8. (1 балл)
--Напишите запрос к таблице numbers, который выводит только положительные числа не
--используя WHERE.
--1 вариант решение этого задания = 1 балл
--2 варианта решения = 2 балла
--2 и более вариантов решения = 3 балла

 
-- 1)
SELECT *
FROM user_26.numbers
  ORDER BY numbers DESC 
  LIMIT 9;
  
--2)
SELECT "number"
FROM user_26.numbers
GROUP BY "number"
HAVING "number" >0
ORDER BY "number"

--3)
SELECT CASE WHEN "number" >0 THEN "number" ELSE null END
FROM user_26.numbers
ORDER BY "number" desc;

--

--Задание 9. (1 балл)
--Обновите данные в таблице number:
--- К положительным числам прибавьте 5;
--- Отрицательные числа разделите на 2.




UPDATE user_26.numbers
SET "number" = CASE  
                    WHEN "number" > 0 THEN "number" + 5 
                    WHEN "number" < 0 THEN "number" / 2 
                    ELSE null
                END;

SELECT *
FROM user_26.numbers;


--Задание 10. (1 балл)
--Удалите все данные из таблицы number.


TRUNCATE user_26.numbers;

SELECT *
FROM user_26.numbers;
