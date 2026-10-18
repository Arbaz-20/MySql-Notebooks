# Lecture 7: Three-Table Joins, Views, CTEs, Many-to-Many & CASE Reporting

> Notebook: [`Lecture 7.sql`](Lecture%207.sql). Brings the earlier lectures together: reusable views over three-table joins, a CTE, a proper **many-to-many** design with a junction table, and report-style queries with `CASE` and `IFNULL`.

## What this lecture covers

| Concept | Syntax practiced |
|---------|------------------|
| Three-table joins | `JOIN orders ... JOIN address ... WHERE ...` |
| Views | `CREATE VIEW GetALLCustomersData AS SELECT ...` |
| CTE | `WITH name AS (SELECT ...) SELECT ... FROM name` |
| Many-to-many | `students` ↔ `student_courses` ↔ `courses` |
| Constraints | `FOREIGN KEY ... ON DELETE CASCADE`, composite `UNIQUE(student_id, course_id)` |
| Conditional aggregation | `COUNT(CASE WHEN ... THEN 1 END)`, `SUM(CASE WHEN ... THEN x ELSE 0 END)` |
| Categorising | `CASE WHEN ... THEN 'Silver' ... END AS customer_tier` |
| NULL handling | `IFNULL(phone_number, 'no phone')` |

## The many-to-many design

One student takes many courses, and one course has many students. Neither table can hold the other's id directly, so a **junction table** stores one row per enrolment:

```
students (id, name, email)          courses (id, course_name, instructor)
      ▲                                    ▲
      │ student_id                course_id│
      └────────── student_courses ─────────┘
            (id, student_id, course_id, enrollment_at)
            UNIQUE(student_id, course_id)
```

## Fixes made while converting

The original notebook ran each statement in its own MySQL Shell block, so several statements had no closing `;`. A `.sql` file needs the semicolon, so it was added to **Q5, Q6, Q8, Q10, Q24, Q33, Q34, Q36 and Q37**. Nothing else in the statements changed.

---

## Query-by-query walkthrough

Every statement below is one cell in [`Lecture 7.sql`](Lecture%207.sql). The `-- Q<n>` comment at the top of each cell matches the number here.

### Setup

**Q1**

```sql
SHOW DATABASES;
```

Lists the databases on the server.

**Q2**

```sql
use maqbool;
```

Selects the `maqbool` schema.

**Q3**

```sql
show TABLES;
```

Four objects so far: three tables and the `maqbool_order` view from Lecture 6.

**Q4**

```sql
SELECT COUNT(*) from address;
```

185 addresses.

### Three-table joins with filters

**Q5**

```sql
SELECT * FROM maqbool_info
JOIN orders ON maqbool_info.id=orders.user_id
JOIN address ON maqbool_info.id=address.user_id;
```

Joins all three tables: each user with each of their orders and each of their addresses. 720 rows. That's more than the 500 orders, because users with two addresses have every order repeated once per address.

**Q6**

```sql
SELECT * FROM maqbool_info
JOIN orders ON maqbool_info.id=orders.user_id
JOIN address ON maqbool_info.id=address.user_id
WHERE orders.status='processing';
```

The same join, keeping only orders in `processing` status: 136 rows.

**Q7**

```sql
SELECT * FROM maqbool_info
JOIN orders ON maqbool_info.id=orders.user_id
JOIN address ON maqbool_info.id=address.user_id
WHERE orders.status='processing' AND maqbool_info.gender='male';
```

Adds a second condition with `AND`: processing orders of male users. 73 rows.

### Views over joins

**Q8**

```sql
CREATE VIEW GetCustomerWithOrderAndAddress AS
SELECT m.id as maqbool_id,m.name,m.gender, m.age,o.id as orders_id,o.status,o.item_count,o.total_amount,ad.address,ad.pincode FROM maqbool_info as m
LEFT JOIN orders as o ON m.id=o.user_id
RIGHT JOIN address as ad ON m.id=ad.user_id;
```

Creates a view over a **mixed join**: `maqbool_info LEFT JOIN orders RIGHT JOIN address`. Joins are evaluated left to right, so the final `RIGHT JOIN` preserves every **address**. Querying it returns 834 rows. Aliases (`m.id AS maqbool_id`, `o.id AS orders_id`) are required, because a view can't have two columns both named `id`. Mixing LEFT and RIGHT joins is hard to read; pick one direction where you can.

**Q9**

```sql
SELECT * FROM GetCustomerWithOrderAndAddress;
```

Queries the view like a table: 834 rows.

**Q10**

```sql
CREATE VIEW GetALLCustomersData AS
SELECT m.id as maqbool_id,m.name,m.gender, m.age,o.id as orders_id,o.status,o.item_count,o.total_amount,ad.address,ad.pincode FROM maqbool_info as m
JOIN orders as o ON m.id=o.user_id
JOIN address as ad ON m.id=ad.user_id;
```

A second view, `GetALLCustomersData`, using plain (inner) `JOIN`s. Only users who have **both** orders and an address appear.

**Q11**

```sql
SELECT * from GetALLCustomersData;
```

720 rows: the same as the Q5 join, now reusable by name.

**Q12**

```sql
SELECT * FROM GetALLCustomersData WHERE gender='male';
```

Filters the view on `gender = 'male'`: 413 rows. A view can be filtered like any table.

**Q13**

```sql
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';
```

Lists the views: `getallcustomersdata`, `getcustomerwithorderandaddress`, `maqbool_order`. Names appear in lowercase because of Windows' case-insensitive naming.

**Q14**

```sql
SELECT * FROM GetALLCustomersData WHERE pincode=411001 AND status='confirmed';
```

Two filters on the view: pincode 411001 and confirmed status. 10 rows.

**Q15**

```sql
CREATE VIEW user_address_data AS
SELECT m.name,m.gender,m.id as users_id,ad.address,ad.pincode FROM maqbool_info as m
JOIN address as ad ON m.id=ad.user_id;
```

A third view, `user_address_data`: user names with their addresses (users → address only).

**Q16**

```sql
SELECT * FROM user_address_data;
```

185 rows, one per address.

**Q17**

```sql
SHOW FULL TABLES WHERE TABLE_TYPE='VIEW';
```

Lists the views again: now 4.

**Q18**

```sql
SELECT * FROM user_address_data WHERE name LIKE 'Arbaz%';
```

Uses the view with a prefix search: addresses of everyone whose name starts with Arbaz. 30 rows.

### Common Table Expression (CTE)

**Q19**

```sql
WITH
total_users_address AS(
    SELECT m.name,m.gender,m.id as users_id,ad.address,ad.pincode,ad.user_id FROM maqbool_info as m
    JOIN address as ad ON m.id=ad.user_id
)
SELECT * FROM total_users_address WHERE name NOT LIKE 'Arbaz%';
```

A **Common Table Expression (CTE)**. `WITH total_users_address AS (...)` defines a named, temporary result that exists **only for this one statement**, and the main `SELECT` then reads from it like a table. 155 rows: the addresses of everyone whose name doesn't start with Arbaz (185 − 30).

CTE vs view: a view is stored in the database and reusable everywhere; a CTE is defined inline and disappears after the query. CTEs make long queries readable by naming the steps. Lecture 5's `WITH RECURSIVE` was a special, self-referencing CTE.

(The `# Common table expression` line in the original notebook is a MySQL comment. It became the heading of this section.)

### Many-to-many relationship: students and courses

**Q20**

```sql
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL
);
```

Creates the `students` table. `email VARCHAR(255)` is the usual size for email addresses.

**Q21**

```sql
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    instructor VARCHAR(100)
);
```

Creates the `courses` table.

**Q22**

```sql
DESC students;
```

Describes `students`.

**Q23**

```sql
DESC courses;
```

Describes `courses`.

**Q24**

```sql
CREATE TABLE student_courses(
    id int PRIMARY KEY UNIQUE AUTO_INCREMENT,
    student_id int NOT NULL,
    course_id int NOT NULL,
    enrollment_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_student FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_course FOREIGN KEY(course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE(student_id,course_id)
);
```

Creates the **junction table** `student_courses`, which links the two tables:
- `student_id` and `course_id` are **foreign keys** to `students(id)` and `courses(id)`, declared inline with `CONSTRAINT fk_... FOREIGN KEY ... REFERENCES ...`.
- **`ON DELETE CASCADE`**: deleting a student (or a course) automatically deletes their enrolment rows, so no orphans are left. Compare this with Lecture 6, where the default `RESTRICT` blocked the delete instead.
- **`UNIQUE(student_id, course_id)`** is a composite unique constraint: the same student can't enrol in the same course twice.
- `enrollment_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP` records when the enrolment happened.

**Q25**

```sql
DESC student_courses;
```

Describes the junction table. `student_id` shows `MUL` in the Key column because it is the first column of the composite unique index.

**Q26**

```sql
INSERT INTO students (name, email) VALUES
('Arbaz', 'arbaz@test.com'),
('Maqbool', 'maqbool@test.com'),
('Zara', 'zara@test.com');
```

Adds 3 students: Arbaz, Maqbool, Zara.

**Q27**

```sql
INSERT INTO courses (course_name, instructor) VALUES
('MySQL', 'Rahul'),
('React', 'Amit'),
('Node.js', 'Priya');
```

Adds 3 courses: MySQL (Rahul), React (Amit), Node.js (Priya).

**Q28**

```sql
SELECT * FROM courses;
```

Shows the courses with their ids 1–3.

**Q29**

```sql
SELECT * FROM students;
```

Shows the students with their ids 1–3.

**Q30**

```sql
INSERT INTO student_courses (student_id, course_id) VALUES
(1, 1),  -- Arbaz → MySQL
(1, 2),  -- Arbaz → React
(1, 3),  -- Arbaz → Node.js
(2, 1),  -- Maqbool → MySQL
(2, 3),  -- Maqbool → Node.js
(3, 2);  -- Zara → React
```

Enrols students in courses by inserting `(student_id, course_id)` pairs. Arbaz takes all 3 courses, Maqbool takes 2, Zara takes 1. The `--` comments at the end of each line document the pairs; MySQL ignores them.

**Q31**

```sql
SELECT * FROM student_courses;
```

Shows the raw junction rows: just pairs of numbers, which is why you need joins to read them.

**Q32**

```sql
SELECT s.name,s.id as student_id, c.id as course_id,c.course_name,sc.enrollment_at FROM students as s
JOIN student_courses as sc ON s.id=sc.student_id
JOIN courses as c ON c.id=sc.course_id;
```

Reads the many-to-many relationship by joining **through** the junction table: students → student_courses → courses. 6 rows, one per enrolment, with names instead of ids.

**Q33**

```sql
SELECT * FROM students as s
JOIN student_courses as sc ON s.id=sc.student_id
JOIN courses as c ON c.id=sc.course_id
WHERE s.name='Arbaz';
```

All of Arbaz's courses: 3 rows.

**Q34**

```sql
SELECT * FROM students as s
JOIN student_courses as sc ON s.id=sc.student_id
JOIN courses as c ON c.id=sc.course_id
WHERE c.instructor='Rahul' OR s.email='arbaz@test.com';
```

Enrolments where the instructor is Rahul **or** the student's email is `arbaz@test.com`: 4 rows (Arbaz × 3 courses, plus Maqbool in Rahul's MySQL course).

### Counting orders by status

**Q35**

```sql
SELECT * FROM orders;
```

Back to `orders`: all 500.

**Q36**

```sql
SELECT COUNT(*) FROM orders WHERE status='confirmed';
```

Counts the confirmed orders: 76.

**Q37**

```sql
SELECT COUNT(*) FROM orders WHERE status='delivered';
```

Counts the delivered orders: 218. Getting each status this way needs one query per status...

**Q38**

```sql
SELECT
    COUNT(CASE WHEN status='confirmed' THEN 1 END) as confirmed_count,
    COUNT(CASE WHEN status='delivered' THEN 1 END) as delivered_count,
    COUNT(CASE WHEN status='processing' THEN 1 END) as processing_count,
    COUNT(CASE WHEN status='pending' THEN 1 END) as pending_count
FROM orders;
```

...whereas **conditional aggregation** gets them all in **one pass**. `CASE WHEN status = 'confirmed' THEN 1 END` returns 1 for matching rows and `NULL` otherwise (there's no `ELSE`), and `COUNT` only counts non-NULL values. Result: 76 confirmed, 218 delivered, 75 processing, 65 pending. This is how you build a "pivot" report in SQL.

**Q39**

```sql
SELECT * FROM orders where status IN ("delivered","processing","confirmed") ORDER BY status DESC;
```

Orders in three statuses, sorted by `status DESC`. The order is **delivered → processing → confirmed**, not alphabetical. An `ENUM` sorts by its *position in the definition* (`'pending'` = 1, `'confirmed'` = 2, `'processing'` = 3, ..., `'delivered'` = 5), not by its text. 369 rows (218 + 75 + 76).

### CASE: customer tiers

**Q40**

```sql
SELECT  m.id as users_id, o.status, o.total_amount,
    CASE
        WHEN o.total_amount <= 5000 THEN "Silver"
        WHEN o.total_amount <= 9000 THEN "GOLD"
        WHEN o.total_amount >= 9001 THEN "Platinum"
    END as customer_tier
FROM orders as o
JOIN maqbool_info as m ON o.user_id=m.id
ORDER BY total_amount ASC;
```

**`CASE` as a computed column**: assigns every order a `customer_tier` based on its amount: ≤ 5000 is *Silver*, ≤ 9000 is *GOLD*, ≥ 9001 is *Platinum*. The `WHEN`s are checked top to bottom and the first match wins.

Edge case: `total_amount` is `DECIMAL(10,2)`, so an amount like 9000.50 matches none of the branches and the tier is `NULL`. Write the last branch as `ELSE 'Platinum'` to cover everything.

### Conditional SUM

**Q41**

```sql
SELECT
    SUM(CASE WHEN orders.status='delivered' THEN total_amount ELSE 0 END) as delivered_status_amount,
    SUM(CASE WHEN orders.status='confirmed' THEN total_amount ELSE 0 END) as confirmed_status_amount
FROM orders;
```

**Conditional SUM**: `SUM(CASE WHEN status = 'delivered' THEN total_amount ELSE 0 END)` adds up the amounts of delivered orders only. Revenue by status in one query: delivered ₹1,873,814.56, confirmed ₹577,292.10.

**Q42**

```sql
SELECT * from orders ORDER BY id ASC;
```

All orders, sorted by id.

### Bulk insert with explicit ids, and IFNULL

**Q43**

```sql
SELECT * FROM maqbool_info;
```

All users before the next insert (127).

**Q44**

```sql
INSERT INTO maqbool_info (id, name, age, gender, is_student, phone_number, createdAt, updatedAt) VALUES
(128, 'Arbaz Khan', 25, 'male', 1, '9876543210', NOW(), NOW()),
(129, 'Maqbool Sheikh', 30, 'male', 0, '9823456789', NOW(), NOW()),
(130, 'Zara Patel', 22, 'female', 1, NULL, NOW(), NOW()),
(131, 'Rahul Sharma', 27, 'male', 1, '9812345678', NOW(), NOW()),
-- ... 19 more lines (see the .sql file) ...
(151, 'Deepak Tiwari', 34, 'male', NULL, '9801237654', NOW(), NOW()),
(152, 'Nisha Agarwal', 21, 'female', 1, NULL, NOW(), NOW());
```

Inserts 25 users with **explicit ids** (128–152) instead of letting `AUTO_INCREMENT` choose them. That's allowed as long as the ids are free, and the counter then continues after the largest id. `NOW()` fills the timestamps, and several rows have `NULL` for `is_student` or `phone_number`, which sets up the next query.

**Q45**

```sql
SELECT * from maqbool_info;
```

152 users now.

**Q46**

```sql
SELECT m.id,m.name,m.gender,m.age,
    IFNULL(m.phone_number,"no phone") as phone_number
FROM maqbool_info as m;
```

**`IFNULL(expr, fallback)`** returns `expr`, or `fallback` when `expr` is NULL. Users without a phone show `no phone` instead of `NULL`. `COALESCE(a, b, c, ...)` is the standard SQL version and accepts more than two arguments.

---

## Key lessons from this lecture

1. **Views make complex joins reusable.** Write the three-table join once and query it by name.
2. **A CTE is a temporary, single-statement view.** Use it to name the steps of a long query.
3. **Many-to-many needs a junction table**, with two foreign keys and a composite `UNIQUE`.
4. **`ON DELETE CASCADE` vs the default `RESTRICT`.** Cascade cleans up child rows automatically; restrict blocks the delete.
5. **Conditional aggregation** (`COUNT/SUM(CASE WHEN ...)`) builds a whole report in one pass.
6. **`ENUM` sorts by definition order**, not alphabetically.
7. **Give `CASE` an `ELSE`** so values that fall between your ranges don't become `NULL`.
8. **`IFNULL` / `COALESCE`** replace NULLs with something readable.

## Prerequisites & how to run

- Requires `maqbool_info`, `orders` and `address` from [Lectures 5](../Lecture%205/README.md) and [6](../Lecture%206/README.md).
- The `CREATE VIEW` / `CREATE TABLE` cells fail if you run them twice ("already exists"). Use `CREATE OR REPLACE VIEW` or `DROP TABLE` first if you want to start over.
- Q44 needs an `updatedAt` column on `maqbool_info` (see [Lecture 4](../Lecture%204/README.md)) and fails if ids 128–152 are already taken.

1. Install the **SQL Notebook** extension (publisher `cmoog`) in VS Code. See the [root README](../README.md#2-install-the-sql-notebook-extension).
2. Right-click `Lecture 7.sql`, choose **Open With…**, then **SQL Notebook**.
3. In the **SQL NOTEBOOK** sidebar panel, connect to your local MySQL server (see the root README).
4. Run cells one at a time with the ▶ button or `Ctrl+Enter`, top to bottom. Each cell holds exactly one statement.

> The cells are separated by blank lines in the `.sql` file. That is how SQL Notebook decides where one cell ends and the next begins, so don't add blank lines *inside* a statement when you edit the file.

## Where to go from here

This is the last lecture notebook. For the full written guide (16 chapters and 3 projects), see [`docs/SQL-Masterclass.pdf`](../docs/SQL-Masterclass.pdf).
