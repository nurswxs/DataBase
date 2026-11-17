CREATE SCHEMA lab8;
SET search_path TO lab8;
-- Part 1: Database Setup
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT REFERENCES departments(dept_id),
    salary DECIMAL(10,2)
);
CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT REFERENCES departments(dept_id)
);
INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');
INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);

-- Part 2: Creating Basic Indexes
-- Exercise 2.1: Create a Simple B-tree Index
CREATE INDEX emp_salary_idx ON employees(salary);
SELECT indexname, indexdef FROM pg_indexes
WHERE schemaname = 'lab8' AND tablename = 'employees';
-- Exercise 2.2: Create an Index on a Foreign Key
CREATE INDEX emp_dept_idx ON employees(dept_id);
SELECT * FROM employees WHERE dept_id = 101;
-- Exercise 2.3: View Index Information
SELECT tablename, indexname, indexdef FROM pg_indexes
WHERE schemaname = 'lab8' ORDER BY tablename, indexname;
-- Part 3: Multicolumn Indexes
-- Exercise 3.1: Create a Multicolumn Index
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);
SELECT emp_name, salary FROM employees
WHERE dept_id = 101 AND salary > 52000;
-- Exercise 3.2: Understanding Column Order
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
-- Part 4: Unique Indexes
-- Exercise 4.1: Create a Unique Index
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = CASE emp_id
    WHEN 1 THEN 'john.smith@company.com'
    WHEN 2 THEN 'jane.doe@company.com'
    WHEN 3 THEN 'mike.johnson@company.com'
    WHEN 4 THEN 'sarah.williams@company.com'
    WHEN 5 THEN 'tom.brown@company.com'
END;
CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);
DO $$
BEGIN
    INSERT INTO employees(emp_id, emp_name, dept_id, salary, email)
    VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
    RAISE EXCEPTION 'Test failed: duplicate email was accepted';
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'Expected error [%]: %', SQLSTATE, SQLERRM;
END $$;
-- Exercise 4.2: Unique Index vs UNIQUE Constraint
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;
SELECT indexname, indexdef FROM pg_indexes
WHERE schemaname = 'lab8' AND tablename = 'employees'
  AND indexname LIKE '%phone%';
-- Part 5: Indexes and Sorting
-- Exercise 5.1: Create an Index for Sorting
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);
SELECT emp_name, salary FROM employees ORDER BY salary DESC;
-- Exercise 5.2: Index with NULL Handling
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);
SELECT proj_name, budget FROM projects ORDER BY budget NULLS FIRST;
-- Part 6: Indexes on Expressions
-- Exercise 6.1: Create a Function-Based Index
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));
SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';
-- Exercise 6.2: Index on Calculated Values
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = CASE emp_id
    WHEN 1 THEN DATE '2020-01-15'
    WHEN 2 THEN DATE '2019-06-20'
    WHEN 3 THEN DATE '2021-03-10'
    WHEN 4 THEN DATE '2020-11-05'
    WHEN 5 THEN DATE '2018-08-25'
END;
CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));
SELECT emp_name, hire_date FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;
-- Part 7: Managing Indexes
-- Exercise 7.1: Rename an Index
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
SELECT indexname FROM pg_indexes
WHERE schemaname = 'lab8' AND tablename = 'employees';
-- Exercise 7.2: Drop Unused Indexes
DROP INDEX emp_salary_dept_idx;
-- Exercise 7.3: Reindex
REINDEX INDEX employees_salary_index;
-- Part 8: Practical Scenarios
-- Exercise 8.1: Optimize a Slow Query
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000 ORDER BY e.salary DESC;
-- Exercise 8.2: Partial Index
CREATE INDEX proj_high_budget_idx ON projects(budget) WHERE budget > 80000;
SELECT proj_name, budget FROM projects WHERE budget > 80000;
-- Exercise 8.3: Analyze Index Usage
ANALYZE employees;
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM employees WHERE salary > 52000;
-- Part 9: Index Types Comparison
-- Exercise 9.1: Create a Hash Index
CREATE INDEX dept_name_hash_idx ON departments USING HASH(dept_name);
SELECT * FROM departments WHERE dept_name = 'IT';
-- Exercise 9.2: Compare Index Types
CREATE INDEX proj_name_btree_idx ON projects USING BTREE(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH(proj_name);
SELECT * FROM projects WHERE proj_name = 'Website Redesign';
SELECT * FROM projects WHERE proj_name > 'Database';
-- Part 10: Cleanup and Best Practices
-- Exercise 10.1: Review All Indexes
SELECT schemaname, tablename, indexname,
       pg_size_pretty(pg_relation_size(
           format('%I.%I', schemaname, indexname)::regclass)) AS index_size,
       pg_relation_size(format('%I.%I', schemaname, indexname)::regclass) AS bytes
FROM pg_indexes WHERE schemaname = 'lab8'
ORDER BY bytes DESC, tablename, indexname;
-- Exercise 10.2: Drop Unnecessary Indexes
DROP INDEX IF EXISTS proj_name_hash_idx;
-- Exercise 10.3: Document Your Indexes
CREATE VIEW index_documentation AS
SELECT tablename, indexname, indexdef,
       'Improves salary-based queries' AS purpose
FROM pg_indexes WHERE schemaname = 'lab8' AND indexname LIKE '%salary%';
SELECT * FROM index_documentation;