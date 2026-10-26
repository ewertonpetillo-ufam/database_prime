-- Consultas do relatório
-- "Análise dos critérios de caracterização de estágio inicial na coorte PRIME"
-- Dados até 22/10/2026. Cada bloco é independente: rode um por vez e
-- exporte o resultado para uma aba do xlsx.
--
-- Coorte, igual em todos os blocos:
--   * um questionário por paciente, collection_date mais recente
--     em ou antes de 22/10/2026 (desempate por updated_at)
--   * status = in_progress
--   * só Parkinson (is_healthy_control IS NOT TRUE)
--   * exclui P000, P00 e P048
--
-- Contas:
--   idade            = 2026 - ano de nascimento
--   duração_estimada = idade - idade de início dos sintomas
--   Nula se faltar nascimento ou idade de início.
--   Medicação        = ao menos uma linha em patient_medications
--   UPDRS leve       = até 32; moderado = 33 a 58; grave = 59 ou mais
--   Porcentagem      = N da regra / N da coorte, uma casa decimal,
--                      salvo quando a coluna diz "% do grupo"
--
-- P048 fica de fora da coorte. O bloco 17 mostra o registro e o motivo.
--
-- Abas sugeridas:
--   01_pacientes
--   02_caracterizacao
--   03_pacientes_por_hy
--   04_revisao
--   05_criterios
--   06_classes_updrs
--   07_hy_x_updrs
--   08_spearman
--   09_grupo_brando_por_hy
--   10_grupo_brando_medicacao
--   11_grupo_brando_duracao
--   12_grupo_brando_sem_medicacao
--   13_duracao_x_updrs
--   14_exemplos_p091_p118
--   15_poucos_anos_mais_comprometidos
--   16_criterios_combinados
--   17_p048_excluido

-- =============================================================================
-- 1. Base individual — uma linha por paciente da coorte
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
      AND q.collection_date <= DATE '2026-10-22'
      AND (
          p.public_identifier IS NULL
          OR UPPER(TRIM(p.public_identifier)) NOT IN ('P000', 'P00', 'P048')
      )
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
),
base AS (
    SELECT
        p.public_identifier AS patient_id,
        lq.collection_date AS data_coleta,
        CASE
            WHEN p.date_of_birth IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int
        END AS idade,
        g.description AS sexo,
        ca.age_at_onset AS idade_inicio,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao,
        hy.stage::numeric AS hy,
        u.total_score AS updrs,
        CASE
            WHEN ca.id IS NULL THEN NULL
            WHEN ca.assessed_on_levodopa IS TRUE THEN 'ON'
            ELSE 'OFF'
        END AS estado_on_off,
        EXISTS (
            SELECT 1 FROM patient_medications pm
            WHERE pm.questionnaire_id = lq.id
        ) AS usa_medicacao
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN gender_types g ON g.id = p.gender_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
)
SELECT
    patient_id,
    data_coleta,
    idade,
    sexo,
    idade_inicio,
    duracao AS "duração_estimada",
    hy AS "H&Y",
    updrs AS "UPDRS_III_total",
    CASE
        WHEN updrs IS NULL THEN NULL
        WHEN updrs <= 32 THEN 'Leve'
        WHEN updrs <= 58 THEN 'Moderado'
        ELSE 'Grave'
    END AS classe_updrs,
    CASE
        WHEN duracao IS NULL THEN NULL
        WHEN duracao < 5 THEN 'Menos de 5 anos'
        WHEN duracao <= 10 THEN '5 a 10 anos'
        ELSE 'Mais de 10 anos'
    END AS faixa_duracao,
    CASE WHEN usa_medicacao THEN 'Sim' ELSE 'Não' END AS "uso_medicação_Parkinson",
    estado_on_off AS estado_ON_OFF,
    CASE WHEN hy IS NOT NULL AND hy <= 2 THEN 'Sim' ELSE 'Não' END AS "H&Y_até_2",
    CASE WHEN hy IS NOT NULL AND hy < 3 THEN 'Sim' ELSE 'Não' END AS "H&Y_inferior_a_3",
    CASE WHEN hy IS NOT NULL AND hy <= 3 THEN 'Sim' ELSE 'Não' END AS "H&Y_até_3",
    CASE WHEN hy = 2.5 THEN 'Sim' ELSE 'Não' END AS "H&Y_igual_a_2,5",
    CASE WHEN duracao IS NOT NULL AND duracao < 5 THEN 'Sim' ELSE 'Não' END AS "duração_inferior_a_5",
    CASE WHEN updrs IS NOT NULL AND updrs <= 32 THEN 'Sim' ELSE 'Não' END AS "UPDRS_leve",
    CASE
        WHEN hy IS NOT NULL AND hy < 3
         AND (
             (duracao IS NOT NULL AND duracao < 5)
             OR (updrs IS NOT NULL AND updrs <= 32)
         ) THEN 'Sim'
        ELSE 'Não'
    END AS criterio_1,
    CASE
        WHEN (duracao IS NOT NULL AND duracao < 5)
          OR (
              hy IS NOT NULL AND hy < 3
              AND updrs IS NOT NULL AND updrs <= 32
          ) THEN 'Sim'
        ELSE 'Não'
    END AS criterio_2,
    CASE
        WHEN hy IS NOT NULL AND hy < 3
         AND updrs IS NOT NULL AND updrs <= 32 THEN 'Sim'
        ELSE 'Não'
    END AS criterio_3,
    CASE
        WHEN hy IS NOT NULL AND hy <= 2
         AND updrs IS NOT NULL AND updrs <= 32 THEN 'Sim'
        ELSE 'Não'
    END AS "H&Y_até_2_e_UPDRS_leve",
    NULLIF(concat_ws('; ',
        CASE WHEN duracao IS NULL THEN 'duração ausente' END,
        CASE WHEN duracao < 0 THEN 'duração negativa' END,
        CASE WHEN duracao = 0 THEN 'duração igual a zero' END,
        CASE WHEN duracao >= 30 THEN 'duração de 30 anos ou mais' END,
        CASE WHEN hy IS NULL THEN 'H&Y ausente' END,
        CASE WHEN hy = 0 THEN 'H&Y 0' END,
        CASE WHEN updrs IS NULL THEN 'UPDRS III ausente' END
    ), '') AS motivo_revisao
FROM base
ORDER BY
    CASE
        WHEN patient_id ~ '^P[0-9]+$' THEN SUBSTRING(patient_id FROM 2)::int
    END NULLS LAST,
    patient_id;

-- =============================================================================
-- 2. Caracterização da coorte (seção 3 do relatório)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
        CASE
            WHEN p.date_of_birth IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int
        END AS idade,
        g.code AS sexo_codigo,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao,
        hy.stage::numeric AS hy,
        u.total_score AS updrs
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN gender_types g ON g.id = p.gender_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
),
tot AS (
    SELECT COUNT(*)::numeric AS n FROM base
)
SELECT indicador AS "Indicador", resultado AS "Resultado"
FROM (
    SELECT 1 AS ordem, 'Pacientes com Parkinson' AS indicador,
           (SELECT n FROM tot)::int::text AS resultado
    UNION ALL
    SELECT 2, 'Idade média',
           ROUND(AVG(idade)::numeric, 1)::text
    FROM base
    UNION ALL
    SELECT 3, 'Homens',
           COUNT(*) FILTER (WHERE sexo_codigo = 'M')::text
           || ' ('
           || ROUND(100 * COUNT(*) FILTER (WHERE sexo_codigo = 'M') / (SELECT n FROM tot), 1)::text
           || '%)'
    FROM base
    UNION ALL
    SELECT 4, 'Mulheres',
           COUNT(*) FILTER (WHERE sexo_codigo = 'F')::text
           || ' ('
           || ROUND(100 * COUNT(*) FILTER (WHERE sexo_codigo = 'F') / (SELECT n FROM tot), 1)::text
           || '%)'
    FROM base
    UNION ALL
    SELECT 5, 'Duração mediana',
           percentile_cont(0.5) WITHIN GROUP (ORDER BY duracao)::text
    FROM base
    UNION ALL
    SELECT 6, 'H&Y mediano',
           percentile_cont(0.5) WITHIN GROUP (ORDER BY hy)::text
    FROM base
    UNION ALL
    SELECT 7, 'UPDRS III média',
           ROUND(AVG(updrs)::numeric, 1)::text
    FROM base
    UNION ALL
    SELECT 8, 'UPDRS III mediana',
           percentile_cont(0.5) WITHIN GROUP (ORDER BY updrs)::text
    FROM base
    UNION ALL
    SELECT 9, 'Duração ausente',
           COUNT(*) FILTER (WHERE duracao IS NULL)::text
    FROM base
    UNION ALL
    SELECT 10, 'H&Y ausente',
           COUNT(*) FILTER (WHERE hy IS NULL)::text
    FROM base
    UNION ALL
    SELECT 11, 'UPDRS III ausente',
           COUNT(*) FILTER (WHERE updrs IS NULL)::text
    FROM base
) indicadores
ORDER BY ordem;

-- =============================================================================
-- 3. Pacientes por estágio de H&Y (seção 3 do relatório)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
    ROUND(100 * COUNT(*) / (SELECT n FROM tot), 1) AS "% da coorte"
FROM base
GROUP BY hy
ORDER BY hy NULLS LAST;

-- =============================================================================
-- 4. Registros que permanecem na contagem e pedem revisão (seção 3)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
        p.public_identifier AS patient_id,
        CASE
            WHEN p.date_of_birth IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int
        END AS idade,
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao,
        hy.stage::numeric AS hy,
        u.total_score AS updrs
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
)
SELECT
    patient_id AS "Paciente",
    idade AS "Idade",
    duracao AS "Duração",
    hy AS "H&Y",
    updrs AS "UPDRS III",
    concat_ws('; ',
        CASE WHEN duracao IS NULL THEN 'duração ausente' END,
        CASE WHEN duracao < 0 THEN 'duração negativa' END,
        CASE WHEN duracao = 0 THEN 'duração igual a zero' END,
        CASE WHEN duracao >= 30 THEN 'duração de 30 anos ou mais' END,
        CASE WHEN hy IS NULL THEN 'H&Y ausente' END,
        CASE WHEN hy = 0 THEN 'H&Y 0' END,
        CASE WHEN updrs IS NULL THEN 'UPDRS III ausente' END
    ) AS "Motivo da revisão"
FROM base
WHERE duracao IS NULL
   OR duracao < 0
   OR duracao = 0
   OR duracao >= 30
   OR hy IS NULL
   OR hy = 0
   OR updrs IS NULL
ORDER BY
    CASE
        WHEN patient_id ~ '^P[0-9]+$' THEN SUBSTRING(patient_id FROM 2)::int
    END NULLS LAST,
    patient_id;

-- =============================================================================
-- 5. Tamanho de cada definição de estágio inicial (seção 4)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao,
        hy.stage::numeric AS hy,
        u.total_score AS updrs
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
),
tot AS (
    SELECT COUNT(*)::numeric AS n FROM base
),
regras AS (
    SELECT 1 AS ordem, 'H&Y igual ou inferior a 2' AS criterio,
           COUNT(*) FILTER (WHERE hy <= 2)::int AS n
    FROM base
    UNION ALL
    SELECT 2, 'H&Y inferior a 3',
           COUNT(*) FILTER (WHERE hy < 3)::int
    FROM base
    UNION ALL
    SELECT 3, 'H&Y igual ou inferior a 3',
           COUNT(*) FILTER (WHERE hy <= 3)::int
    FROM base
    UNION ALL
    SELECT 4, 'Duração inferior a 5 anos',
           COUNT(*) FILTER (WHERE duracao < 5)::int
    FROM base
    UNION ALL
    SELECT 5, 'H&Y inferior a 3 e duração inferior a 5 anos',
           COUNT(*) FILTER (WHERE hy < 3 AND duracao < 5)::int
    FROM base
    UNION ALL
    SELECT 6, 'H&Y igual ou inferior a 3 e duração inferior a 5 anos',
           COUNT(*) FILTER (WHERE hy <= 3 AND duracao < 5)::int
    FROM base
    UNION ALL
    SELECT 7, 'UPDRS III leve (até 32)',
           COUNT(*) FILTER (WHERE updrs <= 32)::int
    FROM base
    UNION ALL
    SELECT 8, 'H&Y igual ou inferior a 2 e UPDRS III leve',
           COUNT(*) FILTER (WHERE hy <= 2 AND updrs <= 32)::int
    FROM base
    UNION ALL
    SELECT 9, 'H&Y inferior a 3 e UPDRS III leve',
           COUNT(*) FILTER (WHERE hy < 3 AND updrs <= 32)::int
    FROM base
)
SELECT
    criterio AS "Critério",
    n AS "N",
    ROUND(100 * n / (SELECT n FROM tot), 1) AS "% da coorte"
FROM regras
ORDER BY ordem;

-- =============================================================================
-- 6. Classes do MDS-UPDRS parte III na coorte (seção 5)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
    SELECT u.total_score AS updrs
    FROM latest_q lq
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
),
tot AS (
    SELECT COUNT(*)::numeric AS n FROM base
)
SELECT classe AS "Classe", n AS "N",
       ROUND(100 * n / (SELECT n FROM tot), 1) AS "% da coorte"
FROM (
    SELECT 1 AS ordem, 'Leve (até 32)' AS classe,
           COUNT(*) FILTER (WHERE updrs <= 32)::int AS n
    FROM base
    UNION ALL
    SELECT 2, 'Moderado (33 a 58)',
           COUNT(*) FILTER (WHERE updrs BETWEEN 33 AND 58)::int
    FROM base
    UNION ALL
    SELECT 3, 'Grave (59 ou mais)',
           COUNT(*) FILTER (WHERE updrs >= 59)::int
    FROM base
    UNION ALL
    SELECT 4, 'UPDRS III ausente',
           COUNT(*) FILTER (WHERE updrs IS NULL)::int
    FROM base
) classes
ORDER BY ordem;

-- =============================================================================
-- 7. H&Y x gravidade do UPDRS III (seção 5)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
    SELECT hy.stage::numeric AS hy, u.total_score AS updrs
    FROM latest_q lq
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
)
SELECT
    faixa AS "H&Y",
    leve AS "UPDRS leve",
    moderado AS "Moderado",
    grave AS "Grave",
    leve + moderado + grave AS "Total"
FROM (
    SELECT 1 AS ordem, 'Igual ou inferior a 2' AS faixa,
           COUNT(*) FILTER (WHERE hy <= 2 AND updrs <= 32)::int AS leve,
           COUNT(*) FILTER (WHERE hy <= 2 AND updrs BETWEEN 33 AND 58)::int AS moderado,
           COUNT(*) FILTER (WHERE hy <= 2 AND updrs >= 59)::int AS grave
    FROM base
    UNION ALL
    SELECT 2, 'Igual a 2,5',
           COUNT(*) FILTER (WHERE hy = 2.5 AND updrs <= 32)::int,
           COUNT(*) FILTER (WHERE hy = 2.5 AND updrs BETWEEN 33 AND 58)::int,
           COUNT(*) FILTER (WHERE hy = 2.5 AND updrs >= 59)::int
    FROM base
    UNION ALL
    SELECT 3, 'Inferior a 3',
           COUNT(*) FILTER (WHERE hy < 3 AND updrs <= 32)::int,
           COUNT(*) FILTER (WHERE hy < 3 AND updrs BETWEEN 33 AND 58)::int,
           COUNT(*) FILTER (WHERE hy < 3 AND updrs >= 59)::int
    FROM base
    UNION ALL
    SELECT 4, 'Igual a 3',
           COUNT(*) FILTER (WHERE hy = 3 AND updrs <= 32)::int,
           COUNT(*) FILTER (WHERE hy = 3 AND updrs BETWEEN 33 AND 58)::int,
           COUNT(*) FILTER (WHERE hy = 3 AND updrs >= 59)::int
    FROM base
    UNION ALL
    SELECT 5, 'Superior a 3',
           COUNT(*) FILTER (WHERE hy > 3 AND updrs <= 32)::int,
           COUNT(*) FILTER (WHERE hy > 3 AND updrs BETWEEN 33 AND 58)::int,
           COUNT(*) FILTER (WHERE hy > 3 AND updrs >= 59)::int
    FROM base
) faixas
ORDER BY ordem;

-- =============================================================================
-- 8. Correlação de Spearman (seção 5)
--    Pearson das posições médias, com desempate pela média do grupo empatado.
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao,
        hy.stage::numeric AS hy,
        u.total_score AS updrs
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
),
par_hy_up AS (
    SELECT
        RANK() OVER (ORDER BY hy) + (COUNT(*) OVER (PARTITION BY hy) - 1) / 2.0 AS r_hy,
        RANK() OVER (ORDER BY updrs) + (COUNT(*) OVER (PARTITION BY updrs) - 1) / 2.0 AS r_up
    FROM base
    WHERE hy IS NOT NULL AND updrs IS NOT NULL
),
par_dur_hy AS (
    SELECT
        RANK() OVER (ORDER BY duracao) + (COUNT(*) OVER (PARTITION BY duracao) - 1) / 2.0 AS r_dur,
        RANK() OVER (ORDER BY hy) + (COUNT(*) OVER (PARTITION BY hy) - 1) / 2.0 AS r_hy
    FROM base
    WHERE duracao IS NOT NULL AND hy IS NOT NULL
),
par_dur_up AS (
    SELECT
        RANK() OVER (ORDER BY duracao) + (COUNT(*) OVER (PARTITION BY duracao) - 1) / 2.0 AS r_dur,
        RANK() OVER (ORDER BY updrs) + (COUNT(*) OVER (PARTITION BY updrs) - 1) / 2.0 AS r_up
    FROM base
    WHERE duracao IS NOT NULL AND updrs IS NOT NULL
)
SELECT
    par AS "Par",
    n_pares AS "N de pares",
    spearman AS "Spearman",
    CASE
        WHEN abs(spearman) >= 0.4 THEN 'moderada'
        WHEN abs(spearman) >= 0.2 THEN 'fraca'
        ELSE 'muito fraca'
    END AS "Força da associação"
FROM (
    SELECT 1 AS ordem, 'H&Y x UPDRS III' AS par,
           COUNT(*)::int AS n_pares,
           ROUND(corr(r_hy, r_up)::numeric, 2) AS spearman
    FROM par_hy_up
    UNION ALL
    SELECT 2, 'Duração x H&Y',
           COUNT(*)::int,
           ROUND(corr(r_dur, r_hy)::numeric, 2)
    FROM par_dur_hy
    UNION ALL
    SELECT 3, 'Duração x UPDRS III',
           COUNT(*)::int,
           ROUND(corr(r_dur, r_up)::numeric, 2)
    FROM par_dur_up
) pares
ORDER BY ordem;

-- =============================================================================
-- 9. Grupo H&Y inferior a 3 e UPDRS leve: distribuição do H&Y (seção 6)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
grupo AS (
    SELECT hy.stage::numeric AS hy
    FROM latest_q lq
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
    WHERE hy.stage < 3
      AND u.total_score <= 32
),
tot AS (
    SELECT COUNT(*)::numeric AS n FROM grupo
)
SELECT
    CASE
        WHEN hy = trunc(hy) THEN trunc(hy)::int::text
        ELSE replace(to_char(hy, 'FM999990.0'), '.', ',')
    END AS "H&Y",
    COUNT(*)::int AS "N",
    ROUND(100 * COUNT(*) / (SELECT n FROM tot), 1) AS "% do grupo"
FROM grupo
GROUP BY hy
ORDER BY hy;

-- =============================================================================
-- 10. Grupo H&Y inferior a 3 e UPDRS leve: medicação (seção 6)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
grupo AS (
    SELECT EXISTS (
        SELECT 1 FROM patient_medications pm
        WHERE pm.questionnaire_id = lq.id
    ) AS usa_medicacao
    FROM latest_q lq
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
    WHERE hy.stage < 3
      AND u.total_score <= 32
),
tot AS (
    SELECT COUNT(*)::numeric AS n FROM grupo
)
SELECT medicacao AS "Medicação", n AS "N",
       ROUND(100 * n / (SELECT n FROM tot), 1) AS "% do grupo"
FROM (
    SELECT 1 AS ordem, 'Em uso' AS medicacao,
           COUNT(*) FILTER (WHERE usa_medicacao)::int AS n
    FROM grupo
    UNION ALL
    SELECT 2, 'Sem uso',
           COUNT(*) FILTER (WHERE NOT usa_medicacao)::int
    FROM grupo
) linhas
ORDER BY ordem;

-- =============================================================================
-- 11. Grupo H&Y inferior a 3 e UPDRS leve: tempo de doença (seção 6)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
grupo AS (
    SELECT
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
    WHERE hy.stage < 3
      AND u.total_score <= 32
),
tot AS (
    SELECT COUNT(*)::numeric AS n FROM grupo
)
SELECT faixa AS "Tempo de doença", n AS "N",
       ROUND(100 * n / (SELECT n FROM tot), 1) AS "% do grupo"
FROM (
    SELECT 1 AS ordem, 'Menos de 5 anos' AS faixa,
           COUNT(*) FILTER (WHERE duracao < 5)::int AS n
    FROM grupo
    UNION ALL
    SELECT 2, '5 a 10 anos',
           COUNT(*) FILTER (WHERE duracao BETWEEN 5 AND 10)::int
    FROM grupo
    UNION ALL
    SELECT 3, 'Mais de 10 anos',
           COUNT(*) FILTER (WHERE duracao > 10)::int
    FROM grupo
) faixas
ORDER BY ordem;

-- =============================================================================
-- 12. Grupo H&Y inferior a 3 e UPDRS leve, sem medicação (seção 6)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
)
SELECT
    p.public_identifier AS "Paciente",
    (2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset) AS "Duração (anos)",
    hy.stage AS "H&Y",
    u.total_score AS "UPDRS III",
    CASE
        WHEN (2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset) >= 5
            THEN 'Exemplo de doença branda após 5 anos'
        ELSE 'Sem medicação antiparkinsoniana'
    END AS "Observação"
FROM latest_q lq
INNER JOIN patients p ON p.id = lq.patient_id
LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
WHERE hy.stage < 3
  AND u.total_score <= 32
  AND NOT EXISTS (
      SELECT 1 FROM patient_medications pm
      WHERE pm.questionnaire_id = lq.id
  )
ORDER BY p.public_identifier;

-- =============================================================================
-- 13. Duração x gravidade do UPDRS III (seção 7)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao,
        u.total_score AS updrs
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
)
SELECT
    faixa AS "Duração",
    leve AS "UPDRS leve",
    moderado AS "Moderado",
    grave AS "Grave",
    leve + moderado + grave AS "Total"
FROM (
    SELECT 1 AS ordem, 'Menos de 5 anos' AS faixa,
           COUNT(*) FILTER (WHERE duracao < 5 AND updrs <= 32)::int AS leve,
           COUNT(*) FILTER (WHERE duracao < 5 AND updrs BETWEEN 33 AND 58)::int AS moderado,
           COUNT(*) FILTER (WHERE duracao < 5 AND updrs >= 59)::int AS grave
    FROM base
    UNION ALL
    SELECT 2, '5 a 10 anos',
           COUNT(*) FILTER (WHERE duracao BETWEEN 5 AND 10 AND updrs <= 32)::int,
           COUNT(*) FILTER (WHERE duracao BETWEEN 5 AND 10 AND updrs BETWEEN 33 AND 58)::int,
           COUNT(*) FILTER (WHERE duracao BETWEEN 5 AND 10 AND updrs >= 59)::int
    FROM base
    UNION ALL
    SELECT 3, 'Mais de 10 anos',
           COUNT(*) FILTER (WHERE duracao > 10 AND updrs <= 32)::int,
           COUNT(*) FILTER (WHERE duracao > 10 AND updrs BETWEEN 33 AND 58)::int,
           COUNT(*) FILTER (WHERE duracao > 10 AND updrs >= 59)::int
    FROM base
) faixas
ORDER BY ordem;

-- =============================================================================
-- 14. Exemplos com doença branda e 5 anos ou mais (seção 7: P091 e P118)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
    FROM questionnaires q
    INNER JOIN patients p ON p.id = q.patient_id
    WHERE q.status = 'in_progress'
      AND q.is_healthy_control IS NOT TRUE
      AND q.collection_date <= DATE '2026-10-22'
      AND UPPER(TRIM(p.public_identifier)) IN ('P091', 'P118')
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
)
SELECT
    p.public_identifier AS "Paciente",
    (2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset) AS "Duração",
    hy.stage AS "H&Y",
    u.total_score AS "UPDRS III",
    CASE
        WHEN EXISTS (
            SELECT 1 FROM patient_medications pm
            WHERE pm.questionnaire_id = lq.id
        ) THEN 'Sim'
        ELSE 'Não'
    END AS "Medicação"
FROM latest_q lq
INNER JOIN patients p ON p.id = lq.patient_id
LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
ORDER BY p.public_identifier;

-- =============================================================================
-- 15. Menos de 5 anos já com exame moderado/grave ou H&Y 3 ou mais (seção 7)
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
        p.public_identifier AS patient_id,
        2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset AS duracao,
        hy.stage::numeric AS hy,
        u.total_score AS updrs
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
    WHERE p.date_of_birth IS NOT NULL
      AND ca.age_at_onset IS NOT NULL
      AND (2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset) < 5
      AND (
          u.total_score > 32
          OR hy.stage >= 3
      )
)
SELECT
    patient_id AS "Paciente",
    duracao AS "Duração",
    hy AS "H&Y",
    updrs AS "UPDRS III",
    CASE
        WHEN updrs BETWEEN 33 AND 58 THEN 'Exame moderado'
        WHEN updrs >= 59 THEN 'Exame grave'
        WHEN hy >= 3 AND updrs <= 32 THEN 'H&Y 3 ou mais, exame ainda leve'
        ELSE 'Revisar'
    END AS "Situação"
FROM base
ORDER BY
    CASE
        WHEN patient_id ~ '^P[0-9]+$' THEN SUBSTRING(patient_id FROM 2)::int
    END NULLS LAST,
    patient_id;

-- =============================================================================
-- 16. Critérios combinados da seção 8
-- =============================================================================

WITH latest_q AS (
    SELECT DISTINCT ON (q.patient_id)
        q.id,
        q.patient_id
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
        CASE
            WHEN p.date_of_birth IS NULL OR ca.age_at_onset IS NULL THEN NULL
            ELSE 2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset
        END AS duracao,
        hy.stage::numeric AS hy,
        u.total_score AS updrs
    FROM latest_q lq
    INNER JOIN patients p ON p.id = lq.patient_id
    LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
    LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
    LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id
),
tot AS (
    SELECT COUNT(*)::numeric AS n FROM base
),
regras AS (
    SELECT 1 AS ordem, 'Só o tempo: duração inferior a 5 anos' AS estrategia,
           COUNT(*) FILTER (WHERE duracao < 5)::int AS n
    FROM base
    UNION ALL
    SELECT 2, 'Só o estágio: H&Y inferior a 3',
           COUNT(*) FILTER (WHERE hy < 3)::int
    FROM base
    UNION ALL
    SELECT 3, 'Só o estágio, corte até 2',
           COUNT(*) FILTER (WHERE hy <= 2)::int
    FROM base
    UNION ALL
    SELECT 4, 'Só o exame: UPDRS III até 32',
           COUNT(*) FILTER (WHERE updrs <= 32)::int
    FROM base
    UNION ALL
    SELECT 5, 'Critério 1: H&Y inferior a 3 e (duração inferior a 5 ou UPDRS até 32)',
           COUNT(*) FILTER (
               WHERE hy < 3 AND (duracao < 5 OR updrs <= 32)
           )::int
    FROM base
    UNION ALL
    SELECT 6, 'Critério 2: duração inferior a 5 ou (H&Y inferior a 3 e UPDRS até 32)',
           COUNT(*) FILTER (
               WHERE duracao < 5 OR (hy < 3 AND updrs <= 32)
           )::int
    FROM base
    UNION ALL
    SELECT 7, 'Critério 3: H&Y inferior a 3 e UPDRS III até 32, sem o tempo',
           COUNT(*) FILTER (WHERE hy < 3 AND updrs <= 32)::int
    FROM base
    UNION ALL
    SELECT 8, 'H&Y igual ou inferior a 2 e UPDRS III até 32, sem o tempo',
           COUNT(*) FILTER (WHERE hy <= 2 AND updrs <= 32)::int
    FROM base
)
SELECT
    estrategia AS "Estratégia",
    n AS "N",
    ROUND(100 * n / (SELECT n FROM tot), 1) AS "% da coorte"
FROM regras
ORDER BY ordem;

-- =============================================================================
-- 17. P048, excluído da coorte
--     Duração longa com H&Y 0, exame leve e sem medicação antiparkinsoniana.
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
      AND q.collection_date <= DATE '2026-10-22'
      AND UPPER(TRIM(p.public_identifier)) = 'P048'
    ORDER BY q.patient_id, q.collection_date DESC, q.updated_at DESC
)
SELECT
    p.public_identifier AS "Paciente",
    lq.collection_date AS "Data da coleta",
    (2026 - EXTRACT(YEAR FROM p.date_of_birth)::int) AS "Idade",
    (2026 - EXTRACT(YEAR FROM p.date_of_birth)::int - ca.age_at_onset) AS "Duração",
    hy.stage AS "H&Y",
    u.total_score AS "UPDRS III",
    CASE
        WHEN EXISTS (
            SELECT 1 FROM patient_medications pm
            WHERE pm.questionnaire_id = lq.id
        ) THEN 'Sim'
        ELSE 'Não'
    END AS "Medicação",
    'Excluído da coorte: duração longa, H&Y 0, exame leve e sem medicação' AS "Motivo"
FROM latest_q lq
INNER JOIN patients p ON p.id = lq.patient_id
LEFT JOIN clinical_assessments ca ON ca.questionnaire_id = lq.id
LEFT JOIN hoehn_yahr_scale hy ON hy.id = ca.hoehn_yahr_stage_id
LEFT JOIN updrs_part3_scores u ON u.questionnaire_id = lq.id;
