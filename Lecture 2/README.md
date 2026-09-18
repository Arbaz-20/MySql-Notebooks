# Lecture 2 — Reading Data: SELECT, WHERE, LIKE & Pagination

> Notebook: `Lecture 2.mysql-notebook` — seeds the `maqbool_info` table with ~127 realistic people, then turns `SELECT` into a precision tool: projection, filtering, pattern matching and paging.

---

## What this lecture covers

| Concept | Commands / clauses practiced |
|---------|------------------------------|
| Projection | `SELECT *`, `SELECT col1, col2` |
| Bulk seeding | one `INSERT INTO ... VALUES` with ~125 rows |
| Row filtering | `WHERE` with `=`, `AND`, `OR`, `NOT` |
| List matching | `WHERE name IN (...)`, `WHERE id IN (1,23,3,...)` |
| Pattern matching | `LIKE '%Arbaz%'`, `LIKE '%P%'`, `NOT LIKE` |
| Paging | `LIMIT 10 OFFSET 0/10/20/30` |

## The bulk seed

The highlight of this lecture is one giant multi-row `INSERT` — real names, mixed ages (15–55), genders and `is_student` flags, with properly quoted phone numbers this time. This grows `maqbool_info` from a handful of rows to ~127 people, which is what makes every later lecture's filters and aggregates meaningful.

A second insert deliberately adds **20 identical `Arbaz Khan` rows** — used to explore how `WHERE`, `LIKE` and `OFFSET` behave when many rows match.

## Patterns worth remembering

```sql
-- paging through a big table, 10 at a time
SELECT * FROM maqbool_info LIMIT 10 OFFSET 0;   -- page 1
SELECT * FROM maqbool_info LIMIT 10 OFFSET 10;  -- page 2

-- exact-list matching (the readable OR)
SELECT * FROM maqbool_info WHERE id IN (1,23,3,4,53);

-- substring search — % on either side
SELECT * FROM maqbool_info WHERE name LIKE '%Arbaz%';
SELECT * FROM maqbool_info WHERE name LIKE '%P%';        -- matches P *or* p (case-insensitive collation)
SELECT * FROM maqbool_info WHERE name NOT LIKE '%Arbaz%';

-- combining conditions
SELECT * FROM maqbool_info
WHERE name="Arbaz Khan" AND gender="male" LIMIT 10 OFFSET 0;
SELECT * FROM maqbool_info
WHERE name="Arbaz" OR gender="female" LIMIT 10 OFFSET 0;
```

## Things noticed along the way

- `WHERE name="Arbaz"` (double quotes) works in MySQL — single quotes are the portable habit.
- `LIKE '%P%'` matching lowercase `p` is the default **case-insensitive collation** at work, not a bug.
- Filtering plus paging compose freely: `WHERE name="Arbaz Khan" LIMIT 10 OFFSET 10` shows page 2 *of the matches*, not of the table.

## Prerequisites & how to run

- Requires the `maqbool_info` table from [Lecture 1](../Lecture%201/README.md). If it was dropped, re-run Lecture 1's `CREATE TABLE` first.
- Open `Lecture 2.mysql-notebook` with the MySQL Shell for VS Code extension, connect, and run cells in order. The big seed cell takes one round-trip — that's the point.

## What comes next

Lecture 3 stacks these filters into combined conditions and adds ordering with `ORDER BY`.
