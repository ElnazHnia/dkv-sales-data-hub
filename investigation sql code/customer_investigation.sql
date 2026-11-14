select 
count(*) cnt_customer
,count(distinct customer_id) cnt_unique_customer // Historical Data
,sum (case when is_internal_test_account = 1 then 1 else 0 end) dummy_data // Dummy Data
,sum (case when md_change_reason = 'SCD2 Closed' and valid_to is null then 1 else 0 end) validate_close_data // if all of customers with closed status have valid_to date.
from DKV_SALES_HUB.RAW.RAW_CUSTOMERS;