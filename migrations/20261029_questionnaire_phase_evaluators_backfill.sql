-- Preenche avaliadores de pacientes antigos a partir de audit_log.
-- Rodar depois de 20261029_questionnaire_phase_evaluators.sql.
--
-- O SELECT é o relatório de revisão.
-- Os UPDATE gravam só confiança alta:
--   médico  = evaluator_id do INSERT do questionário
--   sono    = primeira UPDATE em que last_step passa a 6
--   fisio   = primeira UPDATE em que last_step passa a 7
-- Fala não tem marco de passo e permanece nula.
-- Sem INSERT no log, o médico atual (último que salvou) não é copiado.

DROP TABLE IF EXISTS phase_evaluator_suggestions;

CREATE TEMP TABLE phase_evaluator_suggestions AS
WITH audit AS (
  SELECT
    record_id AS questionnaire_id,
    operation,
    performed_at,
    CASE
      WHEN new_values->>'evaluator_id' ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
        THEN (new_values->>'evaluator_id')::uuid
      ELSE NULL
    END AS new_evaluator_id,
    CASE
      WHEN old_values->>'last_step' ~ '^[0-9]+$' THEN (old_values->>'last_step')::int
      ELSE NULL
    END AS old_last_step,
    CASE
      WHEN new_values->>'last_step' ~ '^[0-9]+$' THEN (new_values->>'last_step')::int
      ELSE NULL
    END AS new_last_step
  FROM audit_log
  WHERE table_name = 'questionnaires'
    AND record_id IS NOT NULL
),
creators AS (
  SELECT DISTINCT ON (questionnaire_id)
    questionnaire_id,
    new_evaluator_id AS evaluator_id,
    performed_at
  FROM audit
  WHERE operation = 'INSERT'
    AND new_evaluator_id IS NOT NULL
  ORDER BY questionnaire_id, performed_at ASC
),
sleep_evals AS (
  SELECT DISTINCT ON (questionnaire_id)
    questionnaire_id,
    new_evaluator_id AS evaluator_id,
    performed_at
  FROM audit
  WHERE operation = 'UPDATE'
    AND new_evaluator_id IS NOT NULL
    AND COALESCE(old_last_step, 0) < 6
    AND new_last_step = 6
  ORDER BY questionnaire_id, performed_at ASC
),
physio_evals AS (
  SELECT DISTINCT ON (questionnaire_id)
    questionnaire_id,
    new_evaluator_id AS evaluator_id,
    performed_at
  FROM audit
  WHERE operation = 'UPDATE'
    AND new_evaluator_id IS NOT NULL
    AND COALESCE(old_last_step, 0) < 7
    AND new_last_step = 7
  ORDER BY questionnaire_id, performed_at ASC
)
SELECT
  q.id AS questionnaire_id,
  p.full_name AS patient_name,
  'medico'::text AS phase,
  c.evaluator_id AS suggested_user_id,
  u.full_name AS suggested_user_name,
  CASE WHEN c.evaluator_id IS NOT NULL THEN 'alta' ELSE 'indeterminado' END AS confidence,
  c.performed_at AS evidence_at
FROM questionnaires q
JOIN patients p ON p.id = q.patient_id
LEFT JOIN creators c ON c.questionnaire_id = q.id
LEFT JOIN users u ON u.id = c.evaluator_id

UNION ALL

SELECT
  q.id,
  p.full_name,
  'sono',
  s.evaluator_id,
  u.full_name,
  CASE WHEN s.evaluator_id IS NOT NULL THEN 'alta' ELSE 'indeterminado' END,
  s.performed_at
FROM questionnaires q
JOIN patients p ON p.id = q.patient_id
LEFT JOIN sleep_evals s ON s.questionnaire_id = q.id
LEFT JOIN users u ON u.id = s.evaluator_id
WHERE s.evaluator_id IS NOT NULL
   OR q.sleep_evaluator_id IS NOT NULL
   OR EXISTS (SELECT 1 FROM stopbang_scores sb WHERE sb.questionnaire_id = q.id)
   OR EXISTS (SELECT 1 FROM epworth_scores ep WHERE ep.questionnaire_id = q.id)
   OR EXISTS (SELECT 1 FROM pdss2_scores pd WHERE pd.questionnaire_id = q.id)
   OR EXISTS (SELECT 1 FROM rbdsq_scores rb WHERE rb.questionnaire_id = q.id)
   OR EXISTS (SELECT 1 FROM rbdsq_br_scores rbr WHERE rbr.questionnaire_id = q.id)

UNION ALL

SELECT
  q.id,
  p.full_name,
  'fisio',
  f.evaluator_id,
  u.full_name,
  CASE WHEN f.evaluator_id IS NOT NULL THEN 'alta' ELSE 'indeterminado' END,
  f.performed_at
FROM questionnaires q
JOIN patients p ON p.id = q.patient_id
LEFT JOIN physio_evals f ON f.questionnaire_id = q.id
LEFT JOIN users u ON u.id = f.evaluator_id
WHERE f.evaluator_id IS NOT NULL
   OR q.physio_evaluator_id IS NOT NULL
   OR EXISTS (SELECT 1 FROM fogq_scores fg WHERE fg.questionnaire_id = q.id)

UNION ALL

SELECT
  q.id,
  p.full_name,
  'fala',
  NULL::uuid,
  NULL::text,
  'manual',
  NULL::timestamp
FROM questionnaires q
JOIN patients p ON p.id = q.patient_id
JOIN clinical_assessments ca ON ca.questionnaire_id = q.id
WHERE NULLIF(btrim(ca.speech_patient_description), '') IS NOT NULL;

-- Relatório para revisão antes de confiar no resultado dos UPDATE.
SELECT
  questionnaire_id,
  patient_name,
  phase,
  suggested_user_id,
  suggested_user_name,
  confidence,
  evidence_at
FROM phase_evaluator_suggestions
ORDER BY patient_name, phase;

-- Médico criador: só quando o INSERT está no log e o usuário ainda existe.
UPDATE questionnaires q
SET evaluator_id = s.suggested_user_id
FROM phase_evaluator_suggestions s
WHERE s.phase = 'medico'
  AND s.confidence = 'alta'
  AND s.suggested_user_id IS NOT NULL
  AND q.id = s.questionnaire_id
  AND EXISTS (SELECT 1 FROM users u WHERE u.id = s.suggested_user_id);

-- Sono e fisio: não sobrescreve valor já preenchido.
UPDATE questionnaires q
SET sleep_evaluator_id = s.suggested_user_id
FROM phase_evaluator_suggestions s
WHERE s.phase = 'sono'
  AND s.confidence = 'alta'
  AND s.suggested_user_id IS NOT NULL
  AND q.id = s.questionnaire_id
  AND q.sleep_evaluator_id IS NULL
  AND EXISTS (SELECT 1 FROM users u WHERE u.id = s.suggested_user_id);

UPDATE questionnaires q
SET physio_evaluator_id = s.suggested_user_id
FROM phase_evaluator_suggestions s
WHERE s.phase = 'fisio'
  AND s.confidence = 'alta'
  AND s.suggested_user_id IS NOT NULL
  AND q.id = s.questionnaire_id
  AND q.physio_evaluator_id IS NULL
  AND EXISTS (SELECT 1 FROM users u WHERE u.id = s.suggested_user_id);

DROP TABLE IF EXISTS phase_evaluator_suggestions;
