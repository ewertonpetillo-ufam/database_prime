-- Migration: Add last_login column to users table
-- Date: 2025-01-15
-- Description: Adds last_login timestamp column to track when users last accessed the system

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS last_login TIMESTAMP NULL;

COMMENT ON COLUMN users.last_login IS 'Timestamp of the user''s last login';

