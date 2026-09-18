# Lecture 3 — Combined Filters, AND/OR/NOT & Sorting

> Notebook: `Lecture 3.mysql-notebook` — a focused practice set on *combining* conditions (`AND` / `OR` / `NOT`) and imposing order on results with `ORDER BY`, against the ~127-person `maqbool_info` table.

---

## What this lecture covers

| Concept | Clauses practiced |
|---------|-------------------|
| Combined filters | `LIKE ... AND gender='male'`, `LIKE ... AND is_student=true` |
| Boolean flags | filtering on `is_student = true / false` |
| OR chains | `WHERE name LIKE 'Arbaz%' OR age=22 OR gender="female"` |
| Negation | `NOT LIKE 'Arbaz%'` |
| Sorting | `ORDER BY id ASC / DESC`, `ORDER BY name ASC` |
| Sort + filter + page | `WHERE ... ORDER BY ... LIMIT 10 OFFSET 0` |

## The shape of every query in this lecture

```sql
SELECT * FROM maqbool_info
WHERE name LIKE 'Arbaz%' AND age=22
ORDER BY id DESC
LIMIT 10 OFFSET 0;
```

Each cell nudges one part of that pattern:

```sql
-- boolean flag filters
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND is_student=false;

-- OR widens the net
SELECT * FROM maqbool_info
WHERE name LIKE 'Arbaz%' OR age=22 OR gender="female"
ORDER BY id ASC LIMIT 10 OFFSET 0;

-- NOT excludes the pattern
SELECT * FROM maqbool_info
WHERE name NOT LIKE 'Arbaz%' AND age=22
ORDER BY name ASC LIMIT 10 OFFSET 0;
```

## Things noticed along the way

- `ORDER BY id DESC` shows *newest matching rows first*; `ORDER BY name ASC` is the alphabetical view of the same matches — sorting is a read-time lens, never a property of the table.
- `AND` binds tighter than `OR`: the `OR age=22 OR gender="female"` cell returns far more rows than it seems like it should, because every female row qualifies regardless of the `LIKE`. Parenthesize when mixing them.

## Prerequisites & how to run

- Requires the seeded `maqbool_info` table from Lectures 1–2.
- Open `Lecture 3.mysql-notebook` in VS Code with the MySQL Shell extension and run the cells in order — see the [root README](../README.md) for connection setup.

## What comes next

Lecture 4 starts collapsing rows: `COUNT`, `SUM`, `MIN`, `MAX`, `AVG`, then `GROUP BY` + `HAVING` — and the first taste of transactions.
