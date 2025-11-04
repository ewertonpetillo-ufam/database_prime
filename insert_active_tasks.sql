-- ============================================================================
-- INSERTS PARA TAREFAS ATIVAS DO SISTEMA PRIME
-- ============================================================================
-- Este arquivo contém os dados iniciais das 18 tarefas ativas e seus
-- respectivos itens de checklist conforme implementado no frontend
-- ============================================================================

-- ============================================================================
-- TAREFAS ATIVAS - CATEGORIA: MOTOR (Stage 1)
-- ============================================================================

-- TA1: Mãos em repouso
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA1',
    'Mãos em repouso',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'BILATERAL'),
    1,
    'Avaliação de tremor de repouso nas mãos. O paciente deve manter as mãos em repouso sobre as coxas enquanto é observada a presença, intensidade e características do tremor. Duração recomendada: 30-60 segundos.',
    'Posicione-se sentado confortavelmente com os braços apoiados e mantenha as mãos em repouso sobre as coxas. Permaneça relaxado durante toda a coleta.',
    TRUE
);

-- TA2: Dedo ao nariz
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA2',
    'Dedo ao nariz',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'BILATERAL'),
    1,
    'Teste de coordenação motora e precisão. Avalia a capacidade de realizar movimentos direcionados alternando as mãos. Observa-se precisão, velocidade e coordenação do movimento. Mínimo de 5 repetições por mão.',
    'Posicione-se sentado com o braço estendido à frente. Toque o nariz com o dedo indicador, alternando as mãos. Execute pelo menos 5 repetições com cada mão.',
    TRUE
);

-- TA3: Pronação e supinação das mãos
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA3',
    'Pronação e supinação das mãos',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'BILATERAL'),
    1,
    'Avaliação de movimentos rotatórios das mãos em três velocidades diferentes (lenta, moderada e rápida). Cada velocidade deve ser executada por 10 repetições. Permite avaliar bradicinesia e rigidez.',
    'Posicione-se sentado com os antebraços apoiados. Faça movimentos de pronação e supinação das mãos em três velocidades: lenta (10 repetições), moderada (10 repetições) e rápida (10 repetições).',
    TRUE
);

-- TA4: Toque alternado dos dedos
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA4',
    'Toque alternado dos dedos',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'BILATERAL'),
    1,
    'Teste de destreza manual (finger tapping). O paciente deve tocar alternadamente o polegar com os outros dedos em sequência. Avalia coordenação fina, velocidade e amplitude dos movimentos. Executa-se com cada mão individualmente e depois bilateralmente.',
    'Posicione-se sentado com as mãos sobre a mesa. Toque alternadamente o polegar com os outros dedos (indicador, médio, anelar, mínimo). Execute 10 ciclos com a mão direita, 10 com a esquerda e depois simultaneamente com ambas as mãos.',
    TRUE
);

-- TA5: Time Up and Go (TUG)
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA5',
    'Time Up and Go (TUG)',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'UNDEFINED'),
    1,
    'Teste funcional de mobilidade e equilíbrio. Avalia o tempo necessário para levantar de uma cadeira, caminhar 3 metros, virar, retornar e sentar novamente. Requer espaço livre de 3 metros e cadeira padronizada.',
    'Sente-se confortavelmente na cadeira. Ao sinal, levante-se, caminhe 3 metros em linha reta, vire-se, retorne e sente-se novamente na cadeira. Execute em sua velocidade habitual de caminhada.',
    TRUE
);

-- TA6: Movimentos alternados dos dedos
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA6',
    'Movimentos alternados dos dedos',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'BILATERAL'),
    1,
    'Avaliação de tapping digital em diferentes velocidades. O paciente realiza movimentos alternados rápidos dos dedos (finger tapping) em três velocidades: lenta, moderada e rápida. Cada velocidade é mantida por 10 segundos.',
    'Posicione-se sentado com as mãos sobre a mesa. Faça movimentos alternados dos dedos (tapping) em três velocidades: lenta (10 segundos), moderada (10 segundos) e rápida (10 segundos).',
    TRUE
);

-- TA7: Movimento em espiral
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA7',
    'Movimento em espiral',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'BILATERAL'),
    1,
    'Teste de coordenação grafomotora. O paciente desenha espirais com cada mão para avaliar tremor, precisão do traçado e coordenação. Diâmetro recomendado: 10cm. Executa-se com mão dominante e não dominante.',
    'Posicione-se sentado confortavelmente à mesa com papel e caneta. Desenhe uma espiral com diâmetro de aproximadamente 10cm, primeiro com a mão dominante e depois com a mão não dominante.',
    TRUE
);

-- TA8: Teste de trilhas
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA8',
    'Teste de trilhas',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'UNDEFINED'),
    1,
    'Trail Making Test (TMT) - avaliação de função executiva, atenção e flexibilidade cognitiva. Aplicado em duas partes (A e B) com cronometragem individual. Requer material específico do protocolo TMT.',
    'Siga as instruções específicas do Trail Making Test conforme o protocolo. Na parte A, conecte os números em ordem crescente. Na parte B, alterne entre números e letras em sequência.',
    TRUE
);

-- TA9: Escrever uma frase
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA9',
    'Escrever uma frase',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'UNILATERAL'),
    1,
    'Avaliação de escrita manual para detecção de micrografia (diminuição progressiva do tamanho das letras) e qualidade da grafia. O paciente escreve uma frase com a mão dominante enquanto se cronometra o tempo de execução.',
    'Posicione-se sentado confortavelmente à mesa com papel e caneta. Escreva uma frase sobre seu dia usando sua mão dominante. Escreva de forma natural, sem pressa.',
    TRUE
);

-- ============================================================================
-- TAREFAS ATIVAS - CATEGORIA: SPEECH (Stage 2)
-- ============================================================================

-- TA10: Respiração
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA10',
    'Respiração',
    'SPEECH',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'UNDEFINED'),
    2,
    'Avaliação completa do sistema respiratório aplicado à fala. Inclui três subtestes: (A) Frequência Respiratória durante fala espontânea de 60 segundos; (B) Tempo Máximo de Fonação (TMF) sustentando vogais /a/, /i/, /s/ e /z/ em 3 ciclos; (C) Palavras por Expiração contando de 40 a 1 em 3 ciclos. Requer ambiente silencioso e microfone de qualidade.',
    'Ambiente silencioso, microfone a 10-20cm da boca. (A) Respire normalmente e fale por 1 minuto; (B) Sustente cada som (/a/, /i/, /s/, /z/) pelo máximo de tempo possível, repetir 3 vezes; (C) Conte de 40 até 1 sem respirar, repetir 3 vezes.',
    TRUE
);

-- TA11: Fonação verbal
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA11',
    'Fonação verbal',
    'SPEECH',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'UNDEFINED'),
    2,
    'Avaliação da qualidade vocal e ataque vocal. O paciente sustenta vogais /a/, /i/, /o/ e /m/ em tom e intensidade confortáveis. Repetir o ciclo 3 vezes. Avalia-se: qualidade (normal, pastosa, trêmula, rouca, áspera, soprosa), altura, ataque vocal (isocrônico, brusco, aspirado), intensidade e estabilidade.',
    'Sustente os sons /a/, /i/, /o/ e /m/ em tom e intensidade confortáveis até conseguir. Repetir o ciclo três vezes. Mantenha o som estável durante toda a emissão.',
    TRUE
);

-- TA12: Ressonância verbal
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA12',
    'Ressonância verbal',
    'SPEECH',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'UNDEFINED'),
    2,
    'Avaliação do sistema ressonantal em três aspectos: (A) Movimento Velar alternando /a/ e /â/ por 10 segundos; (B) Movimentação Faríngea repetindo "ka ka ka" por 10 segundos; (C) Emissão Nasal com frases específicas. Avalia adequação do véu palatino, parede faríngea e nasalidade (normal, hipernasal, hiponasal).',
    'Execute: (A) Alterne /a/ e /â/ por 10 segundos; (B) Repita "ka ka ka" regularmente por 10 segundos; (C) Fale as frases: "Mamão papai", "pau mau", "Vovó viu a uva", "Papai pediu pipoca", "A fita de filó é verde", "Amanhã mamãe amassará mamão".',
    TRUE
);

-- TA13: Articulação verbal
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA13',
    'Articulação verbal',
    'SPEECH',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'UNDEFINED'),
    2,
    'Avaliação completa da precisão articulatória. Inclui: movimentos orofaciais (lábios, língua, mandíbula), leitura de palavras organizadas por classe fonética (plosivas, fricativas, vogais, líquidas, encontros consonantais), frases complexas e teste de Diadococinesia (DDK) com sequências pataka/badaga/fasacha em velocidades crescentes.',
    'Execute os movimentos solicitados (lábios: i-u-pa; língua: ka/ta rápido; mandíbula: abrir/fechar) e leia as palavras e frases apresentadas. Finalize com as sequências rápidas: pataka, badaga, fasacha.',
    TRUE
);

-- TA14: Prosódia verbal
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA14',
    'Prosódia verbal',
    'SPEECH',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'UNDEFINED'),
    2,
    'Avaliação da fluência e prosódia da fala através de três tipos de entonação: (A) Afirmação: "É proibido fumar aqui"; (B) Interrogação: "Você gostaria de comprar bolo ou sorvete?"; (C) Exclamação: "Maria chegou!". Para cada frase avalia-se entonação, velocidade e pausas na fala (escala 0-6).',
    'Repita as frases com a entonação adequada: (A) "É proibido fumar aqui" (afirmação); (B) "Você gostaria de comprar bolo ou sorvete?" (pergunta); (C) "Maria chegou!" (exclamação).',
    TRUE
);

-- ============================================================================
-- TAREFAS ATIVAS - CATEGORIA: GAIT (Stage 3)
-- ============================================================================

-- TA15: Desempenho da marcha TC10
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA15',
    'Desempenho da marcha TC10',
    'GAIT',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'UNDEFINED'),
    3,
    'Teste de Caminhada de 10 metros (TC10m) utilizando sensor inercial G-WALK/Baiobit® posicionado em L5-S1. Avalia variáveis espaço-temporais da marcha: velocidade, cadência, comprimento de passada e passo, fases de suporte e balanço, inclinações pélvicas. Frequência de amostragem: 100 Hz. Executado em triplicata com intervalos entre tentativas.',
    'Caminhe em linha reta por 10 metros em sua velocidade habitual. Não corra nem altere seu padrão natural de caminhada. O teste será repetido 3 vezes com pequenos intervalos de descanso.',
    TRUE
);

-- TA16: Congelamento de marcha FoGQ
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA16',
    'Congelamento de marcha FoGQ',
    'GAIT',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'UNDEFINED'),
    3,
    'Avaliação de Freezing of Gait (FoGQ) - episódios de congelamento da marcha. O paciente realiza manobras específicas que podem desencadear congelamento: curvas de 90° e 180°, passagem por portas estreitas. Utiliza sensores IMU nos pés e cintura para detectar episódios de freezing.',
    'Caminhe normalmente e execute curvas de 90° e 180°. Passe por portas estreitas conforme orientação. Caso sinta bloqueio ou congelamento da marcha, mantenha-se seguro e aguarde orientação.',
    TRUE
);

-- TA17: Tremor das mãos via Delsys Trigno™
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA17',
    'Tremor das mãos via Delsys Trigno™',
    'GAIT',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'BILATERAL'),
    3,
    'Avaliação quantitativa de tremor das mãos utilizando sensores eletromiográficos Delsys Trigno™. Os sensores são posicionados nos músculos das mãos para mensurar tremor de repouso (30 segundos) e tremor postural (30 segundos). Permite análise de frequência, amplitude e características do tremor.',
    'Mantenha as mãos em repouso sobre as coxas por 30 segundos. Em seguida, estenda os braços à frente mantendo posição postural por mais 30 segundos. Permaneça o mais relaxado possível.',
    TRUE
);

-- TA18: Bradicinesia via Delsys Trigno™
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA18',
    'Bradicinesia via Delsys Trigno™',
    'GAIT',
    (SELECT id FROM collection_form_types WHERE form_type_name = 'BILATERAL'),
    3,
    'Avaliação quantitativa de bradicinesia (lentidão de movimentos) utilizando sensores eletromiográficos Delsys Trigno™. Mensura-se a atividade muscular durante finger tapping (10 segundos) e movimentos de pronação-supinação (10 segundos). Permite quantificar velocidade, amplitude e decremento de amplitude dos movimentos.',
    'Execute movimentos rápidos com os dedos (finger tapping) por 10 segundos. Em seguida, realize movimentos de pronação e supinação das mãos por 10 segundos. Mantenha a maior velocidade e amplitude possível.',
    TRUE
);
