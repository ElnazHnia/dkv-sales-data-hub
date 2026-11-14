SELECT
        ORDER_ID::VARCHAR                   AS order_id,
        ORDER_DATE::DATE                    AS order_date,
        CUSTOMER_ID::VARCHAR                AS customer_id,
        PRODUCT_ID::VARCHAR                 AS product_id,
        ORDER_STATUS::VARCHAR               AS order_status,
        ORDER_TYPE::VARCHAR                 AS order_type,

        CURRENCY::VARCHAR                   AS currency,
        FX_RATE_TO_EUR::NUMBER(18,6)        AS fx_rate_to_eur,

        QUANTITY::NUMBER(18,4)              AS quantity,
        GROSS_AMOUNT_LOCAL::NUMBER(18,2)    AS gross_amount_local,
        DISCOUNT_AMOUNT_LOCAL::NUMBER(18,2) AS discount_amount_local,
        TAX_AMOUNT_LOCAL::NUMBER(18,2)      AS tax_amount_local,

        SALES_CHANNEL::VARCHAR              AS sales_channel,

        SYS_INGESTION_TS::TIMESTAMP_NTZ     AS sys_ingestion_ts,
        RAW_KAFKA_OFFSET_ID::NUMBER         AS raw_kafka_offset_id,
        dense_rank() over (partition by order_id order by sys_ingestion_ts desc) rn

    FROM {{ source('sales_raw', 'RAW_SALES_ORDERS') }}
    qualify rn = 1