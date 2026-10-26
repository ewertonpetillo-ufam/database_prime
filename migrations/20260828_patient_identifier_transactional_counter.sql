-- Identificador público transacional: P157 -> P125 e contador que desfaz no rollback.
-- Alinhado a backend/prime_backend/db/migrations/20260828_patient_identifier_transactional_counter.sql
--
-- Aplicar uma vez no Postgres:
--   psql $DATABASE_URL -f database_prime/migrations/20260828_patient_identifier_transactional_counter.sql

BEGIN;

DO $$
DECLARE
  ref_count integer;
  p125_exists boolean;
  p157_exists boolean;
BEGIN
  SELECT COUNT(*) INTO ref_count
  FROM (
    SELECT 1
      FROM pdf_reports pr
      JOIN questionnaires q ON q.id = pr.questionnaire_id
      JOIN patients p ON p.id = q.patient_id
     WHERE p.public_identifier = 'P157'
       AND (
         COALESCE(pr.file_name, '') ILIKE '%P157%'
         OR COALESCE(pr.file_path, '') ILIKE '%P157%'
       )
    UNION ALL
    SELECT 1
      FROM binary_collections bc
      JOIN patients p ON p.cpf_hash = bc.patient_cpf_hash
     WHERE p.public_identifier = 'P157'
       AND COALESCE(bc.metadata::text, '') ILIKE '%P157%'
  ) refs;

  IF ref_count > 0 THEN
    RAISE EXCEPTION
      'Abortando: há % referências a P157 em pdf_reports/binary_collections. Confira antes de renomear.',
      ref_count;
  END IF;

  SELECT EXISTS(SELECT 1 FROM patients WHERE public_identifier = 'P125') INTO p125_exists;
  SELECT EXISTS(SELECT 1 FROM patients WHERE public_identifier = 'P157') INTO p157_exists;

  IF p157_exists AND p125_exists THEN
    RAISE EXCEPTION 'Abortando: P125 já existe; não é seguro renomear P157.';
  END IF;

  IF p157_exists AND NOT p125_exists THEN
    UPDATE patients
       SET public_identifier = 'P125'
     WHERE public_identifier = 'P157';
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS patient_identifier_counter (
  id smallint PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  last_value integer NOT NULL
);

INSERT INTO patient_identifier_counter (id, last_value)
SELECT 1,
       COALESCE(MAX((SUBSTRING(public_identifier FROM 2))::integer), 0)
  FROM patients
 WHERE public_identifier ~ '^P[0-9]+$'
ON CONFLICT (id) DO UPDATE
SET last_value = GREATEST(patient_identifier_counter.last_value, EXCLUDED.last_value);

CREATE OR REPLACE FUNCTION generate_patient_identifier()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  n integer;
BEGIN
  UPDATE patient_identifier_counter
     SET last_value = last_value + 1
   WHERE id = 1
   RETURNING last_value INTO n;

  IF n IS NULL THEN
    RAISE EXCEPTION 'patient_identifier_counter está vazio; rode a migração 20260828.';
  END IF;

  RETURN 'P' || lpad(n::text, 3, '0');
END;
$$;

COMMENT ON TABLE patient_identifier_counter IS
  'Último sufixo numérico atribuído a public_identifier. UPDATE na mesma transação do INSERT; rollback não queima Pxxx.';

COMMIT;
