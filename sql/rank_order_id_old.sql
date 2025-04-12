-- Orders the time that a customer made a specific order and ranks it sequentially

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
)

SELECT 
  customer_id,
  checkout_completed_at,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY checkout_completed_at) AS total_orders
FROM sales_data 
ORDER BY customer_id, checkout_completed_at;
