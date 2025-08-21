# CrunchTime! Multi-Cluster Warehouse Demo - Execution Guide

## Pre-Demo Setup (30-45 minutes before demo)

### Step 1: Environment Preparation
1. **Login to Snowflake** with appropriate admin privileges
2. **Create Demo Environment**:
   ```bash
   # Upload and execute the setup script
   ```
   - Run `snowflake_demo_setup.sql` in Snowflake worksheet
   - Verify all tables and warehouses are created successfully

3. **Generate Sample Data**:
   ```bash
   # Execute data generation script
   ```
   - Run `snowflake_demo_data_generation.sql`
   - **Expected completion time**: 15-20 minutes for large dataset
   - Verify data volumes meet expectations (2M+ transactions)

### Step 2: Demo Queries Preparation
1. **Open Snowflake Web UI**
2. **Create 4 separate worksheet tabs**:
   - Tab 1: "Sales Analysis" 
   - Tab 2: "Menu Performance"
   - Tab 3: "Operational Costs"
   - Tab 4: "Monitoring"

3. **Copy queries to respective tabs** from `snowflake_demo_queries.sql`:
   - **Tab 1**: Query 1 (Complex Sales Analytics)
   - **Tab 2**: Query 2 (Menu Performance Analysis) 
   - **Tab 3**: Query 3 (Inventory and Labor Cost Analysis)
   - **Tab 4**: Monitoring queries

### Step 3: Test Run (Recommended)
1. **Execute test run** with single-cluster warehouse
2. **Verify queries take 15-30 seconds each** (adjust complexity if needed)
3. **Test multi-cluster warehouse** to ensure auto-scaling works
4. **Check monitoring queries** return meaningful data

---

## Demo Execution Steps

### Phase 1: Introduction & Context (Minute 1)
**Actions to perform**:
1. Open Snowflake web interface
2. Navigate to Database → CRUNCHTIME_DEMO → RESTAURANT_DATA
3. Execute data overview query:
   ```sql
   SELECT 'RESTAURANTS' as table_name, COUNT(*) as record_count FROM RESTAURANTS
   UNION ALL SELECT 'MENU_ITEMS', COUNT(*) FROM MENU_ITEMS
   UNION ALL SELECT 'SALES_TRANSACTIONS', COUNT(*) FROM SALES_TRANSACTIONS
   UNION ALL SELECT 'INVENTORY_MOVEMENTS', COUNT(*) FROM INVENTORY_MOVEMENTS
   UNION ALL SELECT 'LABOR_SCHEDULE', COUNT(*) FROM LABOR_SCHEDULE
   ORDER BY record_count DESC;
   ```

**Speaking points while query executes**:
- Explain CrunchTime!'s analytical needs
- Mention realistic dataset size (2M+ transactions)
- Set expectation for performance comparison

### Phase 2: Single-Cluster Demonstration (Minute 2)
**Actions to perform**:
1. **Switch to single-cluster warehouse**:
   ```sql
   USE WAREHOUSE CRUNCHTIME_WH_SINGLE;
   ```

2. **Prepare 3 worksheet tabs** with queries ready to execute

3. **Execute queries simultaneously**:
   - Click on Tab 1 → Press Ctrl+Enter (or Run button)
   - **Immediately** click on Tab 2 → Press Ctrl+Enter  
   - **Immediately** click on Tab 3 → Press Ctrl+Enter

4. **Monitor query execution**:
   - Switch between tabs to show query status
   - Point out "Running" vs "Queued" states
   - Note execution times and queue times

**Speaking points**:
- "Notice the sequential execution pattern"
- "Second and third queries are waiting in queue"
- "This is typical behavior with traditional single-cluster setup"

### Phase 3: Multi-Cluster Demonstration (Minute 3)
**Actions to perform**:
1. **Clear previous results** (click X to cancel any running queries)

2. **Switch to multi-cluster warehouse**:
   ```sql
   USE WAREHOUSE CRUNCHTIME_WH_MULTI;
   ```

3. **Execute the same 3 queries simultaneously**:
   - Quickly execute all three queries using same method as before
   - **Key**: Speed of execution matters here for dramatic effect

4. **Show cluster scaling** (if possible):
   - Navigate to Warehouses in web UI
   - Show multiple clusters spinning up for CRUNCHTIME_WH_MULTI

**Speaking points**:
- "Watch the immediate execution - no queuing"
- "Snowflake automatically provisions additional clusters"
- "Each query gets dedicated resources"

### Phase 4: Results Analysis (Minute 4)
**Actions to perform**:
1. **Switch to Monitoring tab (Tab 4)**

2. **Execute monitoring query**:
   ```sql
   SELECT 
       warehouse_name,
       start_time,
       total_elapsed_time / 1000 as elapsed_seconds,
       queued_provisioning_time / 1000 as queued_seconds,
       cluster_number,
       SUBSTR(query_text, 1, 50) as query_preview
   FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY 
   WHERE warehouse_name IN ('CRUNCHTIME_WH_SINGLE', 'CRUNCHTIME_WH_MULTI')
       AND start_time >= DATEADD('minute', -10, CURRENT_TIMESTAMP())
   ORDER BY start_time DESC
   LIMIT 20;
   ```

3. **Highlight key metrics in results**:
   - Queue times: Single-cluster vs Multi-cluster
   - Total execution times
   - Cluster numbers (showing multiple clusters used)

**Speaking points**:
- Point out specific time savings
- Emphasize zero queue time with multi-cluster
- Relate to business impact (user experience)

### Phase 5: Business Value & Next Steps (Minute 5)
**Actions to perform**:
1. **Summarize key metrics** from monitoring results

2. **Show warehouse scaling** (if accessible):
   - Navigate to Admin → Warehouses
   - Show configuration differences between warehouses
   - Highlight auto-suspend and scaling policies

**Speaking points**:
- Connect technical improvements to business benefits
- Discuss CrunchTime!-specific use cases
- Outline implementation path and next steps

---

## Technical Requirements

### Snowflake Account Permissions
**Required roles/permissions**:
- ACCOUNTADMIN or SYSADMIN role
- CREATE DATABASE privilege
- CREATE WAREHOUSE privilege
- Access to SNOWFLAKE.ACCOUNT_USAGE schema (for monitoring)

### Recommended Account Settings
- **Warehouse auto-suspend**: 1 minute (for demo responsiveness)
- **Query timeout**: 10 minutes
- **Multi-cluster scaling**: Standard policy

### Performance Considerations
- **Minimum account size**: Standard tier or higher
- **Recommended for demo**: Business Critical for consistent performance
- **Expected resource usage**: 2-3 Medium warehouses worth of credits during demo

---

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. **Queries execute too quickly (< 5 seconds)**
**Problem**: Dataset too small or warehouse too large
**Solution**: 
- Increase date range in queries
- Add more complex aggregations
- Use smaller warehouse size (XSMALL)

#### 2. **Data generation takes too long**
**Problem**: Large dataset creation exceeding time limit
**Solution**:
- Reduce GENERATOR rowcounts in data generation script
- Run data generation in smaller batches
- Use faster warehouse for data generation

#### 3. **Multi-cluster scaling doesn't trigger**
**Problem**: Account settings or query timing
**Solution**:
- Verify account has multi-cluster capability
- Ensure queries are resource-intensive enough
- Check scaling policy configuration

#### 4. **Monitoring queries return no data**
**Problem**: ACCOUNT_USAGE latency (up to 45 minutes)
**Solution**:
- Use INFORMATION_SCHEMA.QUERY_HISTORY instead
- Prepare backup monitoring queries
- Run test queries 1 hour before demo

#### 5. **Permission errors**
**Problem**: Insufficient privileges
**Solution**:
- Switch to ACCOUNTADMIN role
- Grant necessary privileges to demo user
- Verify warehouse access permissions

---

## Demo Checklist

### Pre-Demo (Day Before)
- [ ] Snowflake account access confirmed
- [ ] Demo environment setup completed
- [ ] Data generation successful and verified
- [ ] Test run completed successfully
- [ ] Monitoring queries working
- [ ] Backup queries prepared

### Pre-Demo (1 Hour Before)
- [ ] Login to Snowflake confirmed
- [ ] All worksheet tabs prepared
- [ ] Queries tested and timed
- [ ] Warehouses active and responsive
- [ ] Monitoring data populated
- [ ] Screen sharing/presentation setup tested

### During Demo
- [ ] Speak while queries execute (avoid dead air)
- [ ] Use precise language (avoid "um", "so", etc.)
- [ ] Watch timing carefully (use stopwatch if needed)
- [ ] Engage audience with questions
- [ ] Be prepared for technical questions
- [ ] Have backup plans for technical issues

### Post-Demo
- [ ] Cleanup demo environment (optional)
- [ ] Suspend warehouses to avoid unnecessary costs
- [ ] Follow up with technical contacts
- [ ] Schedule implementation planning session
- [ ] Send demo recap with next steps

---

## Success Metrics

### Technical Metrics to Highlight
- **Query Time Reduction**: Target 60-70% improvement
- **Queue Elimination**: 0ms queuing with multi-cluster
- **Concurrent User Support**: 3+ simultaneous queries
- **Auto-scaling Response**: <30 seconds cluster provisioning

### Business Metrics to Emphasize  
- **User Productivity**: Immediate access to insights
- **Cost Efficiency**: Pay-per-use scaling
- **Operational Scalability**: Support business growth
- **Competitive Advantage**: Faster decision-making

---

## Additional Resources
- [Snowflake Multi-Cluster Warehouse Documentation](https://docs.snowflake.com/en/user-guide/warehouses-multicluster.html)
- [Scaling Policies Best Practices](https://docs.snowflake.com/en/user-guide/warehouses-multicluster.html#scaling-policy)
- [Cost Optimization Guidelines](https://docs.snowflake.com/en/user-guide/cost-understanding-overall.html)
