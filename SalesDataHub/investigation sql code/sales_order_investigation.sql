select 
count(*) cnt_order
,count(distinct order_id) cnt_unique_order //RAW_KAFKA_OFFSET_ID
from DKV_SALES_HUB.RAW.raw_sales_orders;


