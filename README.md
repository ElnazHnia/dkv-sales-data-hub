# DKV Sales Data Hub

**One governed source of truth for sales reporting, built with Snowflake, dbt, GitHub and Power BI.**

Different regions report different numbers for the same KPI, because each report applies its own filters and formulas. This project replaces that with one tested data foundation and one set of metric definitions, used by both a global management view and a local operational view.

## Dashboards

**Global Sales Dashboard** (for Global Sales Leadership): how much, how fast, where, and against the plan.

![Global Sales Dashboard](SalesDataHub/screenshot/Global%20sales%20Dashboard.jpg)

**Sales Performance Hub** (for country managers and sales reps): gap to my target, why, who, and which orders.

![Sales Performance Hub dashboard](SalesDataHub/screenshot/Sales%20performance%20Hub%20dashboard.jpg)

## What the data shows (Jan–Oct 2026)

| KPI | Value | Meaning |
|---|---|---|
| Net revenue | EUR 490.6K | Invoiced, non-test revenue in EUR |
| Sales orders | 910 | Invoiced standard orders |
| Growth vs. same months 2025 | +21.95% | Same months in both years |
| Target attainment | 79.46% | Revenue ÷ approved target to date |
| New customers | 92 of 405 (22.72%) | First real order falls in the period |

Growth is real, but the plan assumed more, and new customers are the biggest gap. Poland is the only country below last year (−10.9%). Its revenue per order fell because hardware sales dropped sharply.

## Why teams reported different numbers

The same orders give nine different "revenue" figures, from EUR 1,160K to EUR 491K, depending on which filters are applied (duplicates, test accounts, order status, currency, tax, discount). The governed definition is EUR 491K. The rules now live in dbt, written once.

## Architecture

```text
Snowflake RAW  ->  dbt staging  ->  dbt intermediate  ->  dbt marts (star schema)  ->  Power BI model  ->  2 reports
 4 tables          clean, cast       dedupe, as-of join    facts and dimensions        measures, RLS        Management, Local
```

| Layer | Schema | Materialization | Purpose |
|---|---|---|---|
| Staging | STAGING | view | Rename, cast types, remove duplicate loads. One model per source table. |
| Intermediate | INTERMEDIATE | view | Enrich orders with the customer version valid on the order date and with product data. |
| Marts | MARTS | table | Star schema that Power BI connects to. |

Sales targets follow their own path and are not joined to orders. Actual sales and targets meet only through the shared dimensions `dim_country` and `dim_date`, so target values are never duplicated when order-level data is aggregated.

### Models

| Model | Grain | Notes |
|---|---|---|
| `fct_sales` | One row per order | Revenue, discount, tax, eligibility flags, new-customer flag |
| `fact_sales_target` | Country and month | Approved targets only (`v2_Approved`) |
| `dim_customer` | Customer version (SCD2) | Country, segment, rep, credit tier |
| `dim_product` | Product | Category, list price, service fee % |
| `dim_country` | Country | Shared by actuals and targets |
| `dim_date` | Day | Shared by actuals and targets |

## Metric definitions

| Metric | Definition |
|---|---|
| Net revenue | Invoiced orders, test accounts excluded. (Gross − discount) × FX rate to EUR. Tax is not included. Credit notes are negative. |
| Sales orders | Same filters, standard orders only (a credit note reverses a sale). |
| New customer | The customer's first real order (Invoiced or Completed, standard order, not a test account) falls in the period. Counted once per customer. |
| Target attainment | Net revenue ÷ approved target, for the same months. Draft target versions are never used. |
| YoY growth | (This year − last year) ÷ last year, comparing the same months in both years. |
| Discount rate | Discount ÷ gross amount. |
| Cancellation rate | Cancelled orders ÷ all real standard orders. |

## Key modelling decisions

- **Duplicate order loads** (30 order IDs): keep the latest ingestion per order ID.
- **Customer history** (1,000 rows for 700 customers): each order is joined to the customer version valid on the order date, so country and segment are correct for that date.
- **Two currencies (EUR, PLN):** converted with the FX rate on the order.
- **Tax:** checked that gross equals quantity × list price, so tax is on top and is not part of revenue.
- **Service fee:** not part of the order amount, so it is kept out of revenue and shown as a separate measure.
- **Test accounts:** flagged and excluded from KPIs, rows are kept for audit.
- **Targets:** only the approved version is used.

## Data quality and tests

All tests run with `dbt build` or `dbt test`.

- **Generic tests (YAML):** `unique` and `not_null` on keys, `relationships` from the fact to the dimensions, and `accepted_values` on status, order type, currency, channel, country, segment and category.
- **Custom SQL tests (`SalesDataHub/tests/`):**
  - `assert_revenue_ties_to_source`: revenue in `fct_sales` matches revenue recalculated from the staging models.

## Power BI

- **Global management report:** revenue, orders, growth, target attainment, new customers, country and product mix. Attainment and growth are colored by range.
- **Local report:** gap to target, revenue by month vs. target, rep table (revenue, orders, discount rate, cancellation rate), top products and customers, order status and order details.


## Governance

- Metric definitions are written once, in dbt.
- Code is versioned in GitHub and tests run before changes are merged (CI with GitHub Actions is the next step).
- The shared Power BI model is the only way to report, so teams reuse it instead of connecting to raw tables.
- Row-level security controls access by country.

## Next steps

- GitHub Actions workflow that runs `dbt build` on every pull request, in a separate CI schema.
- Customer-status and pending-approval lists on the local report.
- Incremental models for the order fact if the data grows.

---

**Project:** DKV Mobility – Sales Data Hub candidate case study · **Stack:** Snowflake · dbt · GitHub · Power BI
