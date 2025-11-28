-- Migration: Optimize audit trigger to improve UPDATE performance
-- The current trigger uses row_to_json(OLD) and row_to_json(NEW) which is very slow
-- This optimized version only logs minimal information

-- Drop the existing trigger
DROP TRIGGER IF EXISTS audit_patients ON patients;

-- Create minimal audit function that only logs essential info (much faster)
CREATE OR REPLACE FUNCTION audit_trigger_function_minimal()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO audit_log (table_name, record_id, operation, old_values, performed_at)
    VALUES (TG_TABLE_NAME, OLD.id, TG_OP, 
            jsonb_build_object('id', OLD.id, 'full_name', OLD.full_name), 
            CURRENT_TIMESTAMP);
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE') THEN
    -- Only log ID and timestamp for updates (much faster than full row_to_json)
    INSERT INTO audit_log (table_name, record_id, operation, old_values, new_values, performed_at)
    VALUES (TG_TABLE_NAME, NEW.id, TG_OP, 
            jsonb_build_object('id', OLD.id, 'updated_at', OLD.updated_at),
            jsonb_build_object('id', NEW.id, 'updated_at', NEW.updated_at),
            CURRENT_TIMESTAMP);
    RETURN NEW;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO audit_log (table_name, record_id, operation, new_values, performed_at)
    VALUES (TG_TABLE_NAME, NEW.id, TG_OP, 
            jsonb_build_object('id', NEW.id, 'full_name', NEW.full_name), 
            CURRENT_TIMESTAMP);
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Recreate trigger with minimal version (much faster)
CREATE TRIGGER audit_patients AFTER INSERT OR UPDATE OR DELETE ON patients
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function_minimal();

-- Comment explaining the optimization
COMMENT ON FUNCTION audit_trigger_function_minimal() IS 
'Optimized audit trigger that only logs minimal information (ID and timestamp) for better UPDATE performance. Full row data logging (row_to_json) was causing significant slowdowns.';

-- Alternative: If you want to completely disable audit for patients table (fastest option)
-- DROP TRIGGER IF EXISTS audit_patients ON patients;

