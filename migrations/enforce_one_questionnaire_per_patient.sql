-- Garantir que cada paciente tenha apenas um questionário
-- Esta constraint única garante que não haverá duplicação de questionários por paciente

-- Primeiro, remover possíveis duplicatas mantendo apenas o mais recente
-- (Execute manualmente se necessário antes de adicionar a constraint)

-- Adicionar constraint única para garantir apenas um questionário por paciente
-- Nota: Esta constraint pode falhar se já existirem múltiplos questionários para o mesmo paciente
-- Nesse caso, será necessário limpar os duplicados primeiro

DO $$
BEGIN
    -- Verificar se a constraint já existe
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_constraint 
        WHERE conname = 'uq_questionnaires_patient_id'
    ) THEN
        -- Criar índice único para garantir apenas um questionário por paciente
        CREATE UNIQUE INDEX uq_questionnaires_patient_id 
        ON questionnaires(patient_id);
        
        COMMENT ON INDEX uq_questionnaires_patient_id IS 
        'Garante que cada paciente tenha apenas um questionário';
    END IF;
END $$;

