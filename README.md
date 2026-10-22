# Superstore Profit Analysis: Why Is Profit Under Pressure Even When Sales Grow?

An end-to-end data analytics / consulting capstone project built with **Python, SQL Server and Power BI** on the Superstore sales dataset (2014-2017).

![Executive summary dashboard]()

## Business Problem

> The company's profit from 2014-2017 looks unstable. Management does not understand why profit is under pressure even though sales are increasing. Which Category, Region or Product is causing losses?

**Objectives**

1. Find the reason for the profit problem
2. Identify loss-making products and categories
3. Give 3 actionable recommendations to management

## Dataset

| Item | Detail |
|---|---|
| Source | [Superstore Sales dataset (Kaggle)](https://www.kaggle.com/) |
| Period | January 2014 to December 2017 |
| Size | 9,994 order lines, 5,009 distinct orders, 21 raw columns |
| Totals | Sales 2,297,200.86 and Profit 286,397.02 (overall margin 12.47%) |

Raw file: `data/Superstore_Sales_data.xlsx`. Cleaned file: `data/Clean_Superstore.csv` (adds Year, Month, Year-Month, Profit_Margin, Delivery_Days and Profit_Status).

## Tools Used

- **Python** (pandas, numpy) for cleaning, feature engineering and EDA
- **SQL Server Express** (SQLAlchemy + pyodbc to load, T-SQL for analysis)
- **Power BI** for the 4-page executive dashboard

## Project Workflow

1. **Problem definition**: business problem and 3 objectives
2. **Data cleaning (Python)**: quality checks (no nulls, no duplicates) and a custom `fix_date` function, because the Excel date columns were a mix of swapped day/month dates and text dates
3. **Feature engineering**: Year, Month, Year-Month, row-level Profit_Margin, Delivery_Days, Profit_Status (Profit/Loss), Discount_Bucket
4. **EDA (Python)**: category, region, state, sub-category, product, segment, ship mode and discount analysis
5. **SQL analysis**: cleaned data loaded into `SuperstoreDB.dbo.CleanedOrders` and analysed with 8 queries
6. **Dashboard (Power BI)**: executive summary, category and product, region and customer, trend and recommendations

**Data validation:** totals after cleaning match the raw file exactly, and delivery time ranges from 0 to 7 days with no negative values, which confirms the date fix is correct.

## Key Findings

### 1. Total profit did not fall; margin quality is the real problem

| Year | Sales | Profit | Margin |
|---|---|---|---|
| 2014 | 484,247 | 49,544 | 10.2% |
| 2015 | 470,533 | 61,619 | 13.1% |
| 2016 | 609,206 | 81,795 | 13.4% |
| 2017 | 733,215 | 93,439 | 12.7% |

Profit grows every year, but the overall margin is only **12.5%**, **18.7%** of order lines (1,871 of 9,994) lose money, and the 2017 margin slipped below 2016.

### 2. Discounting is the root cause

| Discount | Rows | Sales | Profit | Margin | Loss-making rows |
|---|---|---|---|---|---|
| 0% | 4,798 | 1,087,908 | 320,988 | 29.5% | 0% |
| 1-20% | 3,803 | 846,522 | 100,785 | 11.9% | 13.8% |
| 21-40% | 460 | 234,138 | -35,817 | -15.3% | 90.2% |
| 40%+ | 933 | 128,632 | -99,559 | -77.4% | 100% |

- Discount and profit margin have a correlation of **-0.86**.
- Rows with more than 20% discount are only 13.9% of rows (15.8% of sales) but lose **135K** combined.
- Delivery time and ship mode are **not** the cause (average delivery 3.97 days for loss rows vs 3.95 days for profit rows).

### 3. Where the losses are

- **Category:** Furniture has a 2.5% margin, against 17.4% for Technology and 17.0% for Office Supplies.
- **Sub-category:** Tables (-17.7K), Bookcases (-3.5K) and Supplies (-1.2K) are the only sub-categories that lose money overall. Tables and Bookcases lose because of high discounts (they earn +13.3K and +6.1K at 0% discount but lose 30.7K and 11.1K above 20%). Supplies has a low average discount (7.7%), so its loss points to a cost or pricing issue instead. Binders and Machines are profitable overall but lose 38.5K and 27.2K on rows discounted above 40%.
- **Products:** Cubify CubeX 3D Printer (double head, -8.9K), Lexmark MX611dhe printer (-4.6K) and Cubify CubeX 3D Printer (triple head, -3.8K) are the biggest losers.
- **Region:** Central has the lowest profit (39.7K) and the highest average discount (24%, against 11% in West).
- **States:** Texas (-25.7K), Ohio (-17.0K), Pennsylvania (-15.6K) and Illinois (-12.6K) lose the most, with average discounts of 32-39% (California: 7%, New York: 5.5%).
- **Segment:** Consumer earns the most profit (134K) but has the lowest margin (11.5%, against 13.0% Corporate and 14.0% Home Office).
- **Seasonality:** Q4 is the peak quarter (878K sales).

## Recommendations

1. **Cap discounts at 20%** and require management approval above it, starting with Tables, Bookcases, Binders and Machines.
2. **Reprice or discontinue the worst loss-making products** (Cubify CubeX 3D printers, Lexmark MX611dhe, loss-making conference tables).
3. **Review discount and cost policy in the Central region and the loss-making states**, and push growth in high-margin Technology and Office Supplies.

## Dashboard

| | |
|---|---|
| ![Category and product](images/dashboard_2_category_product.png) | ![Region and customer](images/dashboard_3_region_customer.png) |
| ![Trend and recommendations](images/dashboard_4_trend_recommendations.png) | |

The Power BI file is in `dashboard/Superstore_Executive_Summary_Dashboard.pbix` (PDF export alongside). It reads from the SQL Server table `CleanedOrders`, so open it with the table loaded, or point the data source to your own server.

## Repository Structure

```
superstore-profit-analysis/
├── README.md
├── requirements.txt
├── data/
│   ├── Superstore_Sales_data.xlsx       # raw data
│   └── Clean_Superstore.csv             # cleaned data (loaded to SQL Server)
├── notebooks/
│   └── Project_1.ipynb                  # cleaning, EDA, discount analysis, SQL load
├── sql/
│   └── SQL_Analysis.sql                 # 8 analysis queries (T-SQL)
├── dashboard/
│   ├── Superstore_Executive_Summary_Dashboard.pbix
│   └── Superstore_Executive_Summary_Dashboard.pdf
└── images/                              # dashboard screenshots used in this README
```

## How to Run

1. Clone the repo and install the libraries: `pip install -r requirements.txt`
2. Open `notebooks/Project_1.ipynb` in Jupyter and run the cells top to bottom. The notebook reads `../data/Superstore_Sales_data.xlsx`, so keep the folder structure as it is.
3. **Optional (SQL Server):** the last section of the notebook loads the data into SQL Server. Edit the connection string in the notebook to match your server (the project used `localhost\SQLEXPRESS`, database `SuperstoreDB`, ODBC Driver 17, Windows authentication). Create the empty database first. Note that `if_exists='replace'` drops and recreates the `CleanedOrders` table.
4. Run `sql/SQL_Analysis.sql` in SQL Server Management Studio, connected to `SuperstoreDB`.

You can skip step 3 and 4 and still reproduce all the Python results.

## Limitations

- The analysis is at order-line level. Discount is strongly associated with losses, but this data cannot prove cause and effect (for example, whether discounts were given on items that already had low margins).
- Profit margin per row is a ratio; use `SUM(Profit) / SUM(Sales)` for any summary margin, not the average of row margins.
- Targets shown on the dashboard KPI cards are assumed values and are not part of the source data.

## Author

**Abhishek Kumar**, MBA (Dual Specialization) 2025-27, School of Business, Galgotias University [Linkedin- www.linkedin.com/in/abhishek-kumar-a5a819283] 
