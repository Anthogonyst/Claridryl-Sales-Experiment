-- Calculates the number of orders per order ID
-- Order ID should be unique and 1-to-1 so filtering for not 1 should always return no results

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
  * 
FROM 
(
  SELECT 
    order_id,
    COUNT(order_id) AS num_orders
  FROM sales_data 
  GROUP BY order_id
) AS agg_orders
WHERE num_orders != 1;
