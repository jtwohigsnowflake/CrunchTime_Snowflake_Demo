# CrunchTime! Snowflake Multi-Cluster Warehouse Demo Package

## 🎯 Demo Overview
A complete 5-minute Snowflake demonstration for CrunchTime! showing how Multi-Cluster Warehouses eliminate query queuing and improve warehouse utilization. Includes realistic restaurant/food service data and business-relevant analytics queries.

## 📁 Demo Package Contents

### Core Files
| File | Purpose | Estimated Runtime |
|------|---------|-------------------|
| `snowflake_demo_setup.sql` | Creates database, tables, warehouses, and initial data | 5-10 minutes |
| `snowflake_demo_data_generation.sql` | Generates 2M+ transaction records for realistic testing | 15-20 minutes |
| `snowflake_demo_queries.sql` | Resource-intensive analytics queries for demonstration | 30-90 seconds each |

### Documentation
| File | Purpose |
|------|---------|
| `CrunchTime_MultiCluster_Demo_Script.md` | 5-minute presentation script with precise timing |
| `CrunchTime_Demo_Execution_Guide.md` | Step-by-step technical execution guide |
| `README_CrunchTime_Demo.md` | This overview document |

## 🚀 Quick Start Guide

### 1. Pre-Demo Setup (30-45 minutes)
1. **Setup Environment**: Execute `snowflake_demo_setup.sql` in Snowflake
2. **Generate Data**: Execute `snowflake_demo_data_generation.sql` 
3. **Prepare Queries**: Copy queries from `snowflake_demo_queries.sql` to 4 worksheet tabs
4. **Test Run**: Execute queries once to verify performance and timing

### 2. Demo Execution (5 minutes)
Follow the `CrunchTime_MultiCluster_Demo_Script.md` for precise timing:
- **Minute 1**: Context and data overview
- **Minute 2**: Single-cluster warehouse queuing demonstration  
- **Minute 3**: Multi-cluster concurrent execution
- **Minute 4**: Performance analysis and monitoring
- **Minute 5**: Business benefits and next steps

### 3. Post-Demo
- Suspend warehouses to avoid unnecessary costs
- Follow up with implementation planning

## 📊 Dataset Details

### Business Context
The demo uses a realistic restaurant dataset relevant to CrunchTime!'s business:
- **10 restaurants** across different cities and cuisine types
- **120+ menu items** with pricing and cost data
- **2M+ sales transactions** over 2 years
- **500K+ inventory movements** (purchases, usage, waste)
- **200K+ labor schedule records** with position and hourly data

### Data Volume Breakdown
```
RESTAURANTS:           10 records
MENU_ITEMS:           120 records  
SALES_TRANSACTIONS:   2M+ records
INVENTORY_MOVEMENTS:  500K+ records
LABOR_SCHEDULE:       200K+ records
```

## 🏭 Warehouse Configuration

### Single-Cluster Warehouse
- **Name**: `CRUNCHTIME_WH_SINGLE`
- **Size**: MEDIUM
- **Clusters**: Min=1, Max=1 (no scaling)
- **Purpose**: Demonstrate query queuing

### Multi-Cluster Warehouse  
- **Name**: `CRUNCHTIME_WH_MULTI`
- **Size**: MEDIUM
- **Clusters**: Min=1, Max=3 (auto-scaling)
- **Purpose**: Demonstrate concurrent execution

## 🎯 Demo Queries

### Query 1: Sales Performance Analysis
- **Business Value**: Monthly revenue analysis across restaurants
- **Technical Focus**: Complex aggregations with window functions
- **Estimated Runtime**: 20-30 seconds

### Query 2: Menu Profitability Analysis
- **Business Value**: Item-level profit margin analysis
- **Technical Focus**: Multi-table joins with cost calculations
- **Estimated Runtime**: 25-35 seconds

### Query 3: Operational Cost Analysis
- **Business Value**: Combined inventory and labor cost analysis
- **Technical Focus**: Heavy multi-table joins and aggregations
- **Estimated Runtime**: 30-45 seconds

### Query 4: Peak Hours Analysis
- **Business Value**: Time-based performance optimization
- **Technical Focus**: Time-series analysis with moving averages
- **Estimated Runtime**: 20-30 seconds

## 📈 Expected Demo Results

### Performance Improvements
- **Query Time Reduction**: 60-70% improvement with multi-cluster
- **Queue Elimination**: 0ms queuing vs 30-60 seconds with single-cluster
- **Concurrent Users**: Support 3+ simultaneous analytics users
- **Auto-scaling**: <30 seconds cluster provisioning time

### Business Benefits Demonstrated
- **User Productivity**: Immediate access to critical insights
- **Scalability**: Automatic handling of concurrent analytical workloads  
- **Cost Efficiency**: Pay-per-use scaling model
- **Operational Excellence**: Support for peak reporting periods

## ⚠️ Requirements & Prerequisites

### Snowflake Account Requirements
- **Edition**: Standard tier or higher (Business Critical recommended)
- **Roles**: ACCOUNTADMIN or SYSADMIN access
- **Features**: Multi-cluster warehouse capability
- **Credits**: ~2-3 Medium warehouse hours for full demo setup

### Technical Prerequisites  
- Access to Snowflake web interface
- Permission to create databases and warehouses
- Access to ACCOUNT_USAGE schema (for monitoring queries)
- Stable internet connection for demo presentation

## 🛠️ Troubleshooting

### Common Issues
1. **Queries too fast**: Use smaller warehouse or add complexity
2. **Data generation slow**: Reduce dataset size or use faster warehouse  
3. **Multi-cluster not scaling**: Verify account capabilities and query intensity
4. **Monitoring no data**: Account usage has 45-minute latency, plan accordingly

### Quick Fixes
- Test run 1 hour before demo to populate monitoring data
- Have backup queries ready with different complexity levels
- Prepare explanation for any technical issues during live demo

## 💡 Customization Options

### Adjust Dataset Size
Modify `GENERATOR(ROWCOUNT => X)` values in data generation script:
- **Smaller dataset** (faster setup): Reduce rowcounts by 50%
- **Larger dataset** (longer queuing): Increase rowcounts by 2x

### Modify Query Complexity  
Adjust queries in `snowflake_demo_queries.sql`:
- **Simpler queries**: Remove window functions and complex aggregations
- **More complex**: Add additional joins and calculations

### Different Business Context
Adapt table schemas and data in setup script:
- Change restaurant names and locations
- Modify menu items for different cuisine types
- Adjust date ranges for different analysis periods

## 📞 Support & Next Steps

### For Technical Issues
- Reference the detailed `CrunchTime_Demo_Execution_Guide.md`
- Check Snowflake documentation for multi-cluster warehouses
- Contact Snowflake support for account-specific issues

### Post-Demo Implementation
1. **Pilot Program**: Enable multi-cluster on existing warehouse
2. **Monitoring Setup**: Implement cost and performance tracking
3. **Team Training**: Conduct workshop on multi-cluster best practices
4. **Optimization**: Fine-tune scaling policies based on actual usage

---

**Demo Success Tips**:
- Practice the presentation timing beforehand
- Have a backup plan for technical difficulties  
- Engage the audience with business-relevant questions
- Focus on measurable business benefits, not just technical features
- Prepare for follow-up questions about implementation and costs
