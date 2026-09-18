# Lecture 4 — Aggregates, GROUP BY, Duplicate Hunting & Transactions

> Notebook: `Lecture 4.mysql-notebook` — collapses 127 rows into single answers with aggregate functions, meets `GROUP BY` + `HAVING` while hunting duplicate names, and discovers `START TRANSACTION` / `ROLLBACK` / `COMMIT` as the undo button.

---

## What this lecture covers

| Concept | Functions / statements practiced |
|---------|----------------------------------|
| Counting | `COUNT(*)`, `COUNT(age)`, `COUNT(DISTINCT age)` |
| The NULL experiment | `ALTER ... age INT DEFAULT NULL`, `UPDATE ... SET age=NULL` |
| Math on columns | `SUM`, `MIN`, `MAX`, `AVG`, aggregate arithmetic (`SUM(age) + COUNT(gender)`) |
| Aliases | `AS total_age`, `AS gender_info` |
| Grouping | `GROUP BY name`, `GROUP BY name, age, gender` |
| Group filtering | `HAVING COUNT(*) > 1` |
| The escape hatch | `ANY_VALUE(id)`, `ANY_VALUE(name)` |
| Subqueries (preview) | `WHERE name IN (SELECT ...)` |
| Transactions | `START TRANSACTION`, `ROLLBACK`, `COMMIT` |

## The NULL experiment (the heart of the lecture)

Lecture 4 makes `age` nullable, sets the `0` ages to `NULL`, then watches the counts disagree:

```sql
ALTER TABLE maqbool_info MODIFY COLUMN age INT DEFAULT NULL;
UPDATE maqbool_info SET age = NULL WHERE age = 0;

SELECT COUNT(*)   FROM maqbool_info;   -- counts EVERY row
SELECT COUNT(age) FROM maqbool_info;   -- skips NULL ages — smaller number!
```

Also in here: `SELECT COUNT(age > 22)` — which does **not** count people over 22. The expression is `1`/`0`, never `NULL`, so it counts nearly everyone. The correct tool is `SELECT COUNT(*) ... WHERE age > 22`.

## The duplicate hunt

```sql
-- which names appear more than once?
SELECT name AS user_name
FROM maqbool_info
GROUP BY name
HAVING COUNT(*) > 1;

-- one sample row per duplicated name (only_full_group_by-safe)
SELECT ANY_VALUE(id) AS id, ANY_VALUE(name) AS user_name,
       ANY_VALUE(age) AS user_age, ANY_VALUE(gender) AS gender
FROM maqbool_info
GROUP BY name
HAVING COUNT(*) > 1;

-- exact-duplicate detector on the full combination
SELECT name, age, gender
FROM maqbool_info
GROUP BY name, age, gender
HAVING COUNT(*) > 0;
```

The famous error lived here too: selecting `name` next to `COUNT(*)` while grouping by `age` → *"Expression #1 of SELECT list is not in GROUP BY clause..."* — the `only_full_group_by` default. `ANY_VALUE()` is the sanctioned shrug.

## Transactions — the undo button

```sql
START TRANSACTION;
UPDATE maqbool_info SET age=23 WHERE name LIKE 'Arbaz%';
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%';  -- changed… but only for me
ROLLBACK;                                             -- ⏪ as if nothing happened

UPDATE maqbool_info SET age=23 WHERE name LIKE 'Arbaz%';
COMMIT;                                               -- 🔒 now it's permanent
ROLLBACK;                                             -- …nothing left to undo
```

Noticed: a `ROLLBACK` right after `COMMIT` changes nothing — it only discards work since the last commit. Also: the `updatedAT` audit column attempt failed with **Error 1054: Unknown column** — `MODIFY` edits what exists, `ADD` creates what doesn't (fixed later with `ADD COLUMN createdAt TIMESTAMP ...`).

## Prerequisites & how to run

- Requires `maqbool_info` seeded in Lectures 1–2.
- Run cells in order — the ALTER/UPDATE cells change the schema and data, so sequence matters. See the [root README](../README.md) for setup.

## What comes next

Lecture 5 flips the pattern: subqueries that feed filters, plus the `orders` table and the first joins.
