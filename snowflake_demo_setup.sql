-- CrunchTime! Snowflake Multi-Cluster Warehouse Demo Setup
-- Demo: Showing warehouse utilization improvements with Multi-Cluster Warehouses

-- 1. Create demo environment
USE ROLE ACCOUNTADMIN;

-- Create database and schema
CREATE DATABASE IF NOT EXISTS CRUNCHTIME_DEMO;
USE DATABASE CRUNCHTIME_DEMO;
CREATE SCHEMA IF NOT EXISTS RESTAURANT_DATA;
USE SCHEMA RESTAURANT_DATA;

-- 2. Create warehouses for the demo
-- Initial warehouse without multi-cluster
CREATE OR REPLACE WAREHOUSE CRUNCHTIME_WH_SINGLE
  WITH WAREHOUSE_SIZE = 'MEDIUM'
       AUTO_SUSPEND = 60
       AUTO_RESUME = TRUE
       MIN_CLUSTER_COUNT = 1
       MAX_CLUSTER_COUNT = 1
       SCALING_POLICY = 'STANDARD';

-- Multi-cluster warehouse for comparison
CREATE OR REPLACE WAREHOUSE CRUNCHTIME_WH_MULTI
  WITH WAREHOUSE_SIZE = 'MEDIUM'
       AUTO_SUSPEND = 60
       AUTO_RESUME = TRUE
       MIN_CLUSTER_COUNT = 1
       MAX_CLUSTER_COUNT = 3
       SCALING_POLICY = 'STANDARD';

-- 3. Create tables relevant to CrunchTime!'s restaurant business
-- Restaurants table
CREATE OR REPLACE TABLE RESTAURANTS (
    restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
    restaurant_name VARCHAR(100),
    location_city VARCHAR(50),
    location_state VARCHAR(2),
    cuisine_type VARCHAR(30),
    opening_date DATE,
    square_footage INT,
    seating_capacity INT
);

-- Menu items table
CREATE OR REPLACE TABLE MENU_ITEMS (
    item_id INT IDENTITY(1,1) PRIMARY KEY,
    restaurant_id INT,
    item_name VARCHAR(100),
    category VARCHAR(30),
    price DECIMAL(8,2),
    cost_of_goods DECIMAL(8,2),
    prep_time_minutes INT,
    calories INT,
    FOREIGN KEY (restaurant_id) REFERENCES RESTAURANTS(restaurant_id)
);

-- Sales transactions table (large table for performance testing)
CREATE OR REPLACE TABLE SALES_TRANSACTIONS (
    transaction_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    restaurant_id INT,
    item_id INT,
    transaction_date TIMESTAMP_NTZ,
    quantity INT,
    unit_price DECIMAL(8,2),
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(20),
    server_id INT,
    table_number INT,
    FOREIGN KEY (restaurant_id) REFERENCES RESTAURANTS(restaurant_id),
    FOREIGN KEY (item_id) REFERENCES MENU_ITEMS(item_id)
);

-- Inventory movements table
CREATE OR REPLACE TABLE INVENTORY_MOVEMENTS (
    movement_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    restaurant_id INT,
    ingredient_name VARCHAR(100),
    movement_type VARCHAR(20), -- 'PURCHASE', 'USAGE', 'WASTE', 'ADJUSTMENT'
    quantity_change DECIMAL(10,3),
    unit_of_measure VARCHAR(20),
    cost_per_unit DECIMAL(8,4),
    movement_date TIMESTAMP_NTZ,
    supplier_id INT,
    FOREIGN KEY (restaurant_id) REFERENCES RESTAURANTS(restaurant_id)
);

-- Labor scheduling table
CREATE OR REPLACE TABLE LABOR_SCHEDULE (
    schedule_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    restaurant_id INT,
    employee_id INT,
    shift_date DATE,
    start_time TIME,
    end_time TIME,
    position VARCHAR(30),
    hourly_rate DECIMAL(6,2),
    scheduled_hours DECIMAL(4,2),
    actual_hours DECIMAL(4,2),
    FOREIGN KEY (restaurant_id) REFERENCES RESTAURANTS(restaurant_id)
);

-- 4. Insert sample data
-- Insert restaurants
INSERT INTO RESTAURANTS (restaurant_name, location_city, location_state, cuisine_type, opening_date, square_footage, seating_capacity)
VALUES 
('Bella Vista Italian', 'New York', 'NY', 'Italian', '2020-03-15', 2500, 80),
('Spice Garden', 'Los Angeles', 'CA', 'Indian', '2019-08-22', 1800, 60),
('Ocean Breeze Seafood', 'Miami', 'FL', 'Seafood', '2021-01-10', 3000, 100),
('Mountain View Grill', 'Denver', 'CO', 'American', '2018-05-30', 2200, 75),
('Sakura Sushi', 'San Francisco', 'CA', 'Japanese', '2020-11-05', 1500, 50),
('Tex-Mex Fiesta', 'Austin', 'TX', 'Mexican', '2019-12-01', 2000, 70),
('Green Garden Cafe', 'Portland', 'OR', 'Vegetarian', '2021-06-15', 1200, 40),
('Chicago Deep Dish', 'Chicago', 'IL', 'Pizza', '2018-09-12', 1800, 65),
('Bourbon Street Bistro', 'New Orleans', 'LA', 'Cajun', '2020-02-28', 1600, 55),
('Pacific Northwest', 'Seattle', 'WA', 'American', '2019-04-18', 2400, 85);

-- Generate menu items for each restaurant
INSERT INTO MENU_ITEMS (restaurant_id, item_name, category, price, cost_of_goods, prep_time_minutes, calories)
SELECT 
    r.restaurant_id,
    CASE 
        WHEN r.cuisine_type = 'Italian' THEN 
            CASE ROW_NUMBER() OVER (PARTITION BY r.restaurant_id ORDER BY RANDOM()) % 8
                WHEN 0 THEN 'Margherita Pizza'
                WHEN 1 THEN 'Spaghetti Carbonara'
                WHEN 2 THEN 'Chicken Parmigiana'
                WHEN 3 THEN 'Caesar Salad'
                WHEN 4 THEN 'Tiramisu'
                WHEN 5 THEN 'Lasagna'
                WHEN 6 THEN 'Risotto Mushroom'
                ELSE 'Bruschetta'
            END
        WHEN r.cuisine_type = 'Indian' THEN 
            CASE ROW_NUMBER() OVER (PARTITION BY r.restaurant_id ORDER BY RANDOM()) % 8
                WHEN 0 THEN 'Butter Chicken'
                WHEN 1 THEN 'Biryani'
                WHEN 2 THEN 'Tandoori Salmon'
                WHEN 3 THEN 'Naan Bread'
                WHEN 4 THEN 'Samosas'
                WHEN 5 THEN 'Dal Curry'
                WHEN 6 THEN 'Mango Lassi'
                ELSE 'Palak Paneer'
            END
        ELSE 'Signature Dish'
    END as item_name,
    CASE ROW_NUMBER() OVER (PARTITION BY r.restaurant_id ORDER BY RANDOM()) % 4
        WHEN 0 THEN 'Appetizer'
        WHEN 1 THEN 'Main Course'
        WHEN 2 THEN 'Dessert'
        ELSE 'Beverage'
    END as category,
    ROUND(UNIFORM(8.99, 35.99, RANDOM())::DECIMAL(8,2), 2) as price,
    ROUND(UNIFORM(3.50, 18.99, RANDOM())::DECIMAL(8,2), 2) as cost_of_goods,
    UNIFORM(5, 45, RANDOM()) as prep_time_minutes,
    UNIFORM(150, 850, RANDOM()) as calories
FROM RESTAURANTS r
CROSS JOIN (SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) as rn FROM TABLE(GENERATOR(ROWCOUNT => 12))) g
WHERE g.rn <= 12;
