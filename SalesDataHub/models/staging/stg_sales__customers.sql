SELECT
    CUSTOMER_RAW_ROW_ID::NUMBER         AS customer_raw_row_id
    ,CUSTOMER_ID::VARCHAR               AS customer_id
    ,CUSTOMER_NAME::VARCHAR             AS customer_name
    ,COUNTRY_CODE::VARCHAR              AS country_code
    ,CUSTOMER_SEGMENT::VARCHAR          AS customer_segment
    ,PRIMARY_SALES_REP_ID::VARCHAR      AS primary_sales_rep_id

    ,ONBOARDING_DATE::DATE              AS onboarding_date
    ,VALID_FROM::DATE                   AS valid_from
    ,VALID_TO::DATE                     AS valid_to

    ,MD_CHANGE_REASON::VARCHAR          AS md_change_reason

    ,(case when IS_INTERNAL_TEST_ACCOUNT = 1 then TRUE else FALSE end)  AS is_internal_test_account

    ,CREDIT_LIMIT_EUR::NUMBER(18,2)     AS credit_limit_eur
    ,dense_rank() OVER (PARTITION BY customer_id ORDER BY  CUSTOMER_RAW_ROW_ID asc) AS  rn_customer
   
FROM {{ source('sales_raw', 'RAW_CUSTOMERS') }}

