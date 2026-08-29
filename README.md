# Instacart Market Basket Analysis — SQL Portfolio Project
- Overview:
An end-to-end data analytics project built on the public Instacart Market Basket dataset, demonstrating SQL querying, data quality remediation, customer segmentation, and reporting. The project moves from raw relational data to stakeholder-ready insights, with every reported figure traceable back to a reproducible SQL query.

- Tech Stack:
SQL Server Express Edition (SSMS) — analysis environment
Python (Jupyter, pandas, pyodbc) — data loading via fast_executemany=True with batch commits
Git/GitHub — version control and portfolio publishing

- Dataset:
The Instacart Market Basket dataset contains anonymized orders, products, aisles, departments, and prior order history for grocery customers.
Key dataset-specific artifacts documented in this project:
Minimum order count per customer: 3
Maximum order count per customer: 100 (a data cap, not a true behavioral ceiling)
days_since_prior_order is capped at 30
order_dow (day of week) encoding is inferred from community convention, not officially documented

- Project Structure:
├── sql/
│   ├── 01_data_quality/        # Integrity checks & cleanup scripts
│   ├── 02_modelling/           # Data model created with PK and FK
│   └── 03_analysis/            # 20+ business queries across 6 categories               
├── docs/
│   └── 01_data_cleaning_and_modelling.pdf    # Data preparation and modelling doc
│   ├── 02_sql_insight_report.pdf             # Insight reports with recommendations
└── README.md

- Data Quality & Integrity:
Identified and resolved orphaned orders (orders with no associated product data) via backup-then-delete.
Fully reloaded the order_products table after a partial-load failure to ensure data completeness.
Verified min/max order count boundaries per customer to confirm dataset scope before analysis.
Analysis Categories

- Over 20 business queries were written across six categories:
Customer behavior — ordering habits, frequency, and volume patterns
Basket analysis — product co-occurrence and basket composition
Reorder patterns — repeat-purchase behavior by product/department
Department & aisle performance — sales and reorder rates by category
Time trends — order timing by day of week and hours since prior order
Churn / retention — customer lifecycle and drop-off signals

Every query follows a dual-query pattern: a base-grain query plus a companion summary/aggregate query, so each reported number is independently reproducible straight from SQL — no external post-processing.

- Customer Segmentation:
A six-tier segmentation scheme was defined using quantile-based breakpoints on total order count:
Tier	Order Count Range:
1.	3
2.	4–19
3.	20–49
4.	50–99
5.	100
Rationale for each boundary is documented in sql/03_analysis/churn_and_prediction.

- Known Constraints:
1. SQL Server Express memory ceiling (~1.4 GB buffer pool): forces disk spills during heavy aggregation/DISTINCT operations. Addressed via temp tables with indexes, CTE splitting, and checking execution plans for Sort spill warnings before adding indexes (Express's memory ceiling is the root cause, not missing indexes).
Small-sample noise: minimum volume thresholds applied before ranking products/departments to avoid misleading results from low-count items.

- Author:
Built by Joyita Sadhukhan as a portfolio project demonstrating SQL analytics and data quality remediation.
