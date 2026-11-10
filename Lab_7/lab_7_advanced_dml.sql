BEGIN;
SET LOCAL search_path TO public;
-- Part 1
CREATE TABLE departments (
    dept_id integer PRIMARY KEY, dept_name varchar(50), location varchar(50)
);
CREATE TABLE employees (
    emp_id integer PRIMARY KEY, emp_name varchar(50),
    dept_id integer REFERENCES departments, salary numeric(10,2)
);
CREATE TABLE projects (
    project_id integer PRIMARY KEY, project_name varchar(50),
    dept_id integer REFERENCES departments, budget numeric(10,2)
);
INSERT INTO departments VALUES
    (101,'IT','Building A'), (102,'HR','Building B'),
    (103,'Finance','Building C'), (104,'Marketing','Building D');
INSERT INTO employees VALUES
    (1,'John Smith',101,50000), (2,'Jane Doe',102,60000),
    (3,'Mike Johnson',101,55000), (4,'Sarah Williams',103,65000),
    (5,'Tom Brown',NULL,45000);
INSERT INTO projects VALUES
    (1,'Website Redesign',101,100000), (2,'Employee Training',102,50000),
    (3,'Budget Analysis',103,75000), (4,'Cloud Migration',101,150000),
    (5,'AI Research',NULL,200000);
-- Part 2
-- 2.1 Creating Basic Views
CREATE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location
FROM employees e JOIN departments d ON d.dept_id = e.dept_id;
SELECT * FROM employee_details ORDER BY emp_name;
-- 2.2 View with Aggregation
CREATE VIEW dept_statistics AS
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count,
       ROUND(AVG(e.salary),2) AS avg_salary, MAX(e.salary) AS max_salary,
       MIN(e.salary) AS min_salary
FROM departments d LEFT JOIN employees e USING (dept_id)
GROUP BY d.dept_id, d.dept_name;
SELECT * FROM dept_statistics ORDER BY employee_count DESC, dept_name;
-- 2.3 View with Multiple Joins
CREATE VIEW project_overview AS
SELECT p.project_name, p.budget, d.dept_name, d.location, COUNT(e.emp_id) AS team_size
FROM projects p
LEFT JOIN departments d ON d.dept_id = p.dept_id
LEFT JOIN employees e ON e.dept_id = d.dept_id
GROUP BY p.project_id, d.dept_id;
SELECT * FROM project_overview ORDER BY project_name;
-- 2.4 View with Filtering
CREATE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e LEFT JOIN departments d USING (dept_id)
WHERE e.salary > 55000;
SELECT * FROM high_earners ORDER BY salary DESC;

-- Part 3 Modifying and Managing Views
-- 3.1 Replace a View
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location,
       CASE WHEN e.salary > 60000 THEN 'High'
            WHEN e.salary > 50000 THEN 'Medium'
            ELSE 'Standard' END AS salary_grade
FROM employees e JOIN departments d ON d.dept_id = e.dept_id;
SELECT * FROM employee_details ORDER BY salary DESC;
-- 3.2 Rename a View
ALTER VIEW high_earners RENAME TO top_performers;
SELECT * FROM top_performers ORDER BY salary DESC;
-- 3.3 Drop a View
CREATE TEMP VIEW temp_view AS SELECT * FROM employees WHERE salary < 50000;
SELECT * FROM temp_view;
DROP VIEW temp_view;

-- Part 4 Updatable Views
-- 4.1 Create an Updatable View
CREATE VIEW employee_salaries AS SELECT emp_id, emp_name, dept_id, salary FROM employees;
-- 4.2 Update Through a View
UPDATE employee_salaries SET salary = 52000 WHERE emp_id = 1 AND emp_name = 'John Smith';
SELECT * FROM employees WHERE emp_name = 'John Smith';
-- 4.3 Insert Through a View
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6,'Alice Johnson',102,58000);
SELECT * FROM employees WHERE emp_id = 6;
-- 4.4 View with CHECK OPTION
CREATE VIEW it_employees AS SELECT * FROM employees WHERE dept_id = 101
WITH LOCAL CHECK OPTION;
DO $$
BEGIN
    INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
    VALUES (7,'Bob Wilson',103,60000);
EXCEPTION WHEN WITH_CHECK_OPTION_VIOLATION THEN
    RAISE NOTICE '4.4 [%] %', SQLSTATE, SQLERRM;
END $$;

-- Part 5 Materialized Views
-- 5.1 Create a Materialized View
CREATE MATERIALIZED VIEW dept_summary_mv AS
WITH staff AS (
    SELECT dept_id, COUNT(*) AS n, SUM(salary) AS salaries FROM employees GROUP BY dept_id
), work AS (
    SELECT dept_id, COUNT(*) AS n, SUM(budget) AS budget FROM projects GROUP BY dept_id
)
SELECT d.dept_id, d.dept_name, COALESCE(s.n,0) AS total_employees,
       COALESCE(s.salaries,0) AS total_salaries, COALESCE(w.n,0) AS total_projects,
       COALESCE(w.budget,0) AS total_project_budget
FROM departments d LEFT JOIN staff s USING (dept_id) LEFT JOIN work w USING (dept_id)
WITH DATA;
SELECT * FROM dept_summary_mv ORDER BY total_employees DESC, dept_id;
-- 5.2 Refresh Materialized View
INSERT INTO employees VALUES (8,'Charlie Brown',101,54000);
SELECT 'Before refresh' AS stage, m.* FROM dept_summary_mv m WHERE dept_id = 101;
REFRESH MATERIALIZED VIEW dept_summary_mv;
SELECT 'After refresh' AS stage, m.* FROM dept_summary_mv m WHERE dept_id = 101;
-- 5.3 Concurrent Refresh
CREATE UNIQUE INDEX dept_summary_mv_dept_id_idx ON dept_summary_mv (dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
-- 5.4 Materialized View with NO DATA
CREATE TABLE assignments (
    project_id integer REFERENCES projects, emp_id integer REFERENCES employees,
    PRIMARY KEY (project_id, emp_id)
);
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT p.project_name, p.budget, d.dept_name, COUNT(a.emp_id) AS assigned_employees
FROM projects p LEFT JOIN departments d USING (dept_id)
LEFT JOIN assignments a ON a.project_id = p.project_id
GROUP BY p.project_id, d.dept_id
WITH NO DATA;
DO $$
BEGIN
    PERFORM * FROM project_stats_mv;
EXCEPTION WHEN OBJECT_NOT_IN_PREREQUISITE_STATE THEN
    RAISE NOTICE '5.4 [%] %', SQLSTATE, SQLERRM;
END $$;
REFRESH MATERIALIZED VIEW project_stats_mv;
SELECT * FROM project_stats_mv ORDER BY project_name;

-- Part 6 Database Roles
-- 6.1 Create Basic Roles
CREATE ROLE analyst NOLOGIN;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE USER report_user PASSWORD 'report456';
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%' ORDER BY rolname;
-- 6.2 Role with Specific Attributes
CREATE ROLE db_creator LOGIN CREATEDB PASSWORD 'creator789';
CREATE ROLE user_manager LOGIN CREATEROLE PASSWORD 'manager101';
CREATE ROLE admin_user LOGIN SUPERUSER PASSWORD 'admin999';
-- 6.3 Grant Privileges to Roles
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;
-- 6.4 Create Group Roles
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;
CREATE USER hr_user1 PASSWORD 'hr001';
CREATE USER hr_user2 PASSWORD 'hr002';
CREATE USER finance_user1 PASSWORD 'fin001';
GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;
GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;
-- 6.5 Revoke Privileges
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;
-- 6.6 Modify Role Attributes
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;

-- Part 7 Advanced Role Management
-- 7.1 Role Hierarchies
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';
GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;
-- 7.2 Object Ownership
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';
GRANT SELECT ON employees, departments TO project_manager;
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;
SELECT tablename, tableowner FROM pg_tables WHERE schemaname = 'public';
SELECT viewname, viewowner FROM pg_views
WHERE schemaname = 'public' AND viewname = 'dept_statistics';
-- 7.3 Reassign and Drop Roles
CREATE ROLE temp_owner LOGIN;
CREATE TABLE temp_table (id integer);
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;
-- 7.4 Row-Level Security with Views
CREATE VIEW hr_employee_view WITH (security_barrier = true) AS
SELECT * FROM employees WHERE dept_id = 102;
REVOKE SELECT ON employees FROM hr_team;
GRANT SELECT ON hr_employee_view TO hr_team;
CREATE VIEW finance_employee_view AS SELECT emp_id, emp_name, salary FROM employees;
GRANT SELECT ON finance_employee_view TO finance_team;
SET LOCAL ROLE hr_user1;
SELECT * FROM hr_employee_view ORDER BY emp_id;
RESET ROLE;

-- Part 8 Practical Scenarios
-- 8.1 Department Dashboard View
CREATE VIEW dept_dashboard AS
WITH work AS (
    SELECT dept_id, COUNT(*) AS n, SUM(budget) AS budget FROM projects GROUP BY dept_id
)
SELECT d.dept_name, d.location, COUNT(e.emp_id) AS employee_count,
       ROUND(AVG(e.salary),2) AS avg_salary, COALESCE(w.n,0) AS active_projects,
       COALESCE(w.budget,0) AS total_project_budget,
       ROUND(COALESCE(w.budget,0) / NULLIF(COUNT(e.emp_id),0),2) AS budget_per_employee
FROM departments d LEFT JOIN employees e USING (dept_id)
LEFT JOIN work w ON w.dept_id = d.dept_id
GROUP BY d.dept_id, w.n, w.budget;
SELECT * FROM dept_dashboard ORDER BY dept_name;
-- 8.2 Audit View
ALTER TABLE projects ADD COLUMN created_date timestamptz DEFAULT CURRENT_TIMESTAMP;
CREATE VIEW high_budget_projects AS
SELECT p.project_name, p.budget, d.dept_name, p.created_date,
       CASE WHEN p.budget > 150000 THEN 'Critical Review Required'
            WHEN p.budget > 100000 THEN 'Management Approval Needed'
            ELSE 'Standard Process' END AS approval_status
FROM projects p LEFT JOIN departments d USING (dept_id)
WHERE p.budget > 75000;
SELECT * FROM high_budget_projects ORDER BY budget DESC;
-- 8.3 Create Access Control System
CREATE ROLE viewer_role;
CREATE ROLE entry_role;
CREATE ROLE analyst_role;
CREATE ROLE manager_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;
CREATE USER alice PASSWORD 'alice123';
CREATE USER bob PASSWORD 'bob123';
CREATE USER charlie PASSWORD 'charlie123';
GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;
SELECT rolname, has_table_privilege(rolname,'employees','SELECT') AS can_read,
       has_table_privilege(rolname,'employees','INSERT') AS can_insert,
       has_table_privilege(rolname,'employees','UPDATE') AS can_update,
       has_table_privilege(rolname,'employees','DELETE') AS can_delete
FROM pg_roles WHERE rolname IN ('alice','bob','charlie') ORDER BY rolname;
COMMIT;