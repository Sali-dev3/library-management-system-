-- ==========================================================
-- Part 2.3 — UPDATE and DELETE (5 marks)
-- ==========================================================
-- 3 UPDATE statements
UPDATE members SET city = 'Koudougou' WHERE member_id = 9;
UPDATE books SET price = 8500 WHERE book_id = 4;
UPDATE fines SET paid_status = 'PAID' WHERE fine_id = 2;

-- 2 DELETE statements
-- Note: Deleting a fine first, so we don't violate referential integrity immediately
DELETE FROM fines WHERE amount = 0.00 LIMIT 1;
DELETE FROM authors WHERE nationality = 'Unknown'; -- Assuming no authors match currently

-- 1 example demonstrating what happens when referential integrity is violated
-- Attempting to delete a member who has existing borrowing history:
-- DELETE FROM members WHERE member_id = 1;
-- Error output: Cannot delete or update a parent row: a foreign key constraint fails...


-- ==========================================================
-- Part 2.4 — SELECT Queries (15 marks)
-- ==========================================================

-- Retrieve all records from a table (1 mark)
SELECT * FROM members;

-- Specific columns with WHERE condition (1 mark)
SELECT first_name, last_name, email FROM members WHERE city = 'Ouagadougou';

-- Sorted results using ORDER BY (1 mark)
SELECT title, price FROM books ORDER BY price DESC;

-- Limited results using LIMIT (1 mark)
SELECT title, category FROM books LIMIT 3;

-- Filter using BETWEEN, LIKE, or IN (2 marks)
SELECT title, price FROM books WHERE price BETWEEN 4000 AND 10000;
SELECT first_name, last_name FROM members WHERE last_name LIKE 'Oue%';
SELECT title, category FROM books WHERE category IN ('Roman', 'Fiction', 'Histoire');

-- INNER JOIN across two tables (2 marks)
SELECT members.first_name, members.last_name, borrowing.borrow_date 
FROM members 
INNER JOIN borrowing ON members.member_id = borrowing.member_id;

-- LEFT JOIN — explain the difference from INNER JOIN (2 marks)
-- Explanation: An INNER JOIN only shows members who HAVE borrowed books. 
-- A LEFT JOIN shows ALL members, even if they have NEVER borrowed a book (borrow_id will be NULL).
SELECT members.first_name, members.last_name, borrowing.borrow_id 
FROM members 
LEFT JOIN borrowing ON members.member_id = borrowing.member_id;

-- JOIN across three or more tables (3 marks)
SELECT members.first_name, books.title, authors.last_name AS author_name, borrowing.due_date
FROM borrowing
JOIN members ON borrowing.member_id = members.member_id
JOIN books ON borrowing.book_id = books.book_id
JOIN authors ON books.author_id = authors.author_id;

-- Query using IS NULL or IS NOT NULL (2 marks)
SELECT members.first_name, borrowing.book_id 
FROM borrowing 
JOIN members ON borrowing.member_id = members.member_id 
WHERE borrowing.return_date IS NULL;


-- ==========================================================
-- Part 3 — Aggregate Functions & Reporting (15 marks)
-- ==========================================================

-- COUNT total records in a table (2 marks)
SELECT COUNT(*) AS total_books_in_library FROM books;

-- MAX and MIN of a numeric column (2 marks)
SELECT MAX(price) AS most_expensive_book, MIN(price) AS cheapest_book FROM books;

-- AVG of a numeric column (2 marks)
SELECT AVG(amount) AS average_fine_amount FROM fines WHERE amount > 0;

-- GROUP BY with an aggregate function (3 marks)
-- How many books exist per category?
SELECT category, COUNT(*) AS number_of_books 
FROM books 
GROUP BY category;

-- HAVING to filter grouped results (3 marks)
-- Which categories have strictly more than 1 book?
SELECT category, COUNT(*) AS number_of_books 
FROM books 
GROUP BY category 
HAVING COUNT(*) > 1;

-- One summary report combining JOIN + GROUP BY + HAVING (3 marks)
-- Total owed in UNPAID fines per member, but only display members owing more than 1000
SELECT members.first_name, members.last_name, SUM(fines.amount) AS total_debt
FROM members
JOIN borrowing ON members.member_id = borrowing.member_id
JOIN fines ON borrowing.borrow_id = fines.borrow_id
WHERE fines.paid_status = 'UNPAID'
GROUP BY members.member_id, members.first_name, members.last_name
HAVING total_debt > 1000;
