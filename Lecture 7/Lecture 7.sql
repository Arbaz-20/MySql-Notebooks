/*markdown
# Lecture 7: Three-Table Joins, Views, CTEs, Many-to-Many & CASE Reporting
Reusable views over joins, a Common Table Expression, a students / courses many-to-many design, conditional aggregation with CASE, and IFNULL.
Explanations for every query (Q1, Q2, ...) are in this folder's README.md.
*/

/*markdown
## Setup
*/

-- Q1
SHOW DATABASES;

-- Q2
use maqbool;

-- Q3
show TABLES;

-- Q4
SELECT COUNT(*) from address;

/*markdown
## Three-table joins with filters
*/

-- Q5
SELECT * FROM maqbool_info
JOIN orders ON maqbool_info.id=orders.user_id
JOIN address ON maqbool_info.id=address.user_id;

-- Q6
SELECT * FROM maqbool_info
JOIN orders ON maqbool_info.id=orders.user_id
JOIN address ON maqbool_info.id=address.user_id
WHERE orders.status='processing';

-- Q7
SELECT * FROM maqbool_info
JOIN orders ON maqbool_info.id=orders.user_id
JOIN address ON maqbool_info.id=address.user_id
WHERE orders.status='processing' AND maqbool_info.gender='male';

/*markdown
## Views over joins
*/

-- Q8
CREATE VIEW GetCustomerWithOrderAndAddress AS
SELECT m.id as maqbool_id,m.name,m.gender, m.age,o.id as orders_id,o.status,o.item_count,o.total_amount,ad.address,ad.pincode FROM maqbool_info as m
LEFT JOIN orders as o ON m.id=o.user_id
RIGHT JOIN address as ad ON m.id=ad.user_id;

-- Q9
SELECT * FROM GetCustomerWithOrderAndAddress;

-- Q10
CREATE VIEW GetALLCustomersData AS
SELECT m.id as maqbool_id,m.name,m.gender, m.age,o.id as orders_id,o.status,o.item_count,o.total_amount,ad.address,ad.pincode FROM maqbool_info as m
JOIN orders as o ON m.id=o.user_id
JOIN address as ad ON m.id=ad.user_id;

-- Q11
SELECT * from GetALLCustomersData;

-- Q12
SELECT * FROM GetALLCustomersData WHERE gender='male';

-- Q13
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';

-- Q14
SELECT * FROM GetALLCustomersData WHERE pincode=411001 AND status='confirmed';

-- Q15
CREATE VIEW user_address_data AS
SELECT m.name,m.gender,m.id as users_id,ad.address,ad.pincode FROM maqbool_info as m
JOIN address as ad ON m.id=ad.user_id;

-- Q16
SELECT * FROM user_address_data;

-- Q17
SHOW FULL TABLES WHERE TABLE_TYPE='VIEW';

-- Q18
SELECT * FROM user_address_data WHERE name LIKE 'Arbaz%';

/*markdown
## Common Table Expression (CTE)
*/

-- Q19
WITH
total_users_address AS(
    SELECT m.name,m.gender,m.id as users_id,ad.address,ad.pincode,ad.user_id FROM maqbool_info as m
    JOIN address as ad ON m.id=ad.user_id
)
SELECT * FROM total_users_address WHERE name NOT LIKE 'Arbaz%';

/*markdown
## Many-to-many relationship: students and courses
*/

-- Q20
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL
);

-- Q21
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    instructor VARCHAR(100)
);

-- Q22
DESC students;

-- Q23
DESC courses;

-- Q24
CREATE TABLE student_courses(
    id int PRIMARY KEY UNIQUE AUTO_INCREMENT,
    student_id int NOT NULL,
    course_id int NOT NULL,
    enrollment_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_student FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_course FOREIGN KEY(course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE(student_id,course_id)
);

-- Q25
DESC student_courses;

-- Q26
INSERT INTO students (name, email) VALUES
('Arbaz', 'arbaz@test.com'),
('Maqbool', 'maqbool@test.com'),
('Zara', 'zara@test.com');

-- Q27
INSERT INTO courses (course_name, instructor) VALUES
('MySQL', 'Rahul'),
('React', 'Amit'),
('Node.js', 'Priya');

-- Q28
SELECT * FROM courses;

-- Q29
SELECT * FROM students;

-- Q30
INSERT INTO student_courses (student_id, course_id) VALUES
(1, 1),  -- Arbaz → MySQL
(1, 2),  -- Arbaz → React
(1, 3),  -- Arbaz → Node.js
(2, 1),  -- Maqbool → MySQL
(2, 3),  -- Maqbool → Node.js
(3, 2);  -- Zara → React

-- Q31
SELECT * FROM student_courses;

-- Q32
SELECT s.name,s.id as student_id, c.id as course_id,c.course_name,sc.enrollment_at FROM students as s
JOIN student_courses as sc ON s.id=sc.student_id
JOIN courses as c ON c.id=sc.course_id;

-- Q33
SELECT * FROM students as s
JOIN student_courses as sc ON s.id=sc.student_id
JOIN courses as c ON c.id=sc.course_id
WHERE s.name='Arbaz';

-- Q34
SELECT * FROM students as s
JOIN student_courses as sc ON s.id=sc.student_id
JOIN courses as c ON c.id=sc.course_id
WHERE c.instructor='Rahul' OR s.email='arbaz@test.com';

/*markdown
## Counting orders by status
*/

-- Q35
SELECT * FROM orders;

-- Q36
SELECT COUNT(*) FROM orders WHERE status='confirmed';

-- Q37
SELECT COUNT(*) FROM orders WHERE status='delivered';

-- Q38
SELECT
    COUNT(CASE WHEN status='confirmed' THEN 1 END) as confirmed_count,
    COUNT(CASE WHEN status='delivered' THEN 1 END) as delivered_count,
    COUNT(CASE WHEN status='processing' THEN 1 END) as processing_count,
    COUNT(CASE WHEN status='pending' THEN 1 END) as pending_count
FROM orders;

-- Q39
SELECT * FROM orders where status IN ("delivered","processing","confirmed") ORDER BY status DESC;

/*markdown
## CASE: customer tiers
*/

-- Q40
SELECT  m.id as users_id, o.status, o.total_amount,
    CASE
        WHEN o.total_amount <= 5000 THEN "Silver"
        WHEN o.total_amount <= 9000 THEN "GOLD"
        WHEN o.total_amount >= 9001 THEN "Platinum"
    END as customer_tier
FROM orders as o
JOIN maqbool_info as m ON o.user_id=m.id
ORDER BY total_amount ASC;

/*markdown
## Conditional SUM
*/

-- Q41
SELECT
    SUM(CASE WHEN orders.status='delivered' THEN total_amount ELSE 0 END) as delivered_status_amount,
    SUM(CASE WHEN orders.status='confirmed' THEN total_amount ELSE 0 END) as confirmed_status_amount
FROM orders;

-- Q42
SELECT * from orders ORDER BY id ASC;

/*markdown
## Bulk insert with explicit ids, and IFNULL
*/

-- Q43
SELECT * FROM maqbool_info;

-- Q44
INSERT INTO maqbool_info (id, name, age, gender, is_student, phone_number, createdAt, updatedAt) VALUES
(128, 'Arbaz Khan', 25, 'male', 1, '9876543210', NOW(), NOW()),
(129, 'Maqbool Sheikh', 30, 'male', 0, '9823456789', NOW(), NOW()),
(130, 'Zara Patel', 22, 'female', 1, NULL, NOW(), NOW()),
(131, 'Rahul Sharma', 27, 'male', 1, '9812345678', NOW(), NOW()),
(132, 'Priya Desai', 28, 'female', 0, NULL, NOW(), NOW()),
(133, 'Amit Joshi', 35, 'male', 0, NULL, NOW(), NOW()),
(134, 'Sneha Kulkarni', 24, 'female', 1, '9867890123', NOW(), NOW()),
(135, 'Vikram Reddy', 32, 'male', NULL, '9834567890', NOW(), NOW()),
(136, 'Neha Gupta', 27, 'female', 0, NULL, NOW(), NOW()),
(137, 'Ravi Patil', 31, 'male', 1, '9856781234', NOW(), NOW()),
(138, 'Pooja Mehta', 23, 'female', 1, NULL, NOW(), NOW()),
(139, 'Sanjay Verma', 29, 'male', 0, NULL, NOW(), NOW()),
(140, 'Anita Rao', 26, 'female', 1, '9801234567', NOW(), NOW()),
(141, 'Karan Singh', 26, 'male', NULL, NULL, NOW(), NOW()),
(142, 'Divya Nair', 20, 'female', 1, NULL, NOW(), NOW()),
(143, 'Rohit Pawar', 33, 'male', 0, '9867654321', NOW(), NOW()),
(144, 'Meera Iyer', 21, 'female', 1, NULL, NOW(), NOW()),
(145, 'Aditya Chopra', 28, 'male', 0, '9845612378', NOW(), NOW()),
(146, 'Kavita Bhatt', 25, 'female', NULL, NULL, NOW(), NOW()),
(147, 'Suresh Menon', 40, 'male', 0, '9890123456', NOW(), NOW()),
(148, 'Tanvi Shah', 22, 'female', 1, '9812340987', NOW(), NOW()),
(149, 'Manoj Kumar', 36, 'male', 0, NULL, NOW(), NOW()),
(150, 'Rashmi Jain', 26, 'female', 1, NULL, NOW(), NOW()),
(151, 'Deepak Tiwari', 34, 'male', NULL, '9801237654', NOW(), NOW()),
(152, 'Nisha Agarwal', 21, 'female', 1, NULL, NOW(), NOW());

-- Q45
SELECT * from maqbool_info;

-- Q46
SELECT m.id,m.name,m.gender,m.age,
    IFNULL(m.phone_number,"no phone") as phone_number
FROM maqbool_info as m;
