-- Migration: Add allergy list fields to clinical_assessments
-- Stores JSON string arrays (same format as comorbidities / other_medications)

ALTER TABLE clinical_assessments
  ADD COLUMN IF NOT EXISTS medication_allergies TEXT,
  ADD COLUMN IF NOT EXISTS food_allergies TEXT;

COMMENT ON COLUMN clinical_assessments.medication_allergies IS 'Alergias medicamentosas (lista JSON em TEXT)';
COMMENT ON COLUMN clinical_assessments.food_allergies IS 'Alergias alimentares (lista JSON em TEXT)';
