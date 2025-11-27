-- Migration: add missing auction_id columns safely
-- Run this on your MySQL server for the Axalta database (make a backup first).
-- Replace `axalta` with your database name if different.

SET @db := DATABASE();

-- Add auction_id to auction_deliveries if missing
SELECT
  COUNT(*) INTO @has_col
FROM
  INFORMATION_SCHEMA.COLUMNS
WHERE
  TABLE_SCHEMA = @db
  AND TABLE_NAME = 'auction_deliveries'
  AND COLUMN_NAME = 'auction_id';

SET @sql = IF(@has_col = 0,
  'ALTER TABLE auction_deliveries ADD COLUMN auction_id BIGINT;',
  'SELECT "auction_deliveries.auction_id already exists";'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Add auction_id to purchase_orders if missing
SELECT
  COUNT(*) INTO @has_col
FROM
  INFORMATION_SCHEMA.COLUMNS
WHERE
  TABLE_SCHEMA = @db
  AND TABLE_NAME = 'purchase_orders'
  AND COLUMN_NAME = 'auction_id';

SET @sql = IF(@has_col = 0,
  'ALTER TABLE purchase_orders ADD COLUMN auction_id BIGINT;',
  'SELECT "purchase_orders.auction_id already exists";'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Add auction_id to payments if missing
SELECT
  COUNT(*) INTO @has_col
FROM
  INFORMATION_SCHEMA.COLUMNS
WHERE
  TABLE_SCHEMA = @db
  AND TABLE_NAME = 'payments'
  AND COLUMN_NAME = 'auction_id';

SET @sql = IF(@has_col = 0,
  'ALTER TABLE payments ADD COLUMN auction_id BIGINT;',
  'SELECT "payments.auction_id already exists";'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Optional: add missing enum values for purchase_orders.status if you want to allow ACCEPTED/DECLINED
-- WARNING: Modifying ENUMs is risky on production. Only run if you understand the impact.
-- Example to add ACCEPTED and DECLINED (uncomment to run):
-- ALTER TABLE purchase_orders MODIFY COLUMN status ENUM('PENDING','SENT','DELIVERED','ACCEPTED','DECLINED');

-- Done.
SELECT 'Migration complete';
