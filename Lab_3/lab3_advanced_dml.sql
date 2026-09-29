-- Part A
-- 1
CREATE DATABASE advanced_lab;

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);
-- Sample data
INSERT INTO employees
(first_name, last_name, department, salary, hire_date, status)
VALUES
('Nursat', 'Doskaliev', 'IT', 70000, '2019-05-10', 'Active'),
('Ali', 'Amanov', 'Sales', 60000, '2021-03-15', 'Active'),
('Ayan', 'Bekov', 'IT', 90000, '2018-07-20', 'Active'),
('Dana', 'Saparova', 'HR', 45000, '2022-01-10', 'Active'),
('Miras', 'Kairatov', 'Sales', 75000, '2019-11-01', 'Active');

INSERT INTO departments
(dept_name, budget, manager_id)
VALUES
('IT', 150000, 1),
('Sales', 120000, 2),
('HR', 80000, 3);

INSERT INTO projects
(project_name, dept_id, start_date, end_date, budget)
VALUES
('Website', 1, '2023-01-01', '2024-01-01', 60000),
('CRM System', 2, '2022-05-01', '2023-05-01', 40000),
('HR Portal', 3, '2022-03-01', '2022-12-01', 30000);
-- Part B
-- 2
INSERT INTO employees
(emp_id, first_name, last_name, department)
VALUES
(1, 'Nursat', 'Doskaliev', 'IT');

-- 3
ALTER TABLE employees
ALTER COLUMN salary SET DEFAULT 50000;

INSERT INTO employees
(first_name, last_name, salary, status)
VALUES
('Ali', 'Amanov', DEFAULT, DEFAULT);

-- 4
INSERT INTO departments
(dept_name, budget, manager_id)
VALUES
('IT', 150000, 1),
('Sales', 100000, 2),
('HR', 80000, 3);

-- 5
INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
('Ayan', 'Bekov', 'IT', 50000 * 1.1, CURRENT_DATE);

-- 6
CREATE TEMP TABLE temp_employees AS
SELECT *
FROM employees
WHERE department = 'IT';

SELECT * FROM temp_employees;

-- 7
UPDATE employees
SET salary = salary * 1.10;

SELECT emp_id, first_name, last_name, salary
FROM employees
ORDER BY emp_id;

-- 8
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';

-- 9
UPDATE employees
SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;

-- 10

ALTER TABLE employees
ALTER COLUMN department SET DEFAULT 'Unassigned';

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

-- 11. UPDATE with subquery

UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
);

-- 12. UPDATE multiple columns

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- PART D: ADVANCED DELETE OPERATIONS
-- 13. DELETE with simple WHERE

DELETE FROM employees
WHERE status = 'Terminated';

-- 14. DELETE with complex WHERE

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

-- 15. DELETE with subquery
DELETE FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department = d.dept_name
);

-- 16. DELETE with RETURNING
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- PART E: OPERATIONS WITH NULL VALUES
-- 17. INSERT with NULL values

INSERT INTO employees
(first_name, last_name, salary, department)
VALUES
('Null', 'Employee', NULL, NULL);

-- 18. UPDATE NULL handling

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- 19. DELETE with NULL conditions

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

-- PART F: RETURNING CLAUSE OPERATIONS
-- 20. INSERT with RETURNING

INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
('Serik', 'Amanov', 'IT', 70000, CURRENT_DATE)
RETURNING
    emp_id,
    first_name || ' ' || last_name AS full_name;

-- 21. UPDATE with RETURNING

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING
    emp_id,
    salary - 5000 AS old_salary,
    salary AS new_salary;

-- 22. DELETE with RETURNING all columns

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- PART G: ADVANCED DML PATTERNS
-- 23. Conditional INSERT
INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
SELECT
    'Nursat',
    'Doskaliev',
    'IT',
    70000,
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'Nursat'
      AND last_name = 'Doskaliev'
);

-- 24. UPDATE salaries based on department budget
UPDATE employees e
SET salary =
    CASE
        WHEN (
            SELECT d.budget
            FROM departments d
            WHERE d.dept_name = e.department
        ) > 100000
        THEN salary * 1.10

        ELSE salary * 1.05
    END;

-- 25. Bulk operations
INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
('Employee1', 'Test', 'IT', 50000, CURRENT_DATE),
('Employee2', 'Test', 'Sales', 50000, CURRENT_DATE),
('Employee3', 'Test', 'HR', 50000, CURRENT_DATE),
('Employee4', 'Test', 'IT', 50000, CURRENT_DATE),
('Employee5', 'Test', 'Sales', 50000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE first_name IN (
    'Employee1',
    'Employee2',
    'Employee3',
    'Employee4',
    'Employee5'
);

-- 26. Data migration simulation

CREATE TABLE IF NOT EXISTS employee_archive (
    emp_id INTEGER,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20)
);

INSERT INTO employee_archive
SELECT *
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

SELECT * FROM employee_archive;

-- 27. Complex business logic
UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      WHERE e.department = (
          SELECT d.dept_name
          FROM departments d
          WHERE d.dept_id = p.dept_id
      )
  ) > 3;

-- FINAL CHECKS
SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM projects;
SELECT * FROM employee_archive;






