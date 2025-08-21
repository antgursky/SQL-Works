-- Домашняя работа 2. 
--вариант 1

--1.Посчитать общее количество самолетов в таблице aircrafts_data
select count(*) as count_model
  from booking.aircrafts_data ad 
;  
 --2.Вычислить среднюю дальность полета самолетов
select cast (avg(range) AS DECIMAL(10,2)) as avg_range
  from booking.aircrafts_data ad 
;  
  --3. Найти максимальную дальность полета среди всех самолетов
  
select model ->> 'ru' as model_ru
	  ,range
  from booking.aircrafts_data ad
 where range = (SELECT MAX(range) FROM booking.aircrafts_data) 
;

--4. Посчитать общее количество аэропортов в таблице airports_data

select count(*) as count_airports
  from booking.airports_data 
;

--5. Вычислить среднюю, медиану и моду стоимости бронирования

select fare_conditions 
	  ,cast (avg(amount) as DECIMAL(10,2)) --средняя
	  ,percentile_cont(0.5) within group (order by amount) --медиана
	  ,mode() within group (order by amount)
  from booking.ticket_flights
 group by fare_conditions
;


--6. Найти первые пять самых дорогих бронирований;

select distinct amount 
  from booking.ticket_flights
 order by amount DESC
 limit 5
;

 --7. Посчитать общее количество посадочных талонов
  
select count(*) as count_tickets
  from booking.tickets t   
;

--8. Вычислить суммарную стоимость всех билетов класса комфорт

select fare_conditions 
	  ,sum (amount)
  from booking.ticket_flights
 where fare_conditions = 'Comfort'
 group by fare_conditions  
;

--9. Вывести дату и время первого и последнего рейса

select TO_CHAR(min(scheduled_departure), 'yyyy-MM-dd HH:mm:ss') as first_race
	  ,TO_CHAR(max(scheduled_departure), 'yyyy-MM-dd HH:mm:ss') as last_race
  from booking.flights f 
;

--10. Найти среднюю стоимость билетов по классам обслуживания

select fare_conditions 
	  ,cast (avg(amount) as DECIMAL(10,2)) as avg_amount
  from booking.ticket_flights
 group by fare_conditions
;

--11. Вычислить среднюю продолжительность рейсов

select TO_CHAR(avg(actual_arrival - actual_departure), 'HH:mm:ss') avg_race
  from booking.flights f 
;

--12. Посчитать общую сумму дохода от авиаперевозок по годам

select extract('year' from f.scheduled_departure) as "Год"
	  ,sum(tf.amount) as "Доход" 
	  --sum(amount)
  from booking.ticket_flights tf
  join booking.flights f 
  on tf.flight_id = f.flight_id 
 group by extract('year' from f.scheduled_departure)
;
  
--13. Найти самый дешевый билет (разделил по классам)

select fare_conditions ,min(amount) as min_amount
  from booking.ticket_flights tf 
 group by fare_conditions 
;
  
--14. Посчитать количество исходящих рейсов для каждого аэропорта  
  
select departure_airport 
	  ,count(departure_airport) as count_sched
  from booking.flights f
 where actual_departure is not null
 group by departure_airport 
 order by count_sched desc
;


--15. Найти аэропорт с наибольшим количеством рейсов (рейс – flight_id,
--учитывать только аэропорт отправления)

select departure_airport 
	  ,count(flight_id) as count_flight
  from booking.flights f
 where actual_departure is not null
 group by departure_airport 
 order by count_flight desc
 limit 1
;

--16. Вычислить общее количество мест для каждого типа самолёта с
--разделением на классы. Необходимо вывести 3 колонки: код самолёта, класс
--обслуживания, кол-во мест

select aircraft_code
	  ,fare_conditions
	  ,count(aircraft_code) as count_seats
  from booking.seats
 group by aircraft_code, fare_conditions
 order by aircraft_code asc 
 	     ,fare_conditions asc 
;

--17. Найти количество бронирований и их суммарную стоимость за 2017 год

select extract('year' from f.scheduled_departure) as "Год"
	  ,count(tf.amount) as "Количество бронирований"
	  ,sum(tf.amount) as "Стоимость"
  from booking.ticket_flights tf
  join booking.flights f 
  on tf.flight_id = f.flight_id
 WHERE extract('year' from f.scheduled_departure) = 2017
 group by extract('year' from f.scheduled_departure)
 ;

--18. Вычислить общую стоимость билетов для каждого рейса

select flight_id 
	  ,sum(amount) as sum_amount
  from booking.ticket_flights tf 
 group by flight_id
 order by sum_amount desc
;

--19. Вычислить количество билетов и общую стоимость бронирований рейсов,
--где количество билетов больше 200 и общая стоимость бронирований
--превышает 16 млн. Данные необходимо отсортировать сначала по количеству
--билетов по убыванию, а затем по стоимости бронирования тоже по убыванию

select flight_id
	  ,count(ticket_no) as count_ticket
	  ,sum(amount) as sum_amount
  from booking.ticket_flights tf 
 group by flight_id
 having count(ticket_no) > 200 and 
 	    sum(amount) > 16000000 
 order by count_ticket desc
 		 ,sum_amount desc
;


--20. Вычислить количество перелётов из Внуково в Адлер и обратно за 2017 год

 
 select distinct extract('year' from scheduled_departure) as "year"
 	   ,departure_airport
 	   ,arrival_airport
 	   ,count(departure_airport) as "count_flights"
   from booking.flights f
   WHERE extract('year' from f.scheduled_departure) = 2017
   and departure_airport in ('VKO', 'AER')
   and arrival_airport in ('VKO', 'AER')
   group by extract('year' from f.scheduled_departure),departure_airport, arrival_airport
;





--II. Вариант (вес одного задания 2 балла)

--Найти рейсы, у которых фактическое время прилета позже
--запланированного времени прилета более чем на 1 час;



SELECT flight_no
	   ,departure_airport
       ,TO_CHAR(scheduled_arrival, 'HH24:MI') AS scheduled_time
       ,TO_CHAR(actual_arrival, 'HH24:MI') AS actual_time
       ,TO_CHAR(actual_arrival - scheduled_arrival, 'HH24:MI') AS time_dif
FROM booking.flights
WHERE actual_arrival > (scheduled_arrival + INTERVAL '1 hour')
order by time_dif desc

  
  
  
  
  
  
  
  
  
  
  
  
  
  