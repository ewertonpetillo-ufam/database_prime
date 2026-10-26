-- Uma linha por paciente: dados mais recentes para idade, mão dominante,
-- estágio de Hoehn & Yahr e tempo de doença.
--
-- Recorte (igual à análise de estágio de 09/10/2026, sem congelar a data):
--   * um questionário por paciente: collection_date mais recente
--     (desempate por updated_at)
--   * status = in_progress
--   * exclui public_identifier P000 e P00
--   * só Parkinson (is_healthy_control IS NOT TRUE)
--
-- Idade e tempo de doença usam a mesma conta do formulário e da análise
-- anterior (diferença de ano-calendário, não anos completos no aniversário):
--   idade            = ano atual - ano de nascimento
--   tempo de doença  = idade - clinical_assessments.age_at_onset
--                    = ano atual - ano de nascimento - idade de início
-- O ano atual vem de CURRENT_DATE, então a conta acompanha o calendário.
-- Tempo de doença fica nulo se faltar data de nascimento ou idade de início.
-- Mão dominante é do cadastro do paciente (Direita / Esquerda).
-- H&Y e idade de início vêm do questionário mais recente; se não foram
-- preenchidos nessa coleta, a coluna fica vazia.

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
    p.public_identifier AS identificador,
    lq.collection_date AS data_coleta,
    CASE
        WHEN p.date_of_birth IS NULL THEN NULL
        ELSE EXTRACT(YEAR FROM CURRENT_DATE)::int
             - EXTRACT(YEAR FROM p.date_of_birth)::int
    END AS idade,
    NULLIF(TRIM(p.dominant_hand), '') AS mao_dominante,
    hy.stage AS estagio_hy,
    ca.age_at_onset AS idade_inicio,
    CASE
        WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
        ELSE EXTRACT(YEAR FROM CURRENT_DATE)::int
             - EXTRACT(YEAR FROM p.date_of_birth)::int
             - ca.age_at_onset
    END AS tempo_doenca_anos
FROM latest_q lq
INNER JOIN patients p ON p.id = lq.patient_id
LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
ORDER BY
    CASE
        WHEN p.public_identifier ~ '^P[0-9]+$'
        THEN SUBSTRING(p.public_identifier FROM 2)::int
    END NULLS LAST,
    p.public_identifier;
