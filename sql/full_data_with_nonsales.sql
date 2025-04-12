-- Joins delivery status to add canceled orders

-- CREATE VIEW FULL_DATA AS
SELECT
  buy.*,
  stat.delivery_status
FROM 
  dev_claridryl.checkout_attempts AS buy
LEFT JOIN
  dev_claridryl.order_status AS stat ON buy.order_id = stat.order_id;
