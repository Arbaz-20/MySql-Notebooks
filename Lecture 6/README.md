# Lecture 6: Addresses, Foreign Keys, Indexes & the First View

> Notebook: [`Lecture 6.sql`](Lecture%206.sql). Adds an `address` table, makes the database **enforce** the relationships with foreign keys, joins three tables, measures query plans with `EXPLAIN` before and after indexing, and saves a query as a view.

## What this lecture covers

| Concept | Syntax practiced |
|---------|------------------|
| Table aliases | `FROM maqbool_info AS m JOIN orders AS o` |
| New table | `CREATE TABLE IF NOT EXISTS Address (...)` |
| One-to-many data | 185 addresses for about 126 users (some users have two or more) |
| Foreign keys | `ALTER TABLE orders ADD CONSTRAINT fk_user_orders FOREIGN KEY (user_id) REFERENCES maqbool_info(id)` |
| Metadata | `INFORMATION_SCHEMA.KEY_COLUMN_USAGE`, `.STATISTICS`, `.VIEWS` |
| Joins | three-table `JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `CROSS JOIN` |
| Query plans | `EXPLAIN SELECT ...` |
| Indexes | `CREATE INDEX`, composite index, `SHOW INDEX`, `DROP INDEX` |
| Views | `CREATE VIEW`, `SHOW CREATE VIEW`, `SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW'` |

## The address table

```sql
CREATE TABLE IF NOT EXISTS Address(
    id INT UNIQUE PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,          -- which user lives here
    address VARCHAR(255),
    pincode BIGINT
);
```

## EXPLAIN before and after indexing (saved run)

| Query | Before index | After index |
|-------|--------------|-------------|
| `WHERE name LIKE 'Arbaz%'` | `type: ALL`, 126 rows scanned | `type: range`, key `idx_user_name`, 22 rows |
| `WHERE age = 21` | `type: ALL`, 126 rows scanned | `type: ref`, key `idx_user_age`, 6 rows |

`ALL` means a full table scan, which reads every row. `range` and `ref` mean MySQL used an index to jump straight to the matching rows.

---

## Query-by-query walkthrough

Every statement below is one cell in [`Lecture 6.sql`](Lecture%206.sql). The `-- Q<n>` comment at the top of each cell matches the number here.

### Setup and a join with table aliases

**Q1**

```sql
use maqbool;
```

Selects the `maqbool` schema.

**Q2**

```sql
show tables;
```

Two tables so far: `maqbool_info` and `orders`.

**Q3**

```sql
SELECT m.id,m.age,m.gender,o.id,o.item_count,o.order_number,o.status,o.total_amount,o.user_id from maqbool_info as m
JOIN orders as o ON o.user_id=m.id
WHERE o.status="confirmed" LIMIT 10 OFFSET 0;
```

A join using **table aliases**: `maqbool_info AS m` and `orders AS o` let you write `m.id` instead of `maqbool_info.id`. Filters to confirmed orders and shows the first 10. The double-quoted `"confirmed"` is treated as a string by MySQL.

### The address table

**Q4**

```sql
CREATE TABLE IF NOT EXISTS Address(id int UNIQUE PRIMARY KEY AUTO_INCREMENT,user_id int NOT NULL,address VARCHAR(255),pincode BIGINT);
```

Creates the `Address` table. `IF NOT EXISTS` makes the statement safe to re-run: if the table already exists, MySQL issues a warning instead of an error.
- `UNIQUE PRIMARY KEY` is redundant, since a primary key is already unique.
- `pincode BIGINT` works, but pincodes are identifiers, not quantities. `CHAR(6)` keeps leading zeros and stops anyone from doing arithmetic on them.
- Because table names are case-insensitive on Windows, the table is referred to later as `address`.

**Q5**

```sql
desc Address;
```

Shows the new table's structure.

**Q6**

```sql
INSERT INTO Address (user_id, address, pincode) VALUES
(1, '12 MG Road, Camp', 411001),
(2, '45 FC Road, Shivajinagar', 411005),
(3, '78 JM Road, Deccan', 411004),
(4, '23 Laxmi Road, Sadashiv Peth', 411030),
-- ... 179 more lines (see the .sql file) ...
(116, '31 Loni Kalbhor Road', 412201),
(126, '64 Uruli Devachi Road', 412308);
```

Inserts **185 addresses** (all in Pune). Many `user_id`s appear two or three times, so one user can have several addresses. This is a **one-to-many** relationship: one user, many addresses.

**Q7**

```sql
show TABLES;
```

Three tables now: `address`, `maqbool_info`, `orders`.

**Q8**

```sql
SELECT * from orders;
```

Shows all 500 orders.

**Q9**

```sql
SELECT * FROM address;
```

Shows all 185 addresses.

### A first three-table join

**Q10**

```sql
SELECT m.id,m.age,m.gender,o.status,o.total_amount,o.id,o.user_id,a.address as address_data,a.id as address_id,a.user_id as address_user_id from maqbool_info as m
INNER JOIN orders as o ON m.id = o.id
INNER JOIN address as a ON a.user_id = m.id;
```

A three-table join: users, their orders and their addresses.

**Bug to notice:** the first join is `ON m.id = o.id`, which matches a *user id* with an *order id*. Those are unrelated numbers, so the pairs are meaningless. The correct condition is `ON m.id = o.user_id`, as Q22 does.

### Foreign keys

**Q11**

```sql
desc maqbool_info;
```

Describes `maqbool_info`: `id` is a signed `INT`.

**Q12**

```sql
desc orders;
```

Describes `orders`: `user_id` is `INT UNSIGNED`.

**Q13**

```sql
desc address;
```

Describes `address`.

**Q14**

```sql
ALTER TABLE address MODIFY user_id INT NOT NULL;
```

Re-declares `address.user_id` as `INT NOT NULL`, the same type as `maqbool_info.id`.

**Q15**

```sql
ALTER TABLE orders MODIFY user_id INT NOT NULL;
```

Changes `orders.user_id` from `INT UNSIGNED` to `INT`. **A foreign key requires the two columns to have the same type, including signedness.** Before this change, the foreign key failed with *Error 3780: Referencing column 'user_id' and referenced column 'id' ... are incompatible* (visible in the original saved output). MySQL rebuilds the table, which is why the saved run reports *500 rows affected*.

**Q16**

```sql
desc orders;
```

Confirms that `orders.user_id` is now `INT`.

**Q17**

```sql
desc maqbool_info;
```

Re-checks `maqbool_info`.

**Q18**

```sql
desc address;
```

Re-checks `address`.

**Q19**

```sql
ALTER TABLE orders ADD CONSTRAINT fk_user_orders FOREIGN KEY (user_id) REFERENCES maqbool_info(id);
```

Adds a **foreign key**: every `orders.user_id` must match an existing `maqbool_info.id`. From now on MySQL rejects:
- inserting an order for a user that doesn't exist, and
- deleting a user who still has orders (the default `ON DELETE RESTRICT`).

The existing data must already satisfy the rule, which it does because Lecture 5 restored user 21. MySQL also creates an index on `orders.user_id` automatically.

**Q20**

```sql
ALTER TABLE address ADD CONSTRAINT fk_users_address FOREIGN KEY (user_id) REFERENCES maqbool_info(id);
```

The same kind of foreign key, for `address.user_id`.

**Q21**

```sql
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME IS NOT NULL
AND TABLE_SCHEMA = 'maqbool';
```

Reads the database's own metadata. `INFORMATION_SCHEMA.KEY_COLUMN_USAGE` lists key columns, and `REFERENCED_TABLE_NAME IS NOT NULL` keeps only foreign keys. Result: `fk_users_address` and `fk_user_orders`, both pointing at `maqbool_info(id)`.

### Multi-table joins: INNER, LEFT, RIGHT, CROSS

**Q22**

```sql
SELECT * FROM maqbool_info
JOIN orders ON maqbool_info.id=orders.user_id
JOIN address ON maqbool_info.id=address.user_id
WHERE orders.status="delivered" AND maqbool_info.age=23;
```

A correct **three-table join**: users → orders (`maqbool_info.id = orders.user_id`) → addresses (`maqbool_info.id = address.user_id`), filtered to delivered orders of 23-year-olds. 64 rows.

Notice the **row multiplication**: a user with 3 orders and 2 addresses produces 3 × 2 = 6 rows, because each order is paired with each address.

**Q23**

```sql
SELECT * FROM maqbool_info
LEFT JOIN address ON maqbool_info.id=address.user_id
LEFT JOIN orders ON maqbool_info.id=orders.user_id
LIMIT 100 OFFSET 0;
```

Two `LEFT JOIN`s: every user is kept, even users with no address or no orders (NULLs fill the gaps). First 100 rows.

**Q24**

```sql
SELECT * FROM maqbool_info
RIGHT JOIN address ON maqbool_info.id=address.user_id
RIGHT JOIN orders ON maqbool_info.id=orders.user_id
LIMIT 100 OFFSET 0;
```

Two `RIGHT JOIN`s. The last `RIGHT JOIN` decides what is preserved, so here every **order** is kept. Chained `RIGHT JOIN`s quickly get confusing. Most people rewrite them as `LEFT JOIN`s by swapping the table order.

**Q25**

```sql
SELECT * FROM maqbool_info
CROSS JOIN orders
CROSS JOIN address;
```

**`CROSS JOIN`** pairs every row with every row (a Cartesian product): 127 users × 500 orders × 185 addresses ≈ **11.7 million rows**. The saved run only displayed the first 1000. It's useful for generating combinations, and dangerous by accident: a join with a missing `ON` behaves the same way.

**Q26**

```sql
SELECT COUNT(*) from orders;
```

500 orders.

**Q27**

```sql
SELECT COUNT(*) from maqbool_info;
```

127 users.

### EXPLAIN and single-column indexes

**Q28**

```sql
select * from maqbool_info WHERE name like 'Arbaz%';
```

The query we're about to optimise: names starting with Arbaz (22 rows).

**Q29**

```sql
EXPLAIN SELECT * from maqbool_info WHERE name like 'Arbaz%';
```

**`EXPLAIN`** shows *how* MySQL will run a query, without running it. Here: `type: ALL`, `key: NULL`, `rows: 126`. That's a **full table scan**: every row is read to find the 22 matches.

**Q30**

```sql
CREATE INDEX idx_user_name on maqbool_info(name);
```

Creates an **index** on `name`. An index is a sorted copy of the column with pointers back to the rows, like the index at the back of a book. Lookups become fast. The cost is extra disk space and slightly slower `INSERT`s and `UPDATE`s, because the index must be kept up to date.

**Q31**

```sql
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' ORDER BY id ASC;
```

The same search, now sorted by `id`.

**Q32**

```sql
EXPLAIN SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' ORDER BY id ASC;
```

`EXPLAIN` now shows `type: range`, `key: idx_user_name`, `rows: 22`. MySQL reads only the matching slice of the index. A **prefix** pattern (`'Arbaz%'`) can use the index; `'%Arbaz%'` can't.

`Using filesort` appears because the results are re-sorted by `id` after the lookup.

**Q33**

```sql
EXPLAIN SELECT * FROM maqbool_info WHERE age=21;
```

`EXPLAIN` for `age = 21` before indexing: `type: ALL`, 126 rows (a full scan).

**Q34**

```sql
CREATE INDEX idx_user_age on maqbool_info(age);
```

Creates an index on `age`.

**Q35**

```sql
SELECT * FROM maqbool_info WHERE age=21;
```

Runs the query: 6 people aged 21.

**Q36**

```sql
EXPLAIN SELECT * FROM maqbool_info WHERE age=21;
```

After indexing: `type: ref`, `key: idx_user_age`, `rows: 6`. `ref` means an equality lookup through an index: only the 6 matching rows are read.

### Composite index

**Q37**

```sql
CREATE INDEX multiIDX_user_gender_is_student_phone_number ON maqbool_info(gender,is_student,phone_number);
```

A **composite (multi-column) index** on `(gender, is_student, phone_number)`. It is sorted by gender first, then by is_student within each gender, then by phone number.

**Leftmost-prefix rule:** it helps queries that filter on `gender`, on `gender + is_student`, or on all three. It does *not* help a query that filters only on `is_student` or `phone_number`, just as a phone book sorted by surname can't find people by first name alone.

**Q38**

```sql
SELECT * from
maqbool_info WHERE gender LIKE 'male%';
```

`gender LIKE 'male%'` returns 75 rows. It matches `'male'` and `'Male'` but not `'female'`, because `'female'` doesn't *start* with "male". The statement is spread over two lines, which is fine.

**Q39**

```sql
EXPLAIN SELECT * from
maqbool_info WHERE gender LIKE 'male%' AND age=21;
```

`EXPLAIN` with two filters. `possible_keys` lists both `idx_user_age` and the composite index. MySQL chose `idx_user_age` (6 rows) because it narrows the search the most. The optimiser picks the most selective index.

### Inspecting and managing indexes

**Q40**

```sql
SELECT
    TABLE_NAME,
    INDEX_NAME,
    NON_UNIQUE,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'maqbool'
AND INDEX_NAME != 'PRIMARY'
ORDER BY TABLE_NAME;
```

`INFORMATION_SCHEMA.STATISTICS` lists every index column in the schema except the primary keys: one row per column per index (10 rows).

**Q41**

```sql
SHOW INDEX FROM maqbool_info;
```

`SHOW INDEX FROM maqbool_info` lists 7 rows: `PRIMARY` (id), the redundant unique `id` index from Lecture 5, `idx_user_name`, `idx_user_age`, and the three columns of the composite index (`Seq_in_index` 1, 2, 3).

**Q42**

```sql
SHOW INDEX FROM orders;
```

`orders` has 3 indexes: `PRIMARY`, `order_number` (created by `UNIQUE`), and `fk_user_orders` (created automatically by the foreign key).

**Q43**

```sql
DROP INDEX idx_user_name on maqbool_info;
```

`DROP INDEX ... ON table` removes an index. The data isn't affected; only lookups get slower.

**Q44**

```sql
SHOW INDEX FROM maqbool_info;
```

6 rows now: `idx_user_name` is gone.

**Q45**

```sql
CREATE INDEX idx_user_name on maqbool_info(name);
```

Re-creates the name index.

**Q46**

```sql
SHOW INDEX FROM maqbool_info;
```

Back to 7 rows.

### The first view

**Q47**

```sql
CREATE VIEW maqbool_order AS
SELECT m.id,m.age,m.is_student,m.gender,m.name,o.status,o.id as order_id,o.user_id,o.total_amount FROM maqbool_info as m
JOIN orders as o
ON m.id=o.user_id
WHERE o.status="confirmed";
```

**`CREATE VIEW`** saves a query under a name. `maqbool_order` joins users with their *confirmed* orders. `o.id AS order_id` renames the column, because a view can't have two columns with the same name (`m.id` and `o.id`).

A view stores **no data**: every time you query it, the underlying `SELECT` runs again, so it always reflects the current tables.

**Q48**

```sql
SELECT * From maqbool_order LIMIT 10 OFFSET 0;
```

You query a view exactly like a table, including `WHERE`, `LIMIT` and so on.

**Q49**

```sql
SHOW CREATE VIEW maqbool_order;
```

`SHOW CREATE VIEW` shows the stored definition, including the `ALGORITHM`, `DEFINER` (`root@localhost`) and `SQL SECURITY` settings MySQL added.

**Q50**

```sql
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';
```

`SHOW TABLES` lists views too. `SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW'` filters to views only.

**Q51**

```sql
SELECT
    TABLE_NAME AS view_name,
    VIEW_DEFINITION
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'maqbool';
```

`INFORMATION_SCHEMA.VIEWS` lists each view and its `VIEW_DEFINITION`. It's handy when you forget what a view selects.

---

## Key lessons from this lecture

1. **Foreign keys need identical column types.** `INT` vs `INT UNSIGNED` caused error 3780 until `orders.user_id` was changed to `INT`.
2. **Foreign keys prevent orphans.** After Q19 and Q20, MySQL rejects orders or addresses for users that don't exist.
3. **Check your join conditions.** Q10 joined `m.id = o.id` (user id to order id) and quietly produced nonsense.
4. **Joins multiply rows.** 3 orders × 2 addresses = 6 rows per user. A `CROSS JOIN` multiplies everything with everything.
5. **`EXPLAIN` before you optimise.** A full scan (`ALL`) became a `range` or `ref` lookup after indexing.
6. **Composite indexes follow the leftmost-prefix rule.**
7. **A view is a saved query, not saved data.**

## Prerequisites & how to run

- Requires `maqbool_info` and the 500-row `orders` table from [Lecture 5](../Lecture%205/README.md), including restoring user 21 (otherwise the foreign key in Q19 fails because of orphaned orders).
- Run the `EXPLAIN` "before" cells *before* the matching `CREATE INDEX` cells, otherwise you'll only see the "after" plan.
- Q25 (`CROSS JOIN`) produces about 11.7 million rows. You can skip it, or add `LIMIT 1000`.

1. Install the **SQL Notebook** extension (publisher `cmoog`) in VS Code. See the [root README](../README.md#2-install-the-sql-notebook-extension).
2. Right-click `Lecture 6.sql`, choose **Open With…**, then **SQL Notebook**.
3. In the **SQL NOTEBOOK** sidebar panel, connect to your local MySQL server (see the root README).
4. Run cells one at a time with the ▶ button or `Ctrl+Enter`, top to bottom. Each cell holds exactly one statement.

> The cells are separated by blank lines in the `.sql` file. That is how SQL Notebook decides where one cell ends and the next begins, so don't add blank lines *inside* a statement when you edit the file.

## What comes next

[Lecture 7](../Lecture%207/README.md) builds reusable views over three-table joins, introduces CTEs and many-to-many relationships, and ends with `CASE` and `IFNULL` reporting.
