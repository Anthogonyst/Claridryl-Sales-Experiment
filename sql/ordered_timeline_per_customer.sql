-- Assigns a rank to order customer orders by time

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
-- Calculates the number of orders per customer
num_orders AS (
  SELECT 
    customer_id AS cust_id,
    COUNT(customer_id) AS total_orders
  FROM sales_data 
  GROUP BY customer_id
)

SELECT 
  sales_data.*,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY checkout_completed_at) AS order_number,
  total_orders
FROM sales_data 
LEFT JOIN 
num_orders ON sales_data.customer_id = num_orders.cust_id
ORDER BY customer_id, checkout_completed_at;
