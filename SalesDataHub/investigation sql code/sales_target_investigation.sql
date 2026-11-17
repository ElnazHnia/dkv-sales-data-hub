select target_month, country_code,
       count(*) cnt,
       count_if(target_version = 'v2_Approved') cnt_approved

from DKV_SALES_HUB.RAW.raw_sales_targets
group by target_month, country_code
having cnt_approved > 1;


select count(*) cnt,
       count_if(target_version = 'v2_Approved') cnt_approved

from DKV_SALES_HUB.RAW.raw_sales_targets;