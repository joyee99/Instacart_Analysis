# Instacart Market Basket Analysis — SQL Portfolio Project

An end-to-end data analytics project built on the public **Instacart Market Basket** dataset. It goes from raw relational data to stakeholder-ready insights through data quality remediation, 20+ business SQL queries, customer segmentation and a Power BI dashboard. Every reported figure can be traced back to a reproducible SQL query.

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?logo=microsoftsqlserver&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)
![pandas](https://img.shields.io/badge/pandas-150458?logo=pandas&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?logo=powerbi&logoColor=black)

---

## Highlights

- **Data quality first:** found and fixed orphaned orders, recovered from a partial table load, and validated dataset boundaries before running any analysis.
- **20+ business queries** across six analysis areas, from basket composition to churn signals.
- **Reproducible numbers:** each analysis has a base-grain query plus a summary query, with no manual post-processing.
- **Customer segmentation** based on order-count quantiles.
- **Performance tuning** within SQL Server Express's memory limits.
- **Power BI dashboard** built on top of the SQL views.

---

## Tech Stack

| Tool | Used for |
|---|---|
| SQL Server Express (SSMS) | Analysis environment |
| Python (Jupyter, pandas, pyodbc) | Data loading with `fast_executemany=True` and batch commits |
| Power BI | Dashboard and reporting |
| Git / GitHub | Version control and publishing |

---

## Project Structure

| Folder | What's inside |
|---|---|
| [`1_Data_Quality_Check`](1_Data_Quality_Check) | Integrity checks and cleanup scripts |
| [`2_Data_Model`](2_Data_Model) | Table design and relationships |
| [`3_Analysis`](3_Analysis) | Business queries across the six analysis categories |
| [`4_DataModel_and_Reports/1_Data_Modelling`](4_DataModel_and_Reports/1_Data_Modelling) | Data model used for reporting |
| [`5_PowerBi`](5_PowerBi) | `Dashboard.pbix`, the Power BI report |
| [`6_SQL_Views`](6_SQL_Views) | Views that feed the dashboard |

---

## Dataset

The Instacart Market Basket dataset contains anonymised grocery orders, products, aisles, departments and prior order history.

Dataset quirks documented in this project:
- Each customer has **at least 3** orders and **at most 100**. The 100 is a data cap, not a real behavioural ceiling.
- `days_since_prior_order` is **capped at 30**.
- The `order_dow` (day of week) encoding is inferred from community convention because it isn't officially documented.

---

## Data Quality & Integrity

- Identified and removed **orphaned orders** (orders with no product data), using a backup-then-delete approach.
- **Fully reloaded** the `order_products` table after a partial-load failure, so the data is complete.
- Verified the **min/max order count** per customer to confirm the dataset's scope before analysis.

---

## Analysis Categories

More than 20 business queries cover six areas:

| Category | Focus |
|---|---|
| Customer behaviour | Ordering habits, frequency and volume |
| Basket analysis | Product co-occurrence and basket composition |
| Reorder patterns | Repeat purchases by product and department |
| Department & aisle performance | Sales and reorder rates by category |
| Time trends | Order timing by day of week and days since prior order |
| Churn / retention | Customer lifecycle and drop-off signals |

**Dual-query pattern:** each analysis pairs a base-grain query with a summary query, so every reported number can be reproduced directly from SQL.

---

## Customer Segmentation

Customers are grouped into tiers using quantile-based breakpoints on total order count:

| Tier | Order count |
|---|---|
| 1 | 3 |
| 2 | 4–19 |
| 3 | 20–49 |
| 4 | 50–99 |
| 5 | 100 |

The rationale for each boundary is documented in [`3_Analysis`](3_Analysis).

---

## Known Constraints & How They Were Handled

1. **SQL Server Express memory ceiling (~1.4 GB buffer pool).** Heavy aggregations and `DISTINCT` operations spill to disk. This was handled with indexed temp tables, splitting CTEs, and checking execution plans for sort-spill warnings before adding indexes. The memory ceiling, not missing indexes, was the root cause.
2. **Small-sample noise.** Minimum volume thresholds are applied before ranking products and departments, so low-count items don't produce misleading results.

---

## Author

**Joyita Sadhukhan** · [LinkedIn](https://www.linkedin.com/in/joyita-sadhukhan-7392a6209/) · [GitHub](https://github.com/joyee99)
