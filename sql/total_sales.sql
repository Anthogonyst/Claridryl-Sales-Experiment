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
  SUM(order_total_dollars) AS total_sales
FROM 
  sales_data
WHERE 
  checkout_completed_at >= '12-1-2023' AND checkout_completed_at < '1-1-2024'
UNION ALL 
SELECT 
  SUM(order_total_dollars) AS total_sales
FROM 
  sales_data
