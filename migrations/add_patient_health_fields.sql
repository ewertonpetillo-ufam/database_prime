-- Migration: Add health-related fields to patients table
-- Adds fields for visual deficiency, hoarseness, and stuttering

-- Add deficiencia_visual column (visual deficiency)
ALTER TABLE patients 
ADD COLUMN IF NOT EXISTS deficiencia_visual BOOLEAN DEFAULT FALSE;

-- Add hoarseness column (rouquidão)
ALTER TABLE patients 
ADD COLUMN IF NOT EXISTS hoarseness BOOLEAN DEFAULT FALSE;

-- Add stuttering column (gagueja)
ALTER TABLE patients 
ADD COLUMN IF NOT EXISTS stuttering BOOLEAN DEFAULT FALSE;

-- Add comments for documentation
COMMENT ON COLUMN patients.deficiencia_visual IS 'Indica se o paciente possui deficiência visual';
COMMENT ON COLUMN patients.hoarseness IS 'Indica se o paciente possui rouquidão';
COMMENT ON COLUMN patients.stuttering IS 'Indica se o paciente possui gagueja';

