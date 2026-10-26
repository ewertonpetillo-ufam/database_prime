-- Distribuição de estágio / severidade — coorte congelada em 09/10/2026
--
-- População (mesma regra da planilha Result_9, com corte de data):
--   * um questionário por paciente: o de collection_date mais recente
--     em ou antes de 09/10/2026 (desempate por updated_at)
--   * status = in_progress
--   * exclui public_identifier P000 e P00
--
-- Duração estimada desde o início dos sintomas:
--   2026 - ano de nascimento - clinical_assessments.age_at_onset
--   Nula se faltar data de nascimento ou age_at_onset.
--   O ano 2026 fica fixo para a conta não mudar numa reexecução posterior.
--
-- Parkinson = is_healthy_control IS NOT TRUE.
-- Controle  = is_healthy_control IS TRUE.
-- Controles entram só no resumo da amostra.
-- As demais tabelas usam somente pacientes com Parkinson.
--
-- Denominador das porcentagens: N de pacientes com Parkinson da coorte
-- (inclui quem tem dado ausente). Uma casa decimal.
-- Quem tem dado ausente na variável de uma regra não entra no N daquela regra.
-- Duração negativa, se existir, conta como < 5 anos e aparece na faixa "< 0".
--
-- Faixas de duração: anos 0 a 10 individuais; depois 11–14, 15–19, 20–29 e ≥30.
--
-- Cada bloco abaixo é independente e pode ser executado sozinho.

-- =============================================================================
-- 0. Resumo da amostra
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id,
        q.is_healthy_control
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.collection_date <= DATE '2026-10-09'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        lq.id AS questionnaire_id,
        (lq.is_healthy_control IS TRUE) AS controle,
        (lq.is_healthy_control IS NOT TRUE) AS parkinson,
        hy.stage AS hoehn_yahr,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE (
                2026
                - EXTRACT(YEAR FROM p.date_of_birth)::int
                - ca.age_at_onset
            )
        END AS duracao_estimada,
        u.total_score AS updrs_iii
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
)
SELECT indicador AS "Indicador", n AS "N"
FROM (
    SELECT 1 AS ordem, 'N pacientes com Parkinson' AS indicador,
           COUNT(*) FILTER (WHERE parkinson)::int AS n
    FROM coorte
    UNION ALL
    SELECT 2, 'N controles',
           COUNT(*) FILTER (WHERE controle)::int
    FROM coorte
    UNION ALL
    SELECT 3, 'N total',
           COUNT(*)::int
    FROM coorte
    UNION ALL
    SELECT 4, 'H&Y ausente (Parkinson)',
           COUNT(*) FILTER (WHERE parkinson AND hoehn_yahr IS NULL)::int
    FROM coorte
    UNION ALL
    SELECT 5, 'H&Y preenchido (Parkinson)',
           COUNT(*) FILTER (WHERE parkinson AND hoehn_yahr IS NOT NULL)::int
    FROM coorte
    UNION ALL
    SELECT 6, 'Duração estimada ausente (Parkinson)',
           COUNT(*) FILTER (WHERE parkinson AND duracao_estimada IS NULL)::int
    FROM coorte
    UNION ALL
    SELECT 7, 'Duração estimada preenchida (Parkinson)',
           COUNT(*) FILTER (WHERE parkinson AND duracao_estimada IS NOT NULL)::int
    FROM coorte
    UNION ALL
    SELECT 8, 'UPDRS III ausente (Parkinson)',
           COUNT(*) FILTER (WHERE parkinson AND updrs_iii IS NULL)::int
    FROM coorte
    UNION ALL
    SELECT 9, 'UPDRS III preenchido (Parkinson)',
           COUNT(*) FILTER (WHERE parkinson AND updrs_iii IS NOT NULL)::int
    FROM coorte
) resumo
ORDER BY ordem;

-- =============================================================================
-- 1. Distribuição por H&Y (níveis individuais, só Parkinson)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id,
        q.is_healthy_control
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.collection_date <= DATE '2026-10-09'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        lq.id AS questionnaire_id,
        (lq.is_healthy_control IS NOT TRUE) AS parkinson,
        hy.stage AS hoehn_yahr
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
),
parkinson AS (
    SELECT questionnaire_id, hoehn_yahr
    FROM coorte
    WHERE parkinson
),
estagios AS (
    SELECT *
    FROM (
        VALUES
            (1, 0::numeric, '0'),
            (2, 1, '1'),
            (3, 1.5, '1.5'),
            (4, 2, '2'),
            (5, 2.5, '2.5'),
            (6, 3, '3'),
            (7, 4, '4'),
            (8, 5, '5'),
            (9, NULL, 'Ausente')
    ) AS t(ordem, stage, rotulo)
),
tot AS (
    SELECT COUNT(*)::numeric AS n_parkinson
    FROM parkinson
)
SELECT
    e.rotulo AS "Estágio H&Y",
    COUNT(p.questionnaire_id)::int AS "N",
    ROUND(100.0 * COUNT(p.questionnaire_id) / NULLIF(tot.n_parkinson, 0), 1)
        AS "% dos pacientes com Parkinson"
FROM estagios e
CROSS JOIN tot
LEFT JOIN parkinson p
    ON (e.stage IS NULL AND p.hoehn_yahr IS NULL)
    OR p.hoehn_yahr = e.stage
GROUP BY e.ordem, e.rotulo, tot.n_parkinson
ORDER BY e.ordem;

-- =============================================================================
-- 2. Distribuição pela duração estimada desde o início dos sintomas
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id,
        q.is_healthy_control
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.collection_date <= DATE '2026-10-09'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        lq.id AS questionnaire_id,
        (lq.is_healthy_control IS NOT TRUE) AS parkinson,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE (
                2026
                - EXTRACT(YEAR FROM p.date_of_birth)::int
                - ca.age_at_onset
            )
        END AS duracao_estimada
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
),
parkinson AS (
    SELECT
        questionnaire_id,
        CASE
            WHEN duracao_estimada IS NULL THEN 'Ausente'
            WHEN duracao_estimada < 0 THEN '< 0'
            WHEN duracao_estimada BETWEEN 0 AND 10 THEN duracao_estimada::text
            WHEN duracao_estimada BETWEEN 11 AND 14 THEN '11–14'
            WHEN duracao_estimada BETWEEN 15 AND 19 THEN '15–19'
            WHEN duracao_estimada BETWEEN 20 AND 29 THEN '20–29'
            ELSE '≥30'
        END AS faixa_duracao
    FROM coorte
    WHERE parkinson
),
faixas AS (
    SELECT *
    FROM (
        VALUES
            (1, '< 0'),
            (2, '0'),
            (3, '1'),
            (4, '2'),
            (5, '3'),
            (6, '4'),
            (7, '5'),
            (8, '6'),
            (9, '7'),
            (10, '8'),
            (11, '9'),
            (12, '10'),
            (13, '11–14'),
            (14, '15–19'),
            (15, '20–29'),
            (16, '≥30'),
            (17, 'Ausente')
    ) AS t(ordem, faixa)
),
tot AS (
    SELECT COUNT(*)::numeric AS n_parkinson
    FROM parkinson
)
SELECT
    f.faixa AS "Duração estimada desde o início dos sintomas",
    COUNT(p.questionnaire_id)::int AS "N",
    ROUND(100.0 * COUNT(p.questionnaire_id) / NULLIF(tot.n_parkinson, 0), 1)
        AS "% dos pacientes com Parkinson"
FROM faixas f
CROSS JOIN tot
LEFT JOIN parkinson p ON p.faixa_duracao = f.faixa
GROUP BY f.ordem, f.faixa, tot.n_parkinson
ORDER BY f.ordem;

-- =============================================================================
-- 3. Tabela cruzada: duração estimada × H&Y (contagens, só Parkinson)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id,
        q.is_healthy_control
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.collection_date <= DATE '2026-10-09'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        lq.id AS questionnaire_id,
        (lq.is_healthy_control IS NOT TRUE) AS parkinson,
        hy.stage AS hoehn_yahr,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE (
                2026
                - EXTRACT(YEAR FROM p.date_of_birth)::int
                - ca.age_at_onset
            )
        END AS duracao_estimada
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
),
parkinson AS (
    SELECT
        questionnaire_id,
        hoehn_yahr,
        CASE
            WHEN duracao_estimada IS NULL THEN 'Ausente'
            WHEN duracao_estimada < 0 THEN '< 0'
            WHEN duracao_estimada BETWEEN 0 AND 10 THEN duracao_estimada::text
            WHEN duracao_estimada BETWEEN 11 AND 14 THEN '11–14'
            WHEN duracao_estimada BETWEEN 15 AND 19 THEN '15–19'
            WHEN duracao_estimada BETWEEN 20 AND 29 THEN '20–29'
            ELSE '≥30'
        END AS faixa_duracao
    FROM coorte
    WHERE parkinson
),
faixas AS (
    SELECT *
    FROM (
        VALUES
            (1, '< 0'),
            (2, '0'),
            (3, '1'),
            (4, '2'),
            (5, '3'),
            (6, '4'),
            (7, '5'),
            (8, '6'),
            (9, '7'),
            (10, '8'),
            (11, '9'),
            (12, '10'),
            (13, '11–14'),
            (14, '15–19'),
            (15, '20–29'),
            (16, '≥30'),
            (17, 'Ausente')
    ) AS t(ordem, faixa)
)
SELECT
    f.faixa AS "Duração estimada",
    COUNT(p.questionnaire_id) FILTER (WHERE p.hoehn_yahr = 0)::int AS "0",
    COUNT(p.questionnaire_id) FILTER (WHERE p.hoehn_yahr = 1)::int AS "1",
    COUNT(p.questionnaire_id) FILTER (WHERE p.hoehn_yahr = 1.5)::int AS "1.5",
    COUNT(p.questionnaire_id) FILTER (WHERE p.hoehn_yahr = 2)::int AS "2",
    COUNT(p.questionnaire_id) FILTER (WHERE p.hoehn_yahr = 2.5)::int AS "2.5",
    COUNT(p.questionnaire_id) FILTER (WHERE p.hoehn_yahr = 3)::int AS "3",
    COUNT(p.questionnaire_id) FILTER (WHERE p.hoehn_yahr = 4)::int AS "4",
    COUNT(p.questionnaire_id) FILTER (WHERE p.hoehn_yahr = 5)::int AS "5",
    COUNT(p.questionnaire_id) FILTER (WHERE p.hoehn_yahr IS NULL)::int AS "Ausente",
    COUNT(p.questionnaire_id)::int AS "Total"
FROM faixas f
LEFT JOIN parkinson p ON p.faixa_duracao = f.faixa
GROUP BY f.ordem, f.faixa
ORDER BY f.ordem;

-- =============================================================================
-- 4a. UPDRS III total por paciente: frequência de cada escore observado
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id,
        q.is_healthy_control
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.collection_date <= DATE '2026-10-09'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        lq.id AS questionnaire_id,
        (lq.is_healthy_control IS NOT TRUE) AS parkinson,
        u.total_score AS updrs_iii
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
),
parkinson AS (
    SELECT questionnaire_id, updrs_iii
    FROM coorte
    WHERE parkinson
),
tot AS (
    SELECT COUNT(*)::numeric AS n_parkinson
    FROM parkinson
)
SELECT
    CASE
        WHEN p.updrs_iii IS NULL THEN 'Ausente'
        ELSE p.updrs_iii::text
    END AS "UPDRS III",
    COUNT(*)::int AS "N",
    ROUND(100.0 * COUNT(*) / NULLIF(tot.n_parkinson, 0), 1)
        AS "% dos pacientes com Parkinson"
FROM parkinson p
CROSS JOIN tot
GROUP BY p.updrs_iii, tot.n_parkinson
ORDER BY p.updrs_iii NULLS LAST;

-- =============================================================================
-- 4b. UPDRS III: classificação leve / moderada / grave
--     leve ≤32; moderada 33–58; grave ≥59
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id,
        q.is_healthy_control
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.collection_date <= DATE '2026-10-09'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        lq.id AS questionnaire_id,
        (lq.is_healthy_control IS NOT TRUE) AS parkinson,
        u.total_score AS updrs_iii
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
),
parkinson AS (
    SELECT
        questionnaire_id,
        CASE
            WHEN updrs_iii IS NULL THEN 'Ausente'
            WHEN updrs_iii <= 32 THEN 'leve: ≤32'
            WHEN updrs_iii BETWEEN 33 AND 58 THEN 'moderada: 33–58'
            ELSE 'grave: ≥59'
        END AS classe
    FROM coorte
    WHERE parkinson
),
classes AS (
    SELECT *
    FROM (
        VALUES
            (1, 'leve: ≤32'),
            (2, 'moderada: 33–58'),
            (3, 'grave: ≥59'),
            (4, 'Ausente')
    ) AS t(ordem, classe)
),
tot AS (
    SELECT COUNT(*)::numeric AS n_parkinson
    FROM parkinson
)
SELECT
    c.classe AS "Classificação UPDRS III",
    COUNT(p.questionnaire_id)::int AS "N",
    ROUND(100.0 * COUNT(p.questionnaire_id) / NULLIF(tot.n_parkinson, 0), 1)
        AS "% dos pacientes com Parkinson"
FROM classes c
CROSS JOIN tot
LEFT JOIN parkinson p ON p.classe = c.classe
GROUP BY c.ordem, c.classe, tot.n_parkinson
ORDER BY c.ordem;

-- =============================================================================
-- 5. Regras de caracterização de estágio inicial (só Parkinson)
--     Cada linha é independente: o mesmo paciente pode contar em mais de uma.
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id,
        q.is_healthy_control
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.collection_date <= DATE '2026-10-09'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        lq.id AS questionnaire_id,
        (lq.is_healthy_control IS NOT TRUE) AS parkinson,
        hy.stage AS hoehn_yahr,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE (
                2026
                - EXTRACT(YEAR FROM p.date_of_birth)::int
                - ca.age_at_onset
            )
        END AS duracao_estimada,
        u.total_score AS updrs_iii
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
),
parkinson AS (
    SELECT questionnaire_id, hoehn_yahr, duracao_estimada, updrs_iii
    FROM coorte
    WHERE parkinson
),
regras AS (
    SELECT 1 AS ordem, 'H&Y < 3' AS criterio,
           COUNT(*) FILTER (WHERE hoehn_yahr < 3)::int AS n
    FROM parkinson
    UNION ALL
    SELECT 2, 'H&Y ≤ 3',
           COUNT(*) FILTER (WHERE hoehn_yahr <= 3)::int
    FROM parkinson
    UNION ALL
    SELECT 3, 'duração < 5 anos',
           COUNT(*) FILTER (WHERE duracao_estimada < 5)::int
    FROM parkinson
    UNION ALL
    SELECT 4, 'H&Y < 3 AND duração < 5 anos',
           COUNT(*) FILTER (WHERE hoehn_yahr < 3 AND duracao_estimada < 5)::int
    FROM parkinson
    UNION ALL
    SELECT 5, 'H&Y ≤ 3 AND duração < 5 anos',
           COUNT(*) FILTER (WHERE hoehn_yahr <= 3 AND duracao_estimada < 5)::int
    FROM parkinson
    UNION ALL
    SELECT 6, 'UPDRS III ≤ 32',
           COUNT(*) FILTER (WHERE updrs_iii <= 32)::int
    FROM parkinson
    UNION ALL
    SELECT 7, 'H&Y < 3 AND UPDRS III ≤ 32',
           COUNT(*) FILTER (WHERE hoehn_yahr < 3 AND updrs_iii <= 32)::int
    FROM parkinson
),
tot AS (
    SELECT COUNT(*)::numeric AS n_parkinson
    FROM parkinson
)
SELECT
    r.criterio AS "Critério",
    r.n AS "N",
    ROUND(100.0 * r.n / NULLIF(tot.n_parkinson, 0), 1)
        AS "% dos pacientes com Parkinson"
FROM regras r
CROSS JOIN tot
ORDER BY r.ordem;
