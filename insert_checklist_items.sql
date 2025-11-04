-- ============================================================================
-- INSERTS PARA ITENS DE CHECKLIST DAS TAREFAS ATIVAS
-- ============================================================================
-- Este arquivo contém todos os itens de checklist para as 18 tarefas ativas
-- Cada item é vinculado à sua tarefa correspondente via task_id
-- ============================================================================

-- ============================================================================
-- TA1: Mãos em repouso
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 1, '1. Identificação do Paciente - Registrar nome completo, idade, sexo e número de prontuário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 2, '1. Identificação do Paciente - Anotar lateralidade da doença (direita, esquerda ou bilateral).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 3, '1. Identificação do Paciente - Verificar e registrar o estágio na Escala de Hoehn & Yahr.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 4, '2. Preparação da Tarefa - Posicionar paciente sentado confortavelmente com braços apoiados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 5, '2. Preparação da Tarefa - Explicar a tarefa: "Mantenha as mãos em repouso sobre as coxas".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 6, '2. Preparação da Tarefa - Definir duração da coleta (recomendado: 30-60 segundos).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 7, '3. Execução da Tarefa - Iniciar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 8, '3. Execução da Tarefa - Observar presença de tremor de repouso nas mãos.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 9, '3. Execução da Tarefa - Registrar intensidade e características do tremor.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 10, '3. Execução da Tarefa - Manter posição por tempo determinado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 11, '4. Pós-Coleta - Parar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 12, '4. Pós-Coleta - Verificar qualidade dos dados coletados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA1'), 13, '4. Pós-Coleta - Salvar arquivos com nomenclatura: PXXX_TA01_RepX.csv');

-- ============================================================================
-- TA2: Dedo ao nariz
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 1, '1. Identificação do Paciente - Registrar nome completo, idade, sexo e número de prontuário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 2, '1. Identificação do Paciente - Anotar lateralidade da doença (direita, esquerda ou bilateral).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 3, '1. Identificação do Paciente - Verificar e registrar o estágio na Escala de Hoehn & Yahr.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 4, '2. Preparação da Tarefa - Posicionar paciente sentado com braço estendido à frente.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 5, '2. Preparação da Tarefa - Explicar: "Toque o nariz com o dedo indicador, alternando as mãos".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 6, '2. Preparação da Tarefa - Definir número de repetições (mínimo 5 por mão).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 7, '3. Execução da Tarefa - Iniciar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 8, '3. Execução da Tarefa - Observar precisão, velocidade e coordenação do movimento.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 9, '3. Execução da Tarefa - Registrar tempo de execução e qualidade do movimento.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 10, '3. Execução da Tarefa - Executar número determinado de repetições.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 11, '4. Pós-Coleta - Parar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 12, '4. Pós-Coleta - Verificar qualidade dos dados coletados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA2'), 13, '4. Pós-Coleta - Salvar arquivos com nomenclatura: PXXX_TA02_RepX.csv');

-- ============================================================================
-- TA3: Pronação e supinação das mãos
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 1, '1. Identificação do Paciente - Registrar nome completo, idade, sexo e número de prontuário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 2, '1. Identificação do Paciente - Anotar lateralidade da doença (direita, esquerda ou bilateral).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 3, '1. Identificação do Paciente - Verificar e registrar o estágio na Escala de Hoehn & Yahr.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 4, '2. Preparação da Tarefa - Posicionar paciente sentado com antebraços apoiados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 5, '2. Preparação da Tarefa - Explicar: "Faça movimentos de pronação e supinação das mãos".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 6, '2. Preparação da Tarefa - Definir velocidade: lenta, moderada e rápida.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 7, '3. Execução da Tarefa - Iniciar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 8, '3. Execução da Tarefa - Executar movimento em velocidade lenta (10 repetições).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 9, '3. Execução da Tarefa - Executar movimento em velocidade moderada (10 repetições).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 10, '3. Execução da Tarefa - Executar movimento em velocidade rápida (10 repetições).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 11, '4. Pós-Coleta - Parar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 12, '4. Pós-Coleta - Verificar qualidade dos dados coletados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA3'), 13, '4. Pós-Coleta - Salvar arquivos com nomenclatura: PXXX_TA03_RepX.csv');

-- ============================================================================
-- TA4: Toque alternado dos dedos
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 1, '1. Identificação do Paciente - Registrar nome completo, idade, sexo e número de prontuário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 2, '1. Identificação do Paciente - Anotar lateralidade da doença (direita, esquerda ou bilateral).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 3, '1. Identificação do Paciente - Verificar e registrar o estágio na Escala de Hoehn & Yahr.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 4, '2. Preparação da Tarefa - Posicionar paciente sentado com mãos sobre mesa.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 5, '2. Preparação da Tarefa - Explicar: "Toque alternadamente o polegar com os outros dedos".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 6, '2. Preparação da Tarefa - Definir sequência: polegar-dedo indicador, polegar-dedo médio, etc.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 7, '3. Execução da Tarefa - Iniciar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 8, '3. Execução da Tarefa - Executar sequência com mão direita (10 ciclos).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 9, '3. Execução da Tarefa - Executar sequência com mão esquerda (10 ciclos).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 10, '3. Execução da Tarefa - Executar sequência com ambas as mãos simultaneamente.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 11, '4. Pós-Coleta - Parar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 12, '4. Pós-Coleta - Verificar qualidade dos dados coletados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA4'), 13, '4. Pós-Coleta - Salvar arquivos com nomenclatura: PXXX_TA04_RepX.csv');

-- ============================================================================
-- TA5: Time Up and Go (TUG)
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 1, '1. Identificação do Paciente - Registrar nome completo, idade, sexo e número de prontuário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 2, '1. Identificação do Paciente - Anotar lateralidade da doença (direita, esquerda ou bilateral).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 3, '1. Identificação do Paciente - Verificar e registrar o estágio na Escala de Hoehn & Yahr.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 4, '2. Preparação da Tarefa - Verificar espaço livre de 3 metros para caminhada.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 5, '2. Preparação da Tarefa - Posicionar paciente sentado em cadeira padronizada.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 6, '2. Preparação da Tarefa - Explicar: "Levante, caminhe 3 metros, vire e retorne".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 7, '3. Execução da Tarefa - Iniciar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 8, '3. Execução da Tarefa - Cronometrar tempo para levantar da cadeira.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 9, '3. Execução da Tarefa - Cronometrar tempo de caminhada (ida e volta).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 10, '3. Execução da Tarefa - Cronometrar tempo para sentar na cadeira.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 11, '4. Pós-Coleta - Parar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 12, '4. Pós-Coleta - Verificar qualidade dos dados coletados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA5'), 13, '4. Pós-Coleta - Salvar arquivos com nomenclatura: PXXX_TA05_RepX.csv');

-- ============================================================================
-- TA6: Movimentos alternados dos dedos
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 1, '1. Identificação do Paciente - Registrar nome completo, idade, sexo e número de prontuário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 2, '1. Identificação do Paciente - Anotar lateralidade da doença (direita, esquerda ou bilateral).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 3, '1. Identificação do Paciente - Verificar e registrar o estágio na Escala de Hoehn & Yahr.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 4, '2. Preparação da Tarefa - Posicionar paciente sentado com mãos sobre mesa.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 5, '2. Preparação da Tarefa - Explicar: "Faça movimentos alternados dos dedos (tapping)".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 6, '2. Preparação da Tarefa - Definir velocidade: lenta, moderada e rápida.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 7, '3. Execução da Tarefa - Iniciar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 8, '3. Execução da Tarefa - Executar tapping em velocidade lenta (10 segundos).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 9, '3. Execução da Tarefa - Executar tapping em velocidade moderada (10 segundos).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 10, '3. Execução da Tarefa - Executar tapping em velocidade rápida (10 segundos).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 11, '4. Pós-Coleta - Parar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 12, '4. Pós-Coleta - Verificar qualidade dos dados coletados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA6'), 13, '4. Pós-Coleta - Salvar arquivos com nomenclatura: PXXX_TA06_RepX.csv');

-- ============================================================================
-- TA7: Movimento em espiral
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 1, '1. Identificação do Paciente - Registrar nome completo, idade, sexo e número de prontuário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 2, '1. Identificação do Paciente - Anotar lateralidade da doença (direita, esquerda ou bilateral).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 3, '1. Identificação do Paciente - Verificar e registrar o estágio na Escala de Hoehn & Yahr.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 4, '2. Preparação da Tarefa - Posicionar paciente sentado com papel e caneta.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 5, '2. Preparação da Tarefa - Explicar: "Desenhe uma espiral com a mão dominante".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 6, '2. Preparação da Tarefa - Definir tamanho da espiral (diâmetro de 10cm).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 7, '3. Execução da Tarefa - Iniciar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 8, '3. Execução da Tarefa - Desenhar espiral com mão dominante.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 9, '3. Execução da Tarefa - Desenhar espiral com mão não dominante.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 10, '3. Execução da Tarefa - Observar qualidade do traçado e tremor.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 11, '4. Pós-Coleta - Parar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 12, '4. Pós-Coleta - Verificar qualidade dos dados coletados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA7'), 13, '4. Pós-Coleta - Salvar arquivos com nomenclatura: PXXX_TA07_RepX.csv');

-- ============================================================================
-- TA8: Teste de trilhas
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 1, '1. Identificação do Paciente - Registrar nome completo, idade, sexo e número de prontuário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 2, '1. Identificação do Paciente - Anotar lateralidade da doença (direita, esquerda ou bilateral).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 3, '1. Identificação do Paciente - Verificar e registrar o estágio na Escala de Hoehn & Yahr.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 4, '2. Preparação da Tarefa - Preparar material do Trail Making Test (parte A e B).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 5, '2. Preparação da Tarefa - Posicionar paciente sentado confortavelmente à mesa.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 6, '2. Preparação da Tarefa - Explicar instruções do teste conforme protocolo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 7, '3. Execução da Tarefa - Iniciar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 8, '3. Execução da Tarefa - Aplicar Trail Making Test parte A.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 9, '3. Execução da Tarefa - Aplicar Trail Making Test parte B.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 10, '3. Execução da Tarefa - Cronometrar tempo de execução de cada parte.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 11, '4. Pós-Coleta - Parar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 12, '4. Pós-Coleta - Verificar qualidade dos dados coletados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA8'), 13, '4. Pós-Coleta - Salvar arquivos com nomenclatura: PXXX_TA08_RepX.csv');

-- ============================================================================
-- TA9: Escrever uma frase
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 1, '1. Identificação do Paciente - Registrar nome completo, idade, sexo e número de prontuário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 2, '1. Identificação do Paciente - Anotar lateralidade da doença (direita, esquerda ou bilateral).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 3, '1. Identificação do Paciente - Verificar e registrar o estágio na Escala de Hoehn & Yahr.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 4, '2. Preparação da Tarefa - Preparar papel e caneta para escrita.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 5, '2. Preparação da Tarefa - Posicionar paciente sentado confortavelmente à mesa.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 6, '2. Preparação da Tarefa - Explicar: "Escreva uma frase sobre seu dia".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 7, '3. Execução da Tarefa - Iniciar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 8, '3. Execução da Tarefa - Paciente escreve a frase com mão dominante.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 9, '3. Execução da Tarefa - Observar qualidade da escrita e micrografia.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 10, '3. Execução da Tarefa - Cronometrar tempo de escrita.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 11, '4. Pós-Coleta - Parar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 12, '4. Pós-Coleta - Verificar qualidade dos dados coletados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA9'), 13, '4. Pós-Coleta - Salvar arquivos com nomenclatura: PXXX_TA09_RepX.csv');

-- ============================================================================
-- TA10: Respiração
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 1, '1. Preparação Rápida - Ambiente silencioso, celular em modo avião, microfone a 10–20 cm da boca; paciente sentado, encosto reto.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 2, '1. Preparação Rápida - Utilizar um microfone de boa qualidade, preferencialmente de lapela.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 3, '1. Preparação Rápida - Fluxo sugerido de aplicação (15–20 min): Respiração → Fonação → Ressonância → Articulação → Prosódia → Diadococinesia.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 4, '1. Preparação Rápida - Para cada tarefa atribua uma nota geral entre 0–6 (0=ausência de distúrbio; 6=grave).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 5, '1. Preparação Rápida - Pausas: 1 minuto entre grandes blocos; 30 segundos entre vogais sustentadas.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 6, '2. Respiração - A. Frequência Respiratória - "Respire normalmente e fale por um minuto".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 7, '2. Respiração - A. Frequência Respiratória - Gravar 60 seg. (PID_01_Respiracao_01_FR.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 8, '2. Respiração - A. Frequência Respiratória - Contar quantidade de respirações realizadas.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 9, '2. Respiração - B. Tempo Máximo de Fonação - "Sustente /a/, /i/, /s/, /z/ máximo possível".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 10, '2. Respiração - B. Tempo Máximo de Fonação - Gravar cada vogal, repetir 3 vezes (PID_01_TMF_aisz_ciclo_N.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 11, '2. Respiração - B. Tempo Máximo de Fonação - Confirmar captura dos dados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 12, '2. Respiração - C. Palavras por Expiração - "Conte de 40 até 1 sem respirar".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 13, '2. Respiração - C. Palavras por Expiração - Registrar palavras por ciclo respiratório, 3 ciclos (PID_01_Contagem_40a1_ciclo_N.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 14, '2. Respiração - C. Palavras por Expiração - Confirmar captura dos dados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 15, '3. Observações Finais - Rótulo clínico da Respiração: 0–6 (0=normal; 6=grave).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 16, '3. Observações Finais - Registrar quaisquer intercorrências clínicas durante o protocolo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA10'), 17, '3. Observações Finais - Assinar e datar o checklist ao final da sessão.');

-- ============================================================================
-- TA11: Fonação verbal
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA11'), 1, '1. Preparação Rápida - Ambiente silencioso, celular em modo avião, microfone a 10–20 cm da boca; paciente sentado, encosto reto.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA11'), 2, '1. Preparação Rápida - Utilizar um microfone de boa qualidade, preferencialmente de lapela.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA11'), 3, '1. Preparação Rápida - Fluxo sugerido de aplicação (15–20 min): Respiração → Fonação → Ressonância → Articulação → Prosódia → Diadococinesia.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA11'), 4, '1. Preparação Rápida - Para cada tarefa atribua uma nota geral entre 0–6 (0=ausência de distúrbio; 6=grave).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA11'), 5, '1. Preparação Rápida - Pausas: 1 minuto entre grandes blocos; 30 segundos entre vogais sustentadas.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA11'), 6, '2. Fonação - A. Qualidade Vocal e Ataque - "Sustente /a/ em tom e intensidade confortáveis".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA11'), 7, '2. Fonação - A. Qualidade Vocal e Ataque - Repetir 3 vezes com /a/, /i/, /o/, /m/ (PID_02_Fonacao_01_sust_ciclo_N.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA11'), 8, '2. Fonação - A. Qualidade Vocal e Ataque - Rotular: Qualidade (normal/pastosa/trêmula/rouca/áspera/soprosa), Altura, Ataque, Intensidade, Estabilidade.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA11'), 9, '3. Observações Finais - Rótulos clínicos da fonação: 0–6 (0=normal; 6=grave).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA11'), 10, '3. Observações Finais - Registrar quaisquer intercorrências clínicas durante o protocolo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA11'), 11, '3. Observações Finais - Assinar e datar o checklist ao final da sessão.');

-- ============================================================================
-- TA12: Ressonância verbal
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 1, '1. Preparação Rápida - Ambiente silencioso, celular em modo avião, microfone a 10–20 cm da boca; paciente sentado, encosto reto.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 2, '1. Preparação Rápida - Utilizar um microfone de boa qualidade, preferencialmente de lapela.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 3, '1. Preparação Rápida - Fluxo sugerido de aplicação (15–20 min): Respiração → Fonação → Ressonância → Articulação → Prosódia → Diadococinesia.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 4, '1. Preparação Rápida - Para cada tarefa atribua uma nota geral entre 0–6 (0=ausência de distúrbio; 6=grave).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 5, '1. Preparação Rápida - Pausas: 1 minuto entre grandes blocos; 30 segundos entre vogais sustentadas.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 6, '2. Ressonância - A. Movimento Velar - "Alterne /a/ e /â/" (10s, PID_03_Ressonancia_01_a_â.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 7, '2. Ressonância - A. Movimento Velar - Anotar elevação do véu palatino: Adequada/Mínima/Ausente.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 8, '2. Ressonância - B. Movimentação Faríngea - "Repita ka ka ka" (10s, ..._ka_ka.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 9, '2. Ressonância - B. Movimentação Faríngea - Anotar movimentação da parede faríngea: Adequada/Mínima/Ausente.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 10, '2. Ressonância - C. Emissão Nasal - Falar frases específicas (..._Emissao_nasal_frases.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 11, '2. Ressonância - C. Emissão Nasal - Anotar nasalidade: Normal/Hipernasal/Hiponasal.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 12, '3. Observações Finais - Rótulo clínico Ressonância: 0–6.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 13, '3. Observações Finais - Registrar quaisquer intercorrências clínicas durante o protocolo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA12'), 14, '3. Observações Finais - Assinar e datar o checklist ao final da sessão.');

-- ============================================================================
-- TA13: Articulação verbal
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 1, '1. Preparação Rápida - Ambiente silencioso, celular em modo avião, microfone a 10–20 cm da boca; paciente sentado, encosto reto.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 2, '1. Preparação Rápida - Utilizar um microfone de boa qualidade, preferencialmente de lapela.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 3, '1. Preparação Rápida - Fluxo sugerido de aplicação (15–20 min): Respiração → Fonação → Ressonância → Articulação → Prosódia → Diadococinesia.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 4, '1. Preparação Rápida - Para cada tarefa atribua uma nota geral entre 0–6 (0=ausência de distúrbio; 6=grave).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 5, '1. Preparação Rápida - Pausas: 1 minuto entre grandes blocos; 30 segundos entre vogais sustentadas.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 6, '2. Articulação - A. Movimentos Orofaciais - Lábios: "i–u–pa" normal e exagerado (..._Labios_i_u_pa.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 7, '2. Articulação - A. Movimentos Orofaciais - Anotar movimento labial: Normal/Alterado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 8, '2. Articulação - B. Língua - "Alterne ka/ta velocidade crescente" (...Lingua_ka_ta_fast.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 9, '2. Articulação - B. Língua - Anotar movimento da língua: Normal/Alterado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 10, '2. Articulação - C. Mandíbula - "Abra e feche a boca".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 11, '2. Articulação - C. Mandíbula - Anotar abertura da mandíbula: Normal/Alterado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 12, '3. Leitura de Palavras - D. Plosivas (Banco, Tucano, Dedo, Panela, Porco, Gato, Batata, Tomate).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 13, '3. Leitura de Palavras - E. Fricativas (Janela, Vaso, Gilete, Vaca, Faca, Lanche, Sapo, Farinha, Chave, Chapéu, Fogão, Gema).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 14, '3. Leitura de Palavras - F. Vogais (A E I O U / Meia, Pia, Bóia, Baú).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 15, '3. Leitura de Palavras - G. Líquidas (Lápis, Milho, Lua, Olho, Bolo, Ilha).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 16, '3. Leitura de Palavras - H. Encontros Consonantais (Prato, Blusa, Flores, Fralda).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 17, '3. Leitura de Palavras - I. Frases ("Papai pediu pipoca", "A fita de filó é verde", "Amanhã mamãe amassará mamão").'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 18, '4. Diadococinesia - J. DDK - Repetir: pataka/badaga/fasacha em velocidades crescentes (PID_06_DDK_01_pataka_badaga_fasacha.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 19, '4. Diadococinesia - J. DDK - Anotar: Normal/Alterado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 20, '5. Observações Finais - Rótulo clínico Precisão articulatória: 0–6.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 21, '5. Observações Finais - Registrar quaisquer intercorrências clínicas durante o protocolo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA13'), 22, '5. Observações Finais - Assinar e datar o checklist ao final da sessão.');

-- ============================================================================
-- TA14: Prosódia verbal
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 1, '1. Preparação Rápida - Ambiente silencioso, celular em modo avião, microfone a 10–20 cm da boca; paciente sentado, encosto reto.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 2, '1. Preparação Rápida - Utilizar um microfone de boa qualidade, preferencialmente de lapela.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 3, '1. Preparação Rápida - Fluxo sugerido de aplicação (15–20 min): Respiração → Fonação → Ressonância → Articulação → Prosódia → Diadococinesia.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 4, '1. Preparação Rápida - Para cada tarefa atribua uma nota geral entre 0–6 (0=ausência de distúrbio; 6=grave).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 5, '1. Preparação Rápida - Pausas: 1 minuto entre grandes blocos; 30 segundos entre vogais sustentadas.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 6, '2. Prosódia - A. Afirmação - "É proibido fumar aqui" (PID_05_Prosodia_01_Afirmacao.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 7, '2. Prosódia - A. Afirmação - Anotar entonação: Normal/Alterado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 8, '2. Prosódia - A. Afirmação - Anotar velocidade: Normal/Alterado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 9, '2. Prosódia - A. Afirmação - Anotar pausas na fala: 0-6.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 10, '2. Prosódia - B. Interrogação - "Você gostaria de comprar bolo ou sorvete?" (…_02_Interrogacao.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 11, '2. Prosódia - B. Interrogação - Anotar entonação: Normal/Alterado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 12, '2. Prosódia - B. Interrogação - Anotar velocidade: Normal/Alterado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 13, '2. Prosódia - B. Interrogação - Anotar pausas na fala: 0-6.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 14, '2. Prosódia - C. Exclamação - "Maria chegou!" (…_03_Exclamacao.wav).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 15, '2. Prosódia - C. Exclamação - Anotar entonação: Normal/Alterado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 16, '2. Prosódia - C. Exclamação - Anotar velocidade: Normal/Alterado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 17, '2. Prosódia - C. Exclamação - Anotar pausas na fala: 0-6.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 18, '3. Observações Finais - Rótulo clínico Prosódia: 0–6.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 19, '3. Observações Finais - Registrar quaisquer intercorrências clínicas durante o protocolo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA14'), 20, '3. Observações Finais - Assinar e datar o checklist ao final da sessão.');

-- ============================================================================
-- TA15: Desempenho da marcha TC10
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 1, '1. Preparação do Equipamento - Certificar-se de que o equipamento G-WALK/Baiobit® esteja carregado e funcional.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 2, '1. Preparação do Equipamento - Verificar o pareamento Bluetooth com o notebook.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 3, '1. Preparação do Equipamento - Abrir o software Rivelo (BTS Bioengineering) e preparar para registro.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 4, '1. Preparação do Equipamento - Configurar a frequência de amostragem em 100 Hz.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 5, '1. Preparação do Equipamento - Confirmar a calibração do sistema.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 6, '2. Posicionamento do Sensor - Identificar a região lombossacral (L5–S1).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 7, '2. Posicionamento do Sensor - Fixar o sensor com cinto semielástico ajustado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 8, '2. Posicionamento do Sensor - Alinhar o sensor corretamente ao eixo corporal.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 9, '2. Posicionamento do Sensor - Garantir a estabilidade e o conforto do participante.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 10, '3. Preparação do Ambiente - Selecionar um piso plano, reto e bem iluminado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 11, '3. Preparação do Ambiente - Delimitar o percurso de 10 metros com marcações visuais.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 12, '3. Preparação do Ambiente - Remover obstáculos e possíveis distrações.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 13, '3. Preparação do Ambiente - Assegurar que iluminação e temperatura sejam adequadas.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 14, '4. Instruções ao Participante - Orientar a andar em linha reta na velocidade habitual.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 15, '4. Instruções ao Participante - Informar que não deve correr nem alterar o padrão natural de marcha.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 16, '4. Instruções ao Participante - Permitir um breve ensaio de familiarização, se necessário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 17, '4. Instruções ao Participante - Confirmar que o participante compreendeu as instruções.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 18, '5. Execução do Teste (TC10m) - Iniciar a gravação no software Rivelo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 19, '5. Execução do Teste (TC10m) - Solicitar que o participante percorra 10 metros em trajetória reta.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 20, '5. Execução do Teste (TC10m) - Repetir o teste três vezes (triplicata).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 21, '5. Execução do Teste (TC10m) - Oferecer intervalos curtos entre as tentativas.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 22, '5. Execução do Teste (TC10m) - Salvar os dados após cada execução.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 23, '6. Coleta e Processamento - Registrar os dados de aceleração e movimento em 100 Hz.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 24, '6. Coleta e Processamento - Confirmar a transmissão via Bluetooth.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 25, '6. Coleta e Processamento - Processar os dados automaticamente no Rivelo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 26, '6. Coleta e Processamento - Nomear e armazenar corretamente os arquivos gerados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 27, '7. Variáveis Medidas - Velocidade da marcha (m/s).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 28, '7. Variáveis Medidas - Cadência (passos/min).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 29, '7. Variáveis Medidas - Comprimento da passada (m).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 30, '7. Variáveis Medidas - Comprimento do passo (m).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 31, '7. Variáveis Medidas - Duração do passo (s).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 32, '7. Variáveis Medidas - Fase de suporte (% do ciclo).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 33, '7. Variáveis Medidas - Fase de balanço (% do ciclo).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 34, '7. Variáveis Medidas - Suporte individual (%).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 35, '7. Variáveis Medidas - Inclinações pélvicas (°).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 36, '8. Armazenamento e Análise - Salvar as três testagens individualmente por participante.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 37, '8. Armazenamento e Análise - Calcular médias e desvios-padrão das variáveis.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 38, '8. Armazenamento e Análise - Avaliar a consistência intra-sujeito.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA15'), 39, '8. Armazenamento e Análise - Gerar o relatório final de desempenho da marcha.');

-- ============================================================================
-- TA16: Congelamento de marcha FoGQ
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 1, '1. Identificação do Paciente - Registrar nome completo, idade, sexo e número de prontuário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 2, '1. Identificação do Paciente - Anotar lateralidade da doença (direita, esquerda ou bilateral).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 3, '1. Identificação do Paciente - Verificar e registrar o estágio na Escala de Hoehn & Yahr.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 4, '2. Preparação da Tarefa - Verificar espaço livre para manobras de marcha.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 5, '2. Preparação da Tarefa - Posicionar sensores de marcha (IMUs) nos pés e cintura.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 6, '2. Preparação da Tarefa - Explicar: "Caminhe e faça curvas, observe se há congelamento".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 7, '3. Execução da Tarefa - Iniciar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 8, '3. Execução da Tarefa - Paciente faz curvas de 90° e 180°.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 9, '3. Execução da Tarefa - Paciente passa por portas estreitas.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 10, '3. Execução da Tarefa - Observar presença de freezing of gait.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 11, '4. Pós-Coleta - Parar gravação dos sensores e vídeo.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 12, '4. Pós-Coleta - Verificar qualidade dos dados coletados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA16'), 13, '4. Pós-Coleta - Salvar arquivos com nomenclatura: PXXX_TA16_RepX.csv');

-- ============================================================================
-- TA17: Tremor das mãos via Delsys Trigno™
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 1, '1. Identificação do Paciente - Registrar nome completo, idade, sexo e número de prontuário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 2, '1. Identificação do Paciente - Anotar lateralidade da doença (direita, esquerda ou bilateral).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 3, '1. Identificação do Paciente - Verificar e registrar o estágio na Escala de Hoehn & Yahr.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 4, '2. Preparação da Tarefa - Posicionar sensores Delsys Trigno™ nos músculos das mãos.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 5, '2. Preparação da Tarefa - Posicionar paciente sentado com braços apoiados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 6, '2. Preparação da Tarefa - Explicar: "Mantenha as mãos em repouso, vamos medir o tremor".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 7, '3. Execução da Tarefa - Iniciar gravação dos sensores Delsys Trigno™.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 8, '3. Execução da Tarefa - Gravar tremor de repouso por 30 segundos.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 9, '3. Execução da Tarefa - Gravar tremor postural por 30 segundos.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 10, '3. Execução da Tarefa - Observar características do tremor registrado.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 11, '4. Pós-Coleta - Parar gravação dos sensores.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 12, '4. Pós-Coleta - Verificar qualidade dos dados coletados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA17'), 13, '4. Pós-Coleta - Salvar arquivos com nomenclatura: PXXX_TA17_RepX.csv');

-- ============================================================================
-- TA18: Bradicinesia via Delsys Trigno™
-- ============================================================================

INSERT INTO task_checklist_items (task_id, item_order, item_description) VALUES
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 1, '1. Identificação do Paciente - Registrar nome completo, idade, sexo e número de prontuário.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 2, '1. Identificação do Paciente - Anotar lateralidade da doença (direita, esquerda ou bilateral).'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 3, '1. Identificação do Paciente - Verificar e registrar o estágio na Escala de Hoehn & Yahr.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 4, '2. Preparação da Tarefa - Posicionar sensores Delsys Trigno™ nos músculos das mãos.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 5, '2. Preparação da Tarefa - Posicionar paciente sentado com braços apoiados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 6, '2. Preparação da Tarefa - Explicar: "Faça movimentos rápidos com os dedos".'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 7, '3. Execução da Tarefa - Iniciar gravação dos sensores Delsys Trigno™.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 8, '3. Execução da Tarefa - Gravar finger tapping por 10 segundos.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 9, '3. Execução da Tarefa - Gravar pronação-supinação por 10 segundos.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 10, '3. Execução da Tarefa - Observar características da bradicinesia.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 11, '4. Pós-Coleta - Parar gravação dos sensores.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 12, '4. Pós-Coleta - Verificar qualidade dos dados coletados.'),
((SELECT id FROM active_task_definitions WHERE task_code = 'TA18'), 13, '4. Pós-Coleta - Salvar arquivos com nomenclatura: PXXX_TA18_RepX.csv');

-- ============================================================================
-- FIM DOS INSERTS
-- ============================================================================
