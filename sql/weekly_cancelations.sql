-- A weekly count of orders canceled after website point of sale

-- Failed sales with only cancelations during delivery
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
    AND delivery_status ILIKE 'cancel%'
)

-- Optionally, GENERATE_SERIES() will fill in dates that are missing, but it was not needed here

SELECT
  DATE_TRUNC('week', checkout_completed_at) AS weekly,
  COUNT(order_id)
FROM sales_data
GROUP BY weekly
ORDER BY weekly;