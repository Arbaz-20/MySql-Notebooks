# Lecture 7 — Multi-Table Joins, Many-to-Many, Views & CASE Reporting

> Notebook: `Lecture 7.mysql-notebook` — the capstone: three-table joins, a full many-to-many setup (`students` ↔ `courses`), several reusable views, a CTE, and business-style reporting with `CASE` and `IFNULL`.

---

## What this lecture covers

| Concept | Syntax practiced |
|---------|------------------|
| Three-table joins | `users → orders → address` in one `SELECT` |
| Reusable views | `GetCustomerWithOrderAndAddress`, `GetALLCustomersData`, `user_address_data` |
| CTE | `WITH total_users_address AS (...) SELECT ...` |
| Many-to-many | `students`, `courses`, junction `student_courses` |
| Cascade deletes | `ON DELETE CASCADE` on the junction table |
| Duplicate protection | `UNIQUE(student_id, course_id)` |
| Conditional logic | `CASE WHEN ... END` inside aggregates |
| NULL handling | `IFNULL(col, fallback)` |
| Bulk insert | one `INSERT` adding ids 128–152 |

## The many-to-many model

A student takes many courses; a course holds many students. That can't be a foreign key on either table — it needs a junction:

```sql
CREATE TABLE student_courses (
    student_id INT,
    course_id  INT,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(id)  ON DELETE CASCADE
);
```

Seeded with Arbaz, Maqbool and Zara taking MySQL (Rahul), React (Amit) and Node.js (Priya). The two protections are the lesson:

- `ON DELETE CASCADE` — deleting a student automatically removes their enrollments (no orphan rows).
- `UNIQUE(student_id, course_id)` — the same enrollment can never be inserted twice.

Then the classic triple join reads it back:

```sql
SELECT s.name AS student, c.course_name, t.name AS teacher
FROM students s
JOIN student_courses sc ON sc.student_id = s.id
JOIN courses c          ON c.course_id  = sc.course_id;
```

## Views across three tables

```sql
CREATE VIEW GetCustomerWithOrderAndAddress AS
SELECT u.name, o.product_name, o.total_amount, a.city
FROM maqbool_info u
JOIN orders  o ON o.user_id = u.id
JOIN address a ON a.user_id = u.id;
```

`GetALLCustomersData` (everyone, order or not — the LEFT-join view) and `user_address_data` (people + city) follow the same idea: build the join once, name it, `SELECT` from it forever. The lecture also re-visits the CTE form (`WITH total_users_address AS (...)`) as an unnamed, single-query alternative to a view.

## CASE reporting — turning rows into a report

```sql
-- order status counts
SELECT status,
       COUNT(*) AS total_orders
FROM orders
GROUP BY status;

-- tier bands straight in SQL
SELECT name, total_amount,
       CASE
         WHEN total_amount >= 40000 THEN 'Platinum'
         WHEN total_amount >= 10000 THEN 'Gold'
         ELSE 'Silver'
       END AS tier
FROM orders;
```

Combined with `SUM(CASE WHEN ...)` this becomes a pivot — one row per group, one column per condition — and `IFNULL(phone_number, 'no phone')` gives missing values a friendly label.

## Things noticed along the way

- The bulk insert at the end adds **25 rows (ids 128–152)**, growing the table past 150 people — handy for making the CASE/aggregate reports look real.
- `ON DELETE CASCADE` is powerful and slightly scary: one `DELETE FROM students WHERE id = 1` silently deletes that student's enrollments too.
- A view joins tables every time it's queried — for heavy reporting you'd reach for indexes (Lecture 6) or summary tables.

## Prerequisites & how to run

- Requires `maqbool_info` + `orders` + `address` from [Lectures 5–6](../Lecture%206/README.md) — the three-table views join all of them.
- Run cells in order: `students`/`courses` must exist before `student_courses`, and the seed rows before the triple joins. See the [root README](../README.md) for setup.

## What comes next

That's the full 7-lecture arc — from `CREATE DATABASE` to many-to-many schemas and SQL-side reporting. For the complete reference, see [SQL-Masterclass.html](../SQL-Masterclass.html) / the PDF guide in the repo root.
