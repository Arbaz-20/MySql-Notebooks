/*markdown
# Lecture 3: Combined Filters & Sorting
Combine LIKE with AND / OR / NOT, then sort the results with ORDER BY and page them with LIMIT / OFFSET.
Explanations for every query (Q1, Q2, ...) are in this folder's README.md.
*/

/*markdown
## Setup
*/

-- Q1
show DATABASES;

-- Q2
use maqbool;

-- Q3
show TABLES;

-- Q4
desc maqbool_info;

-- Q5
SELECT * FROM maqbool_info;

/*markdown
## Prefix search combined with AND
*/

-- Q6
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%';

-- Q7
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND gender='male';

-- Q8
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND is_student=false;

-- Q9
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND is_student=true;

-- Q10
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND is_student=True LIMIT 10 OFFSET 0;

-- Q11
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND age=23 LIMIT 10 OFFSET 0;

/*markdown
## Sorting with ORDER BY
*/

-- Q12
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND age=22 ORDER BY id DESC LIMIT 10 OFFSET 0;

-- Q13
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND age=22 ORDER BY id ASC LIMIT 10 OFFSET 0;

/*markdown
## OR conditions
*/

-- Q14
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' OR age=22 ORDER BY id ASC LIMIT 10 OFFSET 0;

-- Q15
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' OR age=22 OR gender="female" ORDER BY id ASC LIMIT 10 OFFSET 0;

/*markdown
## NOT LIKE and sorting by name
*/

-- Q16
SELECT * FROM maqbool_info WHERE name NOT LIKE 'Arbaz%' AND age=22 ORDER BY id ASC LIMIT 10 OFFSET 0;

-- Q17
SELECT * FROM maqbool_info WHERE name NOT LIKE 'Arbaz%' AND age=22 ORDER BY name ASC LIMIT 10 OFFSET 0;
