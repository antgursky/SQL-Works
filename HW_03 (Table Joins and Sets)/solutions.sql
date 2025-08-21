-- HW_03 — база booking


--1. (1 балл) Выведите список рейсов (список номеров перелётов –
--flight_no) с информацией о модели самолёта на английском языке

select f.flight_no
	  ,ad.model ->> 'en' as model_en
  from booking.flights f
  join booking.aircrafts_data ad 
  on f.aircraft_code = ad.aircraft_code
  
  
  --2. (1 балл) Выведите модели самолётов, на которых совершались
--перелёты из Санкт-Петербурга в другие города в декабре 2016 года
  
  select ad.model ->> 'en' as model_en
	    ,TO_CHAR(f.scheduled_departure, 'yyyy-MM-dd') as date
	    ,f.departure_airport
	    ,f.arrival_airport
  from booking.flights f
  left join booking.aircrafts_data ad 
    on f.aircraft_code = ad.aircraft_code
 where 
 f.departure_airport = 'LED' and
 f.scheduled_departure::date between '2016-12-01' and '2016-12-31'
 and f.actual_departure is not null
 order by f.scheduled_departure asc 
;

--3. (1 балл) Выведите имена, фамилии, адреса электронной почты и
--номера телефонов тех пассажиров, которые осуществили бронирование в октябре 2016 года

  select t.passenger_name
  	    ,t.contact_data ->> 'phone' as phone
  	    ,t.contact_data ->> 'email' as email
  	    ,TO_CHAR(b.book_date, 'yyyy-MM-dd') as booking_date
    from booking.tickets t 
    join booking.bookings b 
	  on t.book_ref =b.book_ref 
   where 
   b.book_date::date between '2016-10-01' and '2016-10-31'
   and b.book_ref is not null
   order by b.book_date asc 
;

--4. (1 балл) Оставьте только тех пассажиров из предыдущего пункта, у
--которых был вылет из Москвы

  select t.passenger_name
  	    ,t.contact_data ->> 'phone' as phone
  	    ,t.contact_data ->> 'email' as email
  	    ,TO_CHAR(b.book_date, 'yyyy-MM-dd') as booking_date
  	    ,ad.city ->> 'ru' as departure_city
    from booking.tickets t 
    join booking.bookings b 
	  on t.book_ref =b.book_ref
	join booking.ticket_flights tf 
	  on t.ticket_no = tf.ticket_no 
	join booking.flights f 
	  on f.flight_id = tf.flight_id 
	join booking.airports_data ad 
	  on ad.airport_code = f.departure_airport
   where 
   b.book_date::date between '2016-10-01' and '2016-10-31'
   and b.book_ref is not null
   and ad.city ->> 'ru' = 'Москва'
   order by b.book_date asc 
;

--5. (1 балл) Выведите список рейсов с информацией о количестве
--пассажиров на борту для 2017 года;

select f.flight_no
	  ,count(bp.seat_no) as count_pas
	  ,extract ('year' from f.scheduled_departure) as year_flight
  from booking.flights f 
  join booking.boarding_passes bp 
    on f.flight_id = bp.flight_id 
 where 1=1
   and extract ('year' from f.scheduled_departure) = 2017
 group by f.flight_no, extract ('year' from f.scheduled_departure)
 order by count(bp.boarding_no) desc
;

--6. (1 балл) Выведите среднюю стоимость билета для каждого
--уникального направления перелёта в зависимости от класса обслуживания

SELECT
    f.departure_airport AS откуда,
    f.arrival_airport AS куда,
    tf.fare_conditions AS класс_обслуживания,
    ROUND(AVG(tf.amount), 0) AS средняя_стоимость_билета
FROM
    booking.ticket_flights tf
JOIN
    booking.flights f ON tf.flight_id = f.flight_id
GROUP BY
    f.departure_airport,
    f.arrival_airport,
    tf.fare_conditions
ORDER BY
    f.departure_airport,
    f.arrival_airport,
    tf.fare_conditions
;

--7. (2 балла) Выведите: номер перелёта, класс обслуживания, общее кол-
--во мест в классе, кол-во мест занято, кол-во место свободно для всех рейсов,
--которые были совершены в январе 2017 года;


select bp.flight_id,
    tf.fare_conditions,
    COUNT(s.seat_no) AS count_seats_all,
    COUNT(bp.seat_no) AS count_seats_br,
    COUNT(s.seat_no) - COUNT(bp.seat_no) AS seats_free
  from booking.boarding_passes bp
  join booking.ticket_flights tf  
    on tf.flight_id = bp.flight_id and tf.ticket_no = bp.ticket_no
  join booking.flights f 
    on  tf.flight_id = f.flight_id 
  join booking.aircrafts_data ad 
    on f.aircraft_code = ad.aircraft_code
  join booking.seats s 
    on ad.aircraft_code = s.aircraft_code AND s.seat_no = bp.seat_no
 where 1=1 and
  f.scheduled_departure::date between '2017-01-01' and '2017-01-31'
  group by bp.flight_id,    tf.fare_conditions
  order by bp.flight_id
  
;


-- 8. (2 балла) Выведите среднюю стоимость билета для каждого класса
--обслуживания по рейсам, которые совершаются в выходные. Отдельно выведите
--среднюю стоимость билета для каждого класса обслуживания по рейсам, которые
--совершаются в будни. Объедините информацию из двух запросов и сравните
--насколько средние стоимости билетов различны, если лететь в будни или в
--выходные.
 
SELECT
    tf.fare_conditions AS class_of_service
    ,ROUND(AVG(CASE 
                WHEN EXTRACT(DOW FROM f.scheduled_departure) IN (0, 6) THEN tf.amount 
              END), 2) AS avg_price_weekend
    ,ROUND(AVG(CASE 
                WHEN EXTRACT(DOW FROM f.scheduled_departure) BETWEEN 1 AND 5 THEN tf.amount 
              END), 2) AS avg_price_weekday
    ,ROUND(
        AVG(CASE 
                WHEN EXTRACT(DOW FROM f.scheduled_departure) IN (0, 6) THEN tf.amount 
            END) -
        AVG(CASE 
                WHEN EXTRACT(DOW FROM f.scheduled_departure) BETWEEN 1 AND 5 THEN tf.amount 
            END), 2
    ) AS price_difference
from booking.ticket_flights tf
join booking.flights f ON tf.flight_id = f.flight_id
GROUP by tf.fare_conditions
ORDER by tf.fare_conditions
;






