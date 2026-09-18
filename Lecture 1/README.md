# Lecture 1 — First Steps: Databases, Tables & CRUD

> Notebook: `Lecture 1.mysql-notebook` — the very first practice session. Creates the `maqbool` schema's core table and walks through the complete lifecycle of a table: create → insert → read → update → destroy.

---

## What this lecture covers

| Family | Commands practiced |
|--------|--------------------|
| Navigation | `SHOW DATABASES`, `USE`, `SHOW TABLES`, `DESC` |
| DDL | `CREATE TABLE`, `ALTER TABLE ... ADD`, `TRUNCATE TABLE`, `DROP TABLE` |
| DML | `INSERT` (single row + multi-row), `SELECT`, `UPDATE`, `DELETE` |

## The table built in this lecture

```sql
CREATE TABLE Maqbool_info(
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   age INT NOT NULL,
   gender VARCHAR(50) NOT NULL,
   is_student BOOLEAN DEFAULT TRUE
);
```

Later in the notebook a phone column is added to prove that **schemas evolve**:

```sql
ALTER TABLE maqbool_info ADD phone_number VARCHAR(20);
```

## Key lessons hidden in this notebook

1. **Unquoted phone numbers lose characters.** The insert `VALUES(..., +91345376898932)` was written *without* quotes — MySQL evaluated the `+` as arithmetic and stored `91345376898932`. The leading `+` vanished. Phones, pincodes and ID numbers are strings — always quote them.
2. **DELETE by name is dangerous.** `DELETE FROM maqbool_info WHERE name='Maqbool';` removed *every* row named Maqbool at once, because names are not unique. Delete by primary key (`WHERE id = 3`) when you mean one row.
3. **UPDATE has the same trap.** `UPDATE ... SET age=32 WHERE name='Arbaz'` hit every Arbaz in the table in one shot.
4. **`TRUNCATE` vs `DROP`.** `TRUNCATE TABLE` empties all rows but keeps the table shell (and resets `AUTO_INCREMENT`); `DROP TABLE` deletes the table itself — after it, `SHOW TABLES` comes back empty.

## Prerequisites & how to run

- MySQL Server 8 running locally, and the **MySQL Shell for VS Code** extension — see the [root README](../README.md) for setup.
- The notebook creates the `maqbool_info` table inside the `maqbool` schema, so run `CREATE DATABASE maqbool; USE maqbool;` first if the schema doesn't exist.
- Run cells top-to-bottom with `Ctrl+Enter` (single statement) or the cell ▶ button.

## What comes next

Lecture 2 seeds ~127 realistic people into this table and starts serious `SELECT` work: filtering, `LIKE`, `IN` and pagination.
