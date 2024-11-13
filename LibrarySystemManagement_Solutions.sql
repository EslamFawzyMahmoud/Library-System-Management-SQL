-- Library System Management SQL 

-- Create table "books"
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

-- Create table "branch"
DROP TABLE IF EXISTS branch;

CREATE TABLE branch(
	branch_id VARCHAR(10) PRIMARY KEY ,
	manager_id VARCHAR(10),
	branch_address VARCHAR(30),
	contact_no VARCHAR(20)
);


-- Create table "employees"
DROP TABLE IF EXISTS employees; 

CREATE TABLE employees(
	emp_id VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(100),
	position VARCHAR(30),
	salary DECIMAL(10,2),
	branch_id VARCHAR(25),
	FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "issued_status"
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


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
     member_id VARCHAR(10) PRIMARY KEY,
     member_name VARCHAR(30),
     member_address VARCHAR(30),
     reg_date DATE
);


-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
     return_id VARCHAR(10) PRIMARY KEY,
     issued_id VARCHAR(30),
     return_book_name VARCHAR(80),
     return_date DATE,
     return_book_isbn VARCHAR(50),
     FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

ALTER TABLE return_status
ADD COLUMN book_Quality VARCHAR(15) DEFAULT 'Good';

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;


--Project Tasks

-- Task 1: Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2','To Kill a Mockingbird','Classic',6.00,'yes','Harper Lee','J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';


-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'

SELECT *
FROM issued_status
WHERE issued_emp_id= 'E101';


--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id , COUNT(*)
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;


-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE Summary_Table AS
SELECT b.isbn , b.book_title , COUNT(iss.issued_id) AS issue_count
FROM books as b
JOIN issued_status as iss 
ON iss.issued_book_isbn = b.isbn
GROUP BY b.isbn , b.book_title;

SELECT * FROM summary_table;


-- Task 7. Retrieve All Books in a Specific Category

SELECT * FROM books
WHERE category = 'Classic';


-- Task 8: Find Total Rental Income by Category

SELECT b.category , SUM(b.rental_price) AS "Total Retal Price" , COUNT(*) AS "Number of Book"
FROM books as b
JOIN issued_status as iss
ON iss.issued_book_isbn = b.isbn
GROUP BY 1;


-- Task 9: List Members Who Registered in the Last 180 Days 

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details

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


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE Expenive_Book AS
SELECT * FROM books
WHERE books.rental_price > 6.00;

SELECT * FROM Expenive_Book;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT DISTINCT iss.issued_book_name
FROM issued_status iss
LEFT JOIN return_status rs 
ON rs.issued_id = iss.issued_id
WHERE rs.return_id IS NULL;

/*  Task 13: identify members who have overdue books (assume a 30-day return period). 
	Display the member's_id, member's name, book title, issue date, and days overdue. */

-- issued_statues == members == books == return_status 
-- Filter books which is return
-- Overdue > 30

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

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).
*/

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


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued,
the number of books returned, and the total revenue generated from book rentals
*/

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


/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have
issued at least one book in the last 12 months.
*/

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


/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

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


/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.
*/

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


/*Task 19: Stored Procedure Objective: 
Create a stored procedure to manage the status of books in a library system. Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available
*/


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


/*
Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines
*/

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