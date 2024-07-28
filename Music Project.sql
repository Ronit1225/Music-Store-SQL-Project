### DIGITAL MUSIC STORE ANALYSIS ###
-- Data Set imported from https://shorturl.at/sEIUV  
-- total tables 13

-- Question set 1
-- Q1) Who is the senior most employee based on job title?
USE music_world; # Create datase music_world > SCHEMAS > music_world > tables > Right click table data import 

select * from employee
order by levels desc
limit 1;
-- Answer: General Manager, Mr Adams Andrew

-- Q2) Which country has the most invoices?
select count(*) as c, billing_country 
from invoice
group by billing_country
order by c desc;
-- USA has 131 Invoices, which is the most in the list.

-- Q3) What are top 3 values of Total Invoice?
select total from invoice
order by total desc
limit 3;
-- Top 3 invoices have the values 23.76, 19.8 and 19.8 respectively. 

-- Q4) Which city has the best customers? 
-- We would like to throw a 'promotional Music Festival' in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals.
select sum(total) as invoice_total , billing_city from invoice # here sum(total) will count the total amount of invoices that came from each city and then group it together with city name then simply order it in decending to get the result.
group by billing_city
order by invoice_total desc
limit 10;
-- Top 3 cities are 273.24 Prague 170	Mountain View and 166 London

-- Q5) Who is the best customer? 
-- The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
SELECT customer.customer_id as ID, customer.first_name, customer.last_name, SUM(invoice.total) AS Max_Invoice_Value
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY ID, customer.first_name, customer.last_name
ORDER BY Max_Invoice_Value DESC
LIMIT 1;
-- BEST CUSTOMER DETAILS:- CUSTOMER ID: 5	NAME: František Wichterlová	TOTAL SPEND: 144.54

-- Question Set 2
-- Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A
select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
select track_id from track
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
)
order by email;
-- We are getting bellow result whic is exactly what the requirement was.
-- aaronmitchell@yahoo.ca	Aaron	Mitchell
-- alero@uol.com.br	Alexandre	Rocha

-- OR we can use the next code where we are using multiple Join's to get the desired filter. 
-- This next code is simply joining all the 5 tables and as a result i can recall any column from all the 5 tables.

SELECT DISTINCT customer.customer_id as ID, customer.email, customer.first_name, customer.last_name, 
genre.genre_id, genre.name as genre_name, track.name as Track_name, invoice.invoice_id
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON track.track_id = invoice_line.track_id  #This is tha part which is different
JOIN genre ON  genre.genre_id = track.genre_id
WHERE genre.name = 'Rock' 
ORDER BY email;
-- We are getting the bellow result as per requirement.
-- 32	aaronmitchell@yahoo.ca	Aaron	Mitchell	1	Rock	Love In An Elevator	107
-- 32	aaronmitchell@yahoo.ca	Aaron	Mitchell	1	Rock	Right Through You	
-- Note: this code is unoptimized so using it will make the system slower as many joins do not make good quary.

-- Q2: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands
select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album_new on album_new.album_id = track.album_id
join artist on artist.artist_id = album_new.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
group by artist.artist_id, artist.name
order by number_of_songs desc
limit 10;
-- This is the result we needed
-- Column names: Artist_id, Name of composure, Number of songs
--                22	    Led Zeppelin	   114
--                150	    U2	               112

-- Q3: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. 
-- Order by the song length with the longest songs listed first
select avg(milliseconds) as avg_track_length
from track;
-- 393733.3383
select name, milliseconds
from track
where milliseconds > (
select avg(milliseconds) as avg_track_length
from track) # This is done to make the quary dynamic or else simply adding "WHERE milliseconds > 393733.3383" will give the same result.
order by milliseconds desc;
-- Answer:
-- Column Name name, Milliseconds
-- Occupation / Precipice	5286953
-- Through a Looking Glass	5088838

-- Finding the count of such track length
SELECT COUNT(*) as Number_of_Tracks_Greaterthan_393733
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_length
    FROM track
);
-- Answer: Number_of_Tracks_Greaterthan_393733 is 492

-- Question Set 3
-- Q1: Find how much amount spent by each customer on artists? 
-- Write a query to return customer name, artist name and total spent.
with best_selling_artist as(
select artist.artist_id as artist_ID, artist.name as artist_name, 
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.track_id
join album_new on album_new.album_id = track.album_id
join artist on artist.artist_id = album_new.artist_id
group by artist.artist_id, artist.name # here "group by 1" is not working and I have to mention all groups as "GROUP BY artist.artist_id, artist.name"
order by 3 desc
limit 1
) # This is a CTE named "best_selling_artist" or Common Table Expression. It's a temporary table made to use in further calculations and will be desolved after the execution
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spend
from invoice i 
join customer c on c.customer_id = i. customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album_new alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1, 2, 3, 4
order by 5 desc;
-- Answer:
-- Column name: customer_id, First_name, Last_name, artist_name, amount_spend
-- 46	Hugh	O'Reilly	Queen	27.719999999999985
-- 38	Niklas	Schröder	Queen	18.81

-- Q2: We want to find out the most popular music Genre for each country. 
-- We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres.
with popular_genre as
(
select count(invoice_line.quantity) as purchases, customer.country,genre.name, genre.genre_id,
row_number() over(partition by customer.country order by count(invoice_line.quantity)desc) as RowNo
from invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on  customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2 asc, 1 desc
) 
select* from popular_genre where RowNo <= 1;
-- With the help of CTE we got the answer
-- purchases=17, country=Argentina, name=Alternative & Punk, genre_id=4, RowNo=1

-- ﻿Q3: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount
with recursive
customer_with_country as (
select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending 
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3,4
order by 2,3 desc),
country_max_spending as
(
select billing_country, max(total_spending) as max_spending
from customer_with_country
group by billing_country
)
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name
from customer_with_country cc
join country_max_spending ms on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending 
order by 1;
-- Answer billing_country  ,  total_spending  ,  fisrt_name  ,  last_name
--         Argentina	      39.6	             Diego	        Gutiérrez
--         Australia	      81.18	             Mark	        Taylor

-- END 
# Thank you #