-- Liga cada ação FreeLiving à atividade (FL01, FL02, ...)

ALTER TABLE freeliving_collection_events
  ADD COLUMN IF NOT EXISTS task_code VARCHAR(20) NULL;

CREATE INDEX IF NOT EXISTS idx_freeliving_events_task_date
  ON freeliving_collection_events (task_code, collection_date);
