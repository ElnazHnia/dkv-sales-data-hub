select customer_id, count(*) as first_orders
from {{ ref('int_sales__orders_enriched') }}
where rn_real_order = 1
group by customer_id
having count(*) > 1