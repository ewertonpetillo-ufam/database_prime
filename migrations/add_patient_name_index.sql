-- Adicionar índice para busca otimizada por nome do paciente (lowercase)
-- Isso melhora significativamente a performance de buscas por nome

CREATE INDEX IF NOT EXISTS idx_patients_full_name_lower 
ON patients(LOWER(full_name));

-- Comentário: Este índice permite buscas case-insensitive mais rápidas
-- quando usamos LOWER(patient.full_name) LIKE nas queries

