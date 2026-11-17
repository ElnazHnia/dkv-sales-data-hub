select 
count(*) cnt_order
,count(distinct order_id) cnt_unique_order //RAW_KAFKA_OFFSET_ID
from DKV_SALES_HUB.RAW.raw_sales_orders;


select distinct c.customer_id
from 
DKV_SALES_HUB.RAW.raw_sales_orders c
where not exists
(select 1
from DKV_SALES_HUB.RAW.RAW_CUSTOMERS so
where c.customer_id = so.customer_id);


select distinct c.product_id
from 
DKV_SALES_HUB.RAW.raw_sales_orders c
where not exists
(select 1
from DKV_SALES_HUB.RAW.RAW_PRODUCTS_CONTRACTS so
where c.product_id = so.product_id);