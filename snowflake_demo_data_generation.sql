-- CrunchTime! Demo - Large Dataset Generation for Performance Testing
-- This script generates substantial data to demonstrate warehouse queuing vs concurrency

USE DATABASE CRUNCHTIME_DEMO;
USE SCHEMA RESTAURANT_DATA;

-- Generate large sales transaction dataset (2+ million records for realistic queuing)
-- This will create data for the past 2 years across all restaurants
INSERT INTO SALES_TRANSACTIONS (restaurant_id, item_id, transaction_date, quantity, unit_price, total_amount, payment_method, server_id, table_number)
WITH date_range AS (
    SELECT DATEADD(day, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, '2022-01-01'::DATE) as transaction_date
    FROM TABLE(GENERATOR(ROWCOUNT => 730))
),
hourly_slots AS (
    SELECT DATEADD(hour, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, '00:00:00'::TIME) as hour_slot
    FROM TABLE(GENERATOR(ROWCOUNT => 16)) -- 8 AM to 11 PM (16 hours)
),
transaction_base AS (
    SELECT 
        r.restaurant_id,
        mi.item_id,
        mi.price as base_price,
        DATEADD(hour, h.hour_slot, d.transaction_date) as transaction_datetime
    FROM RESTAURANTS r
    CROSS JOIN MENU_ITEMS mi
    CROSS JOIN date_range d
    CROSS JOIN hourly_slots h
    WHERE mi.restaurant_id = r.restaurant_id
    AND h.hour_slot BETWEEN TIME('08:00:00') AND TIME('23:00:00')
    -- Add randomness to create realistic transaction patterns
    AND UNIFORM(1, 100, RANDOM()) <= 
        CASE 
            WHEN TIME(h.hour_slot) BETWEEN TIME('11:30:00') AND TIME('14:00:00') THEN 85 -- Lunch rush
            WHEN TIME(h.hour_slot) BETWEEN TIME('17:30:00') AND TIME('21:00:00') THEN 90 -- Dinner rush
            WHEN TIME(h.hour_slot) BETWEEN TIME('08:00:00') AND TIME('10:30:00') THEN 45 -- Breakfast
            ELSE 25 -- Off-peak
        END
)
SELECT 
    tb.restaurant_id,
    tb.item_id,
    tb.transaction_datetime,
    UNIFORM(1, 4, RANDOM()) as quantity,
    ROUND(tb.base_price * UNIFORM(0.95, 1.05, RANDOM())::DECIMAL(8,2), 2) as unit_price,
    ROUND((UNIFORM(1, 4, RANDOM()) * tb.base_price * UNIFORM(0.95, 1.05, RANDOM()))::DECIMAL(10,2), 2) as total_amount,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Cash'
        WHEN 2 THEN 'Credit Card'
        WHEN 3 THEN 'Debit Card'
        WHEN 4 THEN 'Mobile Pay'
        ELSE 'Gift Card'
    END as payment_method,
    UNIFORM(1, 15, RANDOM()) as server_id,
    UNIFORM(1, 20, RANDOM()) as table_number
FROM transaction_base tb
WHERE UNIFORM(1, 100, RANDOM()) <= 60; -- Further filter to create realistic volume

-- Generate inventory movements data (500K+ records)
INSERT INTO INVENTORY_MOVEMENTS (restaurant_id, ingredient_name, movement_type, quantity_change, unit_of_measure, cost_per_unit, movement_date, supplier_id)
WITH ingredients AS (
    SELECT ingredient FROM VALUES 
    ('Ground Beef'), ('Chicken Breast'), ('Salmon Fillet'), ('Tomatoes'), ('Onions'), 
    ('Bell Peppers'), ('Mushrooms'), ('Lettuce'), ('Cheese - Mozzarella'), ('Cheese - Cheddar'),
    ('Flour'), ('Rice'), ('Pasta'), ('Olive Oil'), ('Butter'), ('Milk'), ('Eggs'),
    ('Garlic'), ('Basil'), ('Oregano'), ('Salt'), ('Black Pepper'), ('Sugar'), ('Vanilla'),
    ('Potatoes'), ('Carrots'), ('Celery'), ('Broccoli'), ('Spinach'), ('Bread')
    AS ingredients(ingredient)
),
date_series AS (
    SELECT DATEADD(day, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, '2022-01-01'::DATE) as movement_date
    FROM TABLE(GENERATOR(ROWCOUNT => 730))
)
SELECT 
    r.restaurant_id,
    i.ingredient as ingredient_name,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'PURCHASE'
        WHEN 2 THEN 'USAGE'
        WHEN 3 THEN 'WASTE'
        ELSE 'ADJUSTMENT'
    END as movement_type,
    CASE 
        WHEN UNIFORM(1, 4, RANDOM()) IN (2, 3) THEN -1 * UNIFORM(1, 50, RANDOM())::DECIMAL(10,3) -- Usage/Waste (negative)
        ELSE UNIFORM(10, 100, RANDOM())::DECIMAL(10,3) -- Purchase/Adjustment (positive)
    END as quantity_change,
    CASE i.ingredient
        WHEN 'Ground Beef' THEN 'lbs'
        WHEN 'Chicken Breast' THEN 'lbs'
        WHEN 'Salmon Fillet' THEN 'lbs'
        WHEN 'Olive Oil' THEN 'gallons'
        WHEN 'Milk' THEN 'gallons'
        WHEN 'Flour' THEN 'lbs'
        WHEN 'Rice' THEN 'lbs'
        ELSE 'units'
    END as unit_of_measure,
    ROUND(UNIFORM(0.50, 15.99, RANDOM())::DECIMAL(8,4), 4) as cost_per_unit,
    DATEADD(hour, UNIFORM(6, 22, RANDOM()), ds.movement_date) as movement_date,
    UNIFORM(1, 25, RANDOM()) as supplier_id
FROM RESTAURANTS r
CROSS JOIN ingredients i
CROSS JOIN date_series ds
WHERE UNIFORM(1, 100, RANDOM()) <= 35; -- Create realistic frequency

-- Generate labor scheduling data (200K+ records)
INSERT INTO LABOR_SCHEDULE (restaurant_id, employee_id, shift_date, start_time, end_time, position, hourly_rate, scheduled_hours, actual_hours)
WITH positions AS (
    SELECT position, base_rate FROM VALUES 
    ('Server', 15.50), ('Cook', 18.75), ('Manager', 25.00), ('Host', 14.00), 
    ('Bartender', 16.25), ('Dishwasher', 13.50), ('Prep Cook', 16.00), ('Cashier', 14.50)
    AS positions(position, base_rate)
),
date_range AS (
    SELECT DATEADD(day, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, '2022-01-01'::DATE) as shift_date
    FROM TABLE(GENERATOR(ROWCOUNT => 730))
),
shift_times AS (
    SELECT shift_type, start_time, end_time, hours FROM VALUES
    ('Morning', TIME('06:00:00'), TIME('14:00:00'), 8),
    ('Afternoon', TIME('14:00:00'), TIME('22:00:00'), 8),
    ('Split AM', TIME('08:00:00'), TIME('15:00:00'), 7),
    ('Split PM', TIME('16:00:00'), TIME('23:00:00'), 7),
    ('Double', TIME('10:00:00'), TIME('22:00:00'), 12)
    AS shifts(shift_type, start_time, end_time, hours)
)
SELECT 
    r.restaurant_id,
    UNIFORM(1, 50, RANDOM()) as employee_id,
    dr.shift_date,
    st.start_time,
    st.end_time,
    p.position,
    ROUND(p.base_rate * UNIFORM(0.90, 1.15, RANDOM())::DECIMAL(6,2), 2) as hourly_rate,
    st.hours as scheduled_hours,
    ROUND(st.hours * UNIFORM(0.85, 1.05, RANDOM())::DECIMAL(4,2), 2) as actual_hours
FROM RESTAURANTS r
CROSS JOIN positions p
CROSS JOIN date_range dr
CROSS JOIN shift_times st
WHERE UNIFORM(1, 100, RANDOM()) <= 
    CASE p.position
        WHEN 'Server' THEN 75
        WHEN 'Cook' THEN 85
        WHEN 'Manager' THEN 95
        ELSE 60
    END
AND DAYOFWEEK(dr.shift_date) NOT IN (1, 2) OR UNIFORM(1, 100, RANDOM()) <= 40; -- Reduced weekend staffing

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_sales_restaurant_date ON SALES_TRANSACTIONS(restaurant_id, transaction_date);
CREATE INDEX IF NOT EXISTS idx_inventory_restaurant_date ON INVENTORY_MOVEMENTS(restaurant_id, movement_date);
CREATE INDEX IF NOT EXISTS idx_labor_restaurant_date ON LABOR_SCHEDULE(restaurant_id, shift_date);

-- Update table statistics for optimal query planning
ALTER TABLE RESTAURANTS COMPUTE STATISTICS;
ALTER TABLE MENU_ITEMS COMPUTE STATISTICS;
ALTER TABLE SALES_TRANSACTIONS COMPUTE STATISTICS;
ALTER TABLE INVENTORY_MOVEMENTS COMPUTE STATISTICS;
ALTER TABLE LABOR_SCHEDULE COMPUTE STATISTICS;

-- Verify data volumes
SELECT 'RESTAURANTS' as table_name, COUNT(*) as record_count FROM RESTAURANTS
UNION ALL
SELECT 'MENU_ITEMS' as table_name, COUNT(*) as record_count FROM MENU_ITEMS
UNION ALL
SELECT 'SALES_TRANSACTIONS' as table_name, COUNT(*) as record_count FROM SALES_TRANSACTIONS
UNION ALL
SELECT 'INVENTORY_MOVEMENTS' as table_name, COUNT(*) as record_count FROM INVENTORY_MOVEMENTS
UNION ALL
SELECT 'LABOR_SCHEDULE' as table_name, COUNT(*) as record_count FROM LABOR_SCHEDULE
ORDER BY record_count DESC;
