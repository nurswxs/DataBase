DROP SCHEMA IF EXISTS ecommerce CASCADE;
DROP TABLE IF EXISTS order_items, orders, products_fk, categories CASCADE;
DROP TABLE IF EXISTS books, publishers, authors CASCADE;
DROP TABLE IF EXISTS employees_dept, departments CASCADE;
DROP TABLE IF EXISTS student_courses, course_enrollments, users CASCADE;
DROP TABLE IF EXISTS inventory, customers CASCADE;
DROP TABLE IF EXISTS bookings, products_catalog, employees CASCADE;

-- part 1
-- 1.1 Basic CHECK constraint
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CONSTRAINT chk_employees_age
            CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CONSTRAINT chk_employees_salary
            CHECK (salary > 0)
);
-- 1.2 CHECK constraint
CREATE TABLE products_catalog (
    product_id     INTEGER,
    product_name   TEXT,
    regular_price  NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);
-- 1.3 Multiple-column CHECK
CREATE TABLE bookings (
    booking_id     INTEGER,
    check_in_date  DATE,
    check_out_date DATE,
    num_guests     INTEGER,
    CONSTRAINT chk_bookings_guests CHECK (num_guests BETWEEN 1 AND 10),
    CONSTRAINT chk_bookings_dates  CHECK (check_out_date > check_in_date)
);
-- 1.4 Testing CHECK constraints
INSERT INTO employees VALUES (1, 'Aigerim', 'Nurlanova', 28, 450000.00);
INSERT INTO employees VALUES (2, 'Daniyar', 'Sadykov',   45, 620000.50);
-- INSERT INTO employees VALUES (3, 'Timur', 'Aliyev', 17, 300000);
-- INSERT INTO employees VALUES (4, 'Marat', 'Beketov', 70, 300000);
-- INSERT INTO employees VALUES (5, 'Sara', 'Omarova', 30, 0);
-- INSERT INTO employees VALUES (6, 'Askar', 'Kenzhe', 30, -500);

INSERT INTO products_catalog VALUES (1, 'Laptop', 1000.00, 850.00);
INSERT INTO products_catalog VALUES (2, 'Headphones', 150.00, 120.00);
-- INSERT INTO products_catalog VALUES (3, 'Mouse', 50.00, 60.00);
-- INSERT INTO products_catalog VALUES (4, 'Keyboard', 0, 0);
-- INSERT INTO products_catalog VALUES (5, 'Monitor', 300.00, -10.00);

INSERT INTO bookings VALUES (1, '2026-11-01', '2026-11-05', 2);
INSERT INTO bookings VALUES (2, '2026-12-20', '2026-12-27', 10);
-- INSERT INTO bookings VALUES (3, '2026-11-01', '2026-11-05', 0);
-- INSERT INTO bookings VALUES (4, '2026-11-01', '2026-11-05', 11);
-- INSERT INTO bookings VALUES (5, '2026-11-05', '2026-11-01', 2);
-- INSERT INTO bookings VALUES (6, '2026-11-05', '2026-11-05', 2);

-- part 2
-- 2.1 NOT NULL implementation
CREATE TABLE customers (
    customer_id       INTEGER NOT NULL,
    email             TEXT    NOT NULL,
    phone             TEXT,                -- nullable
    registration_date DATE    NOT NULL
);
-- 2.2 Combining constraints (NOT NULL + CHECK)
CREATE TABLE inventory (
    item_id      INTEGER   NOT NULL,
    item_name    TEXT      NOT NULL,
    quantity     INTEGER   NOT NULL CHECK (quantity >= 0),   -- no negative stock
    unit_price   NUMERIC   NOT NULL CHECK (unit_price > 0),  -- price must be positive
    last_updated TIMESTAMP NOT NULL
);
-- 2.3 Testing NOT NULL
INSERT INTO customers VALUES (1, 'alice@example.com', '+77011234567', '2026-01-15');
INSERT INTO customers VALUES (2, 'bob@example.com', '+77019876543', '2026-02-20');
INSERT INTO inventory VALUES (1, 'Notebook', 100, 2.50, NOW());
INSERT INTO inventory VALUES (2, 'Pen', 500, 0.75, NOW());
-- INSERT INTO customers VALUES (NULL, 'carol@example.com', NULL, '2026-03-01');
-- INSERT INTO customers VALUES (3, NULL, '+77015556677', '2026-03-01');
-- INSERT INTO customers VALUES (4, 'dave@example.com', NULL, NULL);
-- INSERT INTO inventory VALUES (3, NULL, 10, 1.00, NOW());
-- INSERT INTO inventory VALUES (4, 'Stapler', -5, 3.00, NOW());
-- INSERT INTO inventory VALUES (5, 'Marker', 10, 0, NOW());
INSERT INTO customers VALUES (3, 'carol@example.com', NULL, '2026-03-01');
INSERT INTO customers VALUES (4, 'dave@example.com', NULL, '2026-03-05');

-- part 3
-- 3.1 Single-column UNIQUE
CREATE TABLE users (
    user_id    INTEGER,
    username   TEXT UNIQUE,
    email      TEXT UNIQUE,
    created_at TIMESTAMP
);
-- 3.2 Multi-column UNIQUE
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id    INTEGER,
    course_code   TEXT,
    semester      TEXT,
    CONSTRAINT uq_enrollment UNIQUE (student_id, course_code, semester)
);
INSERT INTO course_enrollments VALUES (1, 101, 'CS101', 'Fall 2026');
INSERT INTO course_enrollments VALUES (2, 101, 'CS101', 'Spring 2027');
INSERT INTO course_enrollments VALUES (3, 102, 'CS101', 'Fall 2026');
-- INSERT INTO course_enrollments VALUES (4, 101, 'CS101', 'Fall 2026');

-- 3.3 UNIQUE constraints on users
ALTER TABLE users DROP CONSTRAINT users_username_key;
ALTER TABLE users DROP CONSTRAINT users_email_key;
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users VALUES (1, 'john_doe', 'john@example.com', NOW());
INSERT INTO users VALUES (2, 'jane_smith', 'jane@example.com', NOW());
INSERT INTO users VALUES (3, 'no_email', NULL, NOW());
INSERT INTO users VALUES (4, 'no_email_2', NULL, NOW());
-- INSERT INTO users VALUES (5, 'john_doe', 'other@example.com', NOW());
-- INSERT INTO users VALUES (6, 'new_user', 'jane@example.com', NOW());

-- part 4
-- 4.1 Single-column primary key
CREATE TABLE departments (
    dept_id   INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location  TEXT
);
INSERT INTO departments VALUES (1, 'Engineering', 'Almaty');
INSERT INTO departments VALUES (2, 'Marketing', 'Astana');
INSERT INTO departments VALUES (3, 'Finance', 'Shymkent');
-- INSERT INTO departments VALUES (1, 'HR', 'Almaty');
-- INSERT INTO departments VALUES (NULL, 'Legal', 'Astana');

-- 4.2 Composite primary key
CREATE TABLE student_courses (
    student_id      INTEGER,
    course_id       INTEGER,
    enrollment_date DATE,
    grade           TEXT,
    PRIMARY KEY (student_id, course_id)
);
INSERT INTO student_courses VALUES (1, 10, '2026-09-01', 'A');
INSERT INTO student_courses VALUES (1, 20, '2026-09-01', 'B');
INSERT INTO student_courses VALUES (2, 10, '2026-09-02', 'A-');
-- INSERT INTO student_courses VALUES (1, 10, '2026-09-05', 'C');
-- INSERT INTO student_courses VALUES (NULL, 10, '2026-09-05', 'C');
-- 4.3 Comparison exercise
-- 1) UNIQUE allows NULLs; PRIMARY KEY = UNIQUE + NOT NULL and is the main row identifier.
-- 2) Single-column PK: one attribute identifies the row (dept_id). Composite PK: the combination does (student_id, course_id), typical for many-to-many tables.
-- 3) A table has one main identifier (PK) but can have many other unique rules (UNIQUE).
-- part 5
-- 5.1 Basic foreign key
CREATE TABLE employees_dept (
    emp_id    INTEGER PRIMARY KEY,
    emp_name  TEXT NOT NULL,
    dept_id   INTEGER REFERENCES departments,
    hire_date DATE
);
INSERT INTO employees_dept VALUES (1, 'Aigerim', 1, '2024-03-01');
INSERT INTO employees_dept VALUES (2, 'Daniyar', 2, '2023-07-15');
INSERT INTO employees_dept VALUES (3, 'Timur', 3, '2025-01-10');
INSERT INTO employees_dept VALUES (4, 'Sara', NULL, '2025-05-20');
-- INSERT INTO employees_dept VALUES (5, 'Marat', 99, '2025-06-01');

-- 5.2 Multiple foreign keys - library system
CREATE TABLE authors (
    author_id   INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country     TEXT
);

CREATE TABLE publishers (
    publisher_id   INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city           TEXT
);

CREATE TABLE books (
    book_id          INTEGER PRIMARY KEY,
    title            TEXT NOT NULL,
    author_id        INTEGER REFERENCES authors,
    publisher_id     INTEGER REFERENCES publishers,
    publication_year INTEGER,
    isbn             TEXT UNIQUE
);

INSERT INTO authors VALUES
    (1, 'Leo Tolstoy', 'Russia'),
    (2, 'Abai Kunanbaiuly', 'Kazakhstan'),
    (3, 'George Orwell', 'United Kingdom'),
    (4, 'Mukhtar Auezov', 'Kazakhstan');

INSERT INTO publishers VALUES
    (1, 'Penguin Books', 'London'),
    (2, 'Zhazushy', 'Almaty'),
    (3, 'Eksmo', 'Moscow');

INSERT INTO books VALUES
    (1, 'War and Peace', 1, 3, 1869, '978-5-04-000001-1'),
    (2, 'Book of Words', 2, 2, 1904, '978-601-00-0002-2'),
    (3, '1984', 3, 1, 1949, '978-0-14-000003-3'),
    (4, 'Abai Zholy', 4, 2, 1942, '978-601-00-0004-4'),
    (5, 'Animal Farm', 3, 1, 1945, '978-0-14-000005-5');

-- INSERT INTO books VALUES (6, 'Ghost Book', 99, 1, 2000, '978-0-00-000006-6');
-- INSERT INTO books VALUES (7, 'Copy of 1984', 3, 1, 1950, '978-0-14-000003-3');

-- 5.3 ON DELETE options
CREATE TABLE categories (
    category_id   INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id   INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id  INTEGER REFERENCES categories ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id   INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id    INTEGER PRIMARY KEY,
    order_id   INTEGER REFERENCES orders ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk,
    quantity   INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Electronics'), (2, 'Books'), (3, 'Toys');
INSERT INTO products_fk VALUES (1, 'Smartphone', 1), (2, 'Laptop', 1), (3, 'Novel', 2);
INSERT INTO orders VALUES (1, '2026-10-01'), (2, '2026-10-02');
INSERT INTO order_items VALUES (1, 1, 1, 2), (2, 1, 3, 1), (3, 2, 2, 1);

-- DELETE FROM categories WHERE category_id = 1;
DELETE FROM categories WHERE category_id = 3;
SELECT * FROM order_items ORDER BY item_id;
DELETE FROM orders WHERE order_id = 1;
SELECT * FROM order_items ORDER BY item_id;
-- DELETE FROM products_fk WHERE product_id = 2;
-- INSERT INTO order_items VALUES (10, 2, 1, 0);

-- part 6
-- 6.1 E-commerce Database Design
CREATE SCHEMA ecommerce;
SET search_path TO ecommerce;

CREATE TABLE customers (
    customer_id       SERIAL PRIMARY KEY,
    name              TEXT NOT NULL,
    email             TEXT NOT NULL UNIQUE,
    phone             TEXT,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE products (
    product_id     SERIAL PRIMARY KEY,
    name           TEXT NOT NULL,
    description    TEXT,
    price          NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    order_date   TIMESTAMP NOT NULL DEFAULT NOW(),
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    status       TEXT NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id      INTEGER NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity        INTEGER NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO customers (name, email, phone, registration_date) VALUES
    ('Aigerim Nurlanova', 'aigerim@example.com', '+77011111111', '2026-01-10'),
    ('Daniyar Sadykov', 'daniyar@example.com', '+77022222222', '2026-02-14'),
    ('Timur Aliyev', 'timur@example.com', NULL, '2026-03-03'),
    ('Sara Omarova', 'sara@example.com', '+77044444444', '2026-04-21'),
    ('Marat Beketov', 'marat@example.com', '+77055555555', '2026-05-30');

INSERT INTO products (name, description, price, stock_quantity) VALUES
    ('Laptop', '15-inch laptop', 1200.00, 15),
    ('Smartphone', '128GB smartphone', 800.00, 30),
    ('Headphones', 'Wireless headphones', 150.00, 50),
    ('Keyboard', 'Mechanical keyboard', 90.00, 40),
    ('Mouse', 'Optical mouse', 25.00, 100);

INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
    (1, '2026-09-01 10:00', 1350.00, 'delivered'),
    (2, '2026-09-05 12:30', 800.00, 'shipped'),
    (3, '2026-09-10 09:15', 240.00, 'processing'),
    (4, '2026-09-12 16:45', 25.00, 'pending'),
    (5, '2026-09-15 11:20', 150.00, 'cancelled');

INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 1200.00),
    (1, 3, 1, 150.00),
    (2, 2, 1, 800.00),
    (3, 4, 1, 90.00),
    (3, 3, 1, 150.00),
    (4, 5, 1, 25.00),
    (5, 3, 1, 150.00);

-- INSERT INTO customers (name, email) VALUES ('Fake', 'aigerim@example.com');
-- INSERT INTO customers (name, email) VALUES (NULL, 'x@example.com');
-- INSERT INTO products (name, price, stock_quantity) VALUES ('Bad', -5, 10);
-- INSERT INTO products (name, price, stock_quantity) VALUES ('Bad', 5, -1);
-- INSERT INTO orders (customer_id, status) VALUES (1, 'lost');
-- INSERT INTO orders (customer_id) VALUES (999);
-- INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES (1, 1, 0, 10);
-- INSERT INTO customers (customer_id, name, email) VALUES (1, 'Dup', 'dup@example.com');
-- DELETE FROM customers WHERE customer_id = 1;
-- DELETE FROM products WHERE product_id = 1;

SELECT count(*) FROM order_details WHERE order_id = 3;
DELETE FROM orders WHERE order_id = 3;
SELECT count(*) FROM order_details WHERE order_id = 3;

UPDATE orders SET status = 'delivered' WHERE order_id = 2;
-- UPDATE orders SET status = 'unknown' WHERE order_id = 2;

RESET search_path;


