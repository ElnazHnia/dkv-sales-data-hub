SELECT
    TARGET_ROW_ID::NUMBER                  AS target_row_id
    ,TARGET_MONTH::DATE                     AS target_month
    ,COUNTRY_CODE::VARCHAR                  AS country_code

    ,TARGET_NET_REVENUE_EUR::NUMBER(18,2)   AS target_net_revenue_eur
    ,TARGET_NEW_CUSTOMERS::NUMBER           AS target_new_customers

    ,TARGET_VERSION::VARCHAR                AS target_version
    ,APPROVED_BY::VARCHAR                   AS approved_by

FROM {{ source('sales_raw', 'RAW_SALES_TARGETS') }}



