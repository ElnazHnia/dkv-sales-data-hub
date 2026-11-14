SELECT
    PRODUCT_ID::VARCHAR                      AS product_id
    ,PRODUCT_NAME::VARCHAR                   AS product_name
    ,PRODUCT_CATEGORY::VARCHAR               AS product_category
    ,SERVICE_FEE_PCT::NUMBER(10,4)           AS service_fee_pct
    ,STANDARD_UNIT_PRICE_EUR::NUMBER(18,2)   AS standard_unit_price_eur
    ,(case when IS_ACTIVE_PRODUCT = 1 then TRUE else FALSE end) AS is_active_product
    ,LEGACY_SAP_MATERIAL_NO::VARCHAR         AS legacy_sap_material_no
    
FROM {{ source('sales_raw', 'RAW_PRODUCTS_CONTRACTS') }}