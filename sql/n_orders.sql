-- Counts the number of orders from website point of sale
SELECT 
  COUNT(checkout_completed_at) AS number_of_orders
FROM 
  dev_claridryl.checkout_attempts;
