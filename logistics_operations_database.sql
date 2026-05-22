-- STEP 1: Create the database
DROP DATABASE IF EXISTS logistics_operations_db;
CREATE DATABASE logistics_operations_db;
USE logistics_operations_db;

-- Create all tables
USE logistics_operations_db;

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_type VARCHAR(50),
    credit_terms_days INT,
    primary_freight_type VARCHAR(50),
    account_status VARCHAR(50),
    contract_start_date DATE,
    annual_revenue_potential DECIMAL(12,2)
);

CREATE TABLE drivers (
    driver_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date DATE,
    termination_date DATE NULL,
    license_number VARCHAR(50),
    license_state VARCHAR(10),
    date_of_birth DATE,
    home_terminal VARCHAR(50),
    employment_status VARCHAR(50),
    cdl_class VARCHAR(10),
    years_experience INT
);

CREATE TABLE trucks (
    truck_id VARCHAR(20) PRIMARY KEY,
    unit_number INT,
    make VARCHAR(50),
    model_year INT,
    vin VARCHAR(50),
    acquisition_date DATE,
    acquisition_mileage INT,
    fuel_type VARCHAR(50),
    tank_capacity_gallons INT,
    status VARCHAR(50),
    home_terminal VARCHAR(50)
);

CREATE TABLE trailers (
    trailer_id VARCHAR(20) PRIMARY KEY,
    trailer_number INT,
    trailer_type VARCHAR(50),
    length_feet INT,
    model_year INT,
    vin VARCHAR(50),
    acquisition_date DATE,
    status VARCHAR(50),
    current_location VARCHAR(50)
);

CREATE TABLE routes (
    route_id VARCHAR(20) PRIMARY KEY,
    origin_city VARCHAR(50),
    origin_state VARCHAR(10),
    destination_city VARCHAR(50),
    destination_state VARCHAR(10),
    typical_distance_miles INT,
    base_rate_per_mile DECIMAL(10,2),
    fuel_surcharge_rate DECIMAL(10,3),
    typical_transit_days INT
);

CREATE TABLE facilities (
    facility_id VARCHAR(20) PRIMARY KEY,
    facility_name VARCHAR(100),
    facility_type VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(10),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    dock_doors INT,
    operating_hours VARCHAR(50)
);

CREATE TABLE loads (
    load_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    route_id VARCHAR(20),
    load_date DATE,
    load_type VARCHAR(50),
    weight_lbs INT,
    pieces INT,
    revenue DECIMAL(12,2),
    fuel_surcharge DECIMAL(12,2),
    accessorial_charges DECIMAL(12,2),
    load_status VARCHAR(50),
    booking_type VARCHAR(50),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (route_id) REFERENCES routes(route_id)
);

CREATE TABLE trips (
    trip_id VARCHAR(20) PRIMARY KEY,
    load_id VARCHAR(20),
    driver_id VARCHAR(20) NULL,
    truck_id VARCHAR(20) NULL,
    trailer_id VARCHAR(20) NULL,
    dispatch_date DATE,
    actual_distance_miles INT,
    actual_duration_hours DECIMAL(10,2),
    fuel_gallons_used DECIMAL(10,2),
    average_mpg DECIMAL(10,2),
    idle_time_hours DECIMAL(10,2),
    trip_status VARCHAR(50),

    FOREIGN KEY (load_id) REFERENCES loads(load_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    FOREIGN KEY (truck_id) REFERENCES trucks(truck_id),
    FOREIGN KEY (trailer_id) REFERENCES trailers(trailer_id)
);

CREATE TABLE delivery_events (
    event_id VARCHAR(20) PRIMARY KEY,
    load_id VARCHAR(20),
    trip_id VARCHAR(20),
    event_type VARCHAR(50),
    facility_id VARCHAR(20),
    scheduled_datetime DATETIME,
    actual_datetime DATETIME,
    detention_minutes INT,
    on_time_flag BOOLEAN,
    location_city VARCHAR(50),
    location_state VARCHAR(10),

    FOREIGN KEY (load_id) REFERENCES loads(load_id),
    FOREIGN KEY (trip_id) REFERENCES trips(trip_id),
    FOREIGN KEY (facility_id) REFERENCES facilities(facility_id)
);

CREATE TABLE fuel_purchases (
    fuel_purchase_id VARCHAR(20) PRIMARY KEY,
    trip_id VARCHAR(20),
    truck_id VARCHAR(20) NULL,
    driver_id VARCHAR(20) NULL,
    purchase_date DATETIME,
    location_city VARCHAR(50),
    location_state VARCHAR(10),
    gallons DECIMAL(10,2),
    price_per_gallon DECIMAL(10,3),
    total_cost DECIMAL(12,2),
    fuel_card_number VARCHAR(50),

    FOREIGN KEY (trip_id) REFERENCES trips(trip_id),
    FOREIGN KEY (truck_id) REFERENCES trucks(truck_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

CREATE TABLE maintenance_records (
    maintenance_id VARCHAR(20) PRIMARY KEY,
    truck_id VARCHAR(20),
    maintenance_date DATE,
    maintenance_type VARCHAR(50),
    odometer_reading INT,
    labor_hours DECIMAL(10,2),
    labor_cost DECIMAL(12,2),
    parts_cost DECIMAL(12,2),
    total_cost DECIMAL(12,2),
    facility_location VARCHAR(100),
    downtime_hours DECIMAL(10,2),
    service_description TEXT,

    FOREIGN KEY (truck_id) REFERENCES trucks(truck_id)
);

CREATE TABLE safety_incidents (
    incident_id VARCHAR(20) PRIMARY KEY,
    trip_id VARCHAR(20),
    truck_id VARCHAR(20) NULL,
    driver_id VARCHAR(20) NULL,
    incident_date DATETIME,
    incident_type VARCHAR(50),
    location_city VARCHAR(50),
    location_state VARCHAR(10),
    at_fault_flag BOOLEAN,
    injury_flag BOOLEAN,
    vehicle_damage_cost DECIMAL(12,2),
    cargo_damage_cost DECIMAL(12,2),
    claim_amount DECIMAL(12,2),
    preventable_flag BOOLEAN,
    description TEXT,

    FOREIGN KEY (trip_id) REFERENCES trips(trip_id),
    FOREIGN KEY (truck_id) REFERENCES trucks(truck_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

CREATE TABLE driver_monthly_metrics (
    driver_id VARCHAR(20),
    month DATE,
    trips_completed INT,
    total_miles INT,
    total_revenue DECIMAL(12,2),
    average_mpg DECIMAL(10,2),
    total_fuel_gallons DECIMAL(12,2),
    on_time_delivery_rate DECIMAL(10,3),
    average_idle_hours DECIMAL(10,2),

    PRIMARY KEY (driver_id, month),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

CREATE TABLE truck_utilization_metrics (
    truck_id VARCHAR(20),
    month DATE,
    trips_completed INT,
    total_miles INT,
    total_revenue DECIMAL(12,2),
    average_mpg DECIMAL(10,2),
    maintenance_events INT,
    maintenance_cost DECIMAL(12,2),
    downtime_hours DECIMAL(10,2),
    utilization_rate DECIMAL(10,3),

    PRIMARY KEY (truck_id, month),
    FOREIGN KEY (truck_id) REFERENCES trucks(truck_id)
);
-- LOAD CUSTOMERS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_customers FROM customers;
SELECT * FROM customers LIMIT 5;

-- LOAD DRIVERS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/drivers.csv'
INTO TABLE drivers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
driver_id,
first_name,
last_name,
hire_date,
@termination_date,
license_number,
license_state,
date_of_birth,
home_terminal,
employment_status,
cdl_class,
years_experience
)
SET termination_date = NULLIF(@termination_date, '');

SELECT COUNT(*) AS total_drivers FROM drivers;
SELECT * FROM drivers LIMIT 5;

-- Load trucks
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/trucks.csv'
INTO TABLE trucks
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_trucks FROM trucks;
SELECT * FROM trucks LIMIT 5;

-- Load trailers
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/trailers.csv'
INTO TABLE trailers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_trailers FROM trailers;
SELECT * FROM trailers LIMIT 5;

-- Load routes
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/routes.csv'
INTO TABLE routes
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_routes FROM routes;
SELECT * FROM routes LIMIT 5;

-- Load facilities
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/facilities.csv'
INTO TABLE facilities
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_facilities FROM facilities;
SELECT * FROM facilities LIMIT 5;

-- Load loads
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/loads.csv'
INTO TABLE loads
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_loads FROM loads;
SELECT * FROM loads LIMIT 5;

-- Load trips
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/trips.csv'
INTO TABLE trips
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
trip_id,
load_id,
@driver_id,
@truck_id,
@trailer_id,
dispatch_date,
actual_distance_miles,
actual_duration_hours,
fuel_gallons_used,
average_mpg,
idle_time_hours,
trip_status
)
SET
driver_id = NULLIF(@driver_id, ''),
truck_id = NULLIF(@truck_id, ''),
trailer_id = NULLIF(@trailer_id, '');

SELECT COUNT(*) AS total_trips FROM trips;
SELECT * FROM trips LIMIT 5;

-- Load delivery_events
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/delivery_events.csv'
INTO TABLE delivery_events
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
event_id,
load_id,
trip_id,
event_type,
facility_id,
scheduled_datetime,
actual_datetime,
detention_minutes,
@on_time_flag,
location_city,
location_state
)
SET on_time_flag =
CASE
    WHEN @on_time_flag = 'True' THEN 1
    ELSE 0
END;

SELECT COUNT(*) AS total_delivery_events
FROM delivery_events;

SELECT *
FROM delivery_events
LIMIT 5;

-- Load fuel_purchases
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fuel_purchases.csv'
INTO TABLE fuel_purchases
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
fuel_purchase_id,
trip_id,
@truck_id,
@driver_id,
purchase_date,
location_city,
location_state,
gallons,
price_per_gallon,
total_cost,
fuel_card_number
)
SET
truck_id = NULLIF(@truck_id, ''),
driver_id = NULLIF(@driver_id, '');

SELECT COUNT(*) AS total_fuel_purchases
FROM fuel_purchases;

SELECT *
FROM fuel_purchases
LIMIT 5;

-- Load maintenance_records
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/maintenance_records.csv'
INTO TABLE maintenance_records
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_maintenance_records
FROM maintenance_records;

SELECT *
FROM maintenance_records
LIMIT 5;

-- Load safety_incidents
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/safety_incidents.csv'
INTO TABLE safety_incidents
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
incident_id,
trip_id,
@truck_id,
@driver_id,
incident_date,
incident_type,
location_city,
location_state,
@at_fault_flag,
@injury_flag,
vehicle_damage_cost,
cargo_damage_cost,
claim_amount,
@preventable_flag,
description
)
SET
truck_id = NULLIF(@truck_id, ''),
driver_id = NULLIF(@driver_id, ''),
at_fault_flag =
CASE
    WHEN @at_fault_flag = 'True' THEN 1
    ELSE 0
END,
injury_flag =
CASE
    WHEN @injury_flag = 'True' THEN 1
    ELSE 0
END,
preventable_flag =
CASE
    WHEN @preventable_flag = 'True' THEN 1
    ELSE 0
END;

SELECT COUNT(*) AS total_safety_incidents
FROM safety_incidents;

SELECT *
FROM safety_incidents
LIMIT 5;

-- Load driver_monthly_metrics
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/driver_monthly_metrics.csv'
INTO TABLE driver_monthly_metrics
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_driver_monthly_metrics
FROM driver_monthly_metrics;

SELECT *
FROM driver_monthly_metrics
LIMIT 5;

-- Load truck_utilization_metrics
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/truck_utilization_metrics.csv'
INTO TABLE truck_utilization_metrics
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_truck_utilization_metrics
FROM truck_utilization_metrics;

SELECT *
FROM truck_utilization_metrics
LIMIT 5;

-- final validation
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL
SELECT 'trucks', COUNT(*) FROM trucks
UNION ALL
SELECT 'trailers', COUNT(*) FROM trailers
UNION ALL
SELECT 'routes', COUNT(*) FROM routes
UNION ALL
SELECT 'facilities', COUNT(*) FROM facilities
UNION ALL
SELECT 'loads', COUNT(*) FROM loads
UNION ALL
SELECT 'trips', COUNT(*) FROM trips
UNION ALL
SELECT 'delivery_events', COUNT(*) FROM delivery_events
UNION ALL
SELECT 'fuel_purchases', COUNT(*) FROM fuel_purchases
UNION ALL
SELECT 'maintenance_records', COUNT(*) FROM maintenance_records
UNION ALL
SELECT 'safety_incidents', COUNT(*) FROM safety_incidents
UNION ALL
SELECT 'driver_monthly_metrics', COUNT(*) FROM driver_monthly_metrics
UNION ALL
SELECT 'truck_utilization_metrics', COUNT(*) FROM truck_utilization_metrics;

SELECT l.load_id
FROM loads l
LEFT JOIN customers c ON l.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT t.trip_id
FROM trips t
LEFT JOIN loads l ON t.load_id = l.load_id
WHERE l.load_id IS NULL;

-- Now run these SQL analysis queries one by one
-- 1. Revenue by customer
SELECT
    c.customer_name,
    c.customer_type,
    COUNT(l.load_id) AS total_loads,
    SUM(l.revenue) AS total_revenue,
    SUM(l.fuel_surcharge) AS total_fuel_surcharge,
    SUM(l.accessorial_charges) AS total_accessorial_charges,
    SUM(l.revenue + l.fuel_surcharge + l.accessorial_charges) AS gross_revenue
FROM loads l
JOIN customers c ON l.customer_id = c.customer_id
GROUP BY c.customer_name, c.customer_type
ORDER BY gross_revenue DESC;

-- 2. Route profitability
SELECT
    r.route_id,
    CONCAT(r.origin_city, ', ', r.origin_state, ' to ', r.destination_city, ', ', r.destination_state) AS route_name,
    COUNT(l.load_id) AS total_loads,
    SUM(l.revenue + l.fuel_surcharge + l.accessorial_charges) AS gross_revenue,
    SUM(t.fuel_gallons_used) AS total_fuel_gallons,
    SUM(t.actual_distance_miles) AS total_miles,
    ROUND(SUM(l.revenue + l.fuel_surcharge + l.accessorial_charges) / NULLIF(SUM(t.actual_distance_miles), 0), 2) AS revenue_per_mile
FROM loads l
JOIN routes r ON l.route_id = r.route_id
LEFT JOIN trips t ON l.load_id = t.load_id
GROUP BY r.route_id, route_name
ORDER BY gross_revenue DESC;

-- 3. On-time delivery performance
SELECT
    event_type,
    COUNT(*) AS total_events,
    SUM(on_time_flag) AS on_time_events,
    ROUND(SUM(on_time_flag) / COUNT(*) * 100, 2) AS on_time_rate_percent,
    AVG(detention_minutes) AS avg_detention_minutes
FROM delivery_events
GROUP BY event_type
ORDER BY on_time_rate_percent DESC;

-- 4. Driver performance
SELECT
    d.driver_id,
    CONCAT(d.first_name, ' ', d.last_name) AS driver_name,
    d.home_terminal,
    COUNT(t.trip_id) AS total_trips,
    SUM(t.actual_distance_miles) AS total_miles,
    ROUND(AVG(t.average_mpg), 2) AS avg_mpg,
    ROUND(AVG(t.idle_time_hours), 2) AS avg_idle_hours,
    SUM(l.revenue + l.fuel_surcharge + l.accessorial_charges) AS revenue_handled
FROM trips t
JOIN drivers d ON t.driver_id = d.driver_id
JOIN loads l ON t.load_id = l.load_id
GROUP BY d.driver_id, driver_name, d.home_terminal
ORDER BY revenue_handled DESC;

-- 5. Truck utilization
SELECT
    tr.truck_id,
    tr.unit_number,
    tr.make,
    tr.model_year,
    COUNT(t.trip_id) AS total_trips,
    SUM(t.actual_distance_miles) AS total_miles,
    ROUND(AVG(t.average_mpg), 2) AS avg_mpg,
    SUM(l.revenue + l.fuel_surcharge + l.accessorial_charges) AS revenue_generated
FROM trips t
JOIN trucks tr ON t.truck_id = tr.truck_id
JOIN loads l ON t.load_id = l.load_id
GROUP BY tr.truck_id, tr.unit_number, tr.make, tr.model_year
ORDER BY revenue_generated DESC;

-- 6. Fuel cost analysis
SELECT
    truck_id,
    COUNT(fuel_purchase_id) AS total_fuel_purchases,
    SUM(gallons) AS total_gallons,
    ROUND(AVG(price_per_gallon), 2) AS avg_price_per_gallon,
    SUM(total_cost) AS total_fuel_cost
FROM fuel_purchases
GROUP BY truck_id
ORDER BY total_fuel_cost DESC;

-- 7. Maintenance cost by truck
SELECT
    tr.truck_id,
    tr.unit_number,
    COUNT(m.maintenance_id) AS maintenance_events,
    SUM(m.total_cost) AS total_maintenance_cost,
    SUM(m.downtime_hours) AS total_downtime_hours,
    ROUND(AVG(m.total_cost), 2) AS avg_maintenance_cost
FROM maintenance_records m
JOIN trucks tr ON m.truck_id = tr.truck_id
GROUP BY tr.truck_id, tr.unit_number
ORDER BY total_maintenance_cost DESC;

-- 8. Safety incident analysis
SELECT
    incident_type,
    COUNT(*) AS total_incidents,
    SUM(at_fault_flag) AS at_fault_incidents,
    SUM(injury_flag) AS injury_incidents,
    SUM(preventable_flag) AS preventable_incidents,
    SUM(vehicle_damage_cost + cargo_damage_cost + claim_amount) AS total_incident_cost
FROM safety_incidents
GROUP BY incident_type
ORDER BY total_incident_cost DESC;

-- 9. Monthly revenue trend
SELECT
    DATE_FORMAT(load_date, '%Y-%m') AS month,
    COUNT(load_id) AS total_loads,
    SUM(revenue + fuel_surcharge + accessorial_charges) AS gross_revenue
FROM loads
GROUP BY DATE_FORMAT(load_date, '%Y-%m')
ORDER BY month;

-- 10. Executive KPI summary
SELECT
    COUNT(DISTINCT l.load_id) AS total_loads,
    COUNT(DISTINCT t.trip_id) AS total_trips,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT d.driver_id) AS active_drivers,
    COUNT(DISTINCT tr.truck_id) AS active_trucks,
    SUM(l.revenue + l.fuel_surcharge + l.accessorial_charges) AS gross_revenue,
    ROUND(AVG(t.average_mpg), 2) AS avg_fuel_efficiency_mpg,
    ROUND(AVG(t.idle_time_hours), 2) AS avg_idle_hours
FROM loads l
LEFT JOIN trips t ON l.load_id = t.load_id
LEFT JOIN customers c ON l.customer_id = c.customer_id
LEFT JOIN drivers d ON t.driver_id = d.driver_id
LEFT JOIN trucks tr ON t.truck_id = tr.truck_id;

-- Power BI dashboard SQL view. It combines the key logistics metrics in one clean dataset.
CREATE OR REPLACE VIEW logistics_dashboard_view AS
SELECT
    l.load_id,
    l.load_date,
    DATE_FORMAT(l.load_date, '%Y-%m') AS load_month,

    c.customer_id,
    c.customer_name,
    c.customer_type,

    r.route_id,
    CONCAT(r.origin_city, ', ', r.origin_state, ' to ', r.destination_city, ', ', r.destination_state) AS route_name,
    r.typical_distance_miles,

    t.trip_id,
    t.driver_id,
    CONCAT(d.first_name, ' ', d.last_name) AS driver_name,
    d.home_terminal AS driver_terminal,

    t.truck_id,
    tr.unit_number,
    tr.make AS truck_make,
    tr.model_year,

    t.trailer_id,

    l.load_type,
    l.load_status,
    l.booking_type,
    l.weight_lbs,
    l.pieces,

    l.revenue,
    l.fuel_surcharge,
    l.accessorial_charges,
    (l.revenue + l.fuel_surcharge + l.accessorial_charges) AS gross_revenue,

    t.actual_distance_miles,
    t.actual_duration_hours,
    t.fuel_gallons_used,
    t.average_mpg,
    t.idle_time_hours,
    t.trip_status,

    ROUND(
        (l.revenue + l.fuel_surcharge + l.accessorial_charges) 
        / NULLIF(t.actual_distance_miles, 0), 2
    ) AS revenue_per_mile,

    ROUND(
        t.fuel_gallons_used / NULLIF(t.actual_distance_miles, 0), 4
    ) AS fuel_per_mile,

    CASE
        WHEN l.load_status = 'Delivered' THEN 1
        ELSE 0
    END AS delivered_load_flag

FROM loads l
LEFT JOIN customers c ON l.customer_id = c.customer_id
LEFT JOIN routes r ON l.route_id = r.route_id
LEFT JOIN trips t ON l.load_id = t.load_id
LEFT JOIN drivers d ON t.driver_id = d.driver_id
LEFT JOIN trucks tr ON t.truck_id = tr.truck_id;

SELECT * 
FROM logistics_dashboard_view
LIMIT 20;

SELECT * FROM logistics_dashboard_view;

-- Supply Chain & Inventory Analytics Dashboard SQL view.
CREATE OR REPLACE VIEW supply_chain_inventory_dashboard_view AS
SELECT
    l.load_id,
    l.load_date,
    DATE_FORMAT(l.load_date, '%Y-%m') AS load_month,

    c.customer_id,
    c.customer_name,
    c.customer_type,
    c.primary_freight_type,

    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state,
    CONCAT(r.origin_city, ', ', r.origin_state, ' to ', r.destination_city, ', ', r.destination_state) AS route_name,

    l.load_type AS product_or_freight_type,
    l.weight_lbs,
    l.pieces,

    l.load_status,
    l.booking_type,

    t.trip_id,
    t.dispatch_date,
    t.actual_distance_miles,
    t.actual_duration_hours,
    t.trip_status,

    de.event_type,
    de.facility_id,
    f.facility_name,
    f.facility_type,
    f.city AS facility_city,
    f.state AS facility_state,
    de.scheduled_datetime,
    de.actual_datetime,
    de.detention_minutes,
    de.on_time_flag,

    l.revenue,
    l.fuel_surcharge,
    l.accessorial_charges,
    (l.revenue + l.fuel_surcharge + l.accessorial_charges) AS gross_revenue,

    CASE 
        WHEN l.load_status = 'Delivered' THEN 1 
        ELSE 0 
    END AS delivered_flag,

    CASE 
        WHEN de.on_time_flag = 1 THEN 1 
        ELSE 0 
    END AS on_time_delivery_flag,

    CASE 
        WHEN de.detention_minutes > 0 THEN 1 
        ELSE 0 
    END AS detention_flag,

    ROUND(
        (l.revenue + l.fuel_surcharge + l.accessorial_charges) 
        / NULLIF(l.weight_lbs, 0), 2
    ) AS revenue_per_lb,

    ROUND(
        (l.revenue + l.fuel_surcharge + l.accessorial_charges) 
        / NULLIF(l.pieces, 0), 2
    ) AS revenue_per_piece,

    ROUND(
        t.actual_duration_hours / NULLIF(t.actual_distance_miles, 0), 4
    ) AS hours_per_mile

FROM loads l
LEFT JOIN customers c 
    ON l.customer_id = c.customer_id
LEFT JOIN routes r 
    ON l.route_id = r.route_id
LEFT JOIN trips t 
    ON l.load_id = t.load_id
LEFT JOIN delivery_events de 
    ON l.load_id = de.load_id
LEFT JOIN facilities f 
    ON de.facility_id = f.facility_id;

SELECT *
FROM supply_chain_inventory_dashboard_view
LIMIT 20;

SELECT *
FROM supply_chain_inventory_dashboard_view;

-- Executive Logistics Overview Dashboard
CREATE OR REPLACE VIEW executive_logistics_overview_view AS
SELECT
    l.load_id,
    l.load_date,
    DATE_FORMAT(l.load_date, '%Y-%m') AS load_month,

    c.customer_id,
    c.customer_name,
    c.customer_type,

    r.route_id,
    CONCAT(r.origin_city, ', ', r.origin_state, ' to ', r.destination_city, ', ', r.destination_state) AS route_name,

    t.trip_id,
    t.dispatch_date,
    t.driver_id,
    CONCAT(d.first_name, ' ', d.last_name) AS driver_name,
    t.truck_id,
    tr.unit_number AS truck_number,

    l.load_status,
    t.trip_status,
    l.load_type,
    l.booking_type,

    l.revenue,
    l.fuel_surcharge,
    l.accessorial_charges,
    (l.revenue + l.fuel_surcharge + l.accessorial_charges) AS gross_revenue,

    t.actual_distance_miles,
    t.actual_duration_hours,
    t.fuel_gallons_used,
    t.average_mpg,
    t.idle_time_hours,

    ROUND(
        (l.revenue + l.fuel_surcharge + l.accessorial_charges)
        / NULLIF(t.actual_distance_miles, 0), 2
    ) AS revenue_per_mile,

    CASE 
        WHEN l.load_status = 'Delivered' THEN 1 
        ELSE 0 
    END AS delivered_load_flag,

    CASE 
        WHEN t.trip_status = 'Completed' THEN 1 
        ELSE 0 
    END AS completed_trip_flag

FROM loads l
LEFT JOIN customers c ON l.customer_id = c.customer_id
LEFT JOIN routes r ON l.route_id = r.route_id
LEFT JOIN trips t ON l.load_id = t.load_id
LEFT JOIN drivers d ON t.driver_id = d.driver_id
LEFT JOIN trucks tr ON t.truck_id = tr.truck_id;

SELECT *
FROM executive_logistics_overview_view
LIMIT 20;

SELECT *
FROM executive_logistics_overview_view;

-- Fleet Performance Dashboard.
DROP VIEW IF EXISTS fleet_performance_dashboard_view;

CREATE VIEW fleet_performance_dashboard_view AS
SELECT
    tr.truck_id,
    tr.unit_number,
    tr.make,
    tr.model_year,
    tr.fuel_type,
    tr.status AS truck_status,
    tr.home_terminal,

    DATE_FORMAT(t.dispatch_date, '%Y-%m') AS performance_month,

    COUNT(DISTINCT t.trip_id) AS total_trips,
    COUNT(DISTINCT l.load_id) AS total_loads,

    SUM(t.actual_distance_miles) AS total_miles,
    SUM(t.actual_duration_hours) AS total_hours,
    SUM(t.fuel_gallons_used) AS total_fuel_gallons,

    ROUND(AVG(t.average_mpg), 2) AS avg_mpg,
    ROUND(AVG(t.idle_time_hours), 2) AS avg_idle_hours,

    SUM(l.revenue + l.fuel_surcharge + l.accessorial_charges) AS gross_revenue,

    ROUND(
        SUM(l.revenue + l.fuel_surcharge + l.accessorial_charges)
        / NULLIF(SUM(t.actual_distance_miles), 0), 2
    ) AS revenue_per_mile,

    COALESCE(m.maintenance_events, 0) AS maintenance_events,
    COALESCE(m.total_maintenance_cost, 0) AS total_maintenance_cost,
    COALESCE(m.total_downtime_hours, 0) AS total_downtime_hours,

    ROUND(
        COALESCE(m.total_maintenance_cost, 0)
        / NULLIF(SUM(t.actual_distance_miles), 0), 2
    ) AS maintenance_cost_per_mile,

    COALESCE(s.safety_incidents, 0) AS safety_incidents,
    COALESCE(s.total_incident_cost, 0) AS total_incident_cost

FROM trucks tr
LEFT JOIN trips t
    ON tr.truck_id = t.truck_id
LEFT JOIN loads l
    ON t.load_id = l.load_id

LEFT JOIN (
    SELECT
        truck_id,
        COUNT(*) AS maintenance_events,
        SUM(total_cost) AS total_maintenance_cost,
        SUM(downtime_hours) AS total_downtime_hours
    FROM maintenance_records
    GROUP BY truck_id
) m
    ON tr.truck_id = m.truck_id

LEFT JOIN (
    SELECT
        truck_id,
        COUNT(*) AS safety_incidents,
        SUM(vehicle_damage_cost + cargo_damage_cost + claim_amount) AS total_incident_cost
    FROM safety_incidents
    GROUP BY truck_id
) s
    ON tr.truck_id = s.truck_id

GROUP BY
    tr.truck_id,
    tr.unit_number,
    tr.make,
    tr.model_year,
    tr.fuel_type,
    tr.status,
    tr.home_terminal,
    DATE_FORMAT(t.dispatch_date, '%Y-%m'),
    m.maintenance_events,
    m.total_maintenance_cost,
    m.total_downtime_hours,
    s.safety_incidents,
    s.total_incident_cost;

SELECT *
FROM fleet_performance_dashboard_view
LIMIT 20;

SELECT *
FROM fleet_performance_dashboard_view