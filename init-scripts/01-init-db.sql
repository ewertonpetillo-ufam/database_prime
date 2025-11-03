-- ============================================================================
-- PRIME Parkinson's Disease Clinical Assessment System
-- Database Initialization Script
-- ============================================================================
-- This script creates the database if it doesn't exist
-- It's idempotent - safe to run multiple times
-- ============================================================================

-- Check if database exists and create if not
SELECT 'CREATE DATABASE prime_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'prime_db')\gexec

-- Connect to the newly created database
\c prime_db

-- Create required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Log initialization
DO $$
BEGIN
    RAISE NOTICE 'Database prime_db initialized successfully';
    RAISE NOTICE 'Extensions uuid-ossp and pgcrypto are ready';
END $$;
