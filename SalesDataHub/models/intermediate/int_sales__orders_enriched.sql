SELECT
    so.ORDER_ID
    ,so.CUSTOMER_ID
    ,so.PRODUCT_ID

    -- Sales information
    ,so.ORDER_DATE
    ,so.ORDER_STATUS
    ,so.ORDER_TYPE
    ,so.CURRENCY
    ,so.QUANTITY
    ,so.GROSS_AMOUNT_LOCAL
    ,so.DISCOUNT_AMOUNT_LOCAL
    ,so.FX_RATE_TO_EUR
    ,so.SALES_CHANNEL
    ,so.TAX_AMOUNT_LOCAL

    -- Customer information
    ,c.customer_raw_row_id
    ,c.customer_name
    ,c.country_code
    ,c.customer_segment
    ,c.primary_sales_rep_id
    ,c.onboarding_date
    ,c.valid_from
    ,c.valid_to
    ,c.md_change_reason
    ,c.IS_INTERNAL_TEST_ACCOUNT
    ,c.rn_customer as rn_customer

    -- Product information
    ,p.product_name
    ,p.product_category
    ,p.service_fee_pct
    ,p.standard_unit_price_eur
    ,p.legacy_sap_material_no



FROM {{ ref('stg_sales__orders') }} so
LEFT JOIN {{ ref('stg_sales__customers')}} c
    ON so.CUSTOMER_ID = c.CUSTOMER_ID
    AND so.order_date >= c.valid_from
    AND (
        so.order_date < c.valid_to
        OR c.valid_to IS NULL
    )
LEFT JOIN {{ ref('stg_sales__products')}} p on so.product_id = p.product_id
