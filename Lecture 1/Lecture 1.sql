/*markdown
# Lecture 1: First Steps (Databases, Tables & CRUD)
Create the `maqbool_info` table and walk it through its whole life: create, insert, read, update, delete, truncate, drop.
Run each cell top to bottom. Explanations for every query (Q1, Q2, ...) are in this folder's README.md.
*/

/*markdown
## Explore the server
*/

-- Q1
SHOW DATABASES;

-- Q2
USE maqbool;

-- Q3
SHOW TABLES;

/*markdown
## Create the table
*/

-- Q4
CREATE TABLE Maqbool_info(
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   age INT NOT NULL,
   gender VARCHAR(50) NOT NULL,
   is_student BOOLEAN DEFAULT TRUE
);

-- Q5
show TABLES;

-- Q6
DESC maqbool_info;

-- Q7
ALTER TABLE maqbool_info ADD phone_number VARCHAR(20);

-- Q8
DESC maqbool_info;

/*markdown
## Insert and read rows
*/

-- Q9
SELECT * from maqbool_info;

-- Q10
INSERT INTO maqbool_info(
name,
age,
gender,
is_student,
phone_number
)
VALUES('Arbaz',23,'male',False,+91345376898932);

-- Q11
SELECT * FROM maqbool_info;

-- Q12
INSERT INTO maqbool_info(
name,
age,
gender,
is_student,
phone_number
)
VALUES('Arbaz',23,'male',False,+91345376898932),('Maqbool',20,'male',False,'+9142354543');

-- Q13
SELECT * FROM maqbool_info;

-- Q14
SELECT id,name,age FROM maqbool_info;

/*markdown
## Delete and re-insert
*/

-- Q15
DELETE FROM maqbool_info WHERE id='3';

-- Q16
SELECT * FROM maqbool_info;

-- Q17
INSERT INTO maqbool_info(
name,
age,
gender,
is_student,
phone_number
)
VALUES('Arbaz',23,'male',False,+91345376898932),('Maqbool',20,'male',False,'+9142354543');

-- Q18
SELECT * FROM maqbool_info;

-- Q19
DELETE FROM maqbool_info WHERE name='Maqbool';

-- Q20
SELECT * FROM maqbool_info;

/*markdown
## Update rows
*/

-- Q21
UPDATE maqbool_info SET age=32 WHERE id='2';

-- Q22
SELECT name, age, gender FROM maqbool_info;

-- Q23
SELECT id,name, age, gender FROM maqbool_info;

-- Q24
UPDATE maqbool_info SET age=32 WHERE name='Arbaz';

-- Q25
SELECT id,name, age, gender FROM maqbool_info;

/*markdown
## Empty and remove the table
*/

-- Q26
TRUNCATE TABLE maqbool_info;

-- Q27
SELECT * FROM maqbool_info;

-- Q28
DROP TABLE maqbool_info;

-- Q29
SHOW TABLES;
