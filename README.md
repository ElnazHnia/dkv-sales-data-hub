# DKV Sales Data Hub
### Building a Centralized, Scalable and Governed Sales Analytics Foundation

## 1. Project Overview

This project demonstrates the design and implementation of a centralized Sales Data Hub using **Snowflake, dbt, GitHub and Power BI**.

The objective is to address inconsistent sales reporting, duplicated business logic and fragmented data models by establishing a centralized and reusable data foundation.

The solution is designed to support two main business audiences:

- **Global Sales Leadership:** Company-wide sales performance monitoring and strategic decision-making.
- **Regional Sales Teams:** Country-level performance monitoring and operational sales analysis.

Both audiences use consistent business definitions and a shared semantic data foundation, while maintaining different reporting perspectives and data access permissions.

## 2. Business Challenges

The project addresses the following challenges described in the case study:

### Inconsistent KPI Definitions
Different regional reports calculate the same business metrics using different filters and calculation logic, resulting in conflicting numbers.

### Fragmented Data Models
Direct connections to raw Snowflake tables in Power BI lead to duplicated transformations, complex relationships and difficult maintenance.

### Global vs. Regional Reporting Requirements
Global Sales Leadership needs a consolidated company-wide view, while regional teams require detailed insights into their respective markets.

### Data Governance and Access
A centralized approach is needed to ensure consistent metric definitions, reliable data quality and controlled access to regional sales information.

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| Snowflake | Cloud data warehouse and data storage |
| dbt | Data transformation, testing and documentation |
| GitHub | Version control and collaborative development |
| Power BI | Business intelligence, visualization and semantic modeling |

## 4. Data Sources

The project uses four synthetic source tables provided as part of the DKV case study.

| Source Table | Description |
|---|---|
| RAW_CUSTOMERS | Customer master data, historical records, country information, sales representatives and test-account indicators |
| RAW_SALES_ORDERS | Sales transactions, order statuses, quantities, local currency amounts, discounts and ingestion timestamps |
| RAW_PRODUCTS_CONTRACTS | Product hierarchy, categories, active status, service fee percentages and standard prices |
| RAW_SALES_TARGETS | Monthly sales targets, country codes, target versions and approval information |

## 5. Data Architecture

The solution follows a layered data architecture using Snowflake and dbt, separating raw data ingestion, data transformation and business-ready analytical models.

### 5.1 Sales Data Flow

Customer, product and sales order data are processed through staging and intermediate transformation layers to produce the final sales fact table.

**Staging Layer**
- Standardizes source column names and data types.
- Handles duplicate sales order records.
- Performs basic data cleaning.
- Preserves relevant historical customer records.

**Intermediate Layer**
- Applies reusable business logic.
- Enriches sales orders with customer and product information.
- Handles historical customer matching using effective-date logic.
- Prepares consistent data for analytical models.

**Sales Mart**
- `fct_sales`: Order-level fact table containing enriched sales transactions.
- `dim_customer`: Customer dimension preserving historical customer versions.
- `dim_product`: Product dimension containing product attributes.
- `dim_country`: Shared country dimension.
- `dim_date`: Shared calendar dimension.

### 5.2 Independent Sales Targets Data Flow

Sales targets follow a separate transformation process and are not directly joined with sales orders, customers or products.

**Target Staging**
- Standardizes target source data.
- Handles target version information.
- Identifies approved target records.

**Target Mart**
- `fct_sales_targets`: Fact table containing approved monthly sales targets at country-month grain.

This separation preserves the different grains of actual sales and sales targets.

### 5.3 Shared Reporting Layer

Actual sales and sales targets are not directly joined.

Instead, both fact tables share conformed dimensions:

- `dim_country`
- `dim_date`

This enables comparisons between actual sales performance and monthly targets without duplicating target values when aggregating order-level transactions.

### Architecture Overview

```text
                 SNOWFLAKE RAW LAYER
                         |
          +--------------+--------------+
          |              |              |
      CUSTOMERS        ORDERS         PRODUCTS
          |              |              |
          +--------------+--------------+
                         |
                         v
                  STAGING LAYER
                         |
                         v
                INTERMEDIATE LAYER
                         |
                         v
                    SALES MART
                         |
                 +-------+-------+
                 |               |
              fct_sales      Dimensions
                             dim_customer
                             dim_product
                             dim_country
                             dim_date


          RAW_SALES_TARGETS
                  |
                  v
             STAGING LAYER
                  |
                  v
              TARGET MART
                  |
            fct_sales_targets


          SHARED REPORTING LAYER
          ----------------------
          fct_sales
          fct_sales_targets
                 |
          Shared Dimensions
          dim_country
          dim_date
                 |
                 v
          POWER BI SEMANTIC MODEL
                 |
          +------+------+
          |             |
     Global Sales   Regional Sales
     Management       Reporting
```

## 6. Data Quality and Testing

Data quality is an essential part of the Sales Data Hub.

The project uses dbt testing to validate data integrity and business rules throughout the transformation process.

Examples of data quality checks include:

- `unique`: Ensures uniqueness of business and technical identifiers where applicable.
- `not_null`: Checks mandatory fields.
- `relationships`: Validates referential integrity between related models.
- `accepted_values`: Ensures fields contain expected values.
- Custom SQL tests: Validate specific business rules, such as approved target uniqueness per country and month.

Tests are defined alongside dbt models using YAML and SQL files.

The intended CI/CD approach uses GitHub Actions to automate dbt validation when code changes are submitted through Pull Requests.

## 7. Data Documentation and Lineage

dbt documentation provides transparency into the transformation process and improves model maintainability.

Documentation includes:

- Model-level descriptions.
- Column-level descriptions.
- Source definitions.
- Data quality test definitions.
- Upstream and downstream model dependencies.
- Transformation logic and compiled SQL.

The dbt lineage graph helps analysts and engineers understand how raw source data flows through staging and intermediate models into the final analytical marts.

## 8. Core Business Metrics

The analytical foundation is designed to support centrally governed sales KPIs.

Examples include:

| KPI | Description |
|---|---|
| Total Revenue (EUR) | Recognized sales revenue converted into EUR according to the agreed business definition |
| Invoiced Sales Order Count | Number of qualifying invoiced standard sales orders |
| Revenue vs. Target | Comparison of actual revenue against approved sales targets |
| Target Achievement (%) | Actual revenue divided by the corresponding approved target |
| New Customers | Number of customers meeting the agreed first-purchase definition |
| Revenue by Country | Sales revenue aggregated by country |
| Revenue by Product Category | Sales revenue grouped by product category |
| Sales Representative Performance | Sales performance attributed to sales representatives |

Metric definitions, filters and calculation rules should be centrally maintained to ensure consistent reporting across all regions.

## 9. Power BI Reporting

The solution uses a shared semantic model to support different reporting requirements without duplicating the underlying business logic.

### 9.1 Global Management Report

Designed for Global Sales Leadership, providing a consolidated company-wide overview.

Key analytical areas:

- Executive sales performance.
- Actual revenue and target achievement.
- Country ranking and performance comparisons.
- Product category performance.
- Customer and sales trends.

### 9.2 Regional Sales Report

Designed for Country Managers, Sales Representatives and regional analysts.

Key analytical areas:

- Regional sales performance.
- Order status and sales order analysis.
- Customer segmentation.
- Product and sales channel performance.
- Sales representative performance.

### 9.3 Data Access and Security

Row-Level Security (RLS) is designed to control data visibility based on user access rights.

Regional users should only access information belonging to their authorized markets, while global management should have access to consolidated company-wide information.

Both reporting perspectives use the same governed semantic model.

## 10. Governance and Maintainability

The proposed governance approach establishes a consistent and sustainable analytics environment through:

- Centralized KPI definitions.
- Clearly assigned ownership for each metric.
- dbt tests and documentation.
- Version control through GitHub.
- Automated validation through CI/CD.
- Reusable transformation logic.
- Consistent reporting through a shared Power BI semantic model.
- Controlled data access through Row-Level Security.

The objective is to establish a single source of truth and reduce duplicated business logic across regional reporting environments.

## 11. Expected Business Outcomes

The Sales Data Hub is designed to deliver the following benefits:

- Consistent and trusted sales KPIs across regions.
- Reduced duplication of transformation and calculation logic.
- Improved data quality and transparency.
- Reusable and maintainable data models.
- Clear visibility into data dependencies and lineage.
- Better support for global and regional decision-making.
- Secure and controlled access to sales information.
- A scalable foundation for future analytical requirements.

---

## Project Information

**Project:** DKV Mobility – Sales Data Hub Candidate Case Study

**Technology:** Snowflake | dbt | GitHub | Power BI

**Focus Areas:** Data Engineering | Analytics Engineering | Business Intelligence | Data Governance

**Repository:** [GitHub – DKV Sales Data Hub](https://github.com/ElnazHnia/dkv-sales-data-hub)
