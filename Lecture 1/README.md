# Lecture 1: First Steps (Databases, Tables & CRUD)

> Notebook: [`Lecture 1.sql`](Lecture%201.sql). This is the very first practice session. It creates the core table in the `maqbool` schema and walks it through its whole lifecycle: **create, insert, read, update, delete, destroy**.

## What this lecture covers

| Family | Commands practiced |
|--------|--------------------|
| Navigation | `SHOW DATABASES`, `USE`, `SHOW TABLES`, `DESC` |
| DDL (structure) | `CREATE TABLE`, `ALTER TABLE ... ADD`, `TRUNCATE TABLE`, `DROP TABLE` |
| DML (data) | `INSERT` (single row and multi-row), `SELECT`, `UPDATE`, `DELETE` |

## The table built in this lecture

```sql
CREATE TABLE Maqbool_info(
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   age INT NOT NULL,
   gender VARCHAR(50) NOT NULL,
   is_student BOOLEAN DEFAULT TRUE
);
-- later: ALTER TABLE maqbool_info ADD phone_number VARCHAR(20);
```

| Column | Type | Meaning |
|--------|------|---------|
| `id` | `INT AUTO_INCREMENT PRIMARY KEY` | Unique row number that MySQL assigns automatically (1, 2, 3, ...) |
| `name` | `VARCHAR(50) NOT NULL` | Text up to 50 characters; must be provided |
| `age` | `INT NOT NULL` | Whole number; must be provided (Lecture 4 relaxes this to allow `NULL`) |
| `gender` | `VARCHAR(50) NOT NULL` | Free text |
| `is_student` | `BOOLEAN DEFAULT TRUE` | Stored as `TINYINT(1)`: `TRUE` = 1, `FALSE` = 0 |
| `phone_number` | `VARCHAR(20)` | Added later with `ALTER TABLE`; nullable |

---

## Query-by-query walkthrough

Every statement below is one cell in [`Lecture 1.sql`](Lecture%201.sql). The `-- Q<n>` comment at the top of each cell matches the number here.

### Explore the server

**Q1**

```sql
SHOW DATABASES;
```

Lists every database (schema) on the MySQL server. The saved run showed 10, including system schemas such as `mysql`, `information_schema`, `performance_schema` and `sys`, plus `maqbool`.

**Q2**

```sql
USE maqbool;
```

Makes `maqbool` the **default database** for this connection. From now on, an unqualified table name like `maqbool_info` means `maqbool.maqbool_info`. If you skip this cell, later statements fail with *Error 1046: No database selected*, which happened in the original notebook. If the schema doesn't exist yet, run `CREATE DATABASE maqbool;` first.

**Q3**

```sql
SHOW TABLES;
```

Lists the tables inside the current database. At this point it returns nothing because `maqbool` is still empty.

### Create the table

**Q4**

```sql
CREATE TABLE Maqbool_info(
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   age INT NOT NULL,
   gender VARCHAR(50) NOT NULL,
   is_student BOOLEAN DEFAULT TRUE
);
```

Creates the table. Each column definition is *name + data type + constraints*:
- `id INT AUTO_INCREMENT PRIMARY KEY`: the primary key uniquely identifies each row, and `AUTO_INCREMENT` lets MySQL generate the next number, so you never insert `id` yourself.
- `NOT NULL` means the column must always have a value.
- `BOOLEAN DEFAULT TRUE`: if an insert doesn't mention `is_student`, it becomes `TRUE` (1).

Note that the table is created as `Maqbool_info` but used everywhere else as `maqbool_info`. That works on Windows, where MySQL stores table names in lowercase (`lower_case_table_names=1`). On Linux, table names are case-sensitive and the mismatch would fail.

**Q5**

```sql
show TABLES;
```

Runs `SHOW TABLES` again to confirm that `maqbool_info` now exists. SQL keywords are case-insensitive, so `show TABLES` and `SHOW TABLES` are the same.

**Q6**

```sql
DESC maqbool_info;
```

`DESC` (short for `DESCRIBE`) shows the table's structure: each column's **Field**, **Type**, whether it allows **Null**, its **Key** (`PRI` = primary key), its **Default**, and **Extra** (`auto_increment`).

**Q7**

```sql
ALTER TABLE maqbool_info ADD phone_number VARCHAR(20);
```

Adds a new column `phone_number` (text, up to 20 characters) at the end of the table. Existing rows get `NULL` in the new column. This shows that a schema can change after the table is created.

`ALTER TABLE ... ADD` can't be repeated: running it a second time gives *Error 1060: Duplicate column name 'phone_number'*, which you can see in the original saved output.

**Q8**

```sql
DESC maqbool_info;
```

Describes the table again. `phone_number` is now listed as the last column.

### Insert and read rows

**Q9**

```sql
SELECT * from maqbool_info;
```

`SELECT *` returns every column of every row. The table is still empty, so the result is an empty set.

**Q10**

```sql
INSERT INTO maqbool_info(
name,
age,
gender,
is_student,
phone_number
)
VALUES('Arbaz',23,'male',False,+91345376898932);
```

Inserts **one row**. The column list `(name, age, gender, is_student, phone_number)` says which columns the values map to, in order. `id` is left out because `AUTO_INCREMENT` fills it in (it becomes 1).

**Watch out:** the phone number `+91345376898932` is written *without quotes*. MySQL treats it as a number (unary `+`), so the leading `+` is lost and `91345376898932` is stored. Always quote phone numbers, pincodes and IDs: they are text, not numbers. `False` is stored as `0`.

**Q11**

```sql
SELECT * FROM maqbool_info;
```

Reads the table back. One row: `id = 1, Arbaz, 23, male, 0, 91345376898932`.

**Q12**

```sql
INSERT INTO maqbool_info(
name,
age,
gender,
is_student,
phone_number
)
VALUES('Arbaz',23,'male',False,+91345376898932),('Maqbool',20,'male',False,'+9142354543');
```

A **multi-row insert**: several value tuples separated by commas in one statement, which is faster than separate inserts. It adds a second *Arbaz* (nothing stops duplicate names, since only `id` is unique) and *Maqbool*. Maqbool's phone is quoted (`'+9142354543'`), so the `+` is kept.

**Q13**

```sql
SELECT * FROM maqbool_info;
```

Shows all rows: ids 1, 2 and 3.

**Q14**

```sql
SELECT id,name,age FROM maqbool_info;
```

**Projection**: listing column names instead of `*` returns only those columns (`id, name, age`). Selecting only the columns you need is clearer and moves less data.

### Delete and re-insert

**Q15**

```sql
DELETE FROM maqbool_info WHERE id='3';
```

Deletes the row whose `id` is 3 (Maqbool). The `WHERE` clause decides which rows are removed; **a `DELETE` without `WHERE` empties the whole table**. `'3'` is a string compared to an integer column, so MySQL converts it automatically. Writing `id = 3` is cleaner.

**Q16**

```sql
SELECT * FROM maqbool_info;
```

Checks the result: row 3 is gone.

**Q17**

```sql
INSERT INTO maqbool_info(
name,
age,
gender,
is_student,
phone_number
)
VALUES('Arbaz',23,'male',False,+91345376898932),('Maqbool',20,'male',False,'+9142354543');
```

Inserts the same two rows again. They get ids **4 and 5**, not 3: `AUTO_INCREMENT` never reuses a number, even after the row that had it is deleted.

**Q18**

```sql
SELECT * FROM maqbool_info;
```

Shows the table with the new rows.

**Q19**

```sql
DELETE FROM maqbool_info WHERE name='Maqbool';
```

Deletes **every** row whose name is `'Maqbool'`. Names are not unique, so this can remove more rows than you intended. To delete exactly one row, filter by the primary key (`WHERE id = ...`).

**Q20**

```sql
SELECT * FROM maqbool_info;
```

Checks that no Maqbool rows remain.

### Update rows

**Q21**

```sql
UPDATE maqbool_info SET age=32 WHERE id='2';
```

`UPDATE` changes existing data: `SET age = 32` for the row with `id = 2` only. Filtering by the primary key guarantees a single row is touched.

**Q22**

```sql
SELECT name, age, gender FROM maqbool_info;
```

Projection of three columns to check the update.

**Q23**

```sql
SELECT id,name, age, gender FROM maqbool_info;
```

The same check, with `id` added so you can see which row changed.

**Q24**

```sql
UPDATE maqbool_info SET age=32 WHERE name='Arbaz';
```

Updates **all** rows named `'Arbaz'` in one go (the saved run reports *5 rows affected*). Like `DELETE`, an `UPDATE` without a precise `WHERE` can change far more than you meant; with no `WHERE` at all it changes every row.

**Q25**

```sql
SELECT id,name, age, gender FROM maqbool_info;
```

Checks that every Arbaz now has age 32.

### Empty and remove the table

**Q26**

```sql
TRUNCATE TABLE maqbool_info;
```

`TRUNCATE TABLE` removes **all rows** quickly and resets the `AUTO_INCREMENT` counter to 1, but **keeps the table structure**. It is DDL, so it can't be rolled back inside a transaction (unlike `DELETE FROM maqbool_info;`).

**Q27**

```sql
SELECT * FROM maqbool_info;
```

Confirms the table still exists but is empty.

**Q28**

```sql
DROP TABLE maqbool_info;
```

`DROP TABLE` deletes the table itself: its structure, data, indexes, everything. It is permanent.

**Q29**

```sql
SHOW TABLES;
```

`SHOW TABLES` returns nothing again: we are back where we started.

---

## Key lessons from this lecture

1. **Quote phone numbers.** `+91345376898932` without quotes became the number `91345376898932`. Phones, pincodes and ID numbers are strings.
2. **`DELETE` / `UPDATE` by name hit every match.** Names aren't unique. Use the primary key (`WHERE id = 3`) when you mean one row.
3. **`AUTO_INCREMENT` never reuses ids.** After deleting id 3, the next rows got 4 and 5.
4. **`TRUNCATE` vs `DROP`.** `TRUNCATE` empties the table and keeps its structure; `DROP` removes the table completely.
5. **`ALTER TABLE ... ADD` can't run twice.** The second run fails with *Duplicate column name*.

## Prerequisites & how to run

- MySQL Server 8 running locally. The notebook works in the `maqbool` schema, so run `CREATE DATABASE maqbool;` first if it doesn't exist.
- **Before Lecture 2:** Q26–Q28 empty and then drop the table. Lecture 2 expects `maqbool_info` to exist with its first rows, so either stop after Q25, or re-run Q4 and Q7 (create the table and add `phone_number`) and the inserts afterwards.

1. Install the **SQL Notebook** extension (publisher `cmoog`) in VS Code. See the [root README](../README.md#2-install-the-sql-notebook-extension).
2. Right-click `Lecture 1.sql`, choose **Open With…**, then **SQL Notebook**.
3. In the **SQL NOTEBOOK** sidebar panel, connect to your local MySQL server (see the root README).
4. Run cells one at a time with the ▶ button or `Ctrl+Enter`, top to bottom. Each cell holds exactly one statement.

> The cells are separated by blank lines in the `.sql` file. That is how SQL Notebook decides where one cell ends and the next begins, so don't add blank lines *inside* a statement when you edit the file.

## What comes next

[Lecture 2](../Lecture%202/README.md) seeds about 120 realistic people into this table and starts serious `SELECT` work: filtering, `LIKE`, `IN` and pagination.
