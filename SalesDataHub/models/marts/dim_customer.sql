
SELECT
    CUSTOMER_RAW_ROW_ID,
    CUSTOMER_ID,
    CUSTOMER_NAME,
    COUNTRY_CODE,
    CUSTOMER_SEGMENT,
    PRIMARY_SALES_REP_ID,
    ONBOARDING_DATE,
    VALID_FROM,
    VALID_TO,
    MD_CHANGE_REASON,
    IS_INTERNAL_TEST_ACCOUNT,
    CREDIT_LIMIT_EUR,
    case
        when credit_limit_eur >= 250000 then '1. Very high'
        when credit_limit_eur >= 100000 then '2. High'
        when credit_limit_eur >= 50000  then '3. Medium'
        else '4. Low'
    end as credit_tier

FROM {{ ref('stg_sales__customers') }} c
