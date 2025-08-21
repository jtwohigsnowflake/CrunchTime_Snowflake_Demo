# CrunchTime! Snowflake Multi-Cluster Warehouse Demo Script
**Duration: 5 minutes | Audience: CrunchTime! Technical Team**

---

## Demo Overview
**Objective**: Show how Multi-Cluster Warehouses eliminate query queuing and improve warehouse utilization for CrunchTime!'s restaurant analytics workloads.

**Key Business Value**: 
- Eliminate wait times for critical restaurant operations analytics
- Support concurrent business users without performance degradation
- Scale compute automatically during peak analysis periods

---

## Demo Flow (5 minutes)

### **Minute 1: Context & Setup** (60 seconds)
**[Screen: Snowflake Web UI - Worksheets]**

> "Good morning! Today I'm going to show you how Snowflake's Multi-Cluster Warehouses can dramatically improve your restaurant analytics performance. 
> 
> As CrunchTime! grows, you're likely experiencing situations where multiple team members - operations managers, regional directors, finance teams - all need to run complex analytics simultaneously. 
>
> I've prepared a realistic dataset with 2+ million sales transactions, inventory movements, and labor data across 10 restaurants - similar to what you'd see in your production environment."

**Action**: Show the database schema and data volumes
```sql
-- Quick data overview
SELECT 'SALES_TRANSACTIONS' as table_name, COUNT(*) as records FROM SALES_TRANSACTIONS
UNION ALL SELECT 'INVENTORY_MOVEMENTS', COUNT(*) FROM INVENTORY_MOVEMENTS  
UNION ALL SELECT 'LABOR_SCHEDULE', COUNT(*) FROM LABOR_SCHEDULE;
```

### **Minute 2: Single-Cluster Warehouse Problem** (60 seconds)
**[Screen: Snowflake Web UI - Multiple Worksheets]**

> "Let's first see what happens with a traditional single-cluster warehouse when multiple users run analytics simultaneously."

**Action**: 
1. Switch to single-cluster warehouse: `USE WAREHOUSE CRUNCHTIME_WH_SINGLE;`
2. Open 3 separate worksheet tabs
3. Paste different queries in each (Monthly Sales Analysis, Menu Performance, Operational Costs)

**Worksheet 1**: Monthly Sales Analysis Query
**Worksheet 2**: Menu Performance Query  
**Worksheet 3**: Operational Cost Analysis Query

**Action**: Execute all 3 queries simultaneously (Ctrl+Enter in each tab quickly)

> "Notice how the queries are executing sequentially - you can see in the query history that they're queuing. The second and third queries have to wait for the first to complete. In a busy environment, this creates bottlenecks."

**Point out**:
- Query queue times in the execution details
- Only one query running at a time
- Total time for all queries to complete

### **Minute 3: Multi-Cluster Warehouse Solution** (60 seconds)
**[Screen: Same worksheets, different warehouse]**

> "Now let's see the same workload with Multi-Cluster Warehouses enabled."

**Action**:
1. Switch to multi-cluster warehouse: `USE WAREHOUSE CRUNCHTIME_WH_MULTI;`
2. Clear previous results
3. Execute the same 3 queries simultaneously again

> "Watch this - with Multi-Cluster enabled, Snowflake automatically spins up additional compute clusters to handle concurrent demand. Each query gets its own dedicated resources."

**Point out**:
- Queries start immediately (no queuing)
- Multiple clusters spinning up in warehouse monitoring
- All queries complete in parallel
- Dramatically reduced total time

### **Minute 4: Business Impact Deep-Dive** (60 seconds)
**[Screen: Query results and monitoring views]**

> "Let's look at the business impact of this improvement."

**Action**: Show the monitoring query results
```sql
-- Show warehouse utilization
SELECT warehouse_name, cluster_number, start_time, 
       total_elapsed_time/1000 as seconds,
       queued_provisioning_time/1000 as queued_seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY 
WHERE warehouse_name IN ('CRUNCHTIME_WH_SINGLE', 'CRUNCHTIME_WH_MULTI')
ORDER BY start_time DESC;
```

**Key Points**:
- **Performance**: "Single-cluster: 45 seconds total wait time. Multi-cluster: All queries complete in 15 seconds"
- **User Experience**: "Your operations teams get instant insights instead of waiting in line"
- **Scalability**: "Automatically handles peak periods like month-end reporting or busy dinner rushes"
- **Cost Efficiency**: "You only pay for clusters when they're actively needed - they auto-suspend after the workload"

### **Minute 5: CrunchTime! Specific Benefits & Next Steps** (60 seconds)
**[Screen: Summary slide or Snowflake UI]**

> "For CrunchTime! specifically, this means:"

**Business Benefits**:
- **Operations Teams**: Real-time sales analysis during peak hours without delays
- **Finance**: Month-end reporting completes faster with multiple concurrent users
- **Regional Managers**: Can all run location performance analysis simultaneously
- **Development**: Your application APIs get consistent response times even under load

**Technical Benefits**:
- **Auto-scaling**: 1-10 clusters based on demand
- **Cost Control**: Clusters auto-suspend, you only pay for what you use
- **No Code Changes**: Existing queries work exactly the same
- **Zero Downtime**: Enable multi-cluster without any service interruption

> "Questions about implementing Multi-Cluster Warehouses in your CrunchTime! environment?"

**Next Steps**:
1. **Pilot Program**: Enable on one warehouse for 2-week trial
2. **Scaling Policy**: Configure appropriate min/max clusters for your workload
3. **Monitoring**: Set up alerts for cluster usage and cost optimization
4. **Training**: Workshop with your team on best practices

---

## Key Demo Success Metrics
- **Query Time Reduction**: Single-cluster total time vs Multi-cluster parallel time
- **Eliminated Queue Time**: 0 seconds queuing with multi-cluster
- **User Experience**: Multiple concurrent users supported
- **Cost Efficiency**: Pay only for active clusters

---

## Demo Preparation Checklist
- [ ] Data loaded and verified (2M+ transactions)
- [ ] Both warehouses created and configured
- [ ] Query worksheets prepared and tested
- [ ] Monitoring queries ready
- [ ] Stopwatch for timing
- [ ] Backup queries in case of issues

---

## Troubleshooting
- **If queries run too fast**: Add more complex aggregations or larger date ranges
- **If demo data is insufficient**: Re-run data generation with higher volume
- **If warehouses don't scale**: Check account permissions and scaling policies
- **If timing is off**: Practice run-through beforehand and adjust query complexity
