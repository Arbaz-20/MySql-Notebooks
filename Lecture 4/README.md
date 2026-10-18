# Lecture 4: Aggregates, GROUP BY / HAVING & Transactions

> Notebook: [`Lecture 4.sql`](Lecture%204.sql). Moves from listing rows to **summarising** them, shows how `NULL` changes the numbers, finds duplicates, and finishes with transactions, the safety net for risky updates.

## What this lecture covers

| Concept | Syntax practiced |
|---------|------------------|
| Counting | `COUNT(*)`, `COUNT(column)`, `COUNT(DISTINCT column)` |
| Other aggregates | `SUM`, `MIN`, `MAX`, `AVG`, `SUM(DISTINCT ...)` |
| Aliases | `AS total_age` |
| Schema changes | `ALTER TABLE ... MODIFY COLUMN`, `ADD COLUMN ... DEFAULT CURRENT_TIMESTAMP`, `ON UPDATE CURRENT_TIMESTAMP` |
| Grouping | `GROUP BY`, `HAVING COUNT(*) > 1`, `ANY_VALUE()` |
| Subqueries | `WHERE name IN (SELECT ... GROUP BY ... HAVING ...)` |
| Transactions | `START TRANSACTION`, `ROLLBACK`, `COMMIT` |

## Numbers from the saved run

| Query | Result | Why |
|-------|--------|-----|
| `COUNT(*)` | 127 | every row |
| `COUNT(age)` | 123 | the 4 `NULL` ages are skipped |
| `COUNT(DISTINCT age)` | 38 | distinct non-NULL ages |
| `SUM(age)` | 3378 | NULLs ignored |
| `AVG(age)` | 27.4634 | 3378 / **123** |
| `SUM(age) / COUNT(gender)` | 26.5984 | 3378 / **127**, which is *not* the average |

---

## Query-by-query walkthrough

Every statement below is one cell in [`Lecture 4.sql`](Lecture%204.sql). The `-- Q<n>` comment at the top of each cell matches the number here.

### Setup

**Q1**

```sql
SHOW DATABASES;
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

Lists its tables.

**Q4**

```sql
desc maqbool_info;
```

Shows the table structure. Note that `age` is still `NOT NULL` at this point.

### COUNT basics

**Q5**

```sql
SELECT COUNT(*) from maqbool_info;
```

`COUNT(*)` counts **rows**, whatever their values are. 126 rows.

**Q6**

```sql
SELECT COUNT(*) FROM maqbool_info WHERE name LIKE 'Arbaz%';
```

Counts only the rows that pass the `WHERE`: names starting with Arbaz, so 22. `WHERE` filters first, then `COUNT` counts what's left.

**Q7**

```sql
SELECT * FROM maqbool_info where name like 'Arbaz%';
```

Lists those 22 rows to double-check the count.

**Q8**

```sql
SELECT COUNT(age > 22) from maqbool_info;
```

**Trap:** `COUNT(age > 22)` returns **126**, not the number of people older than 22. `age > 22` evaluates to 1 or 0 for every row, and `COUNT` counts every non-NULL value, so 0s are counted too. Correct alternatives:
```sql
SELECT COUNT(*) FROM maqbool_info WHERE age > 22;
SELECT SUM(age > 22) FROM maqbool_info;   -- adds up the 1s
```

**Q9**

```sql
SELECT COUNT(*) FROM maqbool_info WHERE name like 'Arbaz%';
```

Same as Q6 (`like` is case-insensitive as a keyword): 22.

**Q10**

```sql
SELECT COUNT(age) FROM maqbool_info;
```

`COUNT(age)` counts rows where `age` **is not NULL**. No ages are NULL yet, so it equals `COUNT(*)`: 126.

**Q11**

```sql
SELECT COUNT(*) FROM maqbool_info;
```

`COUNT(*)` again, as the baseline before the next change.

### Allowing NULL ages (and how COUNT reacts)

**Q12**

```sql
ALTER TABLE maqbool_info MODIFY COLUMN age int DEFAULT NULL;
```

`MODIFY COLUMN` redefines an existing column. Here `age` becomes `INT DEFAULT NULL`, which removes the `NOT NULL` rule so an unknown age can be stored as `NULL`. `MODIFY` replaces the whole definition, so anything you don't repeat (like `NOT NULL`) is dropped.

**Q13**

```sql
SELECT * FROM maqbool_info;
```

Views the data after the change. No values changed, only the rule.

**Q14**

```sql
DESC maqbool_info;
```

`DESC` now shows `Null = YES` for `age`.

**Q15**

```sql
UPDATE maqbool_info SET age=null where age=0;
```

Turns placeholder ages of `0` into real `NULL`s, meaning "unknown". The saved run reports *4 rows affected*. Note the syntax: you **set** a value to NULL with `= null`, but you **test** for it with `IS NULL` (`WHERE age = NULL` never matches anything).

**Q16**

```sql
SELECT * FROM maqbool_info;
```

Views the data: the 4 ages now show `NULL`.

**Q17**

```sql
SELECT COUNT(*) from maqbool_info;
```

`COUNT(*)` still returns 126: rows are rows, NULL or not.

**Q18**

```sql
SELECT COUNT(age) from maqbool_info;
```

`COUNT(age)` returns **122**: the 4 NULL ages are skipped. This difference between `COUNT(*)` and `COUNT(column)` is the key lesson of this section.

**Q19**

```sql
SELECT COUNT(gender) from maqbool_info;
```

`COUNT(gender)` returns 126: gender has no NULLs.

### Audit timestamp columns

**Q20**

```sql
ALTER TABLE maqbool_info ADD COLUMN createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
```

Adds an audit column `createdAt` that is filled automatically with the insert time (`DEFAULT CURRENT_TIMESTAMP`). Existing rows get the time of the `ALTER`. In the saved run this failed with *Duplicate column name 'createdAt'* because the column had already been added earlier.

**Q21**

```sql
ALTER TABLE maqbool_info MODIFY COLUMN updatedAT TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
```

Defines `updatedAt` as `DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`, so MySQL refreshes the timestamp **every time the row is updated**. Together with `createdAt`, this is the standard "created / last modified" pair. `MODIFY` only works on a column that already exists; to create it, use `ADD COLUMN updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`.

**Q22**

```sql
SELECT * FROM maqbool_info;
```

Shows the table with the two timestamp columns. The saved output has 127 rows here: one more row had been added outside the notebook.

### COUNT variations and aliases

**Q23**

```sql
SELECT COUNT(*) from maqbool_info;
```

`COUNT(*)` returns 127.

**Q24**

```sql
SELECT COUNT(*) as total_age from maqbool_info;
```

`AS total_age` gives the result column a readable name (an **alias**). The name is misleading here: this counts *rows*, not ages. Pick aliases that describe the value.

**Q25**

```sql
SELECT COUNT(Distinct age) from maqbool_info;
```

`COUNT(DISTINCT age)` counts **unique** non-NULL ages: 38 different ages among 127 people.

**Q26**

```sql
SELECT COUNT(age) as total_age , COUNT(gender) as gender_info from maqbool_info;
```

Two aggregates in one query, each with an alias: `COUNT(age)` = 123 and `COUNT(gender)` = 127.

### SUM / MIN / MAX / AVG

**Q27**

```sql
SELECT SUM(age) FROM maqbool_info;
```

`SUM(age)` adds up all non-NULL ages: 3378.

**Q28**

```sql
SELECT SUM(distinct age) from maqbool_info;
```

`SUM(DISTINCT age)` adds each distinct age **once**: 1277. Rarely useful in practice, but it shows that `DISTINCT` works inside any aggregate.

**Q29**

```sql
select MIN(age) as minimum_age from maqbool_info;
```

`MIN(age)`: the youngest person is 15. NULLs are ignored.

**Q30**

```sql
SELECT Max(age) as maximum_age from maqbool_info;
```

`MAX(age)`: the oldest person is 55. Function names are case-insensitive (`Max` = `MAX`).

**Q31**

```sql
SELECT AVG(age) from maqbool_info;
```

`AVG(age)` = 27.4634, which is `SUM(age) / COUNT(age)` = 3378 / 123. **AVG ignores NULLs** in both the sum and the count.

### Arithmetic on aggregates

**Q32**

```sql
SELECT SUM(age) + COUNT(gender) FROM maqbool_info;
```

Aggregates are just numbers, so you can do arithmetic with them: 3378 + 127 = 3505.

**Q33**

```sql
SELECT SUM(age) - COUNT(gender) FROM maqbool_info;
```

Subtraction: 3378 − 127 = 3251.

**Q34**

```sql
SELECT SUM(age) * COUNT(gender) FROM maqbool_info;
```

Multiplication: 3378 × 127 = 429006.

**Q35**

```sql
SELECT SUM(age) % COUNT(gender) FROM maqbool_info;
```

`%` is modulo (the remainder): 3378 mod 127 = 76.

**Q36**

```sql
SELECT SUM(age) / COUNT(gender) FROM maqbool_info;
```

Division: 3378 / 127 = 26.5984. Compare it with `AVG(age)` = 27.4634 in Q31. Dividing by `COUNT(gender)` (127 rows) instead of `COUNT(age)` (123 non-NULL ages) gives the **wrong average**. Use `AVG()`, or divide by the count of the same column.

### GROUP BY + HAVING: finding duplicate names

**Q37**

```sql
SELECT name from maqbool_info GROUP BY name HAVING COUNT(*) > 1;
```

**Finding duplicates.** `GROUP BY name` puts rows with the same name in one group, and `HAVING COUNT(*) > 1` keeps only groups with more than one row. Result: *Arbaz*, *Preeti Dhawan*, *Arbaz Ayub khan*.

`WHERE` filters **rows before** grouping; `HAVING` filters **groups after** grouping, which is why aggregates like `COUNT(*)` can only appear in `HAVING`.

**Q38**

```sql
SELECT name as user_name from maqbool_info GROUP BY name HAVING COUNT(*) > 1;
```

The same query with an alias on the output column (`user_name`).

**Q39**

```sql
SELECT ANY_VALUE(id) as id,ANY_VALUE(name) as user_name , ANY_VALUE(age) as user_age , ANY_VALUE(gender) as gender FROM maqbool_info GROUP BY name HAVING COUNT(*) > 1;
```

With `ONLY_FULL_GROUP_BY` (the default in MySQL 8), every selected column must either be in the `GROUP BY` or be aggregated. `ANY_VALUE(col)` tells MySQL "any value from the group is fine", so you can show one sample `id`, `age` and `gender` per duplicate name. Result: one row per duplicated name (ids 1, 92, 107).

**Q40**

```sql
SELECT name,age,gender from maqbool_info GROUP BY name,age,gender HAVING COUNT(*) > 0;
```

Groups by the combination `name, age, gender`. `HAVING COUNT(*) > 0` is always true, because every group has at least one row, so this returns each distinct combination once (108 rows). That is the same as `SELECT DISTINCT name, age, gender`.

**Q41**

```sql
SELECT name,age,gender,is_student FROM maqbool_info where name IN(Select name from maqbool_info GROUP BY name HAVING COUNT(*) > 0);
```

A **subquery**: the inner `SELECT` builds a list of names, and the outer query returns the rows whose name is in that list. Because the inner query uses `> 0`, it returns *every* name, so the outer query returns all 127 rows. Change it to `> 1` to list only the people with duplicated names.

### Bulk updates with LIKE

**Q42**

```sql
UPDATE maqbool_info set age=23 where name like 'Arbaz%';
```

A bulk `UPDATE` driven by a pattern: everyone whose name starts with Arbaz gets age 23. The saved run reports *21 rows affected* (22 matched, and one already had age 23, so MySQL didn't count it as changed).

**Q43**

```sql
SELECT * from maqbool_info WHERE name like 'Arbaz%';
```

Checks the update.

**Q44**

```sql
UPDATE maqbool_info set age=22 where name like '%Arbaz Ayub khan%';
```

Updates only the rows whose name contains `Arbaz Ayub khan`, setting their age to 22.

**Q45**

```sql
SELECT * from maqbool_info where name like 'Arbaz%';
```

Checks the result.

### Transactions: START TRANSACTION / ROLLBACK / COMMIT

**Q46**

```sql
start TRANSACTION;
```

**`START TRANSACTION`** opens a transaction. Until you `COMMIT`, your changes are provisional: visible to your own session, and they can be undone.

**Q47**

```sql
update maqbool_info set age=23 WHERE name like 'Arbaz%';
```

Updates 20 rows *inside* the transaction.

**Q48**

```sql
SELECT * FROM maqbool_info WHERE name like 'Arbaz%';
```

Your own session already sees the new ages.

**Q49**

```sql
rollback;
```

**`ROLLBACK`** throws away every change since `START TRANSACTION`. The 20-row update is undone.

**Q50**

```sql
SELECT * FROM maqbool_info WHERE name like 'Arbaz%';
```

Checks: the ages are back to their values before the transaction.

**Q51**

```sql
update maqbool_info set age=23 WHERE name like 'Arbaz%';
```

The same `UPDATE`, but **without** `START TRANSACTION`. MySQL runs in **autocommit** mode by default, so a statement outside a transaction is saved permanently as soon as it finishes.

**Q52**

```sql
SELECT * from maqbool_info where name like 'Arbaz%';
```

Shows the updated ages.

**Q53**

```sql
COMMIT;
```

`COMMIT` with no open transaction does nothing. The change was already saved by autocommit.

**Q54**

```sql
SELECT * from maqbool_info where name like 'Arbaz%';
```

Shows the same data.

**Q55**

```sql
ROLLBACK;
```

`ROLLBACK` here **can't undo Q51**: there's no open transaction, and autocommit has already saved it. This is why risky updates should always be wrapped in `START TRANSACTION`.

**Q56**

```sql
SELECT * from maqbool_info where name like 'Arbaz%';
```

Checks: the ages from Q51 are still there.

**Q57**

```sql
START TRANSACTION;
```

Opens a new transaction.

**Q58**

```sql
UPDATE maqbool_info set name="Arbaz khan" where name="Arbaz Ayub khan";
```

Renames the 20 *Arbaz Ayub khan* rows to *Arbaz khan*, inside the transaction.

**Q59**

```sql
SELECT * FROM maqbool_info;
```

Shows the renamed rows (visible only in this session).

**Q60**

```sql
ROLLBACK;
```

`ROLLBACK`: the rename is undone.

**Q61**

```sql
SELECT * from maqbool_info;
```

Checks: the original names are back.

**Q62**

```sql
UPDATE maqbool_info set name="Arbaz khan" where name='Arbaz';
```

An autocommitted rename: the 2 rows named exactly *Arbaz* become *Arbaz khan* permanently.

**Q63**

```sql
SELECT * from maqbool_info where id IN (1,2);
```

Checks rows 1 and 2.

**Q64**

```sql
COMMIT;
```

`COMMIT` with no open transaction: a no-op again.

### Names that appear only once

**Q65**

```sql
SELECT name,age,gender,is_student from maqbool_info where NOT name IN(select name from maqbool_info GROUP BY name  HAVING COUNT(*) > 1);
```

The opposite of Q41: `NOT name IN (names that appear more than once)` returns people whose name is **unique** in the table (103 rows). `NOT name IN (...)` is the same as `name NOT IN (...)`.

Careful: if the subquery ever returns a `NULL`, `NOT IN` matches nothing at all. `NOT EXISTS` is the safer pattern when NULLs are possible.

---

## Key lessons from this lecture

1. **`COUNT(*)` counts rows; `COUNT(col)` counts non-NULL values.** 127 vs 123 here.
2. **`COUNT(condition)` is a trap.** It counts the 0s too. Use `WHERE` or `SUM(condition)`.
3. **`AVG` ignores NULLs.** Dividing `SUM` by the wrong count gives the wrong average (26.60 vs 27.46).
4. **`WHERE` filters rows, `HAVING` filters groups.** `GROUP BY ... HAVING COUNT(*) > 1` is the classic way to find duplicates.
5. **Autocommit makes every statement permanent**, unless you first run `START TRANSACTION`. `ROLLBACK` only undoes changes made since `START TRANSACTION`.
6. **`ON UPDATE CURRENT_TIMESTAMP`** gives you a "last modified" column for free.

## Prerequisites & how to run

- Requires `maqbool_info` with the data from [Lecture 2](../Lecture%202/README.md).
- Q12, Q20 and Q21 change the table structure, and Q15 and the `UPDATE`s change data. Q20 fails with *Duplicate column name* if `createdAt` already exists. That's expected; just move on.
- Q21 assumes an `updatedAt` column already exists. If it doesn't, create it with `ALTER TABLE maqbool_info ADD COLUMN updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;`. Lecture 7 inserts into it.

1. Install the **SQL Notebook** extension (publisher `cmoog`) in VS Code. See the [root README](../README.md#2-install-the-sql-notebook-extension).
2. Right-click `Lecture 4.sql`, choose **Open With…**, then **SQL Notebook**.
3. In the **SQL NOTEBOOK** sidebar panel, connect to your local MySQL server (see the root README).
4. Run cells one at a time with the ▶ button or `Ctrl+Enter`, top to bottom. Each cell holds exactly one statement.

> The cells are separated by blank lines in the `.sql` file. That is how SQL Notebook decides where one cell ends and the next begins, so don't add blank lines *inside* a statement when you edit the file.

## What comes next

[Lecture 5](../Lecture%205/README.md) adds a second table, `orders`, generates 500 rows of test data with a recursive CTE, and introduces joins.
