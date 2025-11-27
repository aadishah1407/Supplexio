-- Migration: add ACCEPTED and DECLINED to purchase_orders.status enum
-- BACKUP your database before running this.

-- Example: run with mysql client (change user/password/database accordingly):
-- mysql -u root -proot axalta < migrate_add_accept_decline.sql

ALTER TABLE purchase_orders 
MODIFY COLUMN status ENUM('PENDING','SENT','DELIVERED','ACCEPTED','DECLINED') 
NOT NULL DEFAULT 'PENDING';
