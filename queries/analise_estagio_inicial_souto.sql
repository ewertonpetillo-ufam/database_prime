-- Confirmação da análise de estágio inicial — relatório do professor Souto (14/10/2026)
--
-- O relatório sustenta três pontos para a equipe clínica validar:
--   1. Duração, H&Y e MDS-UPDRS III não classificam as mesmas pessoas.
--   2. Na regra "H&Y ≤ 3 E duração < 5", o limite de 5 anos é o que restringe:
--      quem tem duração < 5 já está com H&Y ≤ 3.
--   3. Um corte rígido de duração < 5 deixa de fora pacientes clinicamente
--      precoces (H&Y baixo, UPDRS III leve, sem antiparkinsoniano), como
--      P091 e P118. Os critérios híbridos são exploratórios e precisam de
--      revisão caso a caso.
--
-- Coorte do relatório:
--   * um questionário por paciente, collection_date mais recente em ou antes
--     de 14/10/2026 (desempate por updated_at)
--   * status = in_progress
--   * só Parkinson (is_healthy_control IS NOT TRUE)
--   * exclui public_identifier P000, P00 e P048
-- P048 sai da coorte: duração estimada de 39 anos com H&Y 0 e UPDRS III 14,
-- sem antiparkinsoniano. O registro é atípico e distorcia o híbrido 2.
-- Para a coorte de hoje, apague a linha "q.collection_date <= DATE '2026-10-14'"
-- em cada bloco.
--
-- Contas, iguais às consultas anteriores:
--   idade            = 2026 - ano de nascimento
--   duração_estimada = idade - idade de início dos sintomas
--   Nula se faltar nascimento ou idade de início.
--   Duração negativa, se existir, entra em "< 5".
--
-- MDS-UPDRS III (Martínez-Martín et al., 2015):
--   leve ≤ 32; moderada 33–58; grave ≥ 59.
--
-- Porcentagens usam o N da coorte (Parkinson, sem P000, P00 e P048) como denominador.
-- Quem não tem o dado não entra no N da regra.
-- Cada bloco é independente.
--
-- Referência dos N do PDF, para conferência (a base foi editada depois
-- de 14/10; H&Y, duração e UPDRS que estavam vazios podem ter sido
-- preenchidos):
--   H&Y < 3                              93
--   H&Y ≤ 3                             115
--   duração < 5                          28
--   H&Y < 3 E duração < 5                25
--   H&Y ≤ 3 E duração < 5                28
--   UPDRS III ≤ 32                       53
--   H&Y < 3 E UPDRS III ≤ 32             47
--   híbrido 1                            54
--   híbrido 2                            57

-- =============================================================================
-- 0. Retrato da coorte (seção 3 do relatório)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-14'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        CASE
            WHEN p.date_of_birth IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int
        END AS idade,
        g.code AS sexo,
        hy.stage AS hoehn_yahr,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao_estimada,
        u.total_score AS updrs_iii
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN gender_types g ON g.id = p.gender_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
)
SELECT indicador AS "Indicador", resultado AS "Resultado"
FROM (
    SELECT 1 AS ordem, 'Pacientes com Parkinson' AS indicador,
           COUNT(*)::text AS resultado
    FROM coorte
    UNION ALL
    SELECT 2, 'Idade média (anos)',
           ROUND(AVG(idade)::numeric, 1)::text
    FROM coorte
    UNION ALL
    SELECT 3, 'Homens',
           COUNT(*) FILTER (WHERE sexo = 'M')::text
    FROM coorte
    UNION ALL
    SELECT 4, 'Mulheres',
           COUNT(*) FILTER (WHERE sexo = 'F')::text
    FROM coorte
    UNION ALL
    SELECT 5, 'Duração mediana válida (anos)',
           percentile_cont(0.5) WITHIN GROUP (ORDER BY duracao_estimada)::text
    FROM coorte
    WHERE duracao_estimada IS NOT NULL
    UNION ALL
    SELECT 6, 'H&Y mediano',
           percentile_cont(0.5) WITHIN GROUP (ORDER BY hoehn_yahr)::text
    FROM coorte
    WHERE hoehn_yahr IS NOT NULL
    UNION ALL
    SELECT 7, 'UPDRS III médio',
           ROUND(AVG(updrs_iii)::numeric, 1)::text
    FROM coorte
    UNION ALL
    SELECT 8, 'UPDRS III mediano',
           percentile_cont(0.5) WITHIN GROUP (ORDER BY updrs_iii)::text
    FROM coorte
    WHERE updrs_iii IS NOT NULL
    UNION ALL
    SELECT 9, 'Duração ausente',
           COUNT(*) FILTER (WHERE duracao_estimada IS NULL)::text
    FROM coorte
    UNION ALL
    SELECT 10, 'H&Y ausente',
           COUNT(*) FILTER (WHERE hoehn_yahr IS NULL)::text
    FROM coorte
    UNION ALL
    SELECT 11, 'UPDRS III ausente',
           COUNT(*) FILTER (WHERE updrs_iii IS NULL)::text
    FROM coorte
) resumo
ORDER BY ordem;

-- =============================================================================
-- 1. Tamanho de cada definição de estágio inicial (seções 4 e 7)
--    N_relatorio é o valor impresso no PDF de 14/10, para conferência.
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-14'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        hy.stage AS hoehn_yahr,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao_estimada,
        u.total_score AS updrs_iii
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
),
regras AS (
    SELECT 1 AS ordem, 'Temporal' AS estrategia, 'duração < 5' AS criterio,
           COUNT(*) FILTER (WHERE duracao_estimada < 5)::int AS n,
           28 AS n_relatorio
    FROM coorte
    UNION ALL
    SELECT 2, 'Estágio clínico', 'H&Y < 3',
           COUNT(*) FILTER (WHERE hoehn_yahr < 3)::int, 93
    FROM coorte
    UNION ALL
    SELECT 3, 'Estágio clínico', 'H&Y ≤ 3',
           COUNT(*) FILTER (WHERE hoehn_yahr <= 3)::int, 115
    FROM coorte
    UNION ALL
    SELECT 4, 'Gravidade motora', 'UPDRS III ≤ 32',
           COUNT(*) FILTER (WHERE updrs_iii <= 32)::int, 53
    FROM coorte
    UNION ALL
    SELECT 5, 'Concordância clínica', 'H&Y < 3 E UPDRS III ≤ 32',
           COUNT(*) FILTER (WHERE hoehn_yahr < 3 AND updrs_iii <= 32)::int, 47
    FROM coorte
    UNION ALL
    SELECT 6, 'Temporal + H&Y', 'H&Y < 3 E duração < 5',
           COUNT(*) FILTER (WHERE hoehn_yahr < 3 AND duracao_estimada < 5)::int, 25
    FROM coorte
    UNION ALL
    SELECT 7, 'Temporal + H&Y', 'H&Y ≤ 3 E duração < 5',
           COUNT(*) FILTER (WHERE hoehn_yahr <= 3 AND duracao_estimada < 5)::int, 28
    FROM coorte
    UNION ALL
    SELECT 8, 'Híbrido 1', 'H&Y < 3 E (duração < 5 OU UPDRS III ≤ 32)',
           COUNT(*) FILTER (
               WHERE hoehn_yahr < 3
                 AND (duracao_estimada < 5 OR updrs_iii <= 32)
           )::int, 54
    FROM coorte
    UNION ALL
    SELECT 9, 'Híbrido 2', 'duração < 5 OU (H&Y < 3 E UPDRS III ≤ 32)',
           COUNT(*) FILTER (
               WHERE duracao_estimada < 5
                  OR (hoehn_yahr < 3 AND updrs_iii <= 32)
           )::int, 57
    FROM coorte
),
tot AS (
    SELECT COUNT(*)::numeric AS n_parkinson FROM coorte
)
SELECT
    r.estrategia AS "Estratégia",
    r.criterio AS "Regra",
    r.n AS "N",
    ROUND(100.0 * r.n / NULLIF(tot.n_parkinson, 0), 1) AS "% da coorte",
    r.n_relatorio AS "N no relatório",
    r.n - r.n_relatorio AS "Diferença"
FROM regras r
CROSS JOIN tot
ORDER BY r.ordem;

-- =============================================================================
-- 2. O limite de 5 anos é o fator restritivo?
--    Se esta consulta voltar vazia, todo paciente com duração < 5 tem H&Y ≤ 3,
--    e a regra "H&Y ≤ 3 E duração < 5" coincide com "duração < 5".
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-14'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
)
SELECT
    p.public_identifier AS patient_id,
    2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset AS "duração_estimada",
    hy.stage AS "H&Y",
    u.total_score AS "UPDRS_III_total"
FROM latest_q lq
INNER JOIN patients p ON p.id = lq.patient_id
LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
WHERE (2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset) < 5
  AND (hy.stage > 3 OR hy.stage IS NULL)
ORDER BY p.public_identifier;

-- =============================================================================
-- 3. H&Y × gravidade motora (seção 5)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-14'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        CASE
            WHEN hy.stage IS NULL THEN 'Ausente'
            WHEN hy.stage < 3 THEN '<3'
            WHEN hy.stage = 3 THEN '=3'
            ELSE '>3'
        END AS faixa_hy,
        CASE
            WHEN hy.stage IS NULL THEN 4
            WHEN hy.stage < 3 THEN 1
            WHEN hy.stage = 3 THEN 2
            ELSE 3
        END AS ordem_hy,
        CASE
            WHEN u.total_score IS NULL THEN 'Ausente'
            WHEN u.total_score <= 32 THEN 'Leve'
            WHEN u.total_score <= 58 THEN 'Moderada'
            ELSE 'Grave'
        END AS classe_updrs
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
)
SELECT
    faixa_hy AS "H&Y",
    COUNT(*) FILTER (WHERE classe_updrs = 'Leve')::int AS "UPDRS leve",
    COUNT(*) FILTER (WHERE classe_updrs = 'Moderada')::int AS "Moderada",
    COUNT(*) FILTER (WHERE classe_updrs = 'Grave')::int AS "Grave",
    COUNT(*) FILTER (WHERE classe_updrs = 'Ausente')::int AS "UPDRS ausente",
    COUNT(*)::int AS "Total"
FROM coorte
GROUP BY ordem_hy, faixa_hy
ORDER BY ordem_hy;

-- =============================================================================
-- 4. Duração × gravidade motora (seção 6)
--    Faixas do relatório: <5, 5–10 (inclusive) e >10.
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-14'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao_estimada,
        u.total_score AS updrs_iii
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
),
faixas AS (
    SELECT
        CASE
            WHEN duracao_estimada IS NULL THEN 'Ausente'
            WHEN duracao_estimada < 5 THEN '<5 anos'
            WHEN duracao_estimada <= 10 THEN '5–10 anos'
            ELSE '>10 anos'
        END AS faixa_duracao,
        CASE
            WHEN duracao_estimada IS NULL THEN 4
            WHEN duracao_estimada < 5 THEN 1
            WHEN duracao_estimada <= 10 THEN 2
            ELSE 3
        END AS ordem,
        CASE
            WHEN updrs_iii IS NULL THEN 'Ausente'
            WHEN updrs_iii <= 32 THEN 'Leve'
            WHEN updrs_iii <= 58 THEN 'Moderada'
            ELSE 'Grave'
        END AS classe_updrs
    FROM coorte
)
SELECT
    faixa_duracao AS "Duração",
    COUNT(*) FILTER (WHERE classe_updrs = 'Leve')::int AS "UPDRS leve",
    COUNT(*) FILTER (WHERE classe_updrs = 'Moderada')::int AS "Moderada",
    COUNT(*) FILTER (WHERE classe_updrs = 'Grave')::int AS "Grave",
    COUNT(*) FILTER (WHERE classe_updrs = 'Ausente')::int AS "UPDRS ausente",
    COUNT(*)::int AS "Total"
FROM faixas
GROUP BY ordem, faixa_duracao
ORDER BY ordem;

-- =============================================================================
-- 5. Spearman entre as três dimensões (seção 5)
--    Só entram pares com as duas variáveis preenchidas.
--    Posto médio em caso de empate.
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-14'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        hy.stage AS hoehn_yahr,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao_estimada,
        u.total_score AS updrs_iii
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
),
hy_up AS (
    SELECT
        RANK() OVER (ORDER BY hoehn_yahr) AS rx,
        COUNT(*) OVER (PARTITION BY hoehn_yahr) AS cx,
        RANK() OVER (ORDER BY updrs_iii) AS ry,
        COUNT(*) OVER (PARTITION BY updrs_iii) AS cy
    FROM coorte
    WHERE hoehn_yahr IS NOT NULL AND updrs_iii IS NOT NULL
),
dur_hy AS (
    SELECT
        RANK() OVER (ORDER BY duracao_estimada) AS rx,
        COUNT(*) OVER (PARTITION BY duracao_estimada) AS cx,
        RANK() OVER (ORDER BY hoehn_yahr) AS ry,
        COUNT(*) OVER (PARTITION BY hoehn_yahr) AS cy
    FROM coorte
    WHERE duracao_estimada IS NOT NULL AND hoehn_yahr IS NOT NULL
),
dur_up AS (
    SELECT
        RANK() OVER (ORDER BY duracao_estimada) AS rx,
        COUNT(*) OVER (PARTITION BY duracao_estimada) AS cx,
        RANK() OVER (ORDER BY updrs_iii) AS ry,
        COUNT(*) OVER (PARTITION BY updrs_iii) AS cy
    FROM coorte
    WHERE duracao_estimada IS NOT NULL AND updrs_iii IS NOT NULL
)
SELECT relacao AS "Relação", spearman AS "Spearman ρ", n_pares AS "N pares",
       leitura_relatorio AS "Leitura no relatório"
FROM (
    SELECT 1 AS ordem, 'H&Y × UPDRS III' AS relacao,
           ROUND(corr(rx + (cx - 1) / 2.0, ry + (cy - 1) / 2.0)::numeric, 2) AS spearman,
           COUNT(*)::int AS n_pares,
           '≈ 0,50 associação moderada' AS leitura_relatorio
    FROM hy_up
    UNION ALL
    SELECT 2, 'Duração × H&Y',
           ROUND(corr(rx + (cx - 1) / 2.0, ry + (cy - 1) / 2.0)::numeric, 2),
           COUNT(*)::int,
           '≈ 0,28 associação fraca'
    FROM dur_hy
    UNION ALL
    SELECT 3, 'Duração × UPDRS III',
           ROUND(corr(rx + (cx - 1) / 2.0, ry + (cy - 1) / 2.0)::numeric, 2),
           COUNT(*)::int,
           '≈ 0,17 associação fraca'
    FROM dur_up
) s
ORDER BY ordem;

-- =============================================================================
-- 6. Quem o híbrido 2 acrescenta além de "duração < 5"
--    São os pacientes com H&Y < 3 e UPDRS III ≤ 32, mas duração ≥ 5
--    (ou duração ausente). Esta é a lista para a equipe clínica dizer
--    se continuam precoces. P091 e P118 estão aqui.
--    revisar_dado marca duração ≤ 0, duração ≥ 30 ou H&Y 0.
--    P048 não entra: foi excluído da coorte.
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-14'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        p.public_identifier,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao_estimada,
        hy.stage AS hoehn_yahr,
        u.total_score AS updrs_iii,
        EXISTS (
            SELECT 1 FROM patient_medications pm WHERE pm.questionnaire_id = lq.id
        ) AS usa_medicacao
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
)
SELECT
    public_identifier AS patient_id,
    duracao_estimada AS "duração_estimada",
    hoehn_yahr AS "H&Y",
    updrs_iii AS "UPDRS_III_total",
    CASE WHEN usa_medicacao THEN 'Sim' ELSE 'Não' END AS "uso_medicação_Parkinson",
    CASE
        WHEN duracao_estimada IS NULL
          OR duracao_estimada <= 0
          OR duracao_estimada >= 30
          OR hoehn_yahr = 0
        THEN 'Sim'
        ELSE 'Não'
    END AS revisar_dado
FROM coorte
WHERE (duracao_estimada IS NULL OR duracao_estimada >= 5)
  AND hoehn_yahr < 3
  AND updrs_iii <= 32
ORDER BY
    usa_medicacao,
    duracao_estimada,
    public_identifier;

-- =============================================================================
-- 7. O outro lado do argumento: duração < 5, mas gravidade já moderada/grave
--    ou H&Y ≥ 3. Mostra que tempo curto também não garante estágio leve.
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-14'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
)
SELECT
    p.public_identifier AS patient_id,
    2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset AS "duração_estimada",
    hy.stage AS "H&Y",
    u.total_score AS "UPDRS_III_total",
    CASE
        WHEN u.total_score IS NULL THEN NULL
        WHEN u.total_score <= 32 THEN 'Leve'
        WHEN u.total_score <= 58 THEN 'Moderada'
        ELSE 'Grave'
    END AS classe_updrs,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM patient_medications pm WHERE pm.questionnaire_id = lq.id
        ) THEN 'Sim'
        ELSE 'Não'
    END AS "uso_medicação_Parkinson"
FROM latest_q lq
INNER JOIN patients p ON p.id = lq.patient_id
LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
WHERE (2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset) < 5
  AND (
      hy.stage >= 3
      OR u.total_score > 32
  )
ORDER BY u.total_score DESC NULLS LAST, p.public_identifier;

-- =============================================================================
-- 8. Registros atípicos ou incompletos para a revisão médica
--    Duração ausente, ≤ 0 ou ≥ 30; H&Y ou UPDRS III ausentes; H&Y 0.
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-14'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        p.public_identifier,
        CASE
            WHEN p.date_of_birth IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int
        END AS idade,
        ca.age_at_onset,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao_estimada,
        hy.stage AS hoehn_yahr,
        u.total_score AS updrs_iii
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
)
SELECT
    public_identifier AS patient_id,
    idade,
    age_at_onset AS idade_inicio,
    duracao_estimada AS "duração_estimada",
    hoehn_yahr AS "H&Y",
    updrs_iii AS "UPDRS_III_total",
    concat_ws(
        '; ',
        CASE WHEN duracao_estimada IS NULL THEN 'duração ausente' END,
        CASE WHEN duracao_estimada <= 0 THEN 'duração ≤ 0' END,
        CASE WHEN duracao_estimada >= 30 THEN 'duração ≥ 30' END,
        CASE WHEN hoehn_yahr IS NULL THEN 'H&Y ausente' END,
        CASE WHEN hoehn_yahr = 0 THEN 'H&Y 0' END,
        CASE WHEN updrs_iii IS NULL THEN 'UPDRS III ausente' END
    ) AS motivo
FROM coorte
WHERE duracao_estimada IS NULL
   OR duracao_estimada <= 0
   OR duracao_estimada >= 30
   OR hoehn_yahr IS NULL
   OR hoehn_yahr = 0
   OR updrs_iii IS NULL
ORDER BY public_identifier;

-- =============================================================================
-- 9. Classificação paciente a paciente, para a validação clínica
--    Uma linha por paciente, com Sim/Não em cada regra do relatório.
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id,
        q.collection_date
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-14'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
coorte AS (
    SELECT
        p.public_identifier,
        lq.collection_date,
        CASE
            WHEN p.date_of_birth IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int
        END AS idade,
        g.description AS sexo,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao_estimada,
        hy.stage AS hoehn_yahr,
        u.total_score AS updrs_iii,
        EXISTS (
            SELECT 1 FROM patient_medications pm WHERE pm.questionnaire_id = lq.id
        ) AS usa_medicacao
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN gender_types g ON g.id = p.gender_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
)
SELECT
    public_identifier AS patient_id,
    collection_date AS data_coleta,
    idade,
    sexo,
    duracao_estimada AS "duração_estimada",
    hoehn_yahr AS "H&Y",
    updrs_iii AS "UPDRS_III_total",
    CASE
        WHEN updrs_iii IS NULL THEN NULL
        WHEN updrs_iii <= 32 THEN 'Leve'
        WHEN updrs_iii <= 58 THEN 'Moderada'
        ELSE 'Grave'
    END AS classe_updrs,
    CASE WHEN usa_medicacao THEN 'Sim' ELSE 'Não' END AS "uso_medicação_Parkinson",
    CASE
        WHEN duracao_estimada IS NULL THEN NULL
        WHEN duracao_estimada < 5 THEN 'Sim'
        ELSE 'Não'
    END AS "duração_<5",
    CASE
        WHEN hoehn_yahr IS NULL THEN NULL
        WHEN hoehn_yahr < 3 THEN 'Sim'
        ELSE 'Não'
    END AS "H&Y_<3",
    CASE
        WHEN hoehn_yahr IS NULL THEN NULL
        WHEN hoehn_yahr <= 3 THEN 'Sim'
        ELSE 'Não'
    END AS "H&Y_≤3",
    CASE
        WHEN updrs_iii IS NULL THEN NULL
        WHEN updrs_iii <= 32 THEN 'Sim'
        ELSE 'Não'
    END AS "UPDRS_≤32",
    CASE
        WHEN hoehn_yahr IS NULL OR updrs_iii IS NULL THEN NULL
        WHEN hoehn_yahr < 3 AND updrs_iii <= 32 THEN 'Sim'
        ELSE 'Não'
    END AS "H&Y_<3_e_UPDRS_≤32",
    CASE
        WHEN hoehn_yahr IS NULL THEN NULL
        WHEN hoehn_yahr < 3
         AND (duracao_estimada < 5 OR updrs_iii <= 32) THEN 'Sim'
        ELSE 'Não'
    END AS hibrido_1,
    CASE
        WHEN duracao_estimada < 5
          OR (hoehn_yahr < 3 AND updrs_iii <= 32) THEN 'Sim'
        ELSE 'Não'
    END AS hibrido_2
FROM coorte
ORDER BY
    CASE
        WHEN public_identifier ~ '^P[0-9]+$'
        THEN SUBSTRING(public_identifier FROM 2)::int
    END NULLS LAST,
    public_identifier;
