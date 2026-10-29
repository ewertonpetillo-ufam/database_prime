-- Relatório pedido pelo professor Souto: uma linha por paciente com Parkinson.
--
-- Recorte (igual às consultas anteriores, sem congelar a data):
--   * um questionário por paciente: collection_date mais recente
--     (desempate por updated_at)
--   * status = in_progress
--   * exclui public_identifier P000 e P00
--   * só Parkinson (is_healthy_control IS NOT TRUE)
--
-- patient_id é o public_identifier (P001, P002, …).
--
-- idade e duração_estimada: diferença de ano-calendário, como no formulário.
--   idade            = ano atual - ano de nascimento
--   duração_estimada = idade - idade de início dos sintomas
--   Nula se faltar data de nascimento ou idade de início.
--
-- H&Y e UPDRS III vêm dessa coleta. UPDRS III é o total calculado da parte 3.
-- Sem registro de UPDRS, a coluna fica vazia.
--
-- estado_ON_OFF: Medicado + ON/OFF, ou "Não medicado / Drug naive".
--   Sem avaliação clínica, fica vazio.
--
-- uso_medicação_Parkinson: Sim se a coleta tem ao menos um medicamento
--   da lista de antiparkinsonianos (patient_medications). Não, caso contrário.
--   "Outras medicações em uso" não entra nessa coluna.

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id,
        q.collection_date
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
)
SELECT
    p.public_identifier AS patient_id,
    CASE
        WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
        ELSE EXTRACT(YEAR FROM CURRENT_DATE)::int
             - EXTRACT(YEAR FROM p.date_of_birth)::int
             - ca.age_at_onset
    END AS "duração_estimada",
    hy.stage AS "H&Y",
    u.total_score AS "UPDRS_III_total",
    CASE
        WHEN ca.id IS NULL OR ca.medicated IS NULL THEN NULL
        WHEN ca.medicated IS FALSE THEN 'Não medicado / Drug naive'
        WHEN ca.assessed_on_levodopa IS TRUE THEN 'ON'
        ELSE 'OFF'
    END AS estado_ON_OFF,
    CASE
        WHEN p.date_of_birth IS NULL THEN NULL
        ELSE EXTRACT(YEAR FROM CURRENT_DATE)::int
             - EXTRACT(YEAR FROM p.date_of_birth)::int
    END AS idade,
    g.description AS sexo,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM patient_medications pm
            WHERE pm.questionnaire_id = lq.id
        ) THEN 'Sim'
        ELSE 'Não'
    END AS "uso_medicação_Parkinson"
FROM latest_q lq
INNER JOIN patients p ON p.id = lq.patient_id
LEFT JOIN gender_types g ON g.id = p.gender_id
LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
ORDER BY
    CASE
        WHEN p.public_identifier ~ '^P[0-9]+$'
        THEN SUBSTRING(p.public_identifier FROM 2)::int
    END NULLS LAST,
    p.public_identifier;
