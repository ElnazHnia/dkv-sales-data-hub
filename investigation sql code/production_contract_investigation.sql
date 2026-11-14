select 
count(*) cnt_product
,count(distinct product_id) cnt_unique_product 
,sum (case when is_active_product = 1 then 1 else 0 end) active_product //active_product
from DKV_SALES_HUB.RAW.RAW_PRODUCTS_CONTRACTS;