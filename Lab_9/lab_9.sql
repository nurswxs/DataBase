-- Part 1 DataBase setup
DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;
CREATE TABLE stations (
    station_id INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city VARCHAR(40) NOT NULL,
    capacity INT NOT NULL
);
CREATE TABLE bikes (
    bike_id INT PRIMARY KEY,
    model VARCHAR(50) NOT NULL,
    station_id INT REFERENCES stations(station_id),
    daily_rate NUMERIC(8,2) NOT NULL
);
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    city VARCHAR(40) NOT NULL,
    joined_on DATE NOT NULL
);
CREATE TABLE rentals (
    rental_id INT PRIMARY KEY,
    member_id INT REFERENCES members(member_id),
    bike_id INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
    end_date DATE,
    fee NUMERIC(8,2)
);
INSERT INTO stations VALUES
 (10,'Central Park','Almaty',4),(20,'Riverside','Almaty',3),
 (30,'Expo Gate','Astana',5),(40,'Old Town','Shymkent',2),(50,'Depot','Astana',0);
INSERT INTO bikes VALUES
 (101,'City Cruiser',10,4.50),(102,'City Cruiser',10,4.50),
 (103,'Mountain X',20,7.00),(104,'Mountain X',30,7.00),
 (105,'Road Sprint',30,9.25),(106,'Folding Mini',40,3.75),
 (107,'Cargo Hauler',20,12.00),(108,'Road Sprint',10,9.25);
INSERT INTO members VALUES
 (1,'Aisha Nurlanova','Almaty',DATE '2023-03-14'),
 (2,'Daniyar Serik','Almaty',DATE '2023-07-02'),
 (3,'Marta Kowalski','Astana',DATE '2024-01-20'),
 (4,'Chen Wei','Astana',DATE '2024-05-11'),
 (5,'Omar Haddad','Shymkent',DATE '2024-09-30'),
 (6,'Elena Petrova','Almaty',DATE '2025-02-05');
INSERT INTO rentals VALUES
 (1,1,101,DATE '2024-04-05',DATE '2024-04-08',13.50),
 (2,1,103,DATE '2024-06-11',DATE '2024-06-16',35.00),
 (3,1,108,DATE '2025-02-02',DATE '2025-02-04',18.50),
 (4,1,102,DATE '2025-05-20',DATE '2025-05-27',31.50),
 (5,2,101,DATE '2024-05-01',DATE '2024-05-02',4.50),
 (6,2,107,DATE '2024-11-15',DATE '2024-11-19',48.00),
 (7,2,107,DATE '2025-03-08',DATE '2025-03-14',72.00),
 (8,3,104,DATE '2024-02-14',DATE '2024-02-18',28.00),
 (9,3,105,DATE '2024-08-03',DATE '2024-08-06',27.75),
 (10,3,104,DATE '2025-01-09',DATE '2025-01-10',7.00),
 (11,3,105,DATE '2025-06-01',DATE '2025-06-09',74.00),
 (12,4,104,DATE '2024-07-19',DATE '2024-07-21',14.00),
 (13,4,105,DATE '2025-04-12',DATE '2025-04-15',27.75),
 (14,4,103,DATE '2025-07-23',DATE '2025-07-29',42.00),
 (15,5,106,DATE '2024-10-05',DATE '2024-10-12',26.25),
 (16,5,106,DATE '2025-01-18',DATE '2025-01-20',7.50),
 (17,5,106,DATE '2025-08-14',DATE '2025-08-21',26.25),
 (18,2,102,DATE '2025-09-02',DATE '2025-09-05',13.50),
 (19,1,101,DATE '2025-10-10',NULL,NULL),
 (20,4,108,DATE '2024-12-28',DATE '2025-01-03',55.50),
 (21,3,103,DATE '2025-02-26',DATE '2025-03-02',28.00),
 (22,5,104,DATE '2025-05-05',DATE '2025-05-08',21.00);
SELECT (SELECT COUNT(*) FROM stations) AS stations,
       (SELECT COUNT(*) FROM bikes) AS bikes,
       (SELECT COUNT(*) FROM members) AS members,
       (SELECT COUNT(*) FROM rentals) AS rentals;

-- Part 2 First functions
-- 2.1 A function over one row
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT) RETURNS INT AS $$
DECLARE v_days INT;
BEGIN
    SELECT end_date - start_date INTO v_days
    FROM rentals WHERE rental_id = p_rental_id;
    RETURN v_days;
END; $$ LANGUAGE plpgsql;
SELECT rental_days(2), rental_days(11), rental_days(19), rental_days(999);
-- 2.2 A function over many rows
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT) RETURNS INT AS $$
DECLARE v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM rentals WHERE member_id = p_member_id;
    RETURN v_count;
END; $$ LANGUAGE plpgsql;
SELECT member_rental_count(1), member_rental_count(5), member_rental_count(6), member_rental_count(99);
-- 2.3 Returning text
CREATE OR REPLACE FUNCTION station_city(p_station_id INT) RETURNS VARCHAR AS $$
DECLARE v_city VARCHAR(40);
BEGIN
    SELECT city INTO v_city FROM stations WHERE station_id = p_station_id;
    RETURN v_city;
END; $$ LANGUAGE plpgsql;
SELECT station_city(30), station_city(77);
-- 2.4 Using a function inside a query
SELECT rental_id, member_id, rental_days(rental_id) AS duration_days
FROM rentals
WHERE rental_days(rental_id) > 4
ORDER BY duration_days DESC;
-- Part 3 Parameter Modes
-- 3.1 IN parameters
CREATE OR REPLACE FUNCTION fee_with_discount(p_fee NUMERIC, p_percent NUMERIC) RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100), 2);
END; $$ LANGUAGE plpgsql;
SELECT fee_with_discount(74.00, 15);
-- 3.2 OUT parameters
CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT, OUT rental_cnt INT, OUT total_fee NUMERIC, OUT last_start DATE
) AS $$
BEGIN
    SELECT COUNT(*), COALESCE(SUM(r.fee),0), MAX(r.start_date)
    INTO rental_cnt, total_fee, last_start
    FROM rentals r WHERE r.member_id = p_member_id;
END; $$ LANGUAGE plpgsql;
SELECT member_stats(3);
SELECT * FROM member_stats(3);
SELECT * FROM member_stats(6);
-- 3.3 INOUT parameters
CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC) AS $$
BEGIN
    p_fee := p_fee + 5.00;
END; $$ LANGUAGE plpgsql;
SELECT apply_late_fee(fee) FROM rentals WHERE rental_id = 1;
-- 3.4 VARIADIC parameters
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[], OUT total NUMERIC, OUT average NUMERIC, OUT largest NUMERIC
) AS $$
BEGIN
    SELECT COALESCE(SUM(p_fees[g.i]),0), ROUND(AVG(p_fees[g.i]),2), MAX(p_fees[g.i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees,1) AS g(i);
END; $$ LANGUAGE plpgsql;
SELECT * FROM fee_summary(13.50,35.00,18.50,31.50);
SELECT * FROM fee_summary();
-- 3.5 Choosing a mode
-- (a) IN, id is input only; (b) INOUT, value comes in and updated value goes out;
-- (c) VARIADIC, number of ids is unknown; (d) OUT parameters, return multiple values from one call.

-- Part 4 Default Values and Function Overloading
-- 4.1 A function with one parameter
-- 4.2 Overloading the name
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT) RETURNS NUMERIC AS $$
DECLARE v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee),0) INTO v_total FROM rentals WHERE member_id=p_member_id;
    RETURN v_total;
END; $$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE) RETURNS NUMERIC AS $$
DECLARE v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee),0) INTO v_total FROM rentals
    WHERE member_id=p_member_id AND start_date >= p_from_date;
    RETURN v_total;
END; $$ LANGUAGE plpgsql;
SELECT total_fees(1), total_fees(6);
SELECT total_fees(1,DATE '2024-01-01'), total_fees(1,DATE '2025-01-01');
-- 4.3 Giving a parameter a default value
-- The following ALTERATION creates ambiguity. Uncomment just this definition and failing call
-- to capture PostgreSQL's exact version-specific error. Then drop the one-argument function below.
-- CREATE OR REPLACE FUNCTION total_fees(p_member_id INT,
--      p_from_date DATE DEFAULT DATE '2025-01-01') RETURNS NUMERIC AS $$
-- DECLARE v_total NUMERIC;
-- BEGIN
--     SELECT COALESCE(SUM(fee),0) INTO v_total FROM rentals
--     WHERE member_id=p_member_id AND start_date >= p_from_date;
--     RETURN v_total;
-- END; $$ LANGUAGE plpgsql;
-- SELECT total_fees(1); -- ambiguous while both one-arg and defaulted two-arg versions exist

-- 4.4 Resolving the ambiguity
DROP FUNCTION IF EXISTS total_fees(INT);
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT,
        p_from_date DATE DEFAULT DATE '2025-01-01') RETURNS NUMERIC AS $$
DECLARE v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee),0) INTO v_total FROM rentals
    WHERE member_id=p_member_id AND start_date >= p_from_date;
    RETURN v_total;
END; $$ LANGUAGE plpgsql;
SELECT total_fees(1);
-- 4.5 Overloading on type, not just on count
CREATE OR REPLACE FUNCTION total_fees(p_member_name VARCHAR) RETURNS NUMERIC AS $$
DECLARE v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee),0) INTO v_total
    FROM members m LEFT JOIN rentals r ON r.member_id=m.member_id
    WHERE m.full_name=p_member_name;
    RETURN v_total;
END; $$ LANGUAGE plpgsql;
SELECT total_fees('Aisha Nurlanova'::VARCHAR);
SELECT total_fees(1);

-- Part 5 Functions That Return a Table
-- 5.1 Search by pattern
CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE(found_id INT, found_model VARCHAR, found_rate NUMERIC) AS $$
BEGIN
    RETURN QUERY SELECT b.bike_id, b.model::VARCHAR, b.daily_rate::NUMERIC
    FROM bikes b WHERE b.model ILIKE p_pattern ORDER BY b.bike_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');
SELECT find_bikes('%road%');
-- 5.2 A table from a join
CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE(rental_no INT, bike_model VARCHAR, station_name VARCHAR,
              duration_days INT, rental_fee NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT r.rental_id, b.model::VARCHAR, s.station_name::VARCHAR,
           (r.end_date-r.start_date)::INT, r.fee::NUMERIC
    FROM rentals r JOIN bikes b ON b.bike_id=r.bike_id
    JOIN stations s ON s.station_id=b.station_id
    WHERE r.member_id=p_member_id ORDER BY r.start_date;
END; $$ LANGUAGE plpgsql;
SELECT * FROM member_history(3);
-- 5.3 When the column names collide
-- Fix 1: use non-colliding output names.
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE(found_bike_id INT, found_model VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT b.bike_id, b.model::VARCHAR FROM bikes b
    WHERE b.station_id=p_station_id ORDER BY b.bike_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM bike_list(10);
-- Fix 2: retain output names and qualify every table column with an alias.
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE(bike_id INT, model VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT b.bike_id, b.model::VARCHAR FROM bikes AS b
    WHERE b.station_id=p_station_id ORDER BY b.bike_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM bike_list(10);
-- 5.4 Casting the output
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE(s_name VARCHAR, s_bikes INT, s_free INT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name::VARCHAR, COUNT(b.bike_id)::INT,
           (s.capacity-COUNT(b.bike_id))::INT
    FROM stations s LEFT JOIN bikes b ON b.station_id=s.station_id
    WHERE s.city=p_city GROUP BY s.station_id, s.station_name, s.capacity
    ORDER BY s.station_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM station_board('Almaty');
-- Part 6 Block Structure, DO Blocks and Subblocks
-- 6.1 An anonymous block
-- 6.2 A subblock and a hidden variable
-- 6.3 Declarations are local
-- 6.1, 6.2 and 6.3 combined. To demonstrate a scope error in 6.3, uncomment the marked line.
DO $$
<<rental_report>>
DECLARE
    total_rentals INT := 0;
    fee_total NUMERIC := 0;
    inner_only NUMERIC;
BEGIN
    SELECT COUNT(*) INTO total_rentals FROM rentals;
    RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
    SELECT COALESCE(SUM(fee),0) INTO fee_total FROM rentals;
    RAISE NOTICE 'Outer total before subblock: %', fee_total;
    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT COALESCE(SUM(fee),0) INTO fee_total FROM rentals
        WHERE start_date >= DATE '2025-01-01';
        RAISE NOTICE 'Subblock total: %', fee_total;
        RAISE NOTICE 'Outer total from subblock: %', rental_report.fee_total;
    END;
    RAISE NOTICE 'Outer total after subblock: %', fee_total;
    DECLARE
        second_block_value NUMERIC;
    BEGIN
        second_block_value := inner_only; -- outer variable exists; local declarations do not cross scopes
        RAISE NOTICE 'Moved-to-outer variable is visible here: %', second_block_value;
    END;
END rental_report $$;
-- 6.4 From a block to a function
CREATE OR REPLACE FUNCTION fee_split(p_from_date DATE,
    OUT before_total NUMERIC, OUT after_total NUMERIC) AS $$
BEGIN
    SELECT COALESCE(SUM(fee) FILTER (WHERE start_date < p_from_date),0),
           COALESCE(SUM(fee) FILTER (WHERE start_date >= p_from_date),0)
    INTO before_total, after_total FROM rentals;
END; $$ LANGUAGE plpgsql;
SELECT * FROM fee_split(DATE '2025-01-01');
SELECT before_total+after_total AS all_fees FROM fee_split(DATE '2025-01-01');
-- Part 7 Practical Scenarios
-- 7.1 Station occupancy
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT, OUT bikes_parked INT, OUT capacity_pct NUMERIC
) AS $$
DECLARE v_capacity INT;
BEGIN
    SELECT s.capacity, COUNT(b.bike_id)::INT INTO v_capacity, bikes_parked
    FROM stations s LEFT JOIN bikes b ON b.station_id=s.station_id
    WHERE s.station_id=p_station_id GROUP BY s.capacity;
    IF NOT FOUND THEN
        bikes_parked := NULL; capacity_pct := NULL;
    ELSIF v_capacity=0 THEN
        capacity_pct := NULL;
    ELSE
        capacity_pct := ROUND(bikes_parked::NUMERIC*100/v_capacity,1);
    END IF;
END; $$ LANGUAGE plpgsql;
SELECT s.station_id, s.station_name, l.*
FROM stations s, LATERAL station_load(s.station_id) l ORDER BY s.station_id;
-- 7.2 Top members, with a default
CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
RETURNS TABLE(member_name VARCHAR, rental_count BIGINT, amount_spent NUMERIC) AS $$
BEGIN
    RETURN QUERY SELECT m.full_name::VARCHAR, COUNT(r.rental_id),
                        COALESCE(SUM(r.fee),0)::NUMERIC
    FROM members m LEFT JOIN rentals r ON r.member_id=m.member_id
    GROUP BY m.member_id, m.full_name
    ORDER BY COALESCE(SUM(r.fee),0) DESC, m.member_id
    LIMIT p_limit;
END; $$ LANGUAGE plpgsql;
SELECT * FROM top_members();
SELECT * FROM top_members(6);
-- 7.3 An invoice for an open rental
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE(member_name VARCHAR, bike_model VARCHAR, duration_days INT,
              amount_owed NUMERIC, rental_status VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name::VARCHAR, b.model::VARCHAR,
           (COALESCE(r.end_date,CURRENT_DATE)-r.start_date)::INT,
           ROUND((COALESCE(r.end_date,CURRENT_DATE)-r.start_date)::NUMERIC*b.daily_rate,2),
           CASE WHEN r.end_date IS NULL THEN 'OPEN'::VARCHAR ELSE 'CLOSED'::VARCHAR END
    FROM rentals r JOIN members m ON m.member_id=r.member_id
    JOIN bikes b ON b.bike_id=r.bike_id WHERE r.rental_id=p_rental_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);
-- 7.4 A report per city
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR)
RETURNS TABLE(city_members BIGINT, city_rentals BIGINT, city_revenue NUMERIC) AS $$
BEGIN
    RETURN QUERY SELECT COUNT(DISTINCT m.member_id), COUNT(r.rental_id),
                        COALESCE(SUM(r.fee),0)::NUMERIC
    FROM members m LEFT JOIN rentals r ON r.member_id=m.member_id
    WHERE m.city=p_city;
END; $$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR, p_from_date DATE)
RETURNS TABLE(city_members BIGINT, city_rentals BIGINT, city_revenue NUMERIC) AS $$
BEGIN
    RETURN QUERY SELECT COUNT(DISTINCT m.member_id), COUNT(r.rental_id),
                        COALESCE(SUM(r.fee),0)::NUMERIC
    FROM members m LEFT JOIN rentals r
      ON r.member_id=m.member_id AND r.start_date>=p_from_date
    WHERE m.city=p_city;
END; $$ LANGUAGE plpgsql;
SELECT * FROM city_report('Almaty');
SELECT * FROM city_report('Almaty',DATE '2025-01-01');