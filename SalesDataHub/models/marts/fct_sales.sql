select 
       -- PK
        ORDER_ID,

        -- FK
         CUSTOMER_ID,
         customer_raw_row_id,
         PRODUCT_ID,
         ORDER_DATE,

        -- Order attributes
        ORDER_STATUS,
        ORDER_TYPE,
        CURRENCY,
        FX_RATE_TO_EUR,
        SALES_CHANNEL,

        -- Measures
        QUANTITY,

        --internal cal Rev
        QUANTITY * standard_unit_price_eur as GROSS_AMOUNT_euro_internal_cal,
                
        GROSS_AMOUNT_LOCAL AS GROSS_AMOUNT_LC,
        DISCOUNT_AMOUNT_LOCAL AS DISCOUNT_AMOUNT_LC,
        TAX_AMOUNT_LOCAL AS TAX_AMOUNT_LC,
        
      
        GROSS_AMOUNT_LOCAL * FX_RATE_TO_EUR AS GROSS_AMOUNT_EUR,

        DISCOUNT_AMOUNT_LOCAL * FX_RATE_TO_EUR AS DISCOUNT_AMOUNT_EUR,

        TAX_AMOUNT_LOCAL * FX_RATE_TO_EUR AS TAX_AMOUNT_EUR,

        -- REVENUE
        (GROSS_AMOUNT_LOCAL - DISCOUNT_AMOUNT_LOCAL) as REVENUE_LOCAL,
        (GROSS_AMOUNT_LOCAL - DISCOUNT_AMOUNT_LOCAL)* FX_RATE_TO_EUR AS REVENUE_EUR,
        (GROSS_AMOUNT_LOCAL - DISCOUNT_AMOUNT_LOCAL)* FX_RATE_TO_EUR * service_fee_pct         as service_fee_eur,
        -- Revenue eligibility
        CASE 
            WHEN ORDER_STATUS = 'Invoiced' AND COALESCE(IS_INTERNAL_TEST_ACCOUNT, FALSE) = FALSE
            THEN TRUE
            ELSE FALSE
        END AS IS_REVENUE_ELIGIBLE,
        
        -- is real order 
        CASE 
         when ((order_status in ('Invoiced', 'Completed')
         and order_type = 'Standard_Order'
         and coalesce(is_internal_test_account, false) = false)) then
          TRUE
         ELSE
          FALSE
        END as is_real_order,
         
        -- Credit note sign
        CASE
            WHEN ORDER_TYPE = 'Credit_Note' THEN -1
            ELSE 1
        END AS REVENUE_SIGN,

        -- Signed revenue
        CASE
            WHEN ORDER_STATUS = 'Invoiced'
             AND COALESCE(IS_INTERNAL_TEST_ACCOUNT, FALSE) = FALSE
            THEN
                (GROSS_AMOUNT_LOCAL - DISCOUNT_AMOUNT_LOCAL)
                * FX_RATE_TO_EUR
                * CASE
                    WHEN ORDER_TYPE = 'Credit_Note' THEN -1
                    ELSE 1
                  END
            ELSE 0
        END AS REVENUE_WITH_SIGN_EUR,
     
        -- Audit field
        IS_INTERNAL_TEST_ACCOUNT,

        -- NEW CUSTOMER
        row_number() over ( partition by customer_id, is_real_order order by order_date, order_id)  as rn_real_order,
        
        case when order_status in ('Invoiced', 'Completed')
          and order_type = 'Standard_Order'
          and coalesce(is_internal_test_account, false) = false
          and rn_real_order = 1 then
           CUSTOMER_ID
        end as new_customer,

        CASE 
            WHEN ORDER_STATUS = 'Invoiced' AND COALESCE(IS_INTERNAL_TEST_ACCOUNT, FALSE) = FALSE and order_type = 'Standard_Order'
            THEN ORDER_ID
        END AS ELIGIBLE_ORDER

        
        
            
from {{ref('int_sales__orders_enriched')}} so

