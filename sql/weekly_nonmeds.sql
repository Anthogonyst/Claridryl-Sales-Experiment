-- Calculates the ratio of non-medication additions per week

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
  DATE_TRUNC('week', checkout_completed_at) AS weekly,
  COUNT(CASE WHEN customer_added_non_med_to_order THEN 1 END)::NUMERIC / COUNT(order_id) AS non_meds
FROM sales_data
GROUP BY weekly
ORDER BY weekly;
