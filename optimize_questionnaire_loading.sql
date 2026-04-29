-- Script de otimização para melhorar performance do carregamento de questionários
-- Execute este script no banco de dados para adicionar índices que melhoram as queries

-- ============================================================================
-- ÍNDICES COMPOSTOS PARA BINARY_COLLECTIONS
-- ============================================================================

-- Índice composto para busca por questionnaire_id OU patient_cpf_hash (usado na query otimizada)
-- Este índice ajuda na query: WHERE questionnaire_id = ? OR patient_cpf_hash = ?
CREATE INDEX IF NOT EXISTS idx_binary_questionnaire_or_cpf 
ON binary_collections(questionnaire_id, patient_cpf_hash) 
WHERE questionnaire_id IS NOT NULL OR patient_cpf_hash IS NOT NULL;

-- Índice composto para ordenação por collected_at junto com questionnaire_id
CREATE INDEX IF NOT EXISTS idx_binary_questionnaire_collected_at 
ON binary_collections(questionnaire_id, collected_at DESC) 
WHERE questionnaire_id IS NOT NULL;

-- Índice composto para ordenação por collected_at junto com patient_cpf_hash
CREATE INDEX IF NOT EXISTS idx_binary_cpf_collected_at 
ON binary_collections(patient_cpf_hash, collected_at DESC);

-- ============================================================================
-- ÍNDICES PARA PATIENT_MEDICATIONS
-- ============================================================================

-- Índice para busca rápida de medicamentos por questionnaire_id
-- (já deve existir via foreign key, mas vamos garantir)
CREATE INDEX IF NOT EXISTS idx_patient_medications_questionnaire 
ON patient_medications(questionnaire_id);

-- ============================================================================
-- ÍNDICES PARA QUESTIONNAIRES
-- ============================================================================

-- Índice composto para busca por ID com patient_id (já carregado)
CREATE INDEX IF NOT EXISTS idx_questionnaires_id_patient 
ON questionnaires(id, patient_id);

-- ============================================================================
-- ÍNDICES PARA PDF_REPORTS
-- ============================================================================

-- Índice para busca rápida de relatórios PDF por questionnaire_id
CREATE INDEX IF NOT EXISTS idx_pdf_reports_questionnaire 
ON pdf_reports(questionnaire_id);

-- ============================================================================
-- ANÁLISE DE PERFORMANCE
-- ============================================================================

-- Para verificar se os índices estão sendo usados, execute:
-- EXPLAIN ANALYZE 
-- SELECT bc.* FROM binary_collections bc 
-- WHERE bc.questionnaire_id = 'uuid-aqui' OR bc.patient_cpf_hash = 'hash-aqui'
-- ORDER BY bc.collected_at DESC;

-- Para verificar estatísticas dos índices:
-- SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
-- FROM pg_stat_user_indexes 
-- WHERE tablename IN ('binary_collections', 'patient_medications', 'questionnaires', 'pdf_reports')
-- ORDER BY tablename, indexname;

-- ============================================================================
-- VACUUM E ANALYZE (para atualizar estatísticas)
-- ============================================================================

-- Execute após criar os índices para atualizar as estatísticas do planner
VACUUM ANALYZE binary_collections;
VACUUM ANALYZE patient_medications;
VACUUM ANALYZE questionnaires;
VACUUM ANALYZE pdf_reports;

