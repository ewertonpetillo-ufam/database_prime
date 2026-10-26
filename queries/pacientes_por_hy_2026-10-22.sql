-- Quantidade de pacientes com Parkinson por estágio de Hoehn & Yahr
-- Corte: avaliação com collection_date até 22/10/2026
--
-- Coorte, igual à do relatório de 22/10/2026:
--   * um questionário por paciente: collection_date mais recente
--     (desempate por updated_at)
--   * status = in_progress
--   * só Parkinson (is_healthy_control IS NOT TRUE)
--   * exclui public_identifier P000, P00 e P048
--
-- H&Y igual ou inferior a 2 para antes do estágio 2,5.
-- H&Y inferior a 3 inclui o 2,5.
-- Porcentagem sobre os pacientes da coorte, uma casa decimal.
-- Cada bloco é independente.

-- =============================================================================
-- 1. Pacientes por estágio de H&Y
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-22'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
base AS (
    SELECT hy.stage::numeric AS hy
    FROM latest_q lq
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
),
tot AS (
    SELECT COUNT(*)::numeric AS n FROM base
)
SELECT
    CASE
        WHEN hy IS NULL THEN 'ausente'
        WHEN hy = trunc(hy) THEN trunc(hy)::int::text
        ELSE replace(to_char(hy, 'FM999990.0'), '.', ',')
    END AS "H&Y",
    COUNT(*)::int AS "N",
    ROUND((100 * COUNT(*))::numeric / (SELECT n FROM tot), 1) AS "% da coorte"
FROM base
GROUP BY hy
ORDER BY hy NULLS LAST;

-- =============================================================================
-- 2. Cortes usados na análise (até 2, 2,5 e abaixo de 3)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-22'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
base AS (
    SELECT
        hy.stage::numeric AS hy,
        u.total_score AS updrs
    FROM latest_q lq
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
),
tot AS (
    SELECT COUNT(*)::numeric AS n FROM base
)
SELECT
    corte AS "Corte",
    n AS "N",
    ROUND((100 * n)::numeric / (SELECT n FROM tot), 1) AS "% da coorte"
FROM (
    SELECT 1 AS ordem, 'H&Y igual ou inferior a 2' AS corte,
           COUNT(*) FILTER (WHERE hy <= 2)::int AS n
    FROM base
    UNION ALL
    SELECT 2, 'H&Y igual a 2,5',
           COUNT(*) FILTER (WHERE hy = 2.5)::int
    FROM base
    UNION ALL
    SELECT 3, 'H&Y inferior a 3',
           COUNT(*) FILTER (WHERE hy < 3)::int
    FROM base
    UNION ALL
    SELECT 4, 'H&Y igual a 3',
           COUNT(*) FILTER (WHERE hy = 3)::int
    FROM base
    UNION ALL
    SELECT 5, 'H&Y superior a 3',
           COUNT(*) FILTER (WHERE hy > 3)::int
    FROM base
    UNION ALL
    SELECT 6, 'H&Y igual ou inferior a 2 e UPDRS III até 32',
           COUNT(*) FILTER (WHERE hy <= 2 AND updrs <= 32)::int
    FROM base
    UNION ALL
    SELECT 7, 'H&Y inferior a 3 e UPDRS III até 32',
           COUNT(*) FILTER (WHERE hy < 3 AND updrs <= 32)::int
    FROM base
) cortes
ORDER BY ordem;
