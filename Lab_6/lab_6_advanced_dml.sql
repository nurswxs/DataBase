DROP TABLE IF EXISTS public.employees_dept;
DROP TABLE IF EXISTS public.departments;
DROP TABLE IF EXISTS public.assignments;
DROP TABLE IF EXISTS public.projects;
-- Part 1: Database Setup
-- 1.1 Create Sample Tables
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

-- 1.2 Insert Sample Data
INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

-- Part 2: CROSS JOIN Exercises
-- 2.1: Basic CROSS JOIN
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;

-- 2.2: Alternative CROSS JOIN Syntax
-- A
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;
-- B
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d ON TRUE;

-- 2.3: Practical CROSS JOIN
SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p;

-- Part 3: INNER JOIN Exercises
-- 3.1: Basic INNER JOIN with ON
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- 3.2: INNER JOIN with USING
SELECT emp_name, dept_name, location
FROM employees INNER JOIN departments USING (dept_id);

-- 3.3: NATURAL INNER JOIN
SELECT emp_name, dept_name, location
FROM employees NATURAL INNER JOIN departments;

-- 3.4: Multi-table INNER JOIN
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

-- Part 4: LEFT JOIN Exercises
-- 4.1: Basic LEFT JOIN
SELECT e.emp_name, e.dept_id AS emp_dept,
       d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- 4.2: LEFT JOIN with USING
SELECT e.emp_name, e.dept_id AS emp_dept,
       d.dept_id AS dept_dept, d.dept_name
FROM employees e LEFT JOIN departments d USING (dept_id);

-- 4.3: Find Unmatched Records
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- 4.4: LEFT JOIN with Aggregation
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC, d.dept_name;

-- Part 5: RIGHT JOIN Exercises
-- 5.1: Basic RIGHT JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- 5.2: Convert to LEFT JOIN
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id;

-- 5.3: Find Departments Without Employees
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

-- Part 6: FULL JOIN Exercises
-- 6.1: Basic FULL JOIN
SELECT e.emp_name, e.dept_id AS emp_dept,
       d.dept_id AS dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;

-- 6.2: FULL JOIN with Projects
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

-- 6.3: Find Orphaned Records
SELECT CASE
           WHEN e.emp_id IS NULL THEN 'Department without employees'
           WHEN d.dept_id IS NULL THEN 'Employee without department'
           ELSE 'Matched'
       END AS record_status,
       e.emp_name, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;
-- Part 7: ON vs WHERE Clause
-- 7.1: Filtering in ON Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- 7.2: Filtering in WHERE Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- 7.3: ON vs WHERE with INNER JOIN
-- A
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id AND d.location = 'Building A';
-- B
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Part 8: Complex JOIN Scenarios
-- 8.1: Multiple Joins with Different Types
SELECT d.dept_name, e.emp_name, e.salary, p.project_name, p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name, p.project_name;

-- 8.2: Self Join
ALTER TABLE employees ADD COLUMN manager_id INT;
UPDATE employees SET manager_id = 3 WHERE emp_id IN (1, 2, 4, 5);
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
SELECT e.emp_name AS employee, m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- 8.3: Join with Subquery
SELECT d.dept_name, s.avg_salary
FROM departments d
INNER JOIN (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
    HAVING AVG(salary) > 50000
) s ON s.dept_id = d.dept_id;

-- Optional 1
SELECT e.emp_id, e.emp_name, e.dept_id AS emp_dept,
       d.dept_id AS dept_dept, d.dept_name
FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.emp_id, e.emp_name, e.dept_id AS emp_dept,
       d.dept_id AS dept_dept, d.dept_name
FROM employees e RIGHT JOIN departments d ON e.dept_id = d.dept_id;
-- Optional 2
SELECT e.emp_name, d.dept_name
FROM employees e
JOIN departments d ON d.dept_id = e.dept_id
JOIN (
    SELECT dept_id FROM projects
    GROUP BY dept_id HAVING COUNT(*) > 1
) p ON p.dept_id = d.dept_id;
-- Optional 3
WITH RECURSIVE hierarchy AS (
    SELECT emp_id AS employee_id, emp_name AS employee_name,
           emp_id AS ancestor_id, emp_name AS ancestor_name,
           manager_id, 0 AS depth, ARRAY[emp_id] AS path
    FROM employees
    UNION ALL
    SELECT h.employee_id, h.employee_name,
           m.emp_id, m.emp_name, m.manager_id,
           h.depth + 1, h.path || m.emp_id
    FROM hierarchy h
    JOIN employees m ON m.emp_id = h.manager_id
    WHERE NOT (m.emp_id = ANY(h.path))
)
SELECT employee_name, ancestor_name, depth
FROM hierarchy
ORDER BY employee_id, depth;
-- Optional 4
SELECT e1.emp_name AS employee_1, e2.emp_name AS employee_2, d.dept_name
FROM employees e1
JOIN employees e2 ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
JOIN departments d ON d.dept_id = e1.dept_id;


