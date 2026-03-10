-- Migration: Add password reset fields to users table
-- Date: 2025-01-XX
-- Description: Adds password_reset_token and password_reset_expires columns to support password recovery via email

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS password_reset_token VARCHAR(255) NULL,
ADD COLUMN IF NOT EXISTS password_reset_expires TIMESTAMP NULL;

COMMENT ON COLUMN users.password_reset_token IS 'Token used for password reset via email';
COMMENT ON COLUMN users.password_reset_expires IS 'Expiration timestamp for the password reset token';

