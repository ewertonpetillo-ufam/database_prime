-- Migration: Add cpf column to patients table
-- This allows storing CPF in plain text for retrieval while maintaining cpf_hash for anonymization

-- Add cpf column (nullable to support existing records)
ALTER TABLE patients 
ADD COLUMN IF NOT EXISTS cpf VARCHAR(11);

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_patients_cpf ON patients(cpf);

-- Add comment
COMMENT ON COLUMN patients.cpf IS 'CPF stored in plain text for retrieval (11 digits). cpf_hash is still used for anonymization and search.';

