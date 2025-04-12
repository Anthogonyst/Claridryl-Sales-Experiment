-- Creates a ranked table for customer changes in their purchases, with two averages and percents to compare
-- Square form with unique customer IDs per row

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
-- Purchases that exclusively has medication items
med_purchase AS (
  SELECT 
    customer_id,
    AVG(order_total_dollars) AS average_med
  FROM 
    sales_data 
  WHERE
    NOT customer_added_non_med_to_order
  GROUP BY 
    customer_id
),
-- Purchases that contain non-medication items
nonmed_purchase AS (
  SELECT 
    customer_id,
    AVG(order_total_dollars) AS average_nonmed
  FROM 
    sales_data 
  WHERE
    customer_added_non_med_to_order
  GROUP BY 
    customer_id
),
-- Gets two averages per customer, for med purchases and non-med purchases
-- Additionally creates a sum and percentage for ease of downstream analysis
average_purchases AS (
  SELECT 
    COALESCE(med_purchase.customer_id, nonmed_purchase.customer_id) AS customer_id,
    average_med,
    average_nonmed,
    (average_med + average_nonmed) AS sum_of_both_averages,
    average_med / (average_med + average_nonmed) AS percent_med,
    average_nonmed / (average_med + average_nonmed) AS percent_nonmed
  FROM 
    med_purchase
  FULL JOIN 
    nonmed_purchase ON med_purchase.customer_id = nonmed_purchase.customer_id
  ORDER BY 
    customer_id
)

SELECT 
  *,
  ROW_NUMBER() OVER (ORDER BY percent_nonmed) AS purchase_rank
FROM 
  average_purchases 
WHERE 
  sum_of_both_averages IS NOT NULL; 
