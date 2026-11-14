select * from DKV_SALES_HUB.RAW.RAW_CUSTOMERS; //history -> 

select * from DKV_SALES_HUB.RAW.RAW_PRODUCTS_CONTRACTS;

select * from DKV_SALES_HUB.RAW.RAW_SALES_ORDERS where order_id in ('ORD-20252133');

select * from DKV_SALES_HUB.RAW.RAW_SALES_TARGETS;


select product_id, count(*)
from DKV_SALES_HUB.RAW.RAW_PRODUCTS_CONTRACT ;

select order_id
, count(*)
from DKV_SALES_HUB.RAW.RAW_SALES_ORDERS
group by order_id
having count(*) > 1;