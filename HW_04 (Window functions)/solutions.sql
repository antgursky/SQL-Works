-- HW_04 — база booking.*

--1. (2 балла) Необходимо вывести следующую информацию:
--• Идентификатор перелёта;
--• Код аэропорта отправления;
--• Код аэропорта прибытия;
--• Запланированные дата и время вылета;
--• Актуальные дата и время вылета;
--• На сколько был задержан вылет;
--• Минимальное время задержки вылета для аэропорта вылета;
--• Среднее время задержки вылета для аэропорта вылета;
--• Максимальное время задержки вылета для аэропорта вылета;
--Данные необходимо вывести только для тех перелётов, для которых
--существует информация об актуальных дате и времени вылета и время
--задержки составляет 1 минута и более.

SELECT flight_id
      ,departure_airport
      ,arrival_airport
      ,to_char(scheduled_departure,'YYYY-MM-DD HH24:MI') AS scheduled_departure
      ,to_char(actual_departure,'YYYY-MM-DD HH24:MI') AS actual_departure
      ,actual_departure - scheduled_departure AS delayed_departure
      ,min(actual_departure - scheduled_departure) over(PARTITION BY departure_airport) AS min_delayed
      ,avg(actual_departure - scheduled_departure) over(PARTITION BY departure_airport) AS avg_delayed
      ,max(actual_departure - scheduled_departure) over(PARTITION BY departure_airport) AS max_delayed
  FROM booking.flights f
 WHERE 1=1
   AND actual_departure IS NOT NULL 
   AND actual_departure - scheduled_departure > INTERVAL '1 minute'
   ORDER BY departure_airport ASC 
   ;
   
   
--   2. (2 балла) Вывести следующую информацию для всех пассажиров,
--которые осуществляли бронирование билетов летом 2017 года:
--• Имя и фамилия пассажира;
--• Номер бронирования;
--• Общая сумма бронирования;
--• Номер билета;
--• Стоимость билета;
--• Кол-во билетов в бронировании;
--• Стоимость самого дешёвого билета в бронировании;
--• Стоимость самого дорогого билета в бронировании;
--Данные необходимо отсортировать по убыванию сначала по общей стоимости
--бронирования, а затем по убыванию количества билетов в бронировании.

select t.passenger_name
      ,b.book_ref
      ,b.total_amount
      ,t.ticket_no
      ,tf.amount 
      ,count(t.ticket_no) over(partition by b.book_ref) AS ticket_count
      ,min(tf.amount) over(partition by t.book_ref) AS min_amount
      ,max(tf.amount) over(partition by t.book_ref) AS max_amount
  from booking.tickets t 
  join booking.ticket_flights tf
    on t.ticket_no = tf.ticket_no
  join booking.flights f 
    on f.flight_id = tf.flight_id 
  JOIN booking.bookings b
    ON t.book_ref = b.book_ref 
 WHERE b.book_date::date between '2017-06-01' and '2017-08-31'
      and b.book_ref is not NULL
order by b.total_amount DESC, ticket_count DESC, b.book_ref ASC
  ;
   
--  3. (2 балла) Вывести информацию о последнем совершённом
--перелёте для каждого пассажира (имя и фамилия пассажира, идентификатор
--полёта, актуальная дата вылета, название аэропорта отправления на русском
--языке, название аэропорта прибытия на русском языке) с помощью
--группировок и агрегирующих функций;
  
  
select
      t.passenger_name
     ,f.flight_id
     ,to_char(max(f.actual_departure),'YYYY-MM-DD HH24:MI') as last_flight_date
     ,ad1.airport_name ->> 'ru' as departure_airport_ru
     ,ad2.airport_name ->> 'ru' as arrival_airport_ru
 from booking.tickets t
 join booking.ticket_flights tf
using (ticket_no)
 join booking.flights f
using (flight_id)
 join booking.airports_data ad1
   on f.departure_airport = ad1.airport_code
 join booking.airports_data ad2
   on f.arrival_airport = ad2.airport_code
where f.actual_departure is not null
group by t.passenger_name
        ,f.flight_id
        ,ad1.airport_name
        ,ad2.airport_name
 HAVING max(f.actual_departure) = f.actual_departure
 order by t.passenger_name
         ,last_flight_date
         ,f.flight_id
 limit 1000
   ;
   
-- 4. (2 балла) Вывести информацию из предыдущего пункта с
--использованием оконных функций;
   
SELECT 
     t.passenger_name
     ,f.flight_id
     ,to_char((max(f.actual_departure)
OVER (PARTITION BY f.flight_id)),'YYYY-MM-DD HH24:MI') as last_flight_date
     ,ad1.airport_name ->> 'ru' as departure_airport_ru
     ,ad2.airport_name ->> 'ru' as arrival_airport_ru
 from booking.tickets t
 join booking.ticket_flights tf
using (ticket_no)
 join booking.flights f
using (flight_id)
 join booking.airports_data ad1
   on f.departure_airport = ad1.airport_code
 join booking.airports_data ad2
   on f.arrival_airport = ad2.airport_code
where 1=1
    AND f.actual_departure is not NULL  
order by t.passenger_name
         ,last_flight_date
         ,f.flight_id
 limit 1000 
;


  
--5. (2 балла) Построим маршрут перелётов для всех пассажиров, у
--которых имя начинается на «A» и содержит ещё одну букву «A», а фамилия
--содержит «OV»:
--• Имя и фамилия пассажира в отдельных колонках;
--• Дата предыдущего вылета и аэропорт вылета (в одной колонке);
--• Дата вылета и аэропорт вылета (в одной колонке);
--• Дата следующего вылета и аэропорт вылета (в одной колонке).

SELECT split_part(t.passenger_name, ' ', 1) AS passenger_name
      ,split_part(t.passenger_name, ' ', 2) passenger_surname
      ,last_value(f.scheduled_departure::date || ' / ' || f.departure_airport) over(PARTITION BY t.passenger_id 
                     ORDER BY f.scheduled_departure
          ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                    ) AS last_flight
      ,f.scheduled_departure::date || ' / ' || f.departure_airport AS current_flight
      ,lead(f.scheduled_departure::date || ' / ' || f.departure_airport) over(PARTITION BY t.passenger_id
                     ORDER BY f.scheduled_departure
                    ) AS next_flight
 FROM booking.tickets t
 join booking.ticket_flights tf
using (ticket_no)
 join booking.flights f
using (flight_id)
WHERE 1=1
  AND t.passenger_name ILIKE 'A%A%'    -- Имя начинается на "A" и содержит еще одну "A"
  AND split_part(t.passenger_name, ' ', 2) ILIKE '%OV%' -- Фамилия содержит "OV" 
  ORDER BY 
     t.passenger_name
    ,f.flight_id
LIMIT 100
;








