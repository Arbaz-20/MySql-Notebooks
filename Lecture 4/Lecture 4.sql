/*markdown
# Lecture 4: Aggregates, GROUP BY / HAVING & Transactions
COUNT / SUM / MIN / MAX / AVG, how NULL affects them, finding duplicates with GROUP BY + HAVING, and undoing changes with transactions.
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
desc maqbool_info;

/*markdown
## COUNT basics
*/

-- Q5
SELECT COUNT(*) from maqbool_info;

-- Q6
SELECT COUNT(*) FROM maqbool_info WHERE name LIKE 'Arbaz%';

-- Q7
SELECT * FROM maqbool_info where name like 'Arbaz%';

-- Q8
SELECT COUNT(age > 22) from maqbool_info;

-- Q9
SELECT COUNT(*) FROM maqbool_info WHERE name like 'Arbaz%';

-- Q10
SELECT COUNT(age) FROM maqbool_info;

-- Q11
SELECT COUNT(*) FROM maqbool_info;

/*markdown
## Allowing NULL ages (and how COUNT reacts)
*/

-- Q12
ALTER TABLE maqbool_info MODIFY COLUMN age int DEFAULT NULL;

-- Q13
SELECT * FROM maqbool_info;

-- Q14
DESC maqbool_info;

-- Q15
UPDATE maqbool_info SET age=null where age=0;

-- Q16
SELECT * FROM maqbool_info;

-- Q17
SELECT COUNT(*) from maqbool_info;

-- Q18
SELECT COUNT(age) from maqbool_info;

-- Q19
SELECT COUNT(gender) from maqbool_info;

/*markdown
## Audit timestamp columns
*/

-- Q20
ALTER TABLE maqbool_info ADD COLUMN createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Q21
ALTER TABLE maqbool_info MODIFY COLUMN updatedAT TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Q22
SELECT * FROM maqbool_info;

/*markdown
## COUNT variations and aliases
*/

-- Q23
SELECT COUNT(*) from maqbool_info;

-- Q24
SELECT COUNT(*) as total_age from maqbool_info;

-- Q25
SELECT COUNT(Distinct age) from maqbool_info;

-- Q26
SELECT COUNT(age) as total_age , COUNT(gender) as gender_info from maqbool_info;

/*markdown
## SUM / MIN / MAX / AVG
*/

-- Q27
SELECT SUM(age) FROM maqbool_info;

-- Q28
SELECT SUM(distinct age) from maqbool_info;

-- Q29
select MIN(age) as minimum_age from maqbool_info;

-- Q30
SELECT Max(age) as maximum_age from maqbool_info;

-- Q31
SELECT AVG(age) from maqbool_info;

/*markdown
## Arithmetic on aggregates
*/

-- Q32
SELECT SUM(age) + COUNT(gender) FROM maqbool_info;

-- Q33
SELECT SUM(age) - COUNT(gender) FROM maqbool_info;

-- Q34
SELECT SUM(age) * COUNT(gender) FROM maqbool_info;

-- Q35
SELECT SUM(age) % COUNT(gender) FROM maqbool_info;

-- Q36
SELECT SUM(age) / COUNT(gender) FROM maqbool_info;

/*markdown
## GROUP BY + HAVING: finding duplicate names
*/

-- Q37
SELECT name from maqbool_info GROUP BY name HAVING COUNT(*) > 1;

-- Q38
SELECT name as user_name from maqbool_info GROUP BY name HAVING COUNT(*) > 1;

-- Q39
SELECT ANY_VALUE(id) as id,ANY_VALUE(name) as user_name , ANY_VALUE(age) as user_age , ANY_VALUE(gender) as gender FROM maqbool_info GROUP BY name HAVING COUNT(*) > 1;

-- Q40
SELECT name,age,gender from maqbool_info GROUP BY name,age,gender HAVING COUNT(*) > 0;

-- Q41
SELECT name,age,gender,is_student FROM maqbool_info where name IN(Select name from maqbool_info GROUP BY name HAVING COUNT(*) > 0);

/*markdown
## Bulk updates with LIKE
*/

-- Q42
UPDATE maqbool_info set age=23 where name like 'Arbaz%';

-- Q43
SELECT * from maqbool_info WHERE name like 'Arbaz%';

-- Q44
UPDATE maqbool_info set age=22 where name like '%Arbaz Ayub khan%';

-- Q45
SELECT * from maqbool_info where name like 'Arbaz%';

/*markdown
## Transactions: START TRANSACTION / ROLLBACK / COMMIT
*/

-- Q46
start TRANSACTION;

-- Q47
update maqbool_info set age=23 WHERE name like 'Arbaz%';

-- Q48
SELECT * FROM maqbool_info WHERE name like 'Arbaz%';

-- Q49
rollback;

-- Q50
SELECT * FROM maqbool_info WHERE name like 'Arbaz%';

-- Q51
update maqbool_info set age=23 WHERE name like 'Arbaz%';

-- Q52
SELECT * from maqbool_info where name like 'Arbaz%';

-- Q53
COMMIT;

-- Q54
SELECT * from maqbool_info where name like 'Arbaz%';

-- Q55
ROLLBACK;

-- Q56
SELECT * from maqbool_info where name like 'Arbaz%';

-- Q57
START TRANSACTION;

-- Q58
UPDATE maqbool_info set name="Arbaz khan" where name="Arbaz Ayub khan";

-- Q59
SELECT * FROM maqbool_info;

-- Q60
ROLLBACK;

-- Q61
SELECT * from maqbool_info;

-- Q62
UPDATE maqbool_info set name="Arbaz khan" where name='Arbaz';

-- Q63
SELECT * from maqbool_info where id IN (1,2);

-- Q64
COMMIT;

/*markdown
## Names that appear only once
*/

-- Q65
SELECT name,age,gender,is_student from maqbool_info where NOT name IN(select name from maqbool_info GROUP BY name  HAVING COUNT(*) > 1);
