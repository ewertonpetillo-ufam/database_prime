-- Auditoria de ações do app de coleta FreeLiving + tarefas FL01/FL02

CREATE TABLE IF NOT EXISTS freeliving_action_types (
  code VARCHAR(64) PRIMARY KEY,
  label_pt VARCHAR(120) NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  active BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO freeliving_action_types (code, label_pt, sort_order, active)
VALUES
  ('collection_started', 'Iniciou coleta', 1, TRUE),
  ('collection_finished', 'Finalizou coleta', 2, TRUE)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS freeliving_collection_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id),
  patient_cpf_hash VARCHAR(128) NOT NULL,
  action_code VARCHAR(64) NOT NULL REFERENCES freeliving_action_types(code),
  occurred_at TIMESTAMPTZ NOT NULL,
  received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  collection_date DATE NOT NULL,
  client_event_id UUID NULL,
  source VARCHAR(40) NOT NULL DEFAULT 'collection_app',
  device_type VARCHAR(100) NULL,
  device_model VARCHAR(100) NULL,
  os_version VARCHAR(80) NULL,
  app_version VARCHAR(80) NULL,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_freeliving_collection_events_client_event_id UNIQUE (client_event_id)
);

CREATE INDEX IF NOT EXISTS idx_freeliving_events_date_received
  ON freeliving_collection_events (collection_date DESC, received_at DESC);

CREATE INDEX IF NOT EXISTS idx_freeliving_events_patient_date
  ON freeliving_collection_events (patient_id, collection_date DESC);

CREATE INDEX IF NOT EXISTS idx_freeliving_events_action_date
  ON freeliving_collection_events (action_code, collection_date);

CREATE INDEX IF NOT EXISTS idx_freeliving_events_cpf_hash
  ON freeliving_collection_events (patient_cpf_hash);

INSERT INTO active_task_definitions (
  task_code,
  task_name,
  task_category,
  collection_form_type_id,
  description,
  instructions,
  active
)
SELECT
  'FL01',
  'Atividade FreeLiving 1',
  'OTHER',
  (SELECT id FROM collection_form_types WHERE code = 'UNDEFINED' LIMIT 1),
  'Tarefa de coleta FreeLiving (FL01). Rótulo oficial do protocolo a definir.',
  'Siga as instruções do aplicativo de coleta FreeLiving para a atividade FL01.',
  TRUE
WHERE NOT EXISTS (
  SELECT 1 FROM active_task_definitions WHERE task_code = 'FL01'
);

INSERT INTO active_task_definitions (
  task_code,
  task_name,
  task_category,
  collection_form_type_id,
  description,
  instructions,
  active
)
SELECT
  'FL02',
  'Atividade FreeLiving 2',
  'OTHER',
  (SELECT id FROM collection_form_types WHERE code = 'UNDEFINED' LIMIT 1),
  'Tarefa de coleta FreeLiving (FL02). Rótulo oficial do protocolo a definir.',
  'Siga as instruções do aplicativo de coleta FreeLiving para a atividade FL02.',
  TRUE
WHERE NOT EXISTS (
  SELECT 1 FROM active_task_definitions WHERE task_code = 'FL02'
);
