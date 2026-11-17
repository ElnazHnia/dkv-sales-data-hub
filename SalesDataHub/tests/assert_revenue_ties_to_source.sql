with fact as (
    select sum(revenue_with_sign_eur) as rev from {{ ref('fct_sales') }}
),
source as (
    select sum(
        (gross_amount_local - discount_amount_local) * fx_rate_to_eur
        * case when order_type = 'Credit_Note' then -1 else 1 end
    ) as rev
    from {{ ref('stg_sales__orders') }} o
    join {{ ref('stg_sales__customers') }} c
      on o.customer_id = c.customer_id
     and o.order_date >= c.valid_from
     and (c.valid_to is null or o.order_date < c.valid_to)
    where o.order_status = 'Invoiced'
      and coalesce(c.is_internal_test_account, false) = false
)
select * from fact, source
where abs(fact.rev - source.rev) > 0.01