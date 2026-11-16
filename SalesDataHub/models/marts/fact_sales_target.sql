SELECT
     target_row_id
     ,target_month
     ,country_code
     ,target_net_revenue_eur
     ,target_new_customers
     ,target_version
     ,approved_by
FROM {{ ref('stg_sales__targets') }}
where target_version = 'v2_Approved'