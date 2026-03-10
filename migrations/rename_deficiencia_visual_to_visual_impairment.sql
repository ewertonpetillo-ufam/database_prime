-- Migration: Rename deficiencia_visual column to visual_impairment
-- Context: standardize database column names to English

-- Rename column on patients table (if it exists)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'patients'
      AND column_name = 'deficiencia_visual'
  ) THEN
    ALTER TABLE patients
      RENAME COLUMN deficiencia_visual TO visual_impairment;
  END IF;
END$$;

-- Update column comment (optional documentation)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'patients'
      AND column_name = 'visual_impairment'
  ) THEN
    COMMENT ON COLUMN patients.visual_impairment IS 'Indicates whether the patient has visual impairment';
  END IF;
END$$;

