-- Adiciona campo last_step na tabela questionnaires para rastrear o último passo salvo
-- Este campo armazena o número do passo (1-8) onde o paciente parou

ALTER TABLE questionnaires 
ADD COLUMN IF NOT EXISTS last_step INTEGER DEFAULT 1 CHECK (last_step >= 1 AND last_step <= 8);

COMMENT ON COLUMN questionnaires.last_step IS 'Último passo do questionário que foi salvo (1-8)';

