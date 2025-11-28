-- Migration: add smoked_before flag to patients table
-- Purpose: persist the "Já fumou antes?" response from Step 1

ALTER TABLE patients
ADD COLUMN IF NOT EXISTS smoked_before BOOLEAN;

UPDATE patients
SET smoked_before = CASE
  WHEN is_current_smoker = TRUE THEN TRUE
  WHEN years_since_quit_smoking IS NOT NULL THEN TRUE
  ELSE FALSE
END
WHERE smoked_before IS NULL;

ALTER TABLE patients
ALTER COLUMN smoked_before SET DEFAULT FALSE;

COMMENT ON COLUMN patients.smoked_before IS 'Indica se o paciente já fumou antes (mesmo que atualmente fume).';

