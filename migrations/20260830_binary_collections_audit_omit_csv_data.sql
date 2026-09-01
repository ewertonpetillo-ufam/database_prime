-- binary_collections.audit: NUNCA serializar BYTEA csv_data em JSON.
-- Ver também backend/prime_backend/db/migrations/20260830_binary_collections_audit_omit_csv_data.sql

CREATE OR REPLACE FUNCTION audit_binary_collection_row_to_jsonb(rec binary_collections)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
BEGIN
  rec.csv_data := NULL;
  RETURN (to_jsonb(rec) - 'csv_data')
      || jsonb_build_object('csv_data_omitted', true);
END;
$$;

COMMENT ON FUNCTION audit_binary_collection_row_to_jsonb(binary_collections) IS
  'Serializa binary_collections para audit_log sem o BYTEA csv_data (evita OOM).';

CREATE OR REPLACE FUNCTION audit_binary_collections_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO audit_log (table_name, record_id, operation, old_values, performed_at)
    VALUES (
      TG_TABLE_NAME,
      OLD.id,
      TG_OP,
      audit_binary_collection_row_to_jsonb(OLD),
      CURRENT_TIMESTAMP
    );
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit_log (table_name, record_id, operation, old_values, new_values, performed_at)
    VALUES (
      TG_TABLE_NAME,
      NEW.id,
      TG_OP,
      audit_binary_collection_row_to_jsonb(OLD),
      audit_binary_collection_row_to_jsonb(NEW),
      CURRENT_TIMESTAMP
    );
    RETURN NEW;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO audit_log (table_name, record_id, operation, new_values, performed_at)
    VALUES (
      TG_TABLE_NAME,
      NEW.id,
      TG_OP,
      audit_binary_collection_row_to_jsonb(NEW),
      CURRENT_TIMESTAMP
    );
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION audit_binary_collections_trigger() IS
  'Audit de binary_collections sem serializar csv_data. questionnaires continua em audit_trigger_function().';

DROP TRIGGER IF EXISTS audit_binary_collections ON binary_collections;
CREATE TRIGGER audit_binary_collections
  AFTER INSERT OR UPDATE OR DELETE ON binary_collections
  FOR EACH ROW EXECUTE FUNCTION audit_binary_collections_trigger();
