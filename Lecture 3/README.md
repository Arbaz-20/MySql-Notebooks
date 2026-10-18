# Lecture 3: Combined Filters & Sorting

> Notebook: [`Lecture 3.sql`](Lecture%203.sql). A short, focused session on building a full "filter, sort, page" query, one clause at a time.

## What this lecture covers

| Concept | Syntax practiced |
|---------|------------------|
| Prefix search | `LIKE 'Arbaz%'` |
| Multiple conditions | `AND`, `OR`, `NOT LIKE` |
| Boolean columns | `is_student = true / false` |
| Sorting | `ORDER BY id DESC`, `ORDER BY id ASC`, `ORDER BY name ASC` |
| Full pipeline | `WHERE ... ORDER BY ... LIMIT ... OFFSET ...` |

## Clause order

MySQL requires the clauses in this order. It also processes them roughly in this order:

```sql
SELECT columns
FROM   table
WHERE  conditions        -- 1. filter rows
ORDER BY column ASC|DESC -- 2. sort what's left
LIMIT  n OFFSET m;       -- 3. cut out one page
```

---

## Query-by-query walkthrough

Every statement below is one cell in [`Lecture 3.sql`](Lecture%203.sql). The `-- Q<n>` comment at the top of each cell matches the number here.

### Setup

**Q1**

```sql
show DATABASES;
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

Confirms that `maqbool_info` is the only table.

**Q4**

```sql
desc maqbool_info;
```

Shows the table structure.

**Q5**

```sql
SELECT * FROM maqbool_info;
```

Shows all 126 rows built up in Lecture 2.

### Prefix search combined with AND

**Q6**

```sql
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%';
```

`LIKE 'Arbaz%'` is a **prefix** search: names that *start with* "Arbaz". 22 rows (2 *Arbaz* + 20 *Arbaz Khan*).

Compared with `'%Arbaz%'` (contains), a prefix pattern can use an index on `name`. A leading `%` can't. You'll see this with `EXPLAIN` in Lecture 6.

**Q7**

```sql
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND gender='male';
```

Prefix search **AND** gender. `'male'` matches the stored `'male'` and `'Male'` because comparisons are case-insensitive. Still 22 rows.

**Q8**

```sql
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND is_student=false;
```

Filters on a boolean column: `is_student = false` (stored as 0). Only the original 2 *Arbaz* rows are non-students.

**Q9**

```sql
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND is_student=true;
```

`is_student = true` (1): the 20 *Arbaz Khan* rows.

**Q10**

```sql
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND is_student=True LIMIT 10 OFFSET 0;
```

Same as Q9 with paging: the first 10 of those 20. `True` and `true` are the same keyword.

**Q11**

```sql
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND age=23 LIMIT 10 OFFSET 0;
```

Prefix search AND an exact age: the 2 *Arbaz* rows aged 23.

### Sorting with ORDER BY

**Q12**

```sql
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND age=22 ORDER BY id DESC LIMIT 10 OFFSET 0;
```

Adds **sorting**: `ORDER BY id DESC` puts the highest id first, so you see the most recently inserted *Arbaz Khan* rows (all aged 22). The `ORDER BY` runs before `LIMIT`, so you get the *top 10 after sorting*.

**Q13**

```sql
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' AND age=22 ORDER BY id ASC LIMIT 10 OFFSET 0;
```

Same query with `ASC` (ascending, the default): lowest ids first. Comparing Q12 and Q13 shows why paging needs an explicit order.

### OR conditions

**Q14**

```sql
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' OR age=22 ORDER BY id ASC LIMIT 10 OFFSET 0;
```

Switches `AND` to **`OR`**: rows whose name starts with Arbaz **or** whose age is 22. `OR` widens the result while `AND` narrows it.

**Q15**

```sql
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' OR age=22 OR gender="female" ORDER BY id ASC LIMIT 10 OFFSET 0;
```

Three conditions joined by `OR`: name starts with Arbaz, or age is 22, or gender is female. When you mix `AND` and `OR`, remember that `AND` binds tighter, so use parentheses to make the intent explicit, e.g. `WHERE (a OR b) AND c`.

### NOT LIKE and sorting by name

**Q16**

```sql
SELECT * FROM maqbool_info WHERE name NOT LIKE 'Arbaz%' AND age=22 ORDER BY id ASC LIMIT 10 OFFSET 0;
```

`NOT LIKE 'Arbaz%'` AND `age = 22`: 22-year-olds whose name doesn't start with Arbaz. 5 rows, sorted by id.

**Q17**

```sql
SELECT * FROM maqbool_info WHERE name NOT LIKE 'Arbaz%' AND age=22 ORDER BY name ASC LIMIT 10 OFFSET 0;
```

The same filter sorted **alphabetically by name** (`ORDER BY name ASC`). You can sort by any column, not only the primary key.

---

## Key lessons from this lecture

1. **`'Arbaz%'` (starts with) vs `'%Arbaz%'` (contains).** A prefix pattern can use an index; a leading wildcard can't.
2. **`AND` narrows, `OR` widens.** When you combine them, add parentheses. `AND` is evaluated first.
3. **`ORDER BY` runs before `LIMIT`.** You get "the first N rows after sorting", which is what pagination needs.
4. **Boolean columns are just 0/1.** `is_student = true` and `is_student = 1` are the same.

## Prerequisites & how to run

- Requires the `maqbool_info` table with the data seeded in [Lecture 2](../Lecture%202/README.md). This lecture only reads data; it changes nothing.

1. Install the **SQL Notebook** extension (publisher `cmoog`) in VS Code. See the [root README](../README.md#2-install-the-sql-notebook-extension).
2. Right-click `Lecture 3.sql`, choose **Open With…**, then **SQL Notebook**.
3. In the **SQL NOTEBOOK** sidebar panel, connect to your local MySQL server (see the root README).
4. Run cells one at a time with the ▶ button or `Ctrl+Enter`, top to bottom. Each cell holds exactly one statement.

> The cells are separated by blank lines in the `.sql` file. That is how SQL Notebook decides where one cell ends and the next begins, so don't add blank lines *inside* a statement when you edit the file.

## What comes next

[Lecture 4](../Lecture%204/README.md) moves from reading rows to *summarising* them with `COUNT`, `SUM`, `AVG`, `GROUP BY` and `HAVING`, and introduces transactions.
