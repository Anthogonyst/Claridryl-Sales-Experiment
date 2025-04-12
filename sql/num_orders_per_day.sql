-- Counts the number of orders made per day

-- Subsets full data view into successful sales on website point of sale for downstream analysis
-- Note that it also includes orders that were canceled during delivery
WITH sales_data AS (
  SELECT
    buy.*,
    stat.delivery_status
    -- MONTH(checkout_completed_at) AS mon,
    -- YEAR(checkout_completed_at) AS yr,
    -- MONY
  FROM 
    dev_claridryl.checkout_attempts AS buy
  LEFT JOIN
    dev_claridryl.order_status AS stat ON buy.order_id = stat.order_id
  WHERE 
    stat.delivery_status IS NOT NULL
)

SELECT
  DATE_TRUNC('day', checkout_completed_at) AS day,
  COUNT(order_id)
FROM 
  sales_data 
GROUP BY 
  DATE_TRUNC('day', checkout_completed_at)
ORDER BY 
  day 
