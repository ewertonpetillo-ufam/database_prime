-- Avaliadores por fase do questionário.
-- evaluator_id permanece o médico criador (passos 1 a 4).
-- Fala, sono e fisio passam a ter o próprio avaliador.

ALTER TABLE questionnaires
  ADD COLUMN IF NOT EXISTS speech_evaluator_id UUID REFERENCES users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS sleep_evaluator_id UUID REFERENCES users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS physio_evaluator_id UUID REFERENCES users(id) ON DELETE SET NULL;

COMMENT ON COLUMN questionnaires.evaluator_id IS 'Médico que criou o questionário (avaliador dos passos 1 a 4)';
COMMENT ON COLUMN questionnaires.speech_evaluator_id IS 'Avaliador da fala (passo 5)';
COMMENT ON COLUMN questionnaires.sleep_evaluator_id IS 'Avaliador do sono (passo 6)';
COMMENT ON COLUMN questionnaires.physio_evaluator_id IS 'Avaliador da fisioterapia (passo 7)';

CREATE INDEX IF NOT EXISTS idx_questionnaires_speech_evaluator ON questionnaires(speech_evaluator_id);
CREATE INDEX IF NOT EXISTS idx_questionnaires_sleep_evaluator ON questionnaires(sleep_evaluator_id);
CREATE INDEX IF NOT EXISTS idx_questionnaires_physio_evaluator ON questionnaires(physio_evaluator_id);

-- A view em produção ainda expõe pdss1_score. CREATE OR REPLACE não
-- renomeia coluna de view (erro 42P16). Recria com pdss2_score e os
-- avaliadores por fase.
DROP VIEW IF EXISTS v_questionnaire_summary;
CREATE VIEW v_questionnaire_summary AS
SELECT
    q.id AS questionnaire_id,
    q.patient_id,
    p.full_name AS patient_name,
    p.cpf_hash,
    q.collection_date,
    e.full_name AS evaluator_name,
    q.status,

    a.bmi,

    ca.age_at_onset,
    EXTRACT(YEAR FROM AGE(p.date_of_birth)) - ca.age_at_onset AS disease_duration_years,
    hy.stage AS hoehn_yahr_stage,
    ca.schwab_england_score,

    u3.total_score AS updrs3_score,
    m.total_score AS meem_score,
    ud.total_score AS udysrs_score,
    fg.total_score AS fogq_score,
    rb.total_score AS rbdsq_score,
    sb.total_score AS stopbang_score,
    ep.total_score AS epworth_score,
    pd.total_score AS pdss2_score,

    (SELECT SUM(led_value) FROM patient_medications pm WHERE pm.questionnaire_id = q.id) AS total_ledd,

    q.created_at,
    q.completed_at,
    e_speech.full_name AS speech_evaluator_name,
    e_sleep.full_name AS sleep_evaluator_name,
    e_physio.full_name AS physio_evaluator_name

FROM questionnaires q
JOIN patients p ON q.patient_id = p.id
LEFT JOIN users e ON q.evaluator_id = e.id
LEFT JOIN users e_speech ON q.speech_evaluator_id = e_speech.id
LEFT JOIN users e_sleep ON q.sleep_evaluator_id = e_sleep.id
LEFT JOIN users e_physio ON q.physio_evaluator_id = e_physio.id
LEFT JOIN anthropometric_data a ON q.id = a.questionnaire_id
LEFT JOIN clinical_assessments ca ON q.id = ca.questionnaire_id
LEFT JOIN hoehn_yahr_scale hy ON ca.hoehn_yahr_stage_id = hy.id
LEFT JOIN updrs_part3_scores u3 ON q.id = u3.questionnaire_id
LEFT JOIN meem_scores m ON q.id = m.questionnaire_id
LEFT JOIN udysrs_scores ud ON q.id = ud.questionnaire_id
LEFT JOIN fogq_scores fg ON q.id = fg.questionnaire_id
LEFT JOIN rbdsq_scores rb ON q.id = rb.questionnaire_id
LEFT JOIN stopbang_scores sb ON q.id = sb.questionnaire_id
LEFT JOIN epworth_scores ep ON q.id = ep.questionnaire_id
LEFT JOIN pdss2_scores pd ON q.id = pd.questionnaire_id;
