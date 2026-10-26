BEGIN;

-- Preserve legacy data
ALTER TABLE IF EXISTS pdss1_scores RENAME TO pdss1_scores_legacy;
ALTER INDEX IF EXISTS idx_pdss1_questionnaire RENAME TO idx_pdss1_questionnaire_legacy;

COMMENT ON TABLE pdss1_scores_legacy IS 'Legacy PDSS-1 data kept for reference. Values range 0-10 per item.';

-- New PDSS-2 table (0-4 scale)
CREATE TABLE IF NOT EXISTS pdss2_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    q1 SMALLINT CHECK (q1 BETWEEN 0 AND 4),
    q2 SMALLINT CHECK (q2 BETWEEN 0 AND 4),
    q3 SMALLINT CHECK (q3 BETWEEN 0 AND 4),
    q4 SMALLINT CHECK (q4 BETWEEN 0 AND 4),
    q5 SMALLINT CHECK (q5 BETWEEN 0 AND 4),
    q6 SMALLINT CHECK (q6 BETWEEN 0 AND 4),
    q7 SMALLINT CHECK (q7 BETWEEN 0 AND 4),
    q8 SMALLINT CHECK (q8 BETWEEN 0 AND 4),
    q9 SMALLINT CHECK (q9 BETWEEN 0 AND 4),
    q10 SMALLINT CHECK (q10 BETWEEN 0 AND 4),
    q11 SMALLINT CHECK (q11 BETWEEN 0 AND 4),
    q12 SMALLINT CHECK (q12 BETWEEN 0 AND 4),
    q13 SMALLINT CHECK (q13 BETWEEN 0 AND 4),
    q14 SMALLINT CHECK (q14 BETWEEN 0 AND 4),
    q15 SMALLINT CHECK (q15 BETWEEN 0 AND 4),

    total_score INTEGER GENERATED ALWAYS AS (
        COALESCE(q1, 0) + COALESCE(q2, 0) + COALESCE(q3, 0) +
        COALESCE(q4, 0) + COALESCE(q5, 0) + COALESCE(q6, 0) +
        COALESCE(q7, 0) + COALESCE(q8, 0) + COALESCE(q9, 0) +
        COALESCE(q10, 0) + COALESCE(q11, 0) + COALESCE(q12, 0) +
        COALESCE(q13, 0) + COALESCE(q14, 0) + COALESCE(q15, 0)
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_pdss2_questionnaire ON pdss2_scores(questionnaire_id);

COMMIT;

