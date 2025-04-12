-- Calculates the number of orders per customer and filters for repeat customers

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
    customer_id,
    COUNT(customer_id) AS num_orders
  FROM sales_data 
  GROUP BY customer_id
) AS agg_customers
WHERE num_orders != 1;
