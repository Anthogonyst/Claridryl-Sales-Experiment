-- Counts the number of experimental data in 4 unique ways:
-- The total number of distinct customers, >= '12-28-2023' <= '1-18-2024'
-- The total number of converted experimental customers, >= '12-28-2023' <= '1-18-2024'
-- The total number of distinct customers, >= '2-1-2024' <= '2-22-2024'
-- The total number of converted experimental customers, >= '2-1-2024' <= '2-22-2024'

-- Subsets full data view into successful sales on website point of sale for downstream analysis
-- Note that it also includes orders that were canceled during delivery
WITH sales_data AS (
  SELECT
    buy.*,
    stat.delivery_status
  FROM 
    dev_claridryl.checkout_attempts AS buy
  LEFT JOIN
    dev_claridryl.order_status AS stat ON buy.order_id = stat.order_id
  WHERE 
    stat.delivery_status IS NOT NULL
),
-- Gets an experiment group where customers that have made multiple purchases did not buy non-meds but now do
experimental_population AS (
  SELECT 
    sales.*
  FROM 
    sales_data AS sales
  INNER JOIN
  (
    SELECT DISTINCT customer_id AS exp_group
    FROM 
      sales_data 
    WHERE 
      customer_added_non_med_to_order
  ) AS nonmeds ON sales.customer_id = nonmeds.exp_group
  INNER JOIN 
  (
    SELECT DISTINCT customer_id AS exp_group
    FROM 
      sales_data 
    WHERE
      NOT customer_added_non_med_to_order
  ) AS onlymeds ON sales.customer_id = onlymeds.exp_group 
  WHERE
    sales.customer_added_non_med_to_order IS NOT NULL
)


-- The total number of distinct customers, >= '12-28-2023' <= '1-18-2024'
SELECT 
  COUNT(DISTINCT customer_id)
FROM 
  experimental_population
WHERE 
  checkout_completed_at >= '12-28-2023' AND checkout_completed_at <= '1-18-2024'
UNION ALL 
-- The total number of converted experimental customers, >= '12-28-2023' <= '1-18-2024'
SELECT 
  COUNT(DISTINCT customer_id)
FROM 
  sales_data
WHERE 
  checkout_completed_at >= '12-28-2023' AND checkout_completed_at <= '1-18-2024'
UNION ALL 
-- The total number of distinct customers, >= '2-1-2024' <= '2-22-2024'
SELECT 
  COUNT(DISTINCT customer_id)
FROM 
  experimental_population
WHERE 
  checkout_completed_at >= '2-1-2024' AND checkout_completed_at <= '2-22-2024'
UNION ALL 
-- The total number of converted experimental customers, >= '2-1-2024' <= '2-22-2024'
SELECT 
  COUNT(DISTINCT customer_id)
FROM 
  sales_data
WHERE 
  checkout_completed_at >= '2-1-2024' AND checkout_completed_at <= '2-22-2024';
