# SQL PROJECT - MUSIC STORE DATA ANALYSIS

This repository contains SQL queries for the "Music Store" dataset (typical schema: employees, customers, invoices, invoice_items, tracks, albums, artists, genres).  
These queries are grouped into three question sets (Easy, Moderate, Advance) and are intended for learning and portfolio use.

> ⚠️ Note: Update table/column names if your dataset uses different naming conventions.

## Files
- `Music_Store_Query.sql` — SQL queries for all question sets with explanations and comments.

## How to use
1. Open `Music_Store_Query.sql` in a SQL client that has access to your Music Store database.
2. Run individual queries after confirming table/column names match your DB schema.
3. For any questions or changes, open an issue or edit the SQL file.

## Typical tables used (example)
- employees (EmployeeId, FirstName, LastName, Title)
- customers (CustomerId, FirstName, LastName, Email, Country, City)
- invoices (InvoiceId, CustomerId, InvoiceDate, BillingCity, BillingCountry, Total)
- invoice_items (InvoiceItemId, InvoiceId, TrackId, UnitPrice, Quantity)
- tracks (TrackId, Name, Milliseconds, GenreId, AlbumId, Composer)
- albums (AlbumId, Title, ArtistId)
- artists (ArtistId, Name)
- genres (GenreId, Name)

## Author
Demo / portfolio sample — replace with your name and contact before publishing as your real portfolio.
