-- Identificador público: P001 -> P0001 (4 dígitos), sequência e função generate_patient_identifier (alinhado ao backend/prime_backend/db/migrations).

UPDATE patients
SET public_identifier = 'P' || LPAD((SUBSTRING(public_identifier FROM 2))::integer::text, 4, '0')
WHERE public_identifier IS NOT NULL
  AND public_identifier ~ '^P[0-9]+$';

CREATE SEQUENCE IF NOT EXISTS patient_public_identifier_seq;

DO $$
DECLARE
  max_id integer;
BEGIN
  SELECT COALESCE(MAX((SUBSTRING(public_identifier FROM 2))::integer), 0)
  INTO max_id
  FROM patients
  WHERE public_identifier ~ '^P[0-9]+$';

  IF max_id = 0 THEN
    PERFORM setval('patient_public_identifier_seq', 1, false);
  ELSE
    PERFORM setval('patient_public_identifier_seq', max_id, true);
  END IF;
END $$;

CREATE OR REPLACE FUNCTION generate_patient_identifier()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  n integer;
BEGIN
  n := nextval('patient_public_identifier_seq');
  RETURN 'P' || lpad(n::text, 4, '0');
END;
$$;
