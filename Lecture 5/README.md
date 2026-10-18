# Lecture 5: Subqueries, the Orders Table & Joins

> Notebook: [`Lecture 5.sql`](Lecture%205.sql). The schema gets its second table. The lecture creates `orders`, generates 500 realistic orders in a single statement, and then explores how the different joins behave when some orders have no matching user.

## What this lecture covers

| Concept | Syntax practiced |
|---------|------------------|
| Subquery in `WHERE` | `WHERE age IN (SELECT ... GROUP BY age HAVING COUNT(age) > 1)` |
| Rich column types | `INT UNSIGNED`, `ENUM`, `DECIMAL(10,2)`, `TINYINT`, `DATETIME`, `UNIQUE` |
| Data generation | `WITH RECURSIVE seq AS (...)`, `RAND(n)`, `ELT()`, `LPAD()`, `DATE_SUB()` |
| Joins | `INNER JOIN` / `JOIN`, `LEFT JOIN`, `RIGHT JOIN` |
| NULL checks | `IS NULL` |
| Set operations | `UNION` |

## The `orders` table

| Column | Type | Notes |
|--------|------|-------|
| `id` | `INT UNSIGNED AUTO_INCREMENT PRIMARY KEY` | `UNSIGNED` means no negative numbers |
| `user_id` | `INT UNSIGNED NOT NULL` | Which user placed the order (points at `maqbool_info.id`) |
| `order_number` | `VARCHAR(20) NOT NULL UNIQUE` | No two orders can share a number |
| `status` | `ENUM('pending', ..., 'refunded')` | Only the listed values are allowed |
| `total_amount` | `DECIMAL(10,2)` | Exact money type: 10 digits, 2 after the point |
| `item_count` | `TINYINT UNSIGNED DEFAULT 1` | 0–255 |
| `payment_method` | `ENUM('credit_card', ..., 'wallet')` | |
| `created_at` / `updated_at` | `DATETIME` | `updated_at` refreshes itself on every update |

## How the joins differ (from the saved run)

| Join | Rows | What it keeps |
|------|------|---------------|
| `INNER JOIN` | under 500 | only orders whose user exists |
| `LEFT JOIN` (users → orders) | 567 | every user; users with no orders get `NULL` order columns |
| `RIGHT JOIN` (users → orders) | 500 | every order; orders whose user is missing get `NULL` user columns |

---

## Query-by-query walkthrough

Every statement below is one cell in [`Lecture 5.sql`](Lecture%205.sql). The `-- Q<n>` comment at the top of each cell matches the number here.

### Setup

**Q1**

```sql
use maqbool;
```

Selects the `maqbool` schema.

**Q2**

```sql
show TABLES;
```

Lists the tables. Only `maqbool_info` exists so far.

**Q3**

```sql
desc maqbool_info;
```

Shows the `maqbool_info` structure.

**Q4**

```sql
SELECT * FROM maqbool_info LIMIT 20 OFFSET 0;
```

A quick look at the first 20 users.

### Subqueries: finding repeated ages

**Q5**

```sql
select COUNT(age) from maqbool_info;
```

Counts the non-NULL ages (a reminder from Lecture 4).

**Q6**

```sql
SELECT * FROM maqbool_info WHERE age in (select ANY_VALUE(age) from maqbool_info GROUP BY age HAVING COUNT(age) > 1) ORDER BY age ASC;
```

A **subquery** inside `WHERE`: the inner query `SELECT age ... GROUP BY age HAVING COUNT(age) > 1` produces the list of ages that occur more than once, and the outer query returns every person with one of those ages, sorted by age.

`ANY_VALUE(age)` isn't needed here because `age` is already the `GROUP BY` column, so plain `SELECT age` works.

**Q7**

```sql
SELECT COUNT(age) as age_count,
age as age
from maqbool_info group by age HAVING COUNT(age) > 1;
```

The same idea shown as a summary: one row per repeated age, with the number of people who have it (`age_count`). A statement can span several lines; it ends at the `;`.

**Q8**

```sql
SELECT * from maqbool_info where age=38;
```

Checks everyone aged 38.

### Deleting user 21

**Q9**

```sql
SELECT * from maqbool_info where id=21;
```

Looks at user 21 before deleting it.

**Q10**

```sql
DELETE from maqbool_info where id=21;
```

Deletes user 21. This creates a "hole" that the join experiments below depend on: once orders exist for `user_id = 21`, they have no matching user.

**Q11**

```sql
SELECT * from maqbool_info where id=21;
```

Confirms that user 21 is gone (empty result).

**Q12**

```sql
SELECT * from maqbool_info;
```

Shows all users.

### The orders table

**Q13**

```sql
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
```

Creates the `orders` table (see the column table above). Highlights:
- **`ENUM`** restricts a column to a fixed list of values. Inserting `'lost'` into `status` would be rejected in strict mode.
- **`DECIMAL(10,2)`** stores money exactly. Never use `FLOAT` for money, because it has rounding errors.
- **`UNIQUE`** on `order_number` makes MySQL reject duplicates. It also creates an index.
- **`ON UPDATE CURRENT_TIMESTAMP`** keeps `updated_at` current automatically.

*Fixed while converting:* the original statement ended with `)` and no `;`. The semicolon was added.

**Q14**

```sql
INSERT INTO orders (user_id, order_number, status, total_amount, item_count, payment_method, created_at)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 500
-- ... 25 more lines (see the .sql file) ...
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND(n*7) * 90 * 24 * 60) MINUTE) AS created_at
FROM seq;
```

Generates **500 orders in one statement** with `INSERT ... SELECT` and a **recursive CTE**:
- `WITH RECURSIVE seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 500)` builds a virtual table of the numbers 1–500. The first `SELECT` is the starting row, and the second keeps adding `n + 1` until the `WHERE` stops it.
- `RAND(n)` is a *seeded* random number between 0 and 1, so the same `n` always gives the same value and the data is reproducible. Different multipliers (`n*2`, `n*3`, ...) give each column its own random stream.
- `FLOOR(1 + RAND(n) * 127)` gives a random `user_id` from 1 to 127.
- `CONCAT('ORD-', DATE_FORMAT(...), '-', LPAD(n, 4, '0'))` builds order numbers like `ORD-20260215-0001`. `LPAD` pads with zeros to 4 digits.
- `ELT(k, 'a', 'b', ...)` returns the k-th value from the list. Listing `'delivered'` three times makes it more likely. Note that `FLOOR(1 + RAND() * 7)` only produces 1–7, so the 8th value (`'cancelled'`) is never picked.
- `DATE_SUB(NOW(), INTERVAL ... MINUTE)` gives a random timestamp within the last 90 days.
- `--` starts a comment that runs to the end of the line.

**Q15**

```sql
SELECT * from orders;
```

Shows the 500 generated orders.

### Preparing the id column

**Q16**

```sql
ALTER TABLE maqbool_info MODIFY id int UNIQUE AUTO_INCREMENT;
```

Re-declares `maqbool_info.id` as `INT UNIQUE AUTO_INCREMENT`. `id` is already the primary key, which is unique by definition, so this only adds a second, redundant unique index named `id` (you can see it in Lecture 6's `SHOW INDEX`).

It also leaves `id` as a **signed** `INT` while `orders.user_id` is `INT UNSIGNED`. That type mismatch is why adding a foreign key fails with error 3780 in Lecture 6 until the types are made identical.

### INNER JOIN

**Q17**

```sql
SELECT * FROM maqbool_info
INNER JOIN orders ON maqbool_info.id = orders.user_id;
```

**`INNER JOIN`** pairs every user with each of their orders, matching on `maqbool_info.id = orders.user_id`. Only rows that have a match on **both** sides appear, so users without orders and orders for the deleted user 21 are left out. A user with 5 orders appears 5 times.

**Q18**

```sql
desc maqbool_info;
```

Checks the `id` column after the `ALTER` in Q16.

**Q19**

```sql
SELECT * FROM maqbool_info
JOIN orders ON maqbool_info.id = orders.user_id;
```

Plain `JOIN` is exactly the same as `INNER JOIN`.

**Q20**

```sql
SELECT maqbool_info.id,maqbool_info.name,maqbool_info.age,orders.user_id,orders.order_number,orders.status,orders.item_count,orders.total_amount
FROM maqbool_info
INNER JOIN orders ON maqbool_info.id = orders.user_id ORDER BY name ASC LIMIT 10 OFFSET 0;
```

Selects specific columns with `table.column` qualifiers (needed when both tables have a column with the same name, such as `id`), sorts by name and shows the first page of 10.

**Q21**

```sql
SELECT maqbool_info.id,maqbool_info.name, orders.user_id,orders.status, orders.total_amount
FROM maqbool_info
INNER JOIN orders ON orders.user_id = maqbool_info.id;
```

The `ON` condition is symmetric: `orders.user_id = maqbool_info.id` gives the same result as the reverse.

**Q22**

```sql
SELECT SUM(total_amount) from orders;
```

`SUM(total_amount)`: the total value of all 500 orders.

**Q23**

```sql
SELECT COUNT(*) from maqbool_info;
```

Counts the users, to compare with the join results.

### LEFT JOIN

**Q24**

```sql
SELECT * FROM maqbool_info
LEFT JOIN orders ON orders.user_id = maqbool_info.id;
```

**`LEFT JOIN`** keeps **every row from the left table** (`maqbool_info`), matched or not. Users who have no orders still appear once, with `NULL` in all the order columns. The saved run returned 567 rows: every order with an existing user, plus one row for each user without orders.

**Q25**

```sql
SELECT maqbool_info.id,name,age,gender FROM maqbool_info
LEFT JOIN orders ON orders.user_id = maqbool_info.id;
```

The same `LEFT JOIN` showing only user columns. Users repeat once per order, which shows how a join multiplies rows.

### Joins combined with WHERE filters

**Q26**

```sql
SELECT * FROM maqbool_info
INNER JOIN orders ON orders.user_id = maqbool_info.id
WHERE orders.status in ('delivered','confirmed','pending');
```

A join plus a `WHERE` filter on the right table: only orders that are delivered, confirmed or pending.

**Q27**

```sql
SELECT * FROM maqbool_info
INNER JOIN orders ON orders.user_id = maqbool_info.id
WHERE maqbool_info.age NOT in (21,31,44) AND orders.status in ('pending','delivered') ORDER BY age ASC;
```

Filters on both tables: users whose age is **not** 21, 31 or 44, with pending or delivered orders, sorted by age.

**Q28**

```sql
SELECT * from maqbool_info
LEFT JOIN orders on orders.user_id = maqbool_info.id
WHERE maqbool_info.gender ='female';
```

`LEFT JOIN` filtered on the **left** table (female users). Female users with no orders still appear, with NULL order columns.

If you filter on a *right-table* column in `WHERE` instead, the NULL rows are removed and the `LEFT JOIN` effectively becomes an `INNER JOIN`.

**Q29**

```sql
SELECT * FROM maqbool_info
INNER JOIN orders ON orders.user_id = maqbool_info.id
WHERE maqbool_info.age in (21,31,44) AND orders.status in ('pending','delivered') ORDER BY age ASC;
```

The opposite of Q27: users aged exactly 21, 31 or 44.

### RIGHT JOIN and orphaned orders

**Q30**

```sql
SELECT * from maqbool_info
RIGHT JOIN orders on maqbool_info.id = orders.user_id;
```

**`RIGHT JOIN`** keeps **every row from the right table** (`orders`). Orders whose `user_id` has no matching user (the orders for the deleted user 21) appear with `NULL` in the user columns. These are **orphaned rows**. 500 rows, one per order.

**Q31**

```sql
SELECT COUNT(*) from orders;
```

500 orders in total.

**Q32**

```sql
SELECT COUNT(*) from maqbool_info;
```

The number of users.

**Q33**

```sql
use maqbool;
```

`USE maqbool` again. The session had reconnected, and without this the next queries fail with *No database selected*.

**Q34**

```sql
SELECT COUNT(*) from orders where user_id is NULL;
```

Looks for orders with `user_id IS NULL`: **0**. The orphaned orders do have a `user_id` (21). It just doesn't match any user. The `NULL`s seen in Q30 come from the *join*, not from the orders table. Also note: you test NULL with `IS NULL`, never `= NULL`.

**Q35**

```sql
SELECT * from orders;
```

All orders.

**Q36**

```sql
SELECT * from maqbool_info WHERE id= 21;
```

User 21 doesn't exist (empty result)...

**Q37**

```sql
SELECT * from orders where user_id=21;
```

...but 10 orders still point at `user_id = 21`. Those are the orphans. A **foreign key** (Lecture 6) prevents this situation.

**Q38**

```sql
SELECT * from maqbool_info
RIGHT JOIN orders on maqbool_info.id = orders.user_id;
```

`RIGHT JOIN` again: 500 rows, with the 10 orphans showing NULL user columns.

**Q39**

```sql
SELECT * from maqbool_info
LEFT JOIN orders on maqbool_info.id = orders.user_id;
```

`LEFT JOIN` again: 567 rows. The orphaned orders are missing, and users without orders are present.

**Q40**

```sql
SELECT * from maqbool_info
LEFT JOIN orders on maqbool_info.id = orders.user_id;
```

Same as Q39.

**Q41**

```sql
SELECT * from maqbool_info
RIGHT JOIN orders on maqbool_info.id = orders.user_id
where orders.user_id=21;
```

`RIGHT JOIN` filtered to `orders.user_id = 21`: exactly the 10 orphaned orders, each with NULL user columns.

**Q42**

```sql
SELECT maqbool_info.id,name,gender,orders.id,orders.status,orders.order_number from maqbool_info
RIGHT JOIN orders on orders.user_id = maqbool_info.id order by maqbool_info.id desc;
```

A `RIGHT JOIN` with chosen columns, sorted by `maqbool_info.id DESC`. In MySQL, NULLs sort *first* in ascending order and *last* in descending order, so the orphaned rows end up at the bottom here.

### Restoring user 21

**Q43**

```sql
insert maqbool_info(name,age,gender) values('mira murati',21,'female');
```

Adds a new user, *mira murati*. `INSERT maqbool_info(...)` without `INTO` is valid MySQL (`INTO` is optional). The new row gets the **next** auto-increment id, not 21.

**Q44**

```sql
SELECT maqbool_info.id,name,gender,orders.id,orders.status,orders.order_number,orders.user_id from maqbool_info
RIGHT JOIN orders on orders.user_id = maqbool_info.id order by maqbool_info.id desc;
```

The `RIGHT JOIN` again (with `orders.user_id` shown). The orphans are still orphans, because the new user has a different id.

**Q45**

```sql
SELECT * from maqbool_info where name like 'mira%';
```

Finds the new user and their auto-generated id.

**Q46**

```sql
SELECT maqbool_info.id,name,gender,orders.id,orders.status,orders.order_number,orders.user_id from maqbool_info
RIGHT JOIN orders on orders.user_id = maqbool_info.id order by maqbool_info.id desc;
```

Same as Q44.

**Q47**

```sql
SELECT * from maqbool_info where name like 'mira%';
```

Same as Q45.

**Q48**

```sql
update maqbool_info set id=21 where name='mira murati';
```

Manually sets the new user's primary key to **21**, which fills the hole. Now the 10 orphaned orders point at a real user again. Changing primary keys is unusual in real systems, but it shows that the join simply matches values.

**Q49**

```sql
SELECT maqbool_info.id,name,gender,orders.id,orders.status,orders.order_number,orders.user_id from maqbool_info
RIGHT JOIN orders on orders.user_id = maqbool_info.id order by maqbool_info.id ASC;
```

`RIGHT JOIN` sorted ascending: every order now has a user, and no NULL user columns remain.

### Emulating a FULL OUTER JOIN with UNION

**Q50**

```sql
SELECT * from maqbool_info
LEFT JOIN orders on orders.user_id = maqbool_info.id
WHERE maqbool_info.id is null
UNION
SELECT * from orders
RIGHT JOIN maqbool_info on maqbool_info.id = orders.user_id;
```

An attempt at a **FULL OUTER JOIN**, which MySQL doesn't support, using `UNION` (which combines two result sets and removes duplicate rows):
- Part 1: `maqbool_info LEFT JOIN orders ... WHERE maqbool_info.id IS NULL` is always empty, because a left-table `id` is never NULL in a `LEFT JOIN`.
- Part 2: `orders RIGHT JOIN maqbool_info` returns every user with their orders, but with the **orders columns first**. `UNION` matches columns by *position*, not name, so if part 1 returned rows, the columns would be misaligned.

The standard emulation is:
```sql
SELECT * FROM maqbool_info LEFT  JOIN orders ON orders.user_id = maqbool_info.id
UNION
SELECT * FROM maqbool_info RIGHT JOIN orders ON orders.user_id = maqbool_info.id;
```

---

## Key lessons from this lecture

1. **Recursive CTEs generate test data.** `WITH RECURSIVE` plus seeded `RAND(n)` produced 500 reproducible orders in one statement.
2. **INNER drops unmatched rows; LEFT and RIGHT keep one side whole**, filling the other side with `NULL`.
3. **Orphaned rows** (orders for a deleted user) only show up with a `RIGHT JOIN` here. A `FOREIGN KEY` (Lecture 6) stops them from happening.
4. **NULLs from a join are not NULLs in the table.** `WHERE user_id IS NULL` found 0 orders, even though the join showed NULL user columns.
5. **`UNION` matches columns by position.** Both halves must select the same columns in the same order.
6. **Use `DECIMAL` for money and `ENUM` for fixed sets of values.**

## Prerequisites & how to run

- Requires `maqbool_info` from the earlier lectures.
- Q14 inserts 500 orders every time you run it. Run it once. A second run fails anyway, because the generated `order_number`s repeat and the column is `UNIQUE`.
- Q10 deletes user 21 and Q48 restores the id. Run them in order so the orphan demonstrations make sense.

1. Install the **SQL Notebook** extension (publisher `cmoog`) in VS Code. See the [root README](../README.md#2-install-the-sql-notebook-extension).
2. Right-click `Lecture 5.sql`, choose **Open With…**, then **SQL Notebook**.
3. In the **SQL NOTEBOOK** sidebar panel, connect to your local MySQL server (see the root README).
4. Run cells one at a time with the ▶ button or `Ctrl+Enter`, top to bottom. Each cell holds exactly one statement.

> The cells are separated by blank lines in the `.sql` file. That is how SQL Notebook decides where one cell ends and the next begins, so don't add blank lines *inside* a statement when you edit the file.

## What comes next

[Lecture 6](../Lecture%206/README.md) adds an `address` table, enforces relationships with **foreign keys**, measures queries with `EXPLAIN`, adds indexes, and creates the first view.
