-- Script para inserir os novos fármacos padrão na tabela medications_reference
-- Este script apenas insere os novos fármacos, sem desativar os antigos

-- Inserir novos fármacos padrão (usando ON CONFLICT para evitar duplicatas)
INSERT INTO medications_reference (drug_name, led_conversion_factor, active, medication_class)
VALUES 
  ('Levodopa / Carbidopa', 1, true, 'Levodopa'),
  ('Levodopa / Benserazida BD', 1, true, 'Levodopa'),
  ('Levodopa / Benserazida', 1, true, 'Levodopa'),
  ('Levodopa / Benserazida HBS', 0.75, true, 'Levodopa'),
  ('Levodopa / Benserazida DR', 0.75, true, 'Levodopa'),
  ('Levodopa / Carbidopa / Entacapona', 1, true, 'Levodopa'),
  ('Entacapone', 1, true, 'COMT Inhibitor'),
  ('Rasagilina', 1, true, 'MAO-B Inhibitor'),
  ('Safinamida', 1, true, 'MAO-B Inhibitor'),
  ('Amantadina', 1, true, 'NMDA Antagonist'),
  ('Pramipexol', 1, true, 'Dopamine Agonist')
ON CONFLICT (drug_name) 
DO UPDATE SET 
  led_conversion_factor = EXCLUDED.led_conversion_factor,
  active = true,
  medication_class = EXCLUDED.medication_class;

-- Verificar os fármacos inseridos
SELECT 
  id,
  drug_name,
  led_conversion_factor,
  active,
  medication_class
FROM medications_reference
WHERE drug_name IN (
  'Levodopa / Carbidopa',
  'Levodopa / Benserazida BD',
  'Levodopa / Benserazida',
  'Levodopa / Benserazida HBS',
  'Levodopa / Benserazida DR',
  'Levodopa / Carbidopa / Entacapona',
  'Entacapone',
  'Rasagilina',
  'Safinamida',
  'Amantadina',
  'Pramipexol'
)
ORDER BY drug_name;

