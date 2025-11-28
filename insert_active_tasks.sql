-- ============================================================================
-- INSERTS PARA TAREFAS ATIVAS DO SISTEMA PRIME
-- ============================================================================
-- Este arquivo contém os dados iniciais das 17 tarefas ativas e seus
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
    (SELECT id FROM collection_form_types WHERE code = 'BILATERAL_SYNC'),
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
    (SELECT id FROM collection_form_types WHERE code = 'BILATERAL'),
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
    (SELECT id FROM collection_form_types WHERE code = 'BILATERAL'),
    1,
    'Avaliação de movimentos rotatórios das mãos em três velocidades diferentes (lenta, moderada e rápida). Cada velocidade deve ser executada por 10 repetições. Permite avaliar bradicinesia e rigidez.',
    'Posicione-se sentado com os antebraços apoiados. Faça movimentos de pronação e supinação das mãos em três velocidades: lenta (10 repetições), moderada (10 repetições) e rápida (10 repetições).',
    TRUE
);

-- TA4: Toque dos dedos
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA4',
    'Toque dos dedos',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE code = 'BILATERAL'),
    1,
    'Teste de destreza manual (finger tapping). O paciente deve tocar alternadamente o polegar com os outros dedos em sequência. Avalia coordenação fina, velocidade e amplitude dos movimentos. Executa-se com cada mão individualmente e depois bilateralmente.',
    'Posicione-se sentado com as mãos sobre a mesa. Toque alternadamente o polegar com os outros dedos (indicador, médio, anelar, mínimo). Execute 10 ciclos com a mão direita, 10 com a esquerda e depois simultaneamente com ambas as mãos.',
    TRUE
);

-- TA5: Levantar e caminhar cronometrado (TUG)
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA5',
    'Levantar e caminhar cronometrado (TUG)',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE code = 'BILATERAL_SYNC'),
    1,
    'Teste funcional de mobilidade e equilíbrio. Avalia o tempo necessário para levantar de uma cadeira, caminhar 3 metros, virar, retornar e sentar novamente. Requer espaço livre de 3 metros e cadeira padronizada.',
    'Sente-se confortavelmente na cadeira. Ao sinal, levante-se, caminhe 3 metros em linha reta, vire-se, retorne e sente-se novamente na cadeira. Execute em sua velocidade habitual de caminhada.',
    TRUE
);

-- TA6: Movimento alternado dos dedos
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA6',
    'Movimento alternado dos dedos',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE code = 'UNDEFINED'),
    1,
    'Avaliação de tapping digital em diferentes velocidades. O paciente realiza movimentos alternados rápidos dos dedos (finger tapping) em três velocidades: lenta, moderada e rápida. Cada velocidade é mantida por 10 segundos.',
    'Posicione-se sentado com as mãos sobre a mesa. Faça movimentos alternados dos dedos (tapping) em três velocidades: lenta (10 segundos), moderada (10 segundos) e rápida (10 segundos).',
    TRUE
);

-- TA7: Movimento quasi-circular
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA7',
    'Movimento quasi-circular',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE code = 'UNDEFINED'),
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
    (SELECT id FROM collection_form_types WHERE code = 'UNDEFINED'),
    1,
    'Trail Making Test (TMT) - avaliação de função executiva, atenção e flexibilidade cognitiva. Aplicado em duas partes (A e B) com cronometragem individual. Requer material específico do protocolo TMT.',
    'Siga as instruções específicas do Trail Making Test conforme o protocolo. Na parte A, conecte os números em ordem crescente. Na parte B, alterne entre números e letras em sequência.',
    TRUE
);

-- TA9: Escrever uma sentença
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA9',
    'Escrever uma sentença',
    'MOTOR',
    (SELECT id FROM collection_form_types WHERE code = 'UNDEFINED'),
    1,
    'Avaliação de escrita manual para detecção de micrografia (diminuição progressiva do tamanho das letras) e qualidade da grafia. O paciente escreve uma frase com a mão dominante enquanto se cronometra o tempo de execução.',
    'Posicione-se sentado confortavelmente à mesa com papel e caneta. Escreva uma frase sobre seu dia usando sua mão dominante. Escreva de forma natural, sem pressa.',
    TRUE
);

-- ============================================================================
-- TAREFAS ATIVAS - CATEGORIA: SPEECH (Stage 2)
-- ============================================================================

-- TA10: Diadococinesia
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA10',
    'Diadococinesia',
    'SPEECH',
    (SELECT id FROM collection_form_types WHERE code = 'UNDEFINED'),
    2,
    'Avaliação de diadococinesia (DDK) - capacidade de realizar movimentos rápidos e alternados dos órgãos fonoarticulatórios. Inclui repetição de sequências: /papapa/, /tatata/, /kakaka/, /pataka/. Cada sequência deve ser repetida 3 vezes, com aproximadamente 7 segundos por repetição.',
    'Respire fundo e emita cada som o mais longo e rápido que puder. Repita as sequências: /papapa/, /tatata/, /kakaka/, /pataka/. Execute 3 repetições de cada sequência.',
    TRUE
);

-- TA11: Fonação sustentada
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA11',
    'Fonação sustentada',
    'SPEECH',
    (SELECT id FROM collection_form_types WHERE code = 'UNDEFINED'),
    2,
    'Avaliação da qualidade vocal e ataque vocal através de fonação sustentada. O paciente sustenta vogais /a/, /e/, /i/, /o/, /u/ e nasal /m/ em tom e intensidade confortáveis. Cada som deve ser sustentado por até 10 segundos, repetindo o ciclo 3 vezes. Avalia-se: qualidade (normal, pastosa, trêmula, rouca, áspera, soprosa), altura, ataque vocal (isocrônico, brusco, aspirado), intensidade e estabilidade.',
    'Inspire normalmente e sustente cada som o máximo que conseguir, em tom confortável. Sustente os sons: /a/, /e/, /i/, /o/, /u/, /m/. Repetir o ciclo três vezes. Mantenha o som estável durante toda a emissão.',
    TRUE
);

-- TA12: Leitura de texto
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA12',
    'Leitura de texto',
    'SPEECH',
    (SELECT id FROM collection_form_types WHERE code = 'UNDEFINED'),
    2,
    'Avaliação da leitura de texto com análise de prosódia em três níveis: (1) Prosodia Palavras - análise da entonação e ritmo em nível de palavras; (2) Prosodia Frases - análise da entonação e ritmo em nível de frases; (3) Prosodia Texto - análise da entonação e ritmo em nível de texto completo. O paciente lê um texto completo em ritmo natural.',
    'Respire fundo e leia o texto completo em ritmo natural. O texto será: "Um homem velho que vivia sozinho há muito tempo, não suportava crianças. Ele morava numa casa grande e mantinha uma vara de bambu ao alcance de sua mão, com a qual ameaçava as crianças de um prédio do BNH vizinho. Um dia, quando ele estava destruindo um ninho de pardais, ficou preso, sobre o telhado alto de três metros e cinquenta. Isso porque, querendo descer muito rápido, deixou cair a escada que tinha colocado mal equilibrada contra a parede do sobrado. Como o homem começou logo a gritar, um garoto corajoso, que brincava calmamente na rua, levantou a cabeça, compreendeu a situação e recolocou a escada caída no chão ao lado de uma roseira. Depois dessa vergonhosa aventura, ele ofereceu ao menino um lanche acompanhado de um suco de maçã."',
    TRUE
);

-- TA13: Polissonografia
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA13',
    'Polissonografia',
    'SPEECH',
    (SELECT id FROM collection_form_types WHERE code = 'UNILATERAL'),
    2,
    'Avaliação polissonográfica para análise do sono. Exame não invasivo que monitora múltiplos parâmetros fisiológicos durante o sono, incluindo atividade cerebral (EEG), movimentos oculares (EOG), atividade muscular (EMG), respiração, saturação de oxigênio e posição corporal.',
    'Siga as instruções do técnico para a preparação e realização do exame de polissonografia. O exame será realizado durante a noite, monitorando diversos parâmetros do sono.',
    TRUE
);

-- ============================================================================
-- TAREFAS ATIVAS - CATEGORIA: GAIT (Stage 3)
-- ============================================================================

-- TA14: Desempenho de marcha — Baiobit™
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA14',
    'Desempenho de marcha — Baiobit™',
    'GAIT',
    (SELECT id FROM collection_form_types WHERE code = 'BILATERAL_SYNC'),
    3,
    'Teste de Caminhada de 10 metros (TC10m) utilizando sensor inercial G-WALK/Baiobit® posicionado em L5-S1. Avalia variáveis espaço-temporais da marcha: velocidade, cadência, comprimento de passada e passo, fases de suporte e balanço, inclinações pélvicas. Frequência de amostragem: 100 Hz. Executado em triplicata com intervalos entre tentativas.',
    'Caminhe em linha reta por 10 metros em sua velocidade habitual. Não corra nem altere seu padrão natural de caminhada. O teste será repetido 3 vezes com pequenos intervalos de descanso.',
    TRUE
);

-- TA15: Congelamento de marcha — Baiobit™
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA15',
    'Congelamento de marcha — Baiobit™',
    'GAIT',
    (SELECT id FROM collection_form_types WHERE code = 'BILATERAL_SYNC'),
    3,
    'Avaliação de Freezing of Gait (FoGQ) - episódios de congelamento da marcha utilizando sensor inercial G-WALK/Baiobit®. O paciente realiza manobras específicas que podem desencadear congelamento: curvas de 90° e 180°, passagem por portas estreitas. Utiliza sensores IMU nos pés e cintura para detectar episódios de freezing.',
    'Caminhe normalmente e execute curvas de 90° e 180°. Passe por portas estreitas conforme orientação. Caso sinta bloqueio ou congelamento da marcha, mantenha-se seguro e aguarde orientação.',
    TRUE
);

-- TA16: Tremor das mãos — Delsys Trigno™
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA16',
    'Tremor das mãos — Delsys Trigno™',
    'GAIT',
    (SELECT id FROM collection_form_types WHERE code = 'BILATERAL_SYNC'),
    3,
    'Avaliação quantitativa de tremor das mãos utilizando sensores eletromiográficos Delsys Trigno™. Os sensores são posicionados nos músculos das mãos para mensurar tremor de repouso (30 segundos) e tremor postural (30 segundos). Permite análise de frequência, amplitude e características do tremor.',
    'Mantenha as mãos em repouso sobre as coxas por 30 segundos. Em seguida, estenda os braços à frente mantendo posição postural por mais 30 segundos. Permaneça o mais relaxado possível.',
    TRUE
);

-- TA17: Bradicinesia — Delsys Trigno™
INSERT INTO active_task_definitions (task_code, task_name, task_category, collection_form_type_id, stage, description, instructions, active)
VALUES (
    'TA17',
    'Bradicinesia — Delsys Trigno™',
    'GAIT',
    (SELECT id FROM collection_form_types WHERE code = 'BILATERAL'),
    3,
    'Avaliação quantitativa de bradicinesia (lentidão de movimentos) utilizando sensores eletromiográficos Delsys Trigno™. Mensura-se a atividade muscular durante finger tapping (10 segundos) e movimentos de pronação-supinação (10 segundos). Permite quantificar velocidade, amplitude e decremento de amplitude dos movimentos.',
    'Execute movimentos rápidos com os dedos (finger tapping) por 10 segundos. Em seguida, realize movimentos de pronação e supinação das mãos por 10 segundos. Mantenha a maior velocidade e amplitude possível.',
    TRUE
);

