
# Library System Management SQL

This repository contains SQL scripts to manage a library system's database, which includes tables for books, branches, employees, members, issued books, and returns. The SQL code demonstrates tasks for creating tables, inserting data, updating records, and implementing procedures for effective library management.

## Project Overview

This project focuses on building a library management system using SQL queries. The main objectives include managing book records, handling issuance and returns, tracking member activity, generating summary reports, and automating certain operations with stored procedures.

## Database Structure

The database contains the following tables:

1. **books** - Information on available books in the library.
```
	DROP TABLE IF EXISTS books;
	CREATE TABLE books(
	isbn VARCHAR(50) PRIMARY KEY,
 	book_title VARCHAR(100),
	category VARCHAR(50),
	rental_price DECIMAL(10,2),
	status VARCHAR(10),
	author VARCHAR(50),
	publisher VARCHAR(80)
);
```
2. **branch** - Library branch details.
```
DROP TABLE IF EXISTS branch;

CREATE TABLE branch(
	branch_id VARCHAR(10) PRIMARY KEY ,
	manager_id VARCHAR(10),
	branch_address VARCHAR(30),
	contact_no VARCHAR(20)
);
```
3. **employees** - Employee details, including branch assignments.
```
DROP TABLE IF EXISTS employees; 

CREATE TABLE employees(
	emp_id VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(100),
	position VARCHAR(30),
	salary DECIMAL(10,2),
	branch_id VARCHAR(25),
	FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);
```
4. **issued_status** - Records of books issued to members.
```
DROP TABLE IF EXISTS issued_status;

CREATE TABLE issued_status(
	issued_id VARCHAR(10) PRIMARY KEY,
	issued_member_id VARCHAR(10),
	issued_book_name VARCHAR(100),
	issued_date DATE,
	issued_book_isbn VARCHAR(50),
	issued_emp_id  VARCHAR(10),
    FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
    FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn)
);
```
5. **members** - Information on library members.
```
DROP TABLE IF EXISTS members;

CREATE TABLE members (
     member_id VARCHAR(10) PRIMARY KEY,
     member_name VARCHAR(30),
     member_address VARCHAR(30),
     reg_date DATE
);
```
6. **return_status** - Records of book returns.
```
DROP TABLE IF EXISTS return_status;

CREATE TABLE return_status(
     return_id VARCHAR(10) PRIMARY KEY,
     issued_id VARCHAR(30),
     return_book_name VARCHAR(80),
     return_date DATE,
     return_book_isbn VARCHAR(50),
     FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

ALTER TABLE return_status
ADD COLUMN book_Quality VARCHAR(15) DEFAULT 'Good';
```

## Tasks and Queries

The repository contains the following SQL tasks, each addressing specific requirements for the library management system:

### Task 1: Create a New Book Record
Adds a new book entry to the `books` table.
```
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2','To Kill a Mockingbird','Classic',6.00,'yes','Harper Lee','J.B. Lippincott & Co.');
```
### Task 2: Update an Existing Member's Address
Updates a member’s address based on `member_id`.
```
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```
### Task 3: Delete a Record from the Issued Status Table
Deletes a specific record from `issued_status`.
```
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```
### Task 4: Retrieve All Books Issued by a Specific Employee
Lists books issued by an employee based on `emp_id`.
```
SELECT *
FROM issued_status
WHERE issued_emp_id= 'E101';
```
### Task 5: List Members Who Have Issued More Than One Book
Uses `GROUP BY` to find members who have issued multiple books.
```
SELECT issued_emp_id , COUNT(*)
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;
```
### Task 6: Create Summary Tables
Creates a summary table `Summary_Table` showing the count of each book issued.
```
CREATE TABLE Summary_Table AS
SELECT b.isbn , b.book_title , COUNT(iss.issued_id) AS issue_count
FROM books as b
JOIN issued_status as iss 
ON iss.issued_book_isbn = b.isbn
GROUP BY b.isbn , b.book_title;

SELECT * FROM summary_table;
```
### Task 7: Retrieve All Books in a Specific Category
Lists all books within a specific category, e.g., 'Classic'.
```
SELECT * FROM books
WHERE category = 'Classic';
```
### Task 8: Find Total Rental Income by Category
Calculates total rental income and book count by category.
```
SELECT b.category , SUM(b.rental_price) AS "Total Retal Price" , COUNT(*) AS "Number of Book"
FROM books as b
JOIN issued_status as iss
ON iss.issued_book_isbn = b.isbn
GROUP BY 1;
```
### Task 9: List Members Who Registered in the Last 180 Days
Retrieves members who joined within the last 180 days.
```
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```
### Task 10: List Employees with Their Branch Manager's Name and Branch Details
Lists employees along with their branch details and manager’s name.
```
SELECT  e1.emp_id , 
		e1.emp_name ,
		e1.position ,
		e1.salary,
		br.*,
		e2.emp_name as Manager
FROM employees e1 
	JOIN branch br ON br.branch_id = e1.branch_id
	JOIN employees e2 ON e2.emp_id = br.manager_id
WHERE e1.position != 'Manager'; 
```
### Task 11: Create a Table of Books with High Rental Prices
Creates `Expenive_Book` table for books with rental prices above a specified threshold.
```
CREATE TABLE Expenive_Book AS
SELECT * FROM books
WHERE books.rental_price > 6.00;

SELECT * FROM Expenive_Book;
```
### Task 12: Retrieve the List of Books Not Yet Returned
Lists books that have been issued but not yet returned.
```
SELECT DISTINCT iss.issued_book_name
FROM issued_status iss
LEFT JOIN return_status rs 
ON rs.issued_id = iss.issued_id
WHERE rs.return_id IS NULL;
```
### Task 13: Identify Members with Overdue Books
Identifies members who have overdue books (more than 30 days) and displays the overdue days.
```
SELECT  m.member_id,
		m.member_name,
		b.book_title,
		ist.issued_date,
		(CURRENT_DATE - ist.issued_date) AS OverDue_Date
FROM issued_status ist
	JOIN members m ON m.member_id = ist.issued_member_id
	JOIN books b ON b.isbn = ist.issued_book_isbn
	LEFT JOIN return_status rs ON rs.return_book_isbn = b.isbn
WHERE rs.return_date IS NULL
		AND (CURRENT_DATE - ist.issued_date)>30
```
### Task 14: Update Book Status on Return
Defines a procedure `add_return_book` to update book status to "yes" when returned.
```
CREATE OR REPLACE PROCEDURE add_return_book(p_retuen_id VARCHAR(10),p_issued_id VARCHAR(10),p_book_quality VARCHAR(15))
language plpgsql
AS $$
DECLARE
	v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
BEGIN
	-- Add all logic code
	-- Insert Into return_status table based on user input
	INSERT INTO return_status(return_id , issued_id , return_date , book_quality)
	VALUES (p_retuen_id,p_issued_id, CURRENT_DATE , p_book_quality);

	SELECT 
        issued_book_isbn,
        issued_book_name
    INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;
	
	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;


	RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$

-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');
```
### Task 15: Branch Performance Report
Generates a report on branch performance, showing books issued, books returned, and revenue generated.
```
CREATE TABLE Branch_Reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM Branch_Reports;
```
### Task 16: Create a Table of Active Members
Uses a CTAS query to create `active_members` table, including members who issued at least one book in the last 12 months.
```
DROP TABLE active_members;
CREATE TABLE active_members AS
SELECT 
    m.member_id,
    m.member_name
FROM 
    members AS m
JOIN 
    issued_status AS iss ON m.member_id = iss.issued_member_id
WHERE 
    iss.issued_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY 
    m.member_id, m.member_name;

SELECT * FROM active_members;
```
### Task 17: Find Employees with the Most Book Issues Processed
Lists the top 3 employees who processed the most book issues.
```
SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2;
```
### Task 18: Identify Members Issuing High-Risk Books
Identifies members who have issued books with "damaged" status more than twice.
```
SELECT 
    m.member_name,
    b.book_title,
    COUNT(iss.issued_id) AS times_issued_damaged
FROM 
    issued_status AS iss
JOIN 
    books AS b ON iss.issued_book_isbn = b.isbn
JOIN 
    members AS m ON iss.issued_member_id = m.member_id
WHERE 
    b.status = 'damaged'
GROUP BY 
    m.member_name, b.book_title
HAVING 
    COUNT(iss.issued_id) > 2;
```
### Task 19: Stored Procedure for Book Issuance
Defines a procedure `issue_book` to manage book issuance based on availability.
```
CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'
```
### Task 20: Identify Overdue Books and Calculate Fines
Creates `overdue_books_summary` table listing overdue books, fines, and number of books issued by each member.
```
CREATE TABLE overdue_books_summary AS
SELECT 
    m.member_id,
    COUNT(iss.issued_id) AS num_overdue_books,
    SUM(
        CASE 
            WHEN (CURRENT_DATE - iss.issued_date) > 30 
            THEN (CURRENT_DATE - iss.issued_date - 30) * 0.50
            ELSE 0
        END
    ) AS total_fine,
    COUNT(iss.issued_id) AS num_issued_books
FROM 
    issued_status AS iss
JOIN 
    members AS m ON iss.issued_member_id = m.member_id
LEFT JOIN 
    return_status AS rs ON iss.issued_id = rs.issued_id
WHERE 
    rs.return_id IS NULL  -- Exclude books that have been returned
    AND (CURRENT_DATE - iss.issued_date) > 30  -- Only consider overdue books
GROUP BY 
    m.member_id;

SELECT * FROM overdue_books_summary
```
## Setup and Usage

1. **Database**: The scripts assume a PostgreSQL database but can be adapted for other SQL-compliant databases.
2. **Running the Scripts**:
   - Run the table creation scripts first to set up the schema.
   - Run the individual task queries to manage and interact with the library data.

## License

This project is open-source and available under the MIT License.
