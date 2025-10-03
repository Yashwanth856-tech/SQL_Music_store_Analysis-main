-- Music_Store_Query.sql
-- SQL PROJECT - MUSIC STORE DATA ANALYSIS
-- Adjust table/column names if your schema differs.

-- ############################
-- Question Set 1 - Easy
-- ############################

-- 1) Who is the senior most employee based on job title?
--    Approach: rank common seniority keywords; modify CASE order as required.
SELECT
  EmployeeId,
  FirstName,
  LastName,
  Title
FROM employees
ORDER BY
  CASE
    WHEN Title ILIKE '%Chief%' THEN 1
    WHEN Title ILIKE '%Head%' THEN 2
    WHEN Title ILIKE '%Director%' THEN 3
    WHEN Title ILIKE '%Senior%' THEN 4
    WHEN Title ILIKE '%Lead%' THEN 5
    WHEN Title ILIKE '%Manager%' THEN 6
    ELSE 99
  END,
  Title
LIMIT 1;

-- 2) Which countries have the most Invoices?
SELECT
  BillingCountry,
  COUNT(*) AS invoice_count
FROM invoices
GROUP BY BillingCountry
ORDER BY invoice_count DESC;

-- 3) What are top 3 values of total invoice?
--    (Top 3 distinct invoice totals)
SELECT DISTINCT Total
FROM invoices
ORDER BY Total DESC
LIMIT 3;

-- 4) Which city has the best customers? (city with highest sum of invoice totals)
SELECT
  BillingCity,
  SUM(Total) AS total_revenue
FROM invoices
GROUP BY BillingCity
ORDER BY total_revenue DESC
LIMIT 1;

-- 5) Who is the best customer? (customer who has spent the most money)
SELECT
  c.CustomerId,
  c.FirstName,
  c.LastName,
  SUM(i.Total) AS total_spent
FROM customers c
JOIN invoices i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY total_spent DESC
LIMIT 1;


-- ############################
-- Question Set 2 - Moderate
-- ############################

-- 1) Return email, first name, last name, & Genre of all Rock listeners.
--    Order by email alphabetically starting with 'A'.
--    Note: we use DISTINCT to avoid duplicates if a customer purchased multiple rock tracks.
SELECT DISTINCT
  c.Email,
  c.FirstName,
  c.LastName,
  g.Name AS Genre
FROM customers c
JOIN invoices i ON c.CustomerId = i.CustomerId
JOIN invoice_items ii ON i.InvoiceId = ii.InvoiceId
JOIN tracks t ON ii.TrackId = t.TrackId
JOIN genres g ON t.GenreId = g.GenreId
WHERE g.Name ILIKE 'Rock'
  AND c.Email ILIKE 'a%'    -- starts with 'A' or 'a'
ORDER BY c.Email;

-- 2) Artists who have written the most Rock music (Artist name and track count) — top 10
SELECT
  ar.ArtistId,
  ar.Name AS ArtistName,
  COUNT(t.TrackId) AS rock_track_count
FROM artists ar
JOIN albums al ON ar.ArtistId = al.ArtistId
JOIN tracks t ON al.AlbumId = t.AlbumId
JOIN genres g ON t.GenreId = g.GenreId
WHERE g.Name ILIKE 'Rock'
GROUP BY ar.ArtistId, ar.Name
ORDER BY rock_track_count DESC
LIMIT 10;

-- 3) Return track names that have song length longer than the average song length.
--    Return Name and Milliseconds, ordered by longest first.
SELECT
  Name,
  Milliseconds
FROM tracks
WHERE Milliseconds > (SELECT AVG(Milliseconds) FROM tracks)
ORDER BY Milliseconds DESC;


-- ############################
-- Question Set 3 - Advance
-- ############################

-- 1) How much amount spent by each customer on artists?
--    Return customer name, artist name and total spent.
--    We compute sum(UnitPrice * Quantity) grouped by customer & artist.
SELECT
  c.CustomerId,
  c.FirstName AS CustomerFirstName,
  c.LastName  AS CustomerLastName,
  ar.ArtistId,
  ar.Name AS ArtistName,
  SUM(ii.UnitPrice * ii.Quantity) AS total_spent_on_artist
FROM customers c
JOIN invoices i ON c.CustomerId = i.CustomerId
JOIN invoice_items ii ON i.InvoiceId = ii.InvoiceId
JOIN tracks t ON ii.TrackId = t.TrackId
JOIN albums al ON t.AlbumId = al.AlbumId
JOIN artists ar ON al.ArtistId = ar.ArtistId
GROUP BY c.CustomerId, c.FirstName, c.LastName, ar.ArtistId, ar.Name
ORDER BY c.CustomerId, total_spent_on_artist DESC;

-- 2) Most popular music Genre for each country (by number of purchases).
--    For ties, return all top genres per country.
WITH country_genre_counts AS (
  SELECT
    c.Country,
    g.GenreId,
    g.Name AS GenreName,
    COUNT(ii.InvoiceItemId) AS purchases
  FROM customers c
  JOIN invoices i ON c.CustomerId = i.CustomerId
  JOIN invoice_items ii ON i.InvoiceId = ii.InvoiceId
  JOIN tracks t ON ii.TrackId = t.TrackId
  JOIN genres g ON t.GenreId = g.GenreId
  GROUP BY c.Country, g.GenreId, g.Name
),
ranked AS (
  SELECT
    Country,
    GenreId,
    GenreName,
    purchases,
    RANK() OVER (PARTITION BY Country ORDER BY purchases DESC) AS rk
  FROM country_genre_counts
)
SELECT
  Country,
  GenreName,
  purchases
FROM ranked
WHERE rk = 1
ORDER BY Country, GenreName;

-- 3) Customer that has spent the most on music for each country.
--    For countries where the top amount is shared, provide all customers who spent this amount.
WITH customer_country_spend AS (
  SELECT
    c.Country,
    c.CustomerId,
    c.FirstName,
    c.LastName,
    SUM(ii.UnitPrice * ii.Quantity) AS total_spent
  FROM customers c
  JOIN invoices i ON c.CustomerId = i.CustomerId
  JOIN invoice_items ii ON i.InvoiceId = ii.InvoiceId
  GROUP BY c.Country, c.CustomerId, c.FirstName, c.LastName
),
ranked_cc AS (
  SELECT
    Country,
    CustomerId,
    FirstName,
    LastName,
    total_spent,
    RANK() OVER (PARTITION BY Country ORDER BY total_spent DESC) AS rk
  FROM customer_country_spend
)
SELECT
  Country,
  CustomerId,
  FirstName,
  LastName,
  total_spent
FROM ranked_cc
WHERE rk = 1
ORDER BY Country, total_spent DESC;
