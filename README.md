# MySQL Notebooks: Practice Repository

A collection of MySQL lecture notebooks. Each lecture is a plain **`.sql` file** that opens as a notebook in VS Code with the **SQL Notebook** extension, with **one query per cell**, so you can run the queries one at a time and see each result table inline.

This README explains how to install the extension, connect to a MySQL server, open the `.sql` notebooks, and run them.

---

## Table of Contents

1. [What's in this repo](#whats-in-this-repo)
2. [Prerequisites](#prerequisites)
3. [Install MySQL Server](#1-install-mysql-server)
4. [Install the SQL Notebook extension](#2-install-the-sql-notebook-extension)
5. [Create a database connection](#3-create-a-database-connection)
6. [Open a lecture as a notebook](#4-open-a-lecture-as-a-notebook)
7. [Running queries](#5-running-queries)
8. [How the .sql files are structured](#6-how-the-sql-files-are-structured)
9. [Troubleshooting](#7-troubleshooting)

---

## What's in this repo

Each lecture lives in its own folder with its notebook (`Lecture N.sql`) and a `README.md` that explains **every query** in that notebook (the `-- Q<n>` tag in each cell matches the numbering in the README):

| Folder | Queries | Topics |
|--------|---------|--------|
| [Lecture 1](Lecture%201/README.md) | 29 | `CREATE TABLE`, `INSERT`, `SELECT`, `UPDATE`, `DELETE`, `ALTER`, `TRUNCATE`, `DROP` |
| [Lecture 2](Lecture%202/README.md) | 44 | Bulk seeding (about 126 rows), projection, `WHERE`, `AND`/`OR`/`NOT`, `IN`, `LIKE`, `LIMIT`/`OFFSET` |
| [Lecture 3](Lecture%203/README.md) | 17 | Prefix `LIKE` combined with `AND`/`OR`/`NOT LIKE`, `ORDER BY`, filter + sort + page |
| [Lecture 4](Lecture%204/README.md) | 65 | `COUNT`/`SUM`/`MIN`/`MAX`/`AVG` and `NULL`, `GROUP BY`, `HAVING`, `ANY_VALUE`, transactions |
| [Lecture 5](Lecture%205/README.md) | 50 | Subqueries, `orders` table, recursive-CTE data generation, `INNER`/`LEFT`/`RIGHT` joins, `UNION` |
| [Lecture 6](Lecture%206/README.md) | 51 | `address` table, foreign keys, three-table joins, `EXPLAIN`, indexes, first view |
| [Lecture 7](Lecture%207/README.md) | 46 | Views over joins, CTE, many-to-many, `CASE` reporting, `IFNULL` |

```
MySql Notebooks/
├── Lecture 1/
│   ├── Lecture 1.sql               # open with SQL Notebook
│   └── README.md                   # query-by-query explanation
├── Lecture 2/ ... Lecture 7/       # same layout
├── docs/
│   ├── SQL-Masterclass.html        # full written guide (16 chapters + 3 projects)
│   └── SQL-Masterclass.pdf         # same guide as PDF
└── README.md
```

These notebooks were originally written in the MySQL Shell for VS Code format (`.mysql-notebook`) and converted to `.sql`. Row counts and errors quoted as "the saved run" in the lecture READMEs come from those original runs. The old files, with their saved results, are still in the git history (commit `ed34e1e` and earlier).

---

## Prerequisites

| Tool | Purpose | Download |
|------|---------|----------|
| **VS Code** | Editor | https://code.visualstudio.com/ |
| **MySQL Server 8.0+** | The database engine the notebooks run against | https://dev.mysql.com/downloads/mysql/ |
| **SQL Notebook** extension (by `cmoog`) | Opens `.sql` files as notebooks and runs each cell | VS Code Marketplace |

---

## 1. Install MySQL Server

### Windows (recommended path)

1. Download **MySQL Installer for Windows** from https://dev.mysql.com/downloads/installer/
2. Choose the **Developer Default** or **Server only** setup type.
3. During configuration:
   - Set a **root password** and write it down.
   - Keep the default port `3306`.
   - Tick **Start the MySQL Server at System Startup**.
4. Finish the installer.

### Verify the server is running

```bash
mysql -u root -p
```

Enter your root password. If you get the `mysql>` prompt, the server works. Type `exit;` to leave.

### Create the practice database

All lectures work inside a schema called `maqbool`:

```sql
CREATE DATABASE maqbool;
```

---

## 2. Install the SQL Notebook extension

1. Open VS Code.
2. Open the **Extensions** sidebar (`Ctrl+Shift+X`).
3. Search for **`SQL Notebook`** (publisher: **cmoog**, id `cmoog.sqlnotebook`).
4. Click **Install**.
5. A **SQL NOTEBOOK** panel appears in the Explorer sidebar. That's where you manage connections.

---

## 3. Create a database connection

1. In the **SQL NOTEBOOK** panel, click **+** (*New SQL Connection*).
2. Fill in the form:

   | Field | Value |
   |-------|-------|
   | Display name | `Local MySQL` (any label) |
   | Database driver | `mysql` |
   | Host | `localhost` |
   | Port | `3306` |
   | User | `root` |
   | Password | your root password |
   | Database | `maqbool` |

3. Click **Create**, then click the new connection in the panel to **connect**. A connected connection is marked as active.

---

## 4. Open a lecture as a notebook

1. **File → Open Folder…** and select the `MySql Notebooks` folder.
2. In the Explorer, right-click **`Lecture N/Lecture N.sql`**, then **Open With…**, then **SQL Notebook**.
   (A normal double-click opens it as a plain SQL text file, which is also fine for reading.)
3. To always open `.sql` files as notebooks, choose **Configure default editor for '*.sql'…** in the same *Open With* menu.

---

## 5. Running queries

- Each **code cell holds exactly one query**, so run them one at a time.
- Run a cell with the ▶ button to its left, or press **`Ctrl+Enter`**. **`Shift+Enter`** runs the cell and moves to the next one.
- The result table appears directly under the cell.
- The **markdown cells** (section headings) in between just organise the lecture; they don't run.
- Run each lecture **top to bottom**, and the lectures **in order (1 → 7)**. Later lectures depend on tables and data created earlier. Each lecture README lists its prerequisites.
- Results are not saved into the `.sql` file. Only the SQL text is stored.

| Shortcut | Action |
|----------|--------|
| `Ctrl+Enter` | Run the current cell |
| `Shift+Enter` | Run the current cell and select the next |
| `Ctrl+/` | Toggle a SQL line comment |
| `Ctrl+S` | Save the notebook (writes the `.sql` file) |

---

## 6. How the .sql files are structured

SQL Notebook stores a notebook as an ordinary `.sql` file:

- **A blank line separates cells.** Each query is written with no blank lines inside it, followed by one blank line.
- **Markdown cells** are written as `/*markdown ... */` comments.
- Each code cell starts with a `-- Q<n>` comment that links it to the explanation in the lecture README.

```sql
/*markdown
## Insert and read rows
*/

-- Q9
SELECT * from maqbool_info;

-- Q10
INSERT INTO maqbool_info(
name,
age
...
```

Because the file is plain SQL, you can also run it with any other client (MySQL Workbench, `mysql < "Lecture 1.sql"`, etc.).

---

## 7. Troubleshooting

**The file opens as plain text, not as a notebook**
Use right-click → **Open With…** → **SQL Notebook**. If that option is missing, the extension isn't installed or enabled.

**"No active connection" / nothing happens when running a cell**
Click your connection in the **SQL NOTEBOOK** panel to connect it first.

**`Access denied for user 'root'@'localhost'`**
The password in the connection is wrong. Delete the connection and create it again.

**`No database selected` (Error 1046)**
Run the `USE maqbool;` cell near the top of the lecture, or set **Database** to `maqbool` in the connection.

**`Unknown database 'maqbool'`**
Run `CREATE DATABASE maqbool;` first.

**`Table ... already exists` / `Duplicate column name`**
You've already run that `CREATE` / `ALTER` cell. Skip it and continue.

**Server isn't running**
Open *Services* (`services.msc` on Windows), find **MySQL80**, right-click it and choose *Start*.

---

## Notes

- All queries were written while learning MySQL. They are practice exercises, not production code, and the lecture READMEs point out the mistakes and traps you can learn from.
- Feel free to edit cells, rerun them, and experiment. Just keep a blank line between cells.
