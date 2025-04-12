-- Gets the minimum and maximum date to quantify how large our data spans
( 
SELECT 
  MAX(checkout_completed_at) AS Date
FROM 
  dev_claridryl.checkout_attempts
)
UNION ALL 
(
SELECT 
  MIN(checkout_completed_at) AS Date
FROM 
  dev_claridryl.checkout_attempts
);
