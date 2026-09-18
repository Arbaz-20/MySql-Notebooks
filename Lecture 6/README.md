# Lecture 6 — Addresses, Foreign Keys, Indexes & the First View

> Notebook: `Lecture 6.mysql-notebook` — a second table (`address`), real enforced relationships via foreign keys, a speed experiment with `EXPLAIN`, composite indexes, and a first named view.

---

## What this lecture covers

| Concept | Syntax practiced |
|---------|------------------|
| Second table | `CREATE TABLE address (address_id, city, user_id, ...)` |
| Bulk address seed | ~190 Pune addresses attached to users |
| Foreign keys | `CONSTRAINT fk_users_address FOREIGN KEY (user_id) REFERENCES maqbool_info(id)` |
| Constraint introspection | `INFORMATION_SCHEMA.KEY_COLUMN_USAGE` |
| Query plans | `EXPLAIN SELECT ... ` before and after indexing |
| Indexes | `CREATE INDEX idx_user_name`, `idx_user_age`, composite `multiIDX_user_gender_is_student_phone_number` |
| Index management | `SHOW INDEX FROM maqbool_info`, `DROP INDEX ... ON ...` |
| First view | `CREATE VIEW maqbool_order AS SELECT ...` |
| View catalog | `INFORMATION_SCHEMA.VIEWS` |

## The address table + foreign key

```sql
CREATE TABLE address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    city VARCHAR(50) NOT NULL DEFAULT 'Pune',
    user_id INT,
    CONSTRAINT fk_users_address
        FOREIGN KEY (user_id) REFERENCES maqbool_info(id)
);
```

With the FK in place, inserting an address for a `user_id` that doesn't exist fails immediately — the database now defends the relationship. The same pattern is re-declared on `orders` as `fk_user_orders`.

To see every FK in the schema at once:

```sql
SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME,
       REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'maqbool_info';
```

## The EXPLAIN speed experiment

The lecture runs `EXPLAIN` on a `WHERE name = 'Arbaz Khan'` query and reads the plan: `type: ALL`, `rows: 5080` — a full table scan. Then:

```sql
CREATE INDEX idx_user_name ON maqbool_info(name);
EXPLAIN SELECT * FROM maqbool_info WHERE name = 'Arbaz Khan';
-- type: ref, rows: ~160  → the scan became a lookup
```

Same story for `idx_user_age` on age equality. The composite index demo shows the **leftmost prefix** rule: a query filtering only `is_student` can't use `multiIDX_user_gender_is_student_phone_number`, but one filtering `gender` (the first column) can.

## The first view

```sql
CREATE VIEW maqbool_order AS
SELECT u.name, o.product_name, o.total_amount
FROM maqbool_info u JOIN orders o ON o.user_id = u.id;

SELECT * FROM maqbool_order;   -- query it like a table
```

A view is a saved query, not saved data — every select re-runs the underlying join.

## Things noticed along the way

- An index speeds up reads that filter on it, and silently slows down writes (every INSERT/UPDATE maintains it).
- `SHOW INDEX FROM maqbool_info` confirms which indexes exist before `DROP INDEX idx_name ON maqbool_info` cleans up.
- `INFORMATION_SCHEMA.VIEWS` lists the view's definition — handy when you forget what a view actually selects.

## Prerequisites & how to run

- Requires `maqbool_info` and the 500-row `orders` table from [Lecture 5](../Lecture%205/README.md) — the joins, FK targets and row-count estimates all depend on them.
- Run cells in order; the EXPLAIN "after" cells only make sense once the CREATE INDEX cells above them have run. See the [root README](../README.md) for setup.

## What comes next

Lecture 7 combines everything: multi-table joins across three tables, reusable views, many-to-many relationships, and `CASE` / `IFNULL` reporting.
