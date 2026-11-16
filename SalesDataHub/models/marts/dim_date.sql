WITH date_bounds AS (

    SELECT
        LEAST(
            (SELECT MIN(ORDER_DATE)::DATE
             FROM {{ ref('stg_sales__orders') }}),

            (SELECT MIN(TARGET_MONTH)::DATE
             FROM {{ ref('stg_sales__targets') }})
        ) AS MIN_DATE,

        GREATEST(
            (SELECT MAX(ORDER_DATE)::DATE
             FROM {{ ref('stg_sales__orders') }}),

            (SELECT MAX(TARGET_MONTH)::DATE
             FROM {{ ref('stg_sales__targets') }})
        ) AS MAX_DATE

),

calendar AS (

    SELECT
        DATEADD(
            DAY,
            SEQ4(),
            MIN_DATE
        )::DATE AS DATE_DAY

    FROM date_bounds,
         TABLE(GENERATOR(ROWCOUNT => 5000))

    QUALIFY DATE_DAY <= MAX_DATE

)

SELECT
    DATE_DAY AS DATE_KEY,
    DATE_DAY,
    YEAR(DATE_DAY) AS YEAR,
    QUARTER(DATE_DAY) AS QUARTER,
    MONTH(DATE_DAY) AS MONTH_NUMBER,
    MONTHNAME(DATE_DAY) AS MONTH_NAME,
    DAY(DATE_DAY) AS DAY_OF_MONTH,
    DAYNAME(DATE_DAY) AS DAY_NAME,
    WEEKOFYEAR(DATE_DAY) AS WEEK_OF_YEAR,
    DAYOFWEEKISO(DATE_DAY) AS DAY_OF_WEEK,
    DATE_TRUNC('MONTH', DATE_DAY)::DATE AS MONTH_START_DATE,
    LAST_DAY(DATE_DAY) AS MONTH_END_DATE,
    TO_CHAR(DATE_DAY, 'YYYY-MM') AS YEAR_MONTH

FROM calendar
