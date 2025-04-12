-- Creates a fixed width timeline where customer history can be seen

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
experiment_population AS (
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
),
-- Calculates the number of orders per customer
num_orders AS (
  SELECT 
    customer_id AS cust_id,
    COUNT(customer_id) AS total_orders
  FROM sales_data 
  GROUP BY customer_id
),
-- Assigns a rank to order customer orders by time
ranked_orders AS (
  SELECT 
    sales_data.*,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY checkout_completed_at) AS order_number,
    total_orders
  FROM sales_data 
  LEFT JOIN 
  num_orders ON sales_data.customer_id = num_orders.cust_id
  ORDER BY customer_id, checkout_completed_at
),
-- Assigns a rank to order customer orders by time
experiment_ranked_orders AS (
  SELECT 
    sales_data.*,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY checkout_completed_at) AS order_number,
    total_orders
  FROM sales_data 
  LEFT JOIN 
  num_orders ON sales_data.customer_id = num_orders.cust_id
  INNER JOIN 
  (
    SELECT DISTINCT
      customer_id AS cust_id 
    FROM 
      experiment_population
  ) AS experiment_cust ON sales_data.customer_id = experiment_cust.cust_id
  ORDER BY customer_id, checkout_completed_at
)


SELECT 
  *
FROM 
(
  SELECT 
    *, 
    CASE 
      WHEN total_orders = 1 THEN 0
      ELSE order_number::NUMERIC / total_orders
    END AS timeline
  FROM 
    experiment_ranked_orders
) AS order_timeline
WHERE timeline != 0;
