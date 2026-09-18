# Lecture 5 — Subqueries, the `orders` Table & JOINs

> Notebook: `Lecture 5.mysql-notebook` — queries that build queries (subqueries), a production-style `orders` table, a 500-row data generator, and the lecture where tables finally talk to each other: `INNER` / `LEFT` / `RIGHT` joins.

---

## What this lecture covers

| Concept | Syntax practiced |
|---------|------------------|
| Subqueries | `WHERE name IN (SELECT name ... GROUP BY ... HAVING COUNT(*) > 1)` |
| Cleanup by key | `DELETE FROM maqbool_info WHERE id = ...` |
| New table (DDL) | `CREATE TABLE orders` with `ENUM`, `DECIMAL(10,2)`, defaults, FK |
| Data generation | recursive CTE generating 500 seeded order rows |
| Inner join | `JOIN ... ON u.id = o.user_id` |
| Left join | `LEFT JOIN` + `WHERE o.id IS NULL` (the anti-join) |
| Right join | `RIGHT JOIN`, including a NULL-matching trick row |
| Full outer join | `LEFT JOIN ... UNION ... RIGHT JOIN` |

## The subquery

```sql
-- names that are duplicated, found from inside the WHERE clause
SELECT * FROM maqbool_info
WHERE name IN (
    SELECT name FROM maqbool_info
    GROUP BY name HAVING COUNT(*) > 1
);
```

This is the first time a query's *output* becomes another query's *input* — the `GROUP BY ... HAVING` result from Lecture 4 now feeds an `IN` list.

## The `orders` table

A deliberately production-flavored schema (unlike the casual `maqbool_info`):

```sql
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending','shipped','delivered','cancelled') DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES maqbool_info(id)
);
```

Then a recursive CTE generates **500 rows** with deterministic pseudo-random products, quantities, amounts and statuses — so joins have enough data to be interesting. (CTEs are out of scope for the course guide, but the notebook keeps the generator; any bulk `INSERT` works as a replacement.)

## The joins

```sql
-- every order, stamped with the buyer's name
SELECT o.id, u.name, o.product_name, o.total_amount
FROM orders o JOIN maqbool_info u ON u.id = o.user_id;

-- INNER vs LEFT: who never ordered anything?
SELECT u.id, u.name
FROM maqbool_info u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.id IS NULL;                     -- the anti-join

-- FULL OUTER JOIN, MySQL-style: LEFT ∪ RIGHT via UNION
SELECT u.name, o.id FROM maqbool_info u
LEFT JOIN orders o ON o.user_id = u.id
UNION
SELECT u.name, o.id FROM maqbool_info u
RIGHT JOIN orders o ON o.user_id = u.id;
```

For the `RIGHT JOIN` demo, a customer **"mira murati"** with no orders is inserted so the two sides of the join visibly disagree — a row with `NULL` order columns appears.

## Things noticed along the way

- `LEFT JOIN ... WHERE o.id IS NULL` is the reusable "customers with no orders" pattern — an inner join can never show these rows.
- A `RIGHT JOIN` from `maqbool_info` to `orders` keeps orders whose `user_id` has no matching person (possible only if the FK is dropped/violated) plus the unmatched right table's rows.
- `UNION` (not `UNION ALL`) between the LEFT and RIGHT halves is what removes the duplicated matched rows, producing a true full outer join.

## Prerequisites & how to run

- Requires `maqbool_info` seeded in Lectures 1–2 (some cells clean up Lecture 2's duplicate `Arbaz Khan` rows by `id`).
- Run cells in order: the `CREATE TABLE orders` and generator cells must run before any join. See the [root README](../README.md) for setup.

## What comes next

Lecture 6 gives every person an address, adds real foreign-key constraints, and makes queries fast with indexes and `EXPLAIN`.
