-- Counts the true number of orders that were not canceled

-- Finished orders from website point of sale
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
)

SELECT 
  COUNT(checkout_completed_at) AS number_of_orders
FROM 
  sales_data
WHERE
-- equivalent to LOWER(delivery_status) LIKE 'cancel%'
  delivery_status NOT ILIKE 'cancel%'
UNION ALL
SELECT 
  COUNT(checkout_completed_at) AS number_of_orders
FROM 
  sales_data
WHERE
-- equivalent to LOWER(delivery_status) LIKE 'cancel%'
  delivery_status NOT ILIKE 'cancel%'
  AND checkout_completed_at >= '12-1-2023'
