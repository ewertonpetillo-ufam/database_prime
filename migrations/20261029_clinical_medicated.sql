-- Medicado na avaliação vs não medicado (drug-naive).
-- assessed_on_levodopa: true = ON, false = OFF, null = não se aplica.

ALTER TABLE clinical_assessments
  ADD COLUMN IF NOT EXISTS medicated BOOLEAN;

ALTER TABLE clinical_assessments
  ALTER COLUMN assessed_on_levodopa DROP NOT NULL;

ALTER TABLE clinical_assessments
  ALTER COLUMN assessed_on_levodopa DROP DEFAULT;

-- Quem já tem avaliação clínica já respondeu ON/OFF. Mantém esse estado visível.
UPDATE clinical_assessments
SET medicated = TRUE
WHERE medicated IS NULL;

COMMENT ON COLUMN clinical_assessments.medicated IS
  'true = medicado na avaliação; false = não medicado / drug-naive; null = não informado';
COMMENT ON COLUMN clinical_assessments.assessed_on_levodopa IS
  'true = ON, false = OFF, null = não se aplica (não medicado ou não informado)';
