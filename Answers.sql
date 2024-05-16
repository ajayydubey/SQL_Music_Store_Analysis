Question Set 1 - Easy
1. Who is the senior most employee based on job title?

	SELECT * 
	FROM employee
	Order by levels DESC
	LIMIT 1

2. Which countries have the most Invoices?

	SELECT COUNT(*) as total, billing_country
	FROM Invoice
	group by billing_country
	order by total DESC
	LIMIT 5
	
3. What are top 3 values of total invoice?

	SELECT total as Total
	FROM Invoice
	ORDER BY total DESC
	LIMIT 3

4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

	SELECT SUM(total) as s,billing_city
	FROM invoice
	group by billing_city
	order by s DESC
	LIMIT 1

	
5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money

	SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total
	FROM customer
	JOIN Invoice on customer.customer_id = invoice.customer_id
	group by customer.customer_id
	order by total DESC
	LIMIT 1

	
Question Set 2 - Moderate

	
1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

	SELECT DISTINCT email, first_name, Last_name
	FROM customer
	JOIN invoice ON customer.customer_id = invoice.customer_id
	JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
	WHERE track_id IN (
		select track_id FROM track
		JOIN genre ON track.genre_id = genre.genre_id
		WHERE genre.name LIKE 'Rock'
	)
order by email


2. Lets invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands.

	SELECT artist.artist_id, Artist.Name, COUNT( artist.artist_id) AS number_of_songs
	FROM artist
	JOIN Album on artist.artist_id = album.artist_id
	JOIN Track on album.album_id = track.album_id
	JOIN Genre on track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
	Group by artist.artist_id
	Order by number_of_songs DESC
	
	
3. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

	SELECT *
	FROM invoice_line

	SELECT name, milliseconds
	FROM Track
	where milliseconds > (Select AVG(milliseconds) AS Avg_track_length FROM track)
	order by milliseconds DESC



Question Set 3 - Advance
1. Find how much amount spent by each customer on artists? 
	Write a query to return customer name, artist name and total spent

	WITH best_selling_artist AS (
		SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
		SUM ( invoice_line.unit_price*invoice_line.quantity) AS total_sales
		FROM invoice_line
		JOIN Track on invoice_line.track_id = track.track_id
		JOIN Album on track.album_id = album.album_id
		JOIN Artist on album.artist_id = artist.artist_id
		GROUP BY 1
		ORDER BY 3 DESC
		LIMIT 1
	)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM( il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c on c.customer_id = i.customer_id
JOIN invoice_line il on il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

	
2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres

WITH popular_genre AS (
	SELECT COUNT (invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER () OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC ) AS RoWNo
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

3. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

