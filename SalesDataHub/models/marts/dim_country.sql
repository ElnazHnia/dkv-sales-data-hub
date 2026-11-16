
{{ config(materialized='table') }}

WITH countries AS (

    SELECT COUNTRY_CODE
    FROM {{ ref('stg_sales__customers') }}

    UNION

    SELECT COUNTRY_CODE
    FROM {{ ref('stg_sales__targets') }}

)

SELECT DISTINCT
    COUNTRY_CODE AS COUNTRY_KEY,
    COUNTRY_CODE

FROM countries
WHERE COUNTRY_CODE IS NOT NULL
