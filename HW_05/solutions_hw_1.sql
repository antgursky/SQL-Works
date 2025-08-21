-- HW_01 — база booking

--Задача1
--Вывести все поля(колонки) таблицы flights. Ограничить выборку 100 строками.
select *
  from booking.flights
 limit 100
;
----------------------------------------------------------

--Задача2
--Вывести номера билетов и их стоимость из таблицы ticket_flights, где 
--класс бронирования 'Business'.
select ticket_no
	  ,amount 
  from booking.ticket_flights
 where fare_conditions = 'Business'
;
----------------------------------------------------------

--Задача3
--Вывести код аэропорта, название аэропорта на русском языке и город на
--русском языке для тех аэропортов, которые находятся во временных зонах
--начинающихся на ‘Asia’.
select airport_code
	  ,airport_name ->> 'ru' as airport_name_ru
	  ,city ->> 'ru' as city_ru
	  ,timezone
	from booking.airports_data 
   where timezone LIKE 'Asia%'
;
----------------------------------------------------------

--Задача4
--Вывести номер рейса и код самолёта из таблицы flights для рейсов из
--Домодедово в Пулково и из Пулково в Домодедово.
select flight_no
      ,aircraft_code
--    ,departure_airport
--    ,arrival_airport
  from booking.flights
 where departure_airport = 'DME' and arrival_airport = 'LED'
 	or departure_airport = 'LED' and arrival_airport = 'DME'
;
----------------------------------------------------------

--Задача5
--Вывести дальность полёта и названия моделей самолётов на английском_языке, 
--дальность полёта которых менее 5000 км.
select model ->> 'en' as model
--	  ,"range"
  from booking.aircrafts_data
 where "range" < 5000
;
----------------------------------------------------------

--Задача6
--Вывести следующую информацию из таблицы tickets:
--a. номер билета,
--b. номер бронирования,
--c. имя и фамилию пассажира,
--d. адрес электронной почты в отдельном поле (задайте этому полю
--псевдоним (alias) “passenger_email”),
--e. телефон в отдельном поле (задайте этому полю псевдоним (alias)
--“passenger_phone”).
--для тех билетов, где номер билета начинается на ‘0005435599’. Данные должны
--быть отсортированы по номеру бронирования по возрастанию и по имени и
--фамилии пассажира по убыванию.

select ticket_no
      ,book_ref
      ,passenger_name 
      ,contact_data ->> 'email' passenger_email
      ,contact_data ->> 'phone' passenger_phone
  from booking.tickets
 where  ticket_no LIKE '0005435599%'
 order by book_ref asc
         ,passenger_name desc 
;
----------------------------------------------------------

--Задача7
--Оставьте из предыдущего запроса только те строки, где фамилии
--пассажиров заканчиваются на ‘NOV’ или ‘OVA’.
select ticket_no
      ,book_ref
      ,passenger_name 
      ,contact_data ->> 'email' passenger_email
      ,contact_data ->> 'phone' passenger_phone
  from booking.tickets
 where ticket_no LIKE '0005435599%'
      and (passenger_name LIKE '%NOV' or passenger_name LIKE '%OVA')       
 order by book_ref asc
         ,passenger_name desc 
;
----------------------------------------------------------

--Задача8
--Вывести топ 5 самый дорогих бронирований из таблицы bookings.

select book_ref
      ,total_amount
  from booking.bookings 
  order by total_amount desc
  limit 5
;
----------------------------------------------------------

--Задача9
--Вывести из таблицы flights рейсы, вылет которых был запланирован в
--интервале с 10 февраля 2017 по 10 апреля 2017.

select *
  from booking.flights
 where scheduled_departure >= '2017-02-10' and scheduled_arrival <= '2017-04-10'
 order by scheduled_departure asc
;
----------------------------------------------------------


--Задача10
--Выведите всю информацию (все поля) о последних 3 отменённых рейсах в
--аэропорт города Петрозаводск (PES).
select *
  from booking.flights
 where arrival_airport = 'PES'
       and status = 'Cancelled'
 order by scheduled_departure desc
 limit 3
 ;

----------------------------------------------------------












