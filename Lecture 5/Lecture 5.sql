/*markdown
# Lecture 5: Subqueries, the Orders Table & Joins
A subquery to find repeated ages, a new `orders` table filled with 500 generated rows (recursive CTE), then INNER / LEFT / RIGHT joins and orphaned rows.
Explanations for every query (Q1, Q2, ...) are in this folder's README.md.
*/

/*markdown
## Setup
*/

-- Q1
use maqbool;

-- Q2
show TABLES;

-- Q3
desc maqbool_info;

-- Q4
SELECT * FROM maqbool_info LIMIT 20 OFFSET 0;

/*markdown
## Subqueries: finding repeated ages
*/

-- Q5
select COUNT(age) from maqbool_info;

-- Q6
SELECT * FROM maqbool_info WHERE age in (select ANY_VALUE(age) from maqbool_info GROUP BY age HAVING COUNT(age) > 1) ORDER BY age ASC;

-- Q7
SELECT COUNT(age) as age_count,
age as age
from maqbool_info group by age HAVING COUNT(age) > 1;

-- Q8
SELECT * from maqbool_info where age=38;

/*markdown
## Deleting user 21
*/

-- Q9
SELECT * from maqbool_info where id=21;

-- Q10
DELETE from maqbool_info where id=21;

-- Q11
SELECT * from maqbool_info where id=21;

-- Q12
SELECT * from maqbool_info;

/*markdown
## The orders table
*/

-- Q13
CREATE TABLE orders (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED NOT NULL,
    order_number    VARCHAR(20) NOT NULL UNIQUE,
    status          ENUM('pending','confirmed','processing','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
    total_amount    DECIMAL(10,2) NOT NULL,
    item_count      TINYINT UNSIGNED NOT NULL DEFAULT 1,
    payment_method  ENUM('credit_card','debit_card','upi','net_banking','cod','wallet') NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Q14
INSERT INTO orders (user_id, order_number, status, total_amount, item_count, payment_method, created_at)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 500
)
SELECT
    -- random user_id 1–127
    FLOOR(1 + RAND(n) * 127)                                       AS user_id,
    -- unique order number like ORD-20260215-0001
    CONCAT('ORD-',
        DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND(n*2) * 90) DAY), '%Y%m%d'),
        '-',
        LPAD(n, 4, '0'))                                           AS order_number,
    -- weighted status distribution
    ELT(
        FLOOR(1 + RAND(n*3) * 7),
        'pending','confirmed','processing','shipped',
        'delivered','delivered','delivered','cancelled'
    )                                                               AS status,
    -- random amount ₹150 – ₹25,000
    ROUND(150 + RAND(n*4) * 24850, 2)                              AS total_amount,
    -- random 1–10 items
    FLOOR(1 + RAND(n*5) * 10)                                      AS item_count,
    -- random payment method
    ELT(
        FLOOR(1 + RAND(n*6) * 6),
        'credit_card','debit_card','upi','net_banking','cod','wallet'
    )                                                               AS payment_method,
    -- random date within last 90 days
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND(n*7) * 90 * 24 * 60) MINUTE) AS created_at
FROM seq;

-- Q15
SELECT * from orders;

/*markdown
## Preparing the id column
*/

-- Q16
ALTER TABLE maqbool_info MODIFY id int UNIQUE AUTO_INCREMENT;

/*markdown
## INNER JOIN
*/

-- Q17
SELECT * FROM maqbool_info
INNER JOIN orders ON maqbool_info.id = orders.user_id;

-- Q18
desc maqbool_info;

-- Q19
SELECT * FROM maqbool_info
JOIN orders ON maqbool_info.id = orders.user_id;

-- Q20
SELECT maqbool_info.id,maqbool_info.name,maqbool_info.age,orders.user_id,orders.order_number,orders.status,orders.item_count,orders.total_amount
FROM maqbool_info
INNER JOIN orders ON maqbool_info.id = orders.user_id ORDER BY name ASC LIMIT 10 OFFSET 0;

-- Q21
SELECT maqbool_info.id,maqbool_info.name, orders.user_id,orders.status, orders.total_amount
FROM maqbool_info
INNER JOIN orders ON orders.user_id = maqbool_info.id;

-- Q22
SELECT SUM(total_amount) from orders;

-- Q23
SELECT COUNT(*) from maqbool_info;

/*markdown
## LEFT JOIN
*/

-- Q24
SELECT * FROM maqbool_info
LEFT JOIN orders ON orders.user_id = maqbool_info.id;

-- Q25
SELECT maqbool_info.id,name,age,gender FROM maqbool_info
LEFT JOIN orders ON orders.user_id = maqbool_info.id;

/*markdown
## Joins combined with WHERE filters
*/

-- Q26
SELECT * FROM maqbool_info
INNER JOIN orders ON orders.user_id = maqbool_info.id
WHERE orders.status in ('delivered','confirmed','pending');

-- Q27
SELECT * FROM maqbool_info
INNER JOIN orders ON orders.user_id = maqbool_info.id
WHERE maqbool_info.age NOT in (21,31,44) AND orders.status in ('pending','delivered') ORDER BY age ASC;

-- Q28
SELECT * from maqbool_info
LEFT JOIN orders on orders.user_id = maqbool_info.id
WHERE maqbool_info.gender ='female';

-- Q29
SELECT * FROM maqbool_info
INNER JOIN orders ON orders.user_id = maqbool_info.id
WHERE maqbool_info.age in (21,31,44) AND orders.status in ('pending','delivered') ORDER BY age ASC;

/*markdown
## RIGHT JOIN and orphaned orders
*/

-- Q30
SELECT * from maqbool_info
RIGHT JOIN orders on maqbool_info.id = orders.user_id;

-- Q31
SELECT COUNT(*) from orders;

-- Q32
SELECT COUNT(*) from maqbool_info;

-- Q33
use maqbool;

-- Q34
SELECT COUNT(*) from orders where user_id is NULL;

-- Q35
SELECT * from orders;

-- Q36
SELECT * from maqbool_info WHERE id= 21;

-- Q37
SELECT * from orders where user_id=21;

-- Q38
SELECT * from maqbool_info
RIGHT JOIN orders on maqbool_info.id = orders.user_id;

-- Q39
SELECT * from maqbool_info
LEFT JOIN orders on maqbool_info.id = orders.user_id;

-- Q40
SELECT * from maqbool_info
LEFT JOIN orders on maqbool_info.id = orders.user_id;

-- Q41
SELECT * from maqbool_info
RIGHT JOIN orders on maqbool_info.id = orders.user_id
where orders.user_id=21;

-- Q42
SELECT maqbool_info.id,name,gender,orders.id,orders.status,orders.order_number from maqbool_info
RIGHT JOIN orders on orders.user_id = maqbool_info.id order by maqbool_info.id desc;

/*markdown
## Restoring user 21
*/

-- Q43
insert maqbool_info(name,age,gender) values('mira murati',21,'female');

-- Q44
SELECT maqbool_info.id,name,gender,orders.id,orders.status,orders.order_number,orders.user_id from maqbool_info
RIGHT JOIN orders on orders.user_id = maqbool_info.id order by maqbool_info.id desc;

-- Q45
SELECT * from maqbool_info where name like 'mira%';

-- Q46
SELECT maqbool_info.id,name,gender,orders.id,orders.status,orders.order_number,orders.user_id from maqbool_info
RIGHT JOIN orders on orders.user_id = maqbool_info.id order by maqbool_info.id desc;

-- Q47
SELECT * from maqbool_info where name like 'mira%';

-- Q48
update maqbool_info set id=21 where name='mira murati';

-- Q49
SELECT maqbool_info.id,name,gender,orders.id,orders.status,orders.order_number,orders.user_id from maqbool_info
RIGHT JOIN orders on orders.user_id = maqbool_info.id order by maqbool_info.id ASC;

/*markdown
## Emulating a FULL OUTER JOIN with UNION
*/

-- Q50
SELECT * from maqbool_info
LEFT JOIN orders on orders.user_id = maqbool_info.id
WHERE maqbool_info.id is null
UNION
SELECT * from orders
RIGHT JOIN maqbool_info on maqbool_info.id = orders.user_id;
