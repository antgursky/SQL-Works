# SQL-Works — учебные задания по PostgreSQL

В репозитории собраны домашние и практические работы по SQL.  
Темы охватывают основные операторы, агрегаты, объединения таблиц, оконные функции, а также приёмы работы с DDL/DML и Python+SQL.

## Структура
- Каждая папка `HW_X` содержит:
  - `task.md` — формулировка заданий.
  - `solution.sql` — решение в SQL (с комментариями).
- `README.md` — навигация по курсу.

## Подключение к учебной базе
Все задания выполнялись в PostgreSQL, развернутой в Яндекс Cloud.

**Параметры подключения:**
- Host: `rc1b-7ng6ih3jte3824x8.mdb.yandexcloud.net`
- Port: `6432`
- Database: `demo`
- User: `student`
- Пароль: выдаётся преподавателем по запросу

### Подключение через psql
    psql \
      -h rc1b-7ng6ih3jte3824x8.mdb.yandexcloud.net \
      -p 6432 \
      -U student \
      -d demo

### Подключение через DBeaver
1. Создать новое подключение → PostgreSQL.  
2. Ввести параметры (Host, Port, Database, User, Password).  
3. В разделе **SSL** выбрать режим **Require**.  

---

## Домашние работы

- [**HW_01 (Basic Operators)**](HW_1%20(Basic%20Operators))  
  Базовые выборки, фильтры (`WHERE`), сортировки (`ORDER BY`), ограничение выборки (`LIMIT`), работа с JSON.  

- [**HW_02 (Grouping and Aggregate Functions)**](HW_02%20(Grouping%20and%20Aggregate%20Functions))  
  Группировки (`GROUP BY`), агрегаты (`COUNT`, `SUM`, `AVG`), фильтрация агрегатов через `HAVING`.  

- [**HW_03 (Table Joins and Sets)**](HW_03%20(Table%20Joins%20and%20Sets))  
  Внутренние и внешние соединения (`JOIN`), объединения множеств (`UNION`, `EXCEPT`, `INTERSECT`).  

- [**HW_04 (Window functions)**](HW_04%20(Window%20functions))  
  Использование оконных функций: `ROW_NUMBER`, `RANK`, `LAG`, `LEAD`, вычисления долей и процентов.  

- [**HW_05 (Python + SQL)**](HW_05%20(Python%20+%20SQL))  
  Интеграция SQL-запросов в Python (через `psycopg2`/`pandas`), анализ и визуализация данных.  

- [**HW_06 (DML)**](HW_06%20(DML))  
  Работа с таблицей `TEST_SQL`: `INSERT`, `UPDATE`, `DELETE`, группировки по месяцам, расчёты динамики.  

- [**HW_07 (DDL)**](HW_07%20(DDL))  
  Загрузка CSV (fraud detection dataset), создание таблицы и ограничений (`PRIMARY KEY`, `NOT NULL`), преобразование типов, построение аналитических представлений (`VIEW`).  

- [**HW_08 (Practice)**](HW_08%20(practice))  
  Практические задачи: объединения множеств, выборки с `IN` и `OR`, исключения (`EXCEPT`), удаление дублей, определение лучших филиалов по выполнению плана.  

---

## Мини-глоссарий
- **DDL** — описание данных (`CREATE / ALTER / DROP`).  
- **DML** — манипуляции с данными (`SELECT / INSERT / UPDATE / DELETE`).  
- **VIEW** — сохранённый запрос, «виртуальная таблица» для аналитики.  
- **Оконные функции** — вычисления по окнам строк (`LAG`, `LEAD`, `RANK`).  

## Стек
PostgreSQL · DBeaver / pgAdmin / psql · Python (pandas, psycopg2)
