# Lecture 2: Seeding Data & Filtering with SELECT

> Notebook: [`Lecture 2.sql`](Lecture%202.sql). Turns the tiny table from Lecture 1 into a realistic dataset (about 126 rows) and practices every basic way of reading it: choosing columns, paging, and filtering.

## What this lecture covers

| Concept | Syntax practiced |
|---------|------------------|
| Multi-row insert | `INSERT INTO t (cols) VALUES (...), (...), ...` |
| Projection | `SELECT name, age FROM ...` |
| Pagination | `LIMIT 10 OFFSET 20` |
| Exact filters | `WHERE name = "Arbaz Khan"`, `WHERE id = 1` |
| Boolean logic | `AND`, `OR`, `NOT` |
| Set membership | `IN (...)` |
| Patterns | `LIKE '%Arbaz%'`, `NOT LIKE` |

## How the row count grows

| After | Rows |
|-------|------|
| Start (from Lecture 1) | 3 |
| Q6: 3 more "Sameer" rows | 6 |
| Q13: 100 seeded people | 106 |
| Q23: 20 identical "Arbaz Khan" rows | 126 |

---

## Query-by-query walkthrough

Every statement below is one cell in [`Lecture 2.sql`](Lecture%202.sql). The `-- Q<n>` comment at the top of each cell matches the number here.

### Connect and inspect

**Q1**

```sql
SHOW DATABASES;
```

Lists all databases on the server, to confirm `maqbool` is there.

**Q2**

```sql
use maqbool;
```

Selects `maqbool` as the default schema for the rest of the session.

**Q3**

```sql
show TABLES;
```

Lists the tables in `maqbool`. Only `maqbool_info` exists.

**Q4**

```sql
desc maqbool_info;
```

Shows the table structure (columns, types, keys) so you know which columns to insert into.

**Q5**

```sql
SELECT * FROM maqbool_info;
```

Shows the current data: 3 rows (two *Arbaz*, one *Maqbool*) left over from Lecture 1.

### Insert a few rows and pick columns

**Q6**

```sql
INSERT INTO maqbool_info(name,age,gender,is_student,phone_number) VALUES("Sameer",23,"male",True,+9125349534545),("Sameeruddin",23,"male",True,+9125349534545),("Sam",23,"male",True,+9125349534545);
```

A multi-row insert of three "Sameer" variants. Two things to notice:
- The strings use **double quotes** (`"Sameer"`). MySQL accepts that by default, but standard SQL (and MySQL in `ANSI_QUOTES` mode) treats double quotes as identifiers. Single quotes `'...'` are the portable choice.
- The phone `+9125349534545` is again **unquoted**, so it is stored as the number `9125349534545` and the `+` is lost (the same trap as Lecture 1).

**Q7**

```sql
SELECT * from maqbool_info;
```

Checks the table: 6 rows now.

**Q8**

```sql
SELECT name,age FROM maqbool_info;
```

Projection: only the `name` and `age` columns.

**Q9**

```sql
SELECT name,gender from maqbool_info;
```

Projection: `name` and `gender`.

**Q10**

```sql
SELECT gender,phone_number from maqbool_info;
```

Projection: `gender` and `phone_number`. Column order in the result follows the order you write them.

**Q11**

```sql
SELECT name FROM maqbool_info;
```

Projection: a single column.

**Q12**

```sql
SELECT * from maqbool_info;
```

Back to all columns.

### Bulk seed 100 people

**Q13**

```sql
INSERT INTO maqbool_info (name, age, gender, is_student, phone_number) VALUES
('Aarav Sharma', 22, 'Male', TRUE, '9876543210'),
('Priya Patel', 19, 'Female', TRUE, '9876543211'),
('Rohan Gupta', 35, 'Male', FALSE, '9876543212'),
('Sneha Reddy', 28, 'Female', FALSE, '9876543213'),
-- ... 94 more lines (see the .sql file) ...
('Ishan Khurana', 23, 'Male', TRUE, '9876543308'),
('Padma Sundaresan', 55, 'Female', FALSE, '9876543309');
```

**Bulk seed**: 100 realistic people inserted with one `INSERT` (*100 rows affected*). This time the phone numbers are quoted strings (`'9876543210'`), which is the correct way. Gender is capitalised here (`'Male'`, `'Female'`) while earlier rows use lowercase. With MySQL's default case-insensitive collation, `WHERE gender = 'male'` still matches both.

**Q14**

```sql
SELECT * from maqbool_info;
```

Shows all rows: 106.

### Pagination with LIMIT / OFFSET

**Q15**

```sql
SELECT * FROM maqbool_info LIMIT 10 OFFSET 0;
```

**Pagination**: `LIMIT 10` returns at most 10 rows, and `OFFSET 0` skips none. This is page 1.

**Q16**

```sql
SELECT * FROM maqbool_info LIMIT 10 OFFSET 0;
```

Same query as Q15, run again.

**Q17**

```sql
SELECT * FROM maqbool_info;
```

All rows again, for comparison with the paged results.

**Q18**

```sql
SELECT * FROM maqbool_info LIMIT 10 OFFSET 0;
```

Page 1 (rows 1–10).

**Q19**

```sql
SELECT * FROM maqbool_info LIMIT 10 OFFSET 10;
```

Page 2: `OFFSET 10` skips the first 10 rows and returns rows 11–20. The general formula is `OFFSET = (page - 1) * page_size`.

**Q20**

```sql
SELECT * FROM maqbool_info LIMIT 10 OFFSET 20;
```

Page 3: rows 21–30.

**Q21**

```sql
SELECT * FROM maqbool_info LIMIT 10 OFFSET 30;
```

Page 4: rows 31–40.

Without `ORDER BY`, MySQL doesn't promise any particular order, so pages can in theory shift between runs. Real pagination should always add an `ORDER BY` (for example `ORDER BY id`), which Lecture 3 introduces.

### Filtering by exact name (WHERE =)

**Q22**

```sql
SELECT * FROM maqbool_info where name="Arbaz" LIMIT 10 OFFSET 0;
```

Filters with `WHERE name = "Arbaz"`, combined with paging. `=` is an exact match, so it finds only the 2 rows named exactly *Arbaz*.

**Q23**

```sql
INSERT INTO maqbool_info (name, age, gender, is_student, phone_number) VALUES
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
-- ... 14 more lines (see the .sql file) ...
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210');
```

Inserts **20 identical "Arbaz Khan" rows** on purpose. With no unique constraint on name or phone, the database accepts exact duplicates (only `id` differs). This creates data for practicing filters, and later for duplicate detection in Lecture 4. The table now has 126 rows.

**Q24**

```sql
SELECT * FROM maqbool_info;
```

Shows all 126 rows.

**Q25**

```sql
SELECT * FROM maqbool_info WHERE name="Arbaz Khan" LIMIT 10 OFFSET 0;
```

Exact-name filter plus paging: the first 10 of the 20 *Arbaz Khan* rows.

**Q26**

```sql
SELECT * FROM maqbool_info WHERE name="Arbaz";
```

Exact match on `"Arbaz"`: still 2 rows. "Arbaz Khan" doesn't match because `=` compares the whole string.

*Fixed while converting:* this statement had no closing `;` in the original notebook, so it would have merged with the next statement. The semicolon was added.

**Q27**

```sql
SELECT * FROM maqbool_info;
```

All rows again.

**Q28**

```sql
SELECT * FROM maqbool_info WHERE name="Arbaz Khan" LIMIT 10 OFFSET 0;
```

Page 1 of the *Arbaz Khan* rows (rows 1–10 of 20).

**Q29**

```sql
SELECT * FROM maqbool_info WHERE name="Arbaz Khan" LIMIT 10 OFFSET 10;
```

Page 2 of the *Arbaz Khan* rows (rows 11–20).

### Combining conditions with AND / OR

**Q30**

```sql
SELECT * FROM maqbool_info WHERE name="Arbaz Khan" AND gender="male" LIMIT 10 OFFSET 0;
```

`AND`: both conditions must be true. The rows are named *Arbaz Khan* **and** have gender `"male"`. The stored value is `'Male'`, but the default collation is case-insensitive, so it matches. 10 rows (page 1).

**Q31**

```sql
SELECT * FROM maqbool_info WHERE name="Arbaz Khan" AND gender="female" LIMIT 10 OFFSET 0;
```

`AND` with `gender = "female"`: no *Arbaz Khan* is female, so the result is empty.

**Q32**

```sql
SELECT * FROM maqbool_info WHERE name="Arbaz" OR gender="female" LIMIT 10 OFFSET 0;
```

`OR`: either condition can be true. Every row named *Arbaz* **plus** every female row, first 10 shown.

### Lookups by id, IN lists and NOT

**Q33**

```sql
SELECT * FROM maqbool_info WHERE id=1;
```

Looks up a single row by primary key. This is the fastest kind of lookup because it uses the primary key index.

**Q34**

```sql
SELECT * FROM maqbool_info WHERE name IN ("Arbaz","Arbaz Khan",'Esha Solanki',"Naveen Rathore");
```

`IN (...)` is shorthand for several `OR`s on the same column: `name = "Arbaz" OR name = "Arbaz Khan" OR ...`. It returns 24 rows (2 Arbaz + 20 Arbaz Khan + Esha Solanki + Naveen Rathore). Single and double quotes are mixed in the list. Both work in MySQL.

**Q35**

```sql
SELECT * FROM maqbool_info WHERE NOT name="Arbaz Khan" LIMIT 10 OFFSET 100;
```

`NOT` negates a condition: every row **except** *Arbaz Khan*. There are 106 such rows, so `OFFSET 100` skips the first 100 and the result is the last 6.

**Q36**

```sql
SELECT * FROM maqbool_info WHERE NOT name="Arbaz Khan" LIMIT 10 OFFSET 100;
```

Same query as Q35, run again.

**Q37**

```sql
SELECT * FROM maqbool_info WHERE id IN (1,23,3,4,53,2,11,5,67,4);
```

`IN` with a list of ids. The list contains `4` twice and its order doesn't matter: `IN` is a set test, so each matching row is returned once. 9 rows.

**Q38**

```sql
SELECT * FROM maqbool_info where name="Arbaz Khan";
```

Exact-name filter without paging: all 20 *Arbaz Khan* rows.

*Fixed while converting:* the original had no closing `;` here either. The semicolon was added.

### Pattern matching with LIKE

**Q39**

```sql
SELECT * FROM maqbool_info WHERE name LIKE '%Arbaz%';
```

`LIKE` does pattern matching. `%` means "any sequence of characters, including none", so `'%Arbaz%'` means "contains *Arbaz* anywhere". It matches *Arbaz* and *Arbaz Khan*: 22 rows.

**Q40**

```sql
SELECT * FROM maqbool_info WHERE name="Arbaz";
```

Exact match for comparison with Q39: only the 2 rows named exactly *Arbaz*.

**Q41**

```sql
SELECT * FROM maqbool_info WHERE name LIKE '%P%';
```

`'%P%'`: names that contain the letter P anywhere. Because the comparison is case-insensitive, this matches both `P` and `p` (for example *Priya Patel* and *Deepika Joshi*).

**Q42**

```sql
SELECT * FROM maqbool_info WHERE name NOT LIKE '%Arbaz%';
```

`NOT LIKE` returns the rows that **don't** match the pattern: everyone without *Arbaz* in their name (104 rows).

### Wrap up

**Q43**

```sql
show TABLES;
```

Lists the tables again. In the original run this failed with *No database selected* because the session had reconnected. Re-running `USE maqbool;` (Q2) fixes that.

**Q44**

```sql
desc maqbool_info;
```

Final look at the table structure.

---

## Key lessons from this lecture

1. **`=` is exact, `LIKE` is a pattern.** `name = 'Arbaz'` found 2 rows; `name LIKE '%Arbaz%'` found 22.
2. **Comparisons are case-insensitive by default.** `gender = 'male'` matches `'Male'`, and `LIKE '%P%'` matches lowercase `p` too.
3. **`LIMIT n OFFSET m` gives you pages**, but always pair it with `ORDER BY` so the pages are stable.
4. **`IN` is a cleaner `OR`.** Duplicate values in the list are ignored.
5. **Nothing prevents duplicate rows** unless you add a `UNIQUE` constraint. The 20 identical *Arbaz Khan* rows went in without complaint.
6. **Missing semicolons:** two statements (Q26 and Q38) had no `;` in the original notebook. They were fixed in the `.sql` file.

## Prerequisites & how to run

- Requires the `maqbool` schema and the `maqbool_info` table from [Lecture 1](../Lecture%201/README.md), including the `phone_number` column.
- The inserts (Q6, Q13, Q23) add rows every time you run them. Run them once, or the row counts quoted above will differ.

1. Install the **SQL Notebook** extension (publisher `cmoog`) in VS Code. See the [root README](../README.md#2-install-the-sql-notebook-extension).
2. Right-click `Lecture 2.sql`, choose **Open With…**, then **SQL Notebook**.
3. In the **SQL NOTEBOOK** sidebar panel, connect to your local MySQL server (see the root README).
4. Run cells one at a time with the ▶ button or `Ctrl+Enter`, top to bottom. Each cell holds exactly one statement.

> The cells are separated by blank lines in the `.sql` file. That is how SQL Notebook decides where one cell ends and the next begins, so don't add blank lines *inside* a statement when you edit the file.

## What comes next

[Lecture 3](../Lecture%203/README.md) combines `LIKE` with `AND` / `OR` / `NOT` and introduces sorting with `ORDER BY`.
