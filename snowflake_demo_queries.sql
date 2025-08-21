-- CrunchTime! Multi-Cluster Warehouse Demo Queries
-- These queries are designed to demonstrate warehouse queuing vs. concurrent execution

USE DATABASE CRUNCHTIME_DEMO;
USE SCHEMA RESTAURANT_DATA;

-- ===============================================
-- PART 1: DEMO QUERIES FOR SINGLE-CLUSTER WAREHOUSE
-- ===============================================
-- Use single-cluster warehouse
USE WAREHOUSE CRUNCHTIME_WH_SINGLE;

-- Query 1: Complex Sales Analytics with Multiple Aggregations
-- Purpose: Heavy aggregation query that will consume significant resources
-- Business Value: Monthly sales performance analysis across all restaurants
SELECT 
    r.restaurant_name,
    r.cuisine_type,
    r.location_state,
    DATE_TRUNC('month', st.transaction_date) as sales_month,
    COUNT(DISTINCT st.transaction_id) as total_transactions,
    SUM(st.total_amount) as monthly_revenue,
    AVG(st.total_amount) as avg_transaction_value,
    COUNT(DISTINCT st.server_id) as active_servers,
    COUNT(DISTINCT DATE_TRUNC('day', st.transaction_date)) as operating_days,
    SUM(st.total_amount) / COUNT(DISTINCT DATE_TRUNC('day', st.transaction_date)) as daily_avg_revenue,
    -- Complex window functions for ranking
    RANK() OVER (PARTITION BY DATE_TRUNC('month', st.transaction_date) ORDER BY SUM(st.total_amount) DESC) as monthly_revenue_rank,
    LAG(SUM(st.total_amount)) OVER (PARTITION BY r.restaurant_id ORDER BY DATE_TRUNC('month', st.transaction_date)) as prev_month_revenue,
    (SUM(st.total_amount) - LAG(SUM(st.total_amount)) OVER (PARTITION BY r.restaurant_id ORDER BY DATE_TRUNC('month', st.transaction_date))) / 
     NULLIF(LAG(SUM(st.total_amount)) OVER (PARTITION BY r.restaurant_id ORDER BY DATE_TRUNC('month', st.transaction_date)), 0) * 100 as revenue_growth_pct
FROM SALES_TRANSACTIONS st
JOIN RESTAURANTS r ON st.restaurant_id = r.restaurant_id
JOIN MENU_ITEMS mi ON st.item_id = mi.item_id
WHERE st.transaction_date >= '2022-01-01'
GROUP BY r.restaurant_name, r.cuisine_type, r.location_state, r.restaurant_id, DATE_TRUNC('month', st.transaction_date)
HAVING SUM(st.total_amount) > 1000
ORDER BY sales_month DESC, monthly_revenue DESC;

-- Query 2: Menu Performance Analysis with Cost Calculations
-- Purpose: Resource-intensive query with multiple joins and calculations
-- Business Value: Menu item profitability analysis
SELECT 
    r.restaurant_name,
    r.cuisine_type,
    mi.category,
    mi.item_name,
    mi.price as menu_price,
    mi.cost_of_goods,
    mi.price - mi.cost_of_goods as gross_profit_per_item,
    (mi.price - mi.cost_of_goods) / mi.price * 100 as profit_margin_pct,
    COUNT(st.transaction_id) as times_ordered,
    SUM(st.quantity) as total_quantity_sold,
    SUM(st.total_amount) as total_revenue,
    SUM(st.quantity * mi.cost_of_goods) as total_cost_of_goods,
    SUM(st.total_amount) - SUM(st.quantity * mi.cost_of_goods) as total_profit,
    AVG(st.quantity) as avg_quantity_per_order,
    -- Complex seasonal analysis
    COUNT(CASE WHEN MONTH(st.transaction_date) IN (12,1,2) THEN 1 END) as winter_orders,
    COUNT(CASE WHEN MONTH(st.transaction_date) IN (3,4,5) THEN 1 END) as spring_orders,
    COUNT(CASE WHEN MONTH(st.transaction_date) IN (6,7,8) THEN 1 END) as summer_orders,
    COUNT(CASE WHEN MONTH(st.transaction_date) IN (9,10,11) THEN 1 END) as fall_orders,
    -- Performance ranking
    DENSE_RANK() OVER (PARTITION BY r.restaurant_id ORDER BY SUM(st.total_amount) DESC) as revenue_rank_in_restaurant,
    PERCENT_RANK() OVER (ORDER BY (mi.price - mi.cost_of_goods) / mi.price * 100) as profit_margin_percentile
FROM SALES_TRANSACTIONS st
JOIN RESTAURANTS r ON st.restaurant_id = r.restaurant_id
JOIN MENU_ITEMS mi ON st.item_id = mi.item_id
WHERE st.transaction_date >= '2022-01-01'
GROUP BY r.restaurant_name, r.cuisine_type, r.restaurant_id, mi.category, mi.item_name, 
         mi.price, mi.cost_of_goods, mi.item_id
HAVING COUNT(st.transaction_id) >= 10
ORDER BY total_profit DESC, profit_margin_pct DESC;

-- Query 3: Inventory and Labor Cost Analysis
-- Purpose: Complex multi-table join with heavy aggregations
-- Business Value: Operational cost analysis combining inventory and labor
SELECT 
    r.restaurant_name,
    r.location_city,
    r.location_state,
    DATE_TRUNC('month', COALESCE(im.movement_date, ls.shift_date)) as analysis_month,
    -- Inventory Costs
    SUM(CASE WHEN im.movement_type = 'PURCHASE' THEN im.quantity_change * im.cost_per_unit ELSE 0 END) as inventory_purchases,
    SUM(CASE WHEN im.movement_type = 'WASTE' THEN ABS(im.quantity_change * im.cost_per_unit) ELSE 0 END) as inventory_waste_cost,
    COUNT(DISTINCT im.ingredient_name) as unique_ingredients,
    -- Labor Costs
    SUM(ls.actual_hours * ls.hourly_rate) as total_labor_cost,
    AVG(ls.hourly_rate) as avg_hourly_rate,
    SUM(ls.actual_hours) as total_labor_hours,
    COUNT(DISTINCT ls.employee_id) as active_employees,
    SUM(CASE WHEN ls.position = 'Server' THEN ls.actual_hours * ls.hourly_rate ELSE 0 END) as server_labor_cost,
    SUM(CASE WHEN ls.position = 'Cook' THEN ls.actual_hours * ls.hourly_rate ELSE 0 END) as kitchen_labor_cost,
    -- Combined Analysis
    SUM(CASE WHEN im.movement_type = 'PURCHASE' THEN im.quantity_change * im.cost_per_unit ELSE 0 END) + 
    SUM(ls.actual_hours * ls.hourly_rate) as total_operating_costs,
    -- Efficiency Metrics
    SUM(ls.actual_hours) / COUNT(DISTINCT DATE_TRUNC('day', ls.shift_date)) as avg_daily_labor_hours,
    SUM(CASE WHEN im.movement_type = 'WASTE' THEN ABS(im.quantity_change * im.cost_per_unit) ELSE 0 END) / 
    NULLIF(SUM(CASE WHEN im.movement_type = 'PURCHASE' THEN im.quantity_change * im.cost_per_unit ELSE 0 END), 0) * 100 as waste_percentage
FROM RESTAURANTS r
LEFT JOIN INVENTORY_MOVEMENTS im ON r.restaurant_id = im.restaurant_id 
    AND im.movement_date >= '2022-01-01'
LEFT JOIN LABOR_SCHEDULE ls ON r.restaurant_id = ls.restaurant_id 
    AND ls.shift_date >= '2022-01-01'
WHERE (im.movement_date IS NOT NULL OR ls.shift_date IS NOT NULL)
GROUP BY r.restaurant_name, r.location_city, r.location_state, r.restaurant_id,
         DATE_TRUNC('month', COALESCE(im.movement_date, ls.shift_date))
ORDER BY analysis_month DESC, total_operating_costs DESC;

-- Query 4: Peak Hours Performance Analysis
-- Purpose: Time-series analysis with complex window functions
-- Business Value: Understanding busy periods and staffing optimization
SELECT 
    r.restaurant_name,
    r.cuisine_type,
    EXTRACT(hour FROM st.transaction_date) as hour_of_day,
    DAYNAME(st.transaction_date) as day_of_week,
    COUNT(st.transaction_id) as transaction_count,
    SUM(st.total_amount) as hourly_revenue,
    AVG(st.total_amount) as avg_transaction_value,
    COUNT(DISTINCT st.server_id) as servers_active,
    COUNT(DISTINCT st.table_number) as tables_used,
    -- Complex time-based calculations
    SUM(st.total_amount) / COUNT(DISTINCT st.server_id) as revenue_per_server,
    COUNT(st.transaction_id) / COUNT(DISTINCT st.table_number) as transactions_per_table,
    -- Moving averages and trends
    AVG(SUM(st.total_amount)) OVER (
        PARTITION BY r.restaurant_id, EXTRACT(hour FROM st.transaction_date) 
        ORDER BY DAYNAME(st.transaction_date)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as three_day_moving_avg_revenue,
    -- Peak identification
    CASE 
        WHEN SUM(st.total_amount) > AVG(SUM(st.total_amount)) OVER (PARTITION BY r.restaurant_id) * 1.5 
        THEN 'Peak Hour'
        WHEN SUM(st.total_amount) < AVG(SUM(st.total_amount)) OVER (PARTITION BY r.restaurant_id) * 0.5 
        THEN 'Slow Hour'
        ELSE 'Regular Hour'
    END as hour_classification
FROM SALES_TRANSACTIONS st
JOIN RESTAURANTS r ON st.restaurant_id = r.restaurant_id
WHERE st.transaction_date >= DATEADD('month', -3, CURRENT_DATE())
    AND EXTRACT(hour FROM st.transaction_date) BETWEEN 8 AND 23
GROUP BY r.restaurant_name, r.cuisine_type, r.restaurant_id,
         EXTRACT(hour FROM st.transaction_date), DAYNAME(st.transaction_date)
ORDER BY r.restaurant_name, hour_of_day;

-- ===============================================
-- PART 2: SAME QUERIES FOR MULTI-CLUSTER WAREHOUSE
-- ===============================================
-- Switch to multi-cluster warehouse
USE WAREHOUSE CRUNCHTIME_WH_MULTI;

-- The same four queries will be executed here to demonstrate concurrent processing
-- In the actual demo, these would be run simultaneously by different users/sessions

-- Note: These are the exact same queries as above, just with the multi-cluster warehouse
-- The demo will show how these run concurrently rather than queuing

-- ===============================================
-- PART 3: MONITORING QUERIES FOR THE DEMO
-- ===============================================

-- Query to monitor warehouse usage and queuing
SELECT 
    warehouse_name,
    start_time,
    end_time,
    total_elapsed_time / 1000 as elapsed_seconds,
    compilation_time / 1000 as compilation_seconds,
    execution_time / 1000 as execution_seconds,
    queued_provisioning_time / 1000 as queued_seconds,
    query_text,
    cluster_number
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY 
WHERE warehouse_name IN ('CRUNCHTIME_WH_SINGLE', 'CRUNCHTIME_WH_MULTI')
    AND start_time >= DATEADD('minute', -30, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;

-- Query to show warehouse cluster utilization
SELECT 
    warehouse_name,
    start_time,
    end_time,
    cluster_number,
    credits_used,
    credits_used_cloud_services
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE warehouse_name IN ('CRUNCHTIME_WH_SINGLE', 'CRUNCHTIME_WH_MULTI')
    AND start_time >= DATEADD('hour', -2, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;
