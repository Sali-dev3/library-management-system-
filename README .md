# 📚 Library Management System — CS27

> **End-of-Semester Group Project**  
> CS27 – The Relational Model & Databases  
> Burkina Institute of Technology | Instructor: Kweyakie Afi Blebo

---

## 👥 Group 5 — Members

| Name | Role |
|------|------|
| COMPAORE Salamata | Group Leader — Coordination & submission |
| YELEMOU Josias Martial | Database Design — Entities & Relationships |
| OUEDRAOGO Alimata | Schema Diagram & Normalization |
| KOALAGA Heliane Elichebat | MySQL Implementation — Tables & Data |
| KABORE Tegwende Odiane Elia Aziliz | SQL Queries |
| ROAMBA Sarifatou | Aggregate Functions, Presentation & Video |

---

## 📋 Project Overview

This project implements a fully functional **Library Management System** using MySQL. It allows a library to manage books, authors, members, loan transactions, and fines for late returns.

The project covers:
- Relational database design (entities, relationships, primary keys, foreign keys)
- Normalization from unnormalized data to 3NF
- MySQL implementation with constraints
- SQL queries including JOINs, aggregate functions, and reports

---

## 🗂️ Repository Structure

```
library-management-system/
│
├── README.md                  # This file
│
├── sql/
│   ├── 01_create_database.sql # CREATE DATABASE + USE
│   ├── 02_create_tables.sql   # All CREATE TABLE statements
│   ├── 03_insert_data.sql     # INSERT statements (10+ rows per table)
│   ├── 04_update_delete.sql   # UPDATE, DELETE, FK violation demo
│   ├── 05_select_queries.sql  # All SELECT queries (Part 2.4)
│   └── 06_aggregate.sql       # Aggregate functions & reports (Part 3)
│
├── docs/
│   ├── schema_diagram.png     # ERD / Schema diagram
│   └── normalization.md       # Normalization walkthrough (1NF → 3NF)
│
└── presentation/
    └── CS27_Group5_Presentation.pptx
```

---

## 🗃️ Database Schema

### Entities & Primary Keys

| Entity | Primary Key | Key Attributes |
|--------|-------------|----------------|
| AUTHORS | author_id | first_name, last_name, nationality |
| BOOKS | book_id | title, genre, year_published, author_id (FK) |
| MEMBERS | member_id | name, email, phone, join_date |
| LOANS | loan_id | member_id (FK), book_id (FK), loan_date, return_date |
| FINES | fine_id | loan_id (FK), amount, paid |

### Relationships & Cardinalities

| Relationship | Type | Foreign Key |
|--------------|------|-------------|
| AUTHORS → BOOKS | 1 : N | author_id in BOOKS |
| MEMBERS → LOANS | 1 : N | member_id in LOANS |
| BOOKS → LOANS | 1 : N | book_id in LOANS |
| LOANS → FINES | 1 : 1 | loan_id in FINES |

---

## ⚙️ How to Run

### Requirements
- MySQL 8.0 or higher
- MySQL Workbench (recommended) or any MySQL client

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/library-management-system.git
   cd library-management-system
   ```

2. **Open MySQL Workbench** and connect to your local server.

3. **Run the SQL files in order:**
   ```sql
   source sql/01_create_database.sql;
   source sql/02_create_tables.sql;
   source sql/03_insert_data.sql;
   source sql/04_update_delete.sql;
   source sql/05_select_queries.sql;
   source sql/06_aggregate.sql;
   ```

4. **Verify the setup:**
   ```sql
   USE library_db;
   SHOW TABLES;
   SELECT * FROM books;
   ```

---

## 🏗️ SQL Overview

### Create Tables (Part 2.1)

```sql
CREATE DATABASE library_db;
USE library_db;

CREATE TABLE authors (
    author_id   INT PRIMARY KEY AUTO_INCREMENT,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    nationality VARCHAR(100)
);

CREATE TABLE books (
    book_id         INT PRIMARY KEY AUTO_INCREMENT,
    title           VARCHAR(200) NOT NULL,
    genre           VARCHAR(50),
    year_published  INT,
    author_id       INT NOT NULL,
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

CREATE TABLE members (
    member_id   INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(150) NOT NULL,
    email       VARCHAR(150) UNIQUE NOT NULL,
    phone       VARCHAR(20),
    join_date   DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE loans (
    loan_id      INT PRIMARY KEY AUTO_INCREMENT,
    member_id    INT NOT NULL,
    book_id      INT NOT NULL,
    loan_date    DATE NOT NULL,
    return_date  DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id)   REFERENCES books(book_id)
);

CREATE TABLE fines (
    fine_id   INT PRIMARY KEY AUTO_INCREMENT,
    loan_id   INT NOT NULL,
    amount    DECIMAL(10,2) NOT NULL,
    paid      BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);
```

### UPDATE & DELETE (Part 2.3)

```sql
-- UPDATE examples
UPDATE books SET genre = 'Classic' WHERE book_id = 3;
UPDATE members SET phone = '+226 70 00 00 01' WHERE member_id = 1;
UPDATE fines SET paid = TRUE WHERE fine_id = 2;

-- DELETE examples
DELETE FROM fines WHERE paid = TRUE;
DELETE FROM loans WHERE return_date < '2024-01-01';

-- Referential integrity violation (intentional error demo)
INSERT INTO books (title, author_id) VALUES ('Ghost Book', 9999);
-- ERROR: Cannot add or update a child row: a foreign key constraint fails
```

### Key SELECT Queries (Part 2.4)

```sql
-- All records
SELECT * FROM books;

-- Specific columns with WHERE
SELECT title, genre FROM books WHERE year_published > 2000;

-- ORDER BY + LIMIT
SELECT name, email FROM members ORDER BY name ASC LIMIT 5;

-- BETWEEN
SELECT * FROM fines WHERE amount BETWEEN 500 AND 2000;

-- LIKE
SELECT * FROM members WHERE name LIKE 'A%';

-- INNER JOIN
SELECT m.name, b.title, l.loan_date
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b   ON l.book_id   = b.book_id;

-- LEFT JOIN (all members, even with no loans)
SELECT m.name, l.loan_id
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id;

-- IS NULL (unreturned books)
SELECT * FROM loans WHERE return_date IS NULL;
```

### Aggregate Functions & Report (Part 3)

```sql
-- COUNT
SELECT COUNT(*) AS total_books FROM books;

-- MAX and MIN
SELECT MAX(amount) AS highest_fine, MIN(amount) AS lowest_fine FROM fines;

-- AVG
SELECT AVG(amount) AS average_fine FROM fines;

-- GROUP BY
SELECT member_id, COUNT(loan_id) AS total_loans
FROM loans
GROUP BY member_id;

-- HAVING
SELECT member_id, COUNT(loan_id) AS total_loans
FROM loans
GROUP BY member_id
HAVING total_loans > 2;

-- Summary Report: JOIN + GROUP BY + HAVING
SELECT m.name, COUNT(l.loan_id) AS total_loans
FROM members m
JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id
HAVING total_loans >= 3
ORDER BY total_loans DESC;
```

---

## 📐 Normalization Summary

Starting from one large unnormalized table:

```
member_id | name | phone | book_title | author | loan_date | fine_amount
```

**1NF** — Each column has atomic values. No repeating groups.

**2NF** — Removed partial dependencies: book info (title, author) moved to a separate `BOOKS` table. Member info stays in `MEMBERS`.

**3NF** — Removed transitive dependencies: member contact details (email, phone) depend only on `member_id`, not on `loan_id`. Fine details moved to a separate `FINES` table.

**Result:** 5 clean, normalized tables with no redundant data.

---

## 🎬 Video Walkthrough

Watch our project presentation on YouTube:  
🔗 **[Insert YouTube link here]**

Duration: 5–10 minutes | All group members participate.

---

## 📄 Academic Integrity

All SQL code in this repository was written by Group 5.  
AI tools were used only for learning and debugging — not to write the final code.  
As required, every member can explain each line of the submitted SQL.

---

*CS27 — Computer Science Department | Burkina Institute of Technology*  
*Instructor: Kweyakie Afi Blebo | blebo.kweyakie@bit.bf*
