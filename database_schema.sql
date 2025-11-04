-- ============================================================================
-- DATABASE SCHEMA FOR PARKINSON'S DISEASE CLINICAL ASSESSMENT SYSTEM
-- ============================================================================
--
-- Description: Comprehensive database schema for managing Parkinson's disease
--              clinical assessments, patient data, and motor task collections
--
-- Key Features:
-- - HIPAA-compliant patient data anonymization (CPF stored as HMAC hash)
-- - Full normalization (3NF) following database best practices
-- - Support for binary CSV storage from collector app
-- - Audit trail for all critical operations
-- - Referential integrity with cascading rules
-- - Indexes for optimal query performance
--
-- ============================================================================

-- Extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Extension for cryptographic functions (if needed for additional security)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- DOMAIN TABLES (Reference Data / Enumerations)
-- ============================================================================

-- Gender reference
CREATE TABLE gender_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    description VARCHAR(50) NOT NULL,
    active BOOLEAN DEFAULT TRUE
);

INSERT INTO gender_types (code, description) VALUES
    ('M', 'Masculino'),
    ('F', 'Feminino'),
    ('OTHER', 'Outro');

-- Ethnicity reference
CREATE TABLE ethnicity_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    description VARCHAR(50) NOT NULL,
    active BOOLEAN DEFAULT TRUE
);

INSERT INTO ethnicity_types (code, description) VALUES
    ('WHITE', 'Branco'),
    ('BLACK', 'Negro'),
    ('BROWN', 'Pardo'),
    ('ASIAN', 'Amarelo'),
    ('INDIGENOUS', 'Indígena'),
    ('OTHER', 'Outro');

-- Education level reference
CREATE TABLE education_levels (
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) UNIQUE NOT NULL,
    description VARCHAR(100) NOT NULL,
    years_equivalent INTEGER,
    active BOOLEAN DEFAULT TRUE
);

INSERT INTO education_levels (code, description, years_equivalent) VALUES
    ('ILLITERATE', 'Analfabeto', 0),
    ('ELEMENTARY_INCOMPLETE', 'Ensino Fundamental Incompleto', 4),
    ('ELEMENTARY_COMPLETE', 'Ensino Fundamental Completo', 9),
    ('HIGH_SCHOOL_INCOMPLETE', 'Ensino Médio Incompleto', 10),
    ('HIGH_SCHOOL_COMPLETE', 'Ensino Médio Completo', 12),
    ('COLLEGE_INCOMPLETE', 'Ensino Superior Incompleto', 14),
    ('COLLEGE_COMPLETE', 'Ensino Superior Completo', 16),
    ('POST_GRADUATE', 'Pós-Graduação', 18),
    ('OTHER', 'Outro', NULL);

-- Marital status reference
CREATE TABLE marital_status_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    description VARCHAR(50) NOT NULL,
    active BOOLEAN DEFAULT TRUE
);

INSERT INTO marital_status_types (code, description) VALUES
    ('SINGLE', 'Solteiro'),
    ('MARRIED', 'Casado'),
    ('DOMESTIC_PARTNERSHIP', 'União estável'),
    ('PREFER_NOT_SAY', 'Prefere não informar');

-- Income range reference
CREATE TABLE income_ranges (
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) UNIQUE NOT NULL,
    description VARCHAR(100) NOT NULL,
    min_salary DECIMAL(5,2),
    max_salary DECIMAL(5,2),
    active BOOLEAN DEFAULT TRUE
);

INSERT INTO income_ranges (code, description, min_salary, max_salary) VALUES
    ('UP_TO_1', 'Até 1 salário mínimo', 0, 1),
    ('2_TO_4', '2 a 4 salários mínimos', 2, 4),
    ('4_PLUS', '4 salários mínimos ou mais', 4, NULL);

-- Parkinson phenotypes
CREATE TABLE parkinson_phenotypes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) UNIQUE NOT NULL,
    description VARCHAR(100) NOT NULL,
    active BOOLEAN DEFAULT TRUE
);

INSERT INTO parkinson_phenotypes (code, description) VALUES
    ('TREMOR_DOMINANT', 'Tremulante'),
    ('FREEZING_GAIT', 'Fenótipo de Congelamento de Marcha'),
    ('RIGID_AKINETIC', 'Rígido Assintótico');

-- Hoehn-Yahr scale
CREATE TABLE hoehn_yahr_scale (
    id SERIAL PRIMARY KEY,
    stage DECIMAL(2,1) UNIQUE NOT NULL,
    description TEXT NOT NULL
);

INSERT INTO hoehn_yahr_scale (stage, description) VALUES
    (0, 'Sem sinais de doença'),
    (1, 'Doença unilateral'),
    (1.5, 'Envolvimento unilateral e axial'),
    (2, 'Doença bilateral sem comprometimento de equilíbrio'),
    (2.5, 'Doença bilateral leve, com recuperação no teste de retropulsão'),
    (3, 'Doença bilateral leve a moderada; alguma instabilidade postural; independente fisicamente'),
    (4, 'Incapacidade grave, ainda capaz de caminhar ou permanecer de pé sem ajuda'),
    (5, 'Confinado à cama ou cadeira de rodas a menos que receba ajuda');

-- Dyskinesia classification
CREATE TABLE dyskinesia_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    description VARCHAR(100) NOT NULL
);

INSERT INTO dyskinesia_types (code, description) VALUES
    ('PEAK_DOSE', 'Pico de dose'),
    ('BIPHASIC', 'Bifásicas'),
    ('OFF_DYSTONIA', 'OFF (Distonias)');

-- Medications reference with LED conversion factors
CREATE TABLE medications_reference (
    id SERIAL PRIMARY KEY,
    drug_name VARCHAR(100) UNIQUE NOT NULL,
    generic_name VARCHAR(100),
    led_conversion_factor DECIMAL(6,3) NOT NULL DEFAULT 1.0,
    medication_class VARCHAR(50),
    active BOOLEAN DEFAULT TRUE,
    notes TEXT
);

INSERT INTO medications_reference (drug_name, generic_name, led_conversion_factor, medication_class) VALUES
    ('Levodopa', 'Levodopa', 1.0, 'Levodopa'),
    ('Sinemet', 'Carbidopa/Levodopa', 1.0, 'Levodopa'),
    ('Prolopa', 'Benserazida/Levodopa', 1.0, 'Levodopa'),
    ('Mirapex', 'Pramipexole', 100.0, 'Dopamine Agonist'),
    ('Sifrol', 'Pramipexole', 100.0, 'Dopamine Agonist'),
    ('Requip', 'Ropinirole', 20.0, 'Dopamine Agonist'),
    ('Neupro', 'Rotigotine', 30.0, 'Dopamine Agonist'),
    ('Cabaser', 'Cabergoline', 100.0, 'Dopamine Agonist'),
    ('Parlodel', 'Bromocriptine', 10.0, 'Dopamine Agonist'),
    ('Azilect', 'Rasagiline', 100.0, 'MAO-B Inhibitor'),
    ('Xadago', 'Safinamide', 100.0, 'MAO-B Inhibitor'),
    ('Jumex', 'Selegiline', 10.0, 'MAO-B Inhibitor'),
    ('Mantidan', 'Amantadine', 1.0, 'NMDA Antagonist'),
    ('Comtan', 'Entacapone', 0.33, 'COMT Inhibitor'),
    ('Tasmar', 'Tolcapone', 0.5, 'COMT Inhibitor'),
    ('Ongentys', 'Opicapone', 0.5, 'COMT Inhibitor'),
    ('Nuplazid', 'Pimavanserin', 0.0, 'Antipsychotic'),
    ('Quetiapina', 'Quetiapine', 0.0, 'Antipsychotic'),
    ('Clozapina', 'Clozapine', 0.0, 'Antipsychotic'),
    ('Artane', 'Trihexyphenidyl', 0.0, 'Anticholinergic'),
    ('Akineton', 'Biperiden', 0.0, 'Anticholinergic'),
    ('Apokyn', 'Apomorphine', 10.0, 'Dopamine Agonist'),
    ('Duopa', 'Carbidopa/Levodopa Gel', 1.0, 'Levodopa'),
    ('Stalevo', 'Carbidopa/Levodopa/Entacapone', 1.33, 'Levodopa + COMT'),
    ('Rytary', 'Carbidopa/Levodopa ER', 1.0, 'Levodopa'),
    ('Inbrija', 'Levodopa Inhalation', 1.0, 'Levodopa'),
    ('Nourianz', 'Istradefylline', 0.0, 'Adenosine Antagonist'),
    ('Kynmobi', 'Apomorphine Sublingual', 10.0, 'Dopamine Agonist');

-- Surgery types
CREATE TABLE surgery_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    description VARCHAR(100) NOT NULL,
    active BOOLEAN DEFAULT TRUE
);

INSERT INTO surgery_types (code, description) VALUES
    ('DBS', 'Deep Brain Stimulation (DBS)'),
    ('LESION', 'Lesional Surgery'),
    ('OTHER', 'Outro');

-- Task collection types
CREATE TABLE collection_form_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) UNIQUE NOT NULL,
    description VARCHAR(100) NOT NULL
);

INSERT INTO collection_form_types (code, description) VALUES
    ('BILATERAL_SYNC', 'BILATERAL SINCRONIZADO'),
    ('BILATERAL', 'BILATERAL'),
    ('UNILATERAL', 'UNILATERAL'),
    ('UNDEFINED', 'NÃO DEFINIDO');

-- ============================================================================
-- CORE ENTITY TABLES
-- ============================================================================
-- User for authentication and authorization / Evaluators and Researchers
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'evaluator',
    registration_number VARCHAR(50) UNIQUE,
    specialty VARCHAR(100),
    phone VARCHAR(20),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices recomendados para melhor performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(active);
CREATE INDEX idx_users_registration_number ON users(registration_number);

-- Constraint para validar os papéis permitidos (opcional)
ALTER TABLE users ADD CONSTRAINT check_user_role 
    CHECK (role IN ('admin', 'evaluator', 'researcher'));

-- Patients (Anonymized with CPF as HMAC hash)
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Anonymized identifier (HMAC hash of CPF - to be generated by backend)
    cpf_hash VARCHAR(128) UNIQUE NOT NULL,

    -- Basic demographics
    full_name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender_id INTEGER REFERENCES gender_types(id),
    ethnicity_id INTEGER REFERENCES ethnicity_types(id),
    nationality VARCHAR(100) DEFAULT 'Brasileiro',

    -- Contact information
    email VARCHAR(255),
    phone_primary VARCHAR(20),
    phone_secondary VARCHAR(20),

    -- Socioeconomic data
    education_level_id INTEGER REFERENCES education_levels(id),
    education_other VARCHAR(255),
    marital_status_id INTEGER REFERENCES marital_status_types(id),
    occupation VARCHAR(255),
    income_range_id INTEGER REFERENCES income_ranges(id),

    -- Smoking history
    is_current_smoker BOOLEAN DEFAULT FALSE,
    smoking_duration_years INTEGER,
    years_since_quit_smoking INTEGER,

    -- Metadata
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT chk_age CHECK (date_of_birth <= CURRENT_DATE),
    CONSTRAINT chk_smoking_quit CHECK (
        (is_current_smoker = FALSE AND years_since_quit_smoking >= 0) OR
        (is_current_smoker = TRUE AND years_since_quit_smoking IS NULL)
    )
);

CREATE INDEX idx_patients_cpf_hash ON patients(cpf_hash);
CREATE INDEX idx_patients_active ON patients(active);
CREATE INDEX idx_patients_dob ON patients(date_of_birth);

-- Questionnaires/Clinical Assessments
CREATE TABLE questionnaires (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    evaluator_id UUID NOT NULL REFERENCES users(id),

    -- Assessment metadata
    collection_date DATE NOT NULL,
    assessment_version VARCHAR(10) DEFAULT '1.0',
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'in_progress', 'completed', 'archived')),

    -- Audit fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,

    CONSTRAINT chk_collection_date CHECK (collection_date <= CURRENT_DATE)
);

CREATE INDEX idx_questionnaires_patient ON questionnaires(patient_id);
CREATE INDEX idx_questionnaires_evaluator ON questionnaires(evaluator_id);
CREATE INDEX idx_questionnaires_status ON questionnaires(status);
CREATE INDEX idx_questionnaires_date ON questionnaires(collection_date);

-- ============================================================================
-- CLINICAL DATA TABLES
-- ============================================================================

-- Anthropometric measurements
CREATE TABLE anthropometric_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    weight_kg DECIMAL(5,2) NOT NULL CHECK (weight_kg > 0 AND weight_kg < 500),
    height_cm DECIMAL(5,2) NOT NULL CHECK (height_cm > 0 AND height_cm < 300),
    bmi DECIMAL(5,2) GENERATED ALWAYS AS (weight_kg / POWER(height_cm / 100, 2)) STORED,

    waist_circumference_cm DECIMAL(5,2) CHECK (waist_circumference_cm > 0),
    hip_circumference_cm DECIMAL(5,2) CHECK (hip_circumference_cm > 0),
    abdominal_circumference_cm DECIMAL(5,2) CHECK (abdominal_circumference_cm > 0),

    waist_hip_ratio DECIMAL(4,3) GENERATED ALWAYS AS (
        CASE
            WHEN hip_circumference_cm > 0 THEN waist_circumference_cm / hip_circumference_cm
            ELSE NULL
        END
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_anthropometric_questionnaire ON anthropometric_data(questionnaire_id);

-- Clinical assessment data
CREATE TABLE clinical_assessments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    -- Diagnosis information
    diagnostic_description TEXT NOT NULL,
    age_at_onset INTEGER CHECK (age_at_onset > 0 AND age_at_onset < 150),
    initial_symptom VARCHAR(255),
    affected_side VARCHAR(20) CHECK (affected_side IN ('Direito', 'Esquerdo', 'Bilateral', 'Não especificado')),

    -- Phenotype and staging
    phenotype_id INTEGER REFERENCES parkinson_phenotypes(id),
    hoehn_yahr_stage_id INTEGER REFERENCES hoehn_yahr_scale(id),
    schwab_england_score INTEGER CHECK (schwab_england_score >= 0 AND schwab_england_score <= 100),

    -- Family history
    has_family_history BOOLEAN DEFAULT FALSE,
    family_kinship_degree VARCHAR(100),

    -- Motor fluctuations
    has_dyskinesia BOOLEAN DEFAULT FALSE,
    dyskinesia_interfered BOOLEAN DEFAULT FALSE,
    dyskinesia_type_id INTEGER REFERENCES dyskinesia_types(id),

    has_freezing_of_gait BOOLEAN DEFAULT FALSE,
    has_wearing_off BOOLEAN DEFAULT FALSE,
    average_on_time_hours DECIMAL(4,2),

    has_delayed_on BOOLEAN DEFAULT FALSE,
    ldopa_onset_time_hours DECIMAL(4,2),

    -- Medication status at assessment
    assessed_on_levodopa BOOLEAN DEFAULT FALSE,

    -- Surgery history
    has_surgery_history BOOLEAN DEFAULT FALSE,
    surgery_year INTEGER CHECK (surgery_year >= 1950 AND surgery_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    surgery_type_id INTEGER REFERENCES surgery_types(id),
    surgery_target VARCHAR(100),

    -- Clinical notes
    comorbidities TEXT,
    other_medications TEXT,
    disease_evolution TEXT,
    current_symptoms TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clinical_questionnaire ON clinical_assessments(questionnaire_id);
CREATE INDEX idx_clinical_onset_age ON clinical_assessments(age_at_onset);

-- Patient medications (current regimen)
CREATE TABLE patient_medications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,
    medication_id INTEGER NOT NULL REFERENCES medications_reference(id),

    dose_mg DECIMAL(8,2) NOT NULL CHECK (dose_mg > 0),
    doses_per_day INTEGER NOT NULL CHECK (doses_per_day > 0 AND doses_per_day <= 24),

    -- LED calculation (Levodopa Equivalent Daily Dose)
    led_conversion_factor DECIMAL(6,3) NOT NULL,
    led_value DECIMAL(10,2) GENERATED ALWAYS AS (dose_mg * led_conversion_factor) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(questionnaire_id, medication_id)
);

CREATE INDEX idx_patient_meds_questionnaire ON patient_medications(questionnaire_id);
CREATE INDEX idx_patient_meds_medication ON patient_medications(medication_id);

-- ============================================================================
-- NEUROLOGICAL ASSESSMENT SCALES
-- ============================================================================

-- MDS-UPDRS Part III (Motor Examination)
CREATE TABLE updrs_part3_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    -- Items without laterality (0-4 scale)
    speech SMALLINT CHECK (speech >= 0 AND speech <= 4),
    facial_expression SMALLINT CHECK (facial_expression >= 0 AND facial_expression <= 4),
    rising_from_chair SMALLINT CHECK (rising_from_chair >= 0 AND rising_from_chair <= 4),
    gait SMALLINT CHECK (gait >= 0 AND gait <= 4),
    freezing_of_gait SMALLINT CHECK (freezing_of_gait >= 0 AND freezing_of_gait <= 4),
    postural_stability SMALLINT CHECK (postural_stability >= 0 AND postural_stability <= 4),
    posture SMALLINT CHECK (posture >= 0 AND posture <= 4),
    global_bradykinesia SMALLINT CHECK (global_bradykinesia >= 0 AND global_bradykinesia <= 4),
    postural_tremor_amplitude SMALLINT CHECK (postural_tremor_amplitude >= 0 AND postural_tremor_amplitude <= 4),

    -- Rigidity (5 body regions)
    rigidity_neck SMALLINT CHECK (rigidity_neck >= 0 AND rigidity_neck <= 4),
    rigidity_rue SMALLINT CHECK (rigidity_rue >= 0 AND rigidity_rue <= 4),
    rigidity_lue SMALLINT CHECK (rigidity_lue >= 0 AND rigidity_lue <= 4),
    rigidity_rle SMALLINT CHECK (rigidity_rle >= 0 AND rigidity_rle <= 4),
    rigidity_lle SMALLINT CHECK (rigidity_lle >= 0 AND rigidity_lle <= 4),

    -- Bilateral items (Right/Left)
    finger_tapping_right SMALLINT CHECK (finger_tapping_right >= 0 AND finger_tapping_right <= 4),
    finger_tapping_left SMALLINT CHECK (finger_tapping_left >= 0 AND finger_tapping_left <= 4),
    hand_movements_right SMALLINT CHECK (hand_movements_right >= 0 AND hand_movements_right <= 4),
    hand_movements_left SMALLINT CHECK (hand_movements_left >= 0 AND hand_movements_left <= 4),
    pronation_supination_right SMALLINT CHECK (pronation_supination_right >= 0 AND pronation_supination_right <= 4),
    pronation_supination_left SMALLINT CHECK (pronation_supination_left >= 0 AND pronation_supination_left <= 4),
    toe_tapping_right SMALLINT CHECK (toe_tapping_right >= 0 AND toe_tapping_right <= 4),
    toe_tapping_left SMALLINT CHECK (toe_tapping_left >= 0 AND toe_tapping_left <= 4),
    leg_agility_right SMALLINT CHECK (leg_agility_right >= 0 AND leg_agility_right <= 4),
    leg_agility_left SMALLINT CHECK (leg_agility_left >= 0 AND leg_agility_left <= 4),
    postural_tremor_right SMALLINT CHECK (postural_tremor_right >= 0 AND postural_tremor_right <= 4),
    postural_tremor_left SMALLINT CHECK (postural_tremor_left >= 0 AND postural_tremor_left <= 4),
    kinetic_tremor_right SMALLINT CHECK (kinetic_tremor_right >= 0 AND kinetic_tremor_right <= 4),
    kinetic_tremor_left SMALLINT CHECK (kinetic_tremor_left >= 0 AND kinetic_tremor_left <= 4),

    -- Resting tremor (5 body regions)
    rest_tremor_rue SMALLINT CHECK (rest_tremor_rue >= 0 AND rest_tremor_rue <= 4),
    rest_tremor_lue SMALLINT CHECK (rest_tremor_lue >= 0 AND rest_tremor_lue <= 4),
    rest_tremor_rle SMALLINT CHECK (rest_tremor_rle >= 0 AND rest_tremor_rle <= 4),
    rest_tremor_lle SMALLINT CHECK (rest_tremor_lle >= 0 AND rest_tremor_lle <= 4),
    rest_tremor_lip_jaw SMALLINT CHECK (rest_tremor_lip_jaw >= 0 AND rest_tremor_lip_jaw <= 4),

    -- Dyskinesia impact
    dyskinesia_present BOOLEAN DEFAULT FALSE,
    dyskinesia_interfered BOOLEAN DEFAULT FALSE,

    -- Total score (auto-calculated)
    total_score INTEGER GENERATED ALWAYS AS (
        COALESCE(speech, 0) + COALESCE(facial_expression, 0) +
        COALESCE(rigidity_neck, 0) + COALESCE(rigidity_rue, 0) + COALESCE(rigidity_lue, 0) +
        COALESCE(rigidity_rle, 0) + COALESCE(rigidity_lle, 0) +
        COALESCE(finger_tapping_right, 0) + COALESCE(finger_tapping_left, 0) +
        COALESCE(hand_movements_right, 0) + COALESCE(hand_movements_left, 0) +
        COALESCE(pronation_supination_right, 0) + COALESCE(pronation_supination_left, 0) +
        COALESCE(toe_tapping_right, 0) + COALESCE(toe_tapping_left, 0) +
        COALESCE(leg_agility_right, 0) + COALESCE(leg_agility_left, 0) +
        COALESCE(rising_from_chair, 0) + COALESCE(gait, 0) + COALESCE(freezing_of_gait, 0) +
        COALESCE(postural_stability, 0) + COALESCE(posture, 0) + COALESCE(global_bradykinesia, 0) +
        COALESCE(postural_tremor_right, 0) + COALESCE(postural_tremor_left, 0) +
        COALESCE(kinetic_tremor_right, 0) + COALESCE(kinetic_tremor_left, 0) +
        COALESCE(rest_tremor_rue, 0) + COALESCE(rest_tremor_lue, 0) +
        COALESCE(rest_tremor_rle, 0) + COALESCE(rest_tremor_lle, 0) + COALESCE(rest_tremor_lip_jaw, 0) +
        COALESCE(postural_tremor_amplitude, 0)
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_updrs3_questionnaire ON updrs_part3_scores(questionnaire_id);

-- Mini Mental State Examination (MEEM)
CREATE TABLE meem_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    -- Orientation (10 points)
    orientation_day SMALLINT CHECK (orientation_day IN (0, 1)),
    orientation_date SMALLINT CHECK (orientation_date IN (0, 1)),
    orientation_month SMALLINT CHECK (orientation_month IN (0, 1)),
    orientation_year SMALLINT CHECK (orientation_year IN (0, 1)),
    orientation_time SMALLINT CHECK (orientation_time IN (0, 1)),
    orientation_location SMALLINT CHECK (orientation_location IN (0, 1)),
    orientation_institution SMALLINT CHECK (orientation_institution IN (0, 1)),
    orientation_city SMALLINT CHECK (orientation_city IN (0, 1)),
    orientation_state SMALLINT CHECK (orientation_state IN (0, 1)),
    orientation_country SMALLINT CHECK (orientation_country IN (0, 1)),

    -- Immediate memory/Registration (3 points)
    registration_word1 SMALLINT CHECK (registration_word1 IN (0, 1)),
    registration_word2 SMALLINT CHECK (registration_word2 IN (0, 1)),
    registration_word3 SMALLINT CHECK (registration_word3 IN (0, 1)),

    -- Attention and calculation (5 points)
    attention_calc1 SMALLINT CHECK (attention_calc1 IN (0, 1)),
    attention_calc2 SMALLINT CHECK (attention_calc2 IN (0, 1)),
    attention_calc3 SMALLINT CHECK (attention_calc3 IN (0, 1)),
    attention_calc4 SMALLINT CHECK (attention_calc4 IN (0, 1)),
    attention_calc5 SMALLINT CHECK (attention_calc5 IN (0, 1)),

    -- Recall (3 points)
    recall_word1 SMALLINT CHECK (recall_word1 IN (0, 1)),
    recall_word2 SMALLINT CHECK (recall_word2 IN (0, 1)),
    recall_word3 SMALLINT CHECK (recall_word3 IN (0, 1)),

    -- Language (9 points)
    language_naming1 SMALLINT CHECK (language_naming1 IN (0, 1)),
    language_naming2 SMALLINT CHECK (language_naming2 IN (0, 1)),
    language_repetition SMALLINT CHECK (language_repetition IN (0, 1)),
    language_command1 SMALLINT CHECK (language_command1 IN (0, 1)),
    language_command2 SMALLINT CHECK (language_command2 IN (0, 1)),
    language_command3 SMALLINT CHECK (language_command3 IN (0, 1)),
    language_reading SMALLINT CHECK (language_reading IN (0, 1)),
    language_writing SMALLINT CHECK (language_writing IN (0, 1)),
    language_copying SMALLINT CHECK (language_copying IN (0, 1)),

    -- Total score (0-30)
    total_score INTEGER GENERATED ALWAYS AS (
        COALESCE(orientation_day, 0) + COALESCE(orientation_date, 0) +
        COALESCE(orientation_month, 0) + COALESCE(orientation_year, 0) +
        COALESCE(orientation_time, 0) + COALESCE(orientation_location, 0) +
        COALESCE(orientation_institution, 0) + COALESCE(orientation_city, 0) +
        COALESCE(orientation_state, 0) + COALESCE(orientation_country, 0) +
        COALESCE(registration_word1, 0) + COALESCE(registration_word2, 0) + COALESCE(registration_word3, 0) +
        COALESCE(attention_calc1, 0) + COALESCE(attention_calc2, 0) +
        COALESCE(attention_calc3, 0) + COALESCE(attention_calc4, 0) + COALESCE(attention_calc5, 0) +
        COALESCE(recall_word1, 0) + COALESCE(recall_word2, 0) + COALESCE(recall_word3, 0) +
        COALESCE(language_naming1, 0) + COALESCE(language_naming2, 0) +
        COALESCE(language_repetition, 0) + COALESCE(language_command1, 0) +
        COALESCE(language_command2, 0) + COALESCE(language_command3, 0) +
        COALESCE(language_reading, 0) + COALESCE(language_writing, 0) + COALESCE(language_copying, 0)
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_meem_questionnaire ON meem_scores(questionnaire_id);

-- Unified Dyskinesia Rating Scale (UDysRS)
CREATE TABLE udysrs_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    -- Part 1A: On-Dyskinesia Time (0-4)
    on_dyskinesia_time SMALLINT CHECK (on_dyskinesia_time >= 0 AND on_dyskinesia_time <= 4),

    -- Part 1B: On-Dyskinesia Impact (10 items, 0-4 each)
    impact_speech SMALLINT CHECK (impact_speech >= 0 AND impact_speech <= 4),
    impact_chewing SMALLINT CHECK (impact_chewing >= 0 AND impact_chewing <= 4),
    impact_eating SMALLINT CHECK (impact_eating >= 0 AND impact_eating <= 4),
    impact_dressing SMALLINT CHECK (impact_dressing >= 0 AND impact_dressing <= 4),
    impact_hygiene SMALLINT CHECK (impact_hygiene >= 0 AND impact_hygiene <= 4),
    impact_writing SMALLINT CHECK (impact_writing >= 0 AND impact_writing <= 4),
    impact_hobbies SMALLINT CHECK (impact_hobbies >= 0 AND impact_hobbies <= 4),
    impact_walking SMALLINT CHECK (impact_walking >= 0 AND impact_walking <= 4),
    impact_social SMALLINT CHECK (impact_social >= 0 AND impact_social <= 4),
    impact_emotional SMALLINT CHECK (impact_emotional >= 0 AND impact_emotional <= 4),

    -- Part 2A: Off-Dystonia Time (0-4)
    off_dystonia_time SMALLINT CHECK (off_dystonia_time >= 0 AND off_dystonia_time <= 4),

    -- Part 2B: Off-Dystonia Impact (3 items, 0-4 each)
    dystonia_activities SMALLINT CHECK (dystonia_activities >= 0 AND dystonia_activities <= 4),
    dystonia_pain_impact SMALLINT CHECK (dystonia_pain_impact >= 0 AND dystonia_pain_impact <= 4),
    dystonia_pain_severity SMALLINT CHECK (dystonia_pain_severity >= 0 AND dystonia_pain_severity <= 4),

    -- Part 3: Dyskinesia Severity by Body Region (7 items, 0-4 each)
    severity_face SMALLINT CHECK (severity_face >= 0 AND severity_face <= 4),
    severity_neck SMALLINT CHECK (severity_neck >= 0 AND severity_neck <= 4),
    severity_right_arm SMALLINT CHECK (severity_right_arm >= 0 AND severity_right_arm <= 4),
    severity_left_arm SMALLINT CHECK (severity_left_arm >= 0 AND severity_left_arm <= 4),
    severity_trunk SMALLINT CHECK (severity_trunk >= 0 AND severity_trunk <= 4),
    severity_right_leg SMALLINT CHECK (severity_right_leg >= 0 AND severity_right_leg <= 4),
    severity_left_leg SMALLINT CHECK (severity_left_leg >= 0 AND severity_left_leg <= 4),

    -- Part 4: Functional Disability (4 items, 0-4 each)
    disability_communication SMALLINT CHECK (disability_communication >= 0 AND disability_communication <= 4),
    disability_drinking SMALLINT CHECK (disability_drinking >= 0 AND disability_drinking <= 4),
    disability_dressing SMALLINT CHECK (disability_dressing >= 0 AND disability_dressing <= 4),
    disability_walking SMALLINT CHECK (disability_walking >= 0 AND disability_walking <= 4),

    -- Calculated scores
    historical_subscore INTEGER GENERATED ALWAYS AS (
        COALESCE(on_dyskinesia_time, 0) +
        COALESCE(impact_speech, 0) + COALESCE(impact_chewing, 0) + COALESCE(impact_eating, 0) +
        COALESCE(impact_dressing, 0) + COALESCE(impact_hygiene, 0) + COALESCE(impact_writing, 0) +
        COALESCE(impact_hobbies, 0) + COALESCE(impact_walking, 0) + COALESCE(impact_social, 0) +
        COALESCE(impact_emotional, 0) + COALESCE(off_dystonia_time, 0) +
        COALESCE(dystonia_activities, 0) + COALESCE(dystonia_pain_impact, 0) + COALESCE(dystonia_pain_severity, 0)
    ) STORED,

    objective_subscore INTEGER GENERATED ALWAYS AS (
        COALESCE(severity_face, 0) + COALESCE(severity_neck, 0) +
        COALESCE(severity_right_arm, 0) + COALESCE(severity_left_arm, 0) +
        COALESCE(severity_trunk, 0) + COALESCE(severity_right_leg, 0) + COALESCE(severity_left_leg, 0) +
        COALESCE(disability_communication, 0) + COALESCE(disability_drinking, 0) +
        COALESCE(disability_dressing, 0) + COALESCE(disability_walking, 0)
    ) STORED,

    total_score INTEGER GENERATED ALWAYS AS (
        COALESCE(on_dyskinesia_time, 0) +
        COALESCE(impact_speech, 0) + COALESCE(impact_chewing, 0) + COALESCE(impact_eating, 0) +
        COALESCE(impact_dressing, 0) + COALESCE(impact_hygiene, 0) + COALESCE(impact_writing, 0) +
        COALESCE(impact_hobbies, 0) + COALESCE(impact_walking, 0) + COALESCE(impact_social, 0) +
        COALESCE(impact_emotional, 0) + COALESCE(off_dystonia_time, 0) +
        COALESCE(dystonia_activities, 0) + COALESCE(dystonia_pain_impact, 0) + COALESCE(dystonia_pain_severity, 0) +
        COALESCE(severity_face, 0) + COALESCE(severity_neck, 0) +
        COALESCE(severity_right_arm, 0) + COALESCE(severity_left_arm, 0) +
        COALESCE(severity_trunk, 0) + COALESCE(severity_right_leg, 0) + COALESCE(severity_left_leg, 0) +
        COALESCE(disability_communication, 0) + COALESCE(disability_drinking, 0) +
        COALESCE(disability_dressing, 0) + COALESCE(disability_walking, 0)
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_udysrs_questionnaire ON udysrs_scores(questionnaire_id);

-- Non-Motor Symptoms Scale (NMS)
CREATE TABLE nms_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    -- Each NMS item has frequency (0-4) and severity (1-4)
    -- Score = frequency × severity (only if frequency > 0)
    -- Storing all subscale items as JSONB for flexibility due to large number of items

    cardiovascular_items JSONB DEFAULT '[]',
    sleep_items JSONB DEFAULT '[]',
    mood_items JSONB DEFAULT '[]',
    perceptual_items JSONB DEFAULT '[]',
    attention_items JSONB DEFAULT '[]',
    gastrointestinal_items JSONB DEFAULT '[]',
    urinary_items JSONB DEFAULT '[]',
    sexual_items JSONB DEFAULT '[]',
    miscellaneous_items JSONB DEFAULT '[]',

    -- Total score (calculated by application)
    total_score INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_nms_questionnaire ON nms_scores(questionnaire_id);

-- Non-Motor Fluctuations (NMF)
CREATE TABLE nmf_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    -- Change domains (0-4 each)
    change_depression SMALLINT CHECK (change_depression >= 0 AND change_depression <= 4),
    change_anxiety SMALLINT CHECK (change_anxiety >= 0 AND change_anxiety <= 4),
    change_cognition SMALLINT CHECK (change_cognition >= 0 AND change_cognition <= 4),
    change_urinary SMALLINT CHECK (change_urinary >= 0 AND change_urinary <= 4),
    change_restlessness SMALLINT CHECK (change_restlessness >= 0 AND change_restlessness <= 4),
    change_pain SMALLINT CHECK (change_pain >= 0 AND change_pain <= 4),
    change_fatigue SMALLINT CHECK (change_fatigue >= 0 AND change_fatigue <= 4),
    change_sweating SMALLINT CHECK (change_sweating >= 0 AND change_sweating <= 4),

    -- Time rating (0-4)
    time_rating SMALLINT CHECK (time_rating >= 0 AND time_rating <= 4),

    -- Total score = sum of changes × time rating
    total_score INTEGER GENERATED ALWAYS AS (
        (COALESCE(change_depression, 0) + COALESCE(change_anxiety, 0) +
         COALESCE(change_cognition, 0) + COALESCE(change_urinary, 0) +
         COALESCE(change_restlessness, 0) + COALESCE(change_pain, 0) +
         COALESCE(change_fatigue, 0) + COALESCE(change_sweating, 0)) * COALESCE(time_rating, 0)
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_nmf_questionnaire ON nmf_scores(questionnaire_id);

-- Freezing of Gait Questionnaire (FOGQ)
CREATE TABLE fogq_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    gait_worst_state SMALLINT CHECK (gait_worst_state >= 0 AND gait_worst_state <= 4),
    impact_daily_activities SMALLINT CHECK (impact_daily_activities >= 0 AND impact_daily_activities <= 4),
    feet_stuck SMALLINT CHECK (feet_stuck >= 0 AND feet_stuck <= 4),
    longest_episode SMALLINT CHECK (longest_episode >= 0 AND longest_episode <= 4),
    hesitation_initiation SMALLINT CHECK (hesitation_initiation >= 0 AND hesitation_initiation <= 4),
    hesitation_turning SMALLINT CHECK (hesitation_turning >= 0 AND hesitation_turning <= 4),

    total_score INTEGER GENERATED ALWAYS AS (
        COALESCE(gait_worst_state, 0) + COALESCE(impact_daily_activities, 0) +
        COALESCE(feet_stuck, 0) + COALESCE(longest_episode, 0) +
        COALESCE(hesitation_initiation, 0) + COALESCE(hesitation_turning, 0)
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fogq_questionnaire ON fogq_scores(questionnaire_id);

-- STOP-Bang Sleep Apnea Screening
CREATE TABLE stopbang_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    -- STOP questions
    snoring BOOLEAN DEFAULT FALSE,
    tired BOOLEAN DEFAULT FALSE,
    observed_apnea BOOLEAN DEFAULT FALSE,
    blood_pressure BOOLEAN DEFAULT FALSE,

    -- BANG questions
    bmi_over_35 BOOLEAN DEFAULT FALSE,
    age_over_50 BOOLEAN DEFAULT FALSE,
    neck_circumference_large BOOLEAN DEFAULT FALSE,
    gender_male BOOLEAN DEFAULT FALSE,

    total_score INTEGER GENERATED ALWAYS AS (
        (CASE WHEN snoring THEN 1 ELSE 0 END) +
        (CASE WHEN tired THEN 1 ELSE 0 END) +
        (CASE WHEN observed_apnea THEN 1 ELSE 0 END) +
        (CASE WHEN blood_pressure THEN 1 ELSE 0 END) +
        (CASE WHEN bmi_over_35 THEN 1 ELSE 0 END) +
        (CASE WHEN age_over_50 THEN 1 ELSE 0 END) +
        (CASE WHEN neck_circumference_large THEN 1 ELSE 0 END) +
        (CASE WHEN gender_male THEN 1 ELSE 0 END)
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stopbang_questionnaire ON stopbang_scores(questionnaire_id);

-- Epworth Sleepiness Scale
CREATE TABLE epworth_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    sitting_reading SMALLINT CHECK (sitting_reading >= 0 AND sitting_reading <= 3),
    watching_tv SMALLINT CHECK (watching_tv >= 0 AND watching_tv <= 3),
    sitting_inactive_public SMALLINT CHECK (sitting_inactive_public >= 0 AND sitting_inactive_public <= 3),
    passenger_car SMALLINT CHECK (passenger_car >= 0 AND passenger_car <= 3),
    lying_down_afternoon SMALLINT CHECK (lying_down_afternoon >= 0 AND lying_down_afternoon <= 3),
    sitting_talking SMALLINT CHECK (sitting_talking >= 0 AND sitting_talking <= 3),
    sitting_after_lunch SMALLINT CHECK (sitting_after_lunch >= 0 AND sitting_after_lunch <= 3),
    car_stopped_traffic SMALLINT CHECK (car_stopped_traffic >= 0 AND car_stopped_traffic <= 3),

    total_score INTEGER GENERATED ALWAYS AS (
        COALESCE(sitting_reading, 0) + COALESCE(watching_tv, 0) +
        COALESCE(sitting_inactive_public, 0) + COALESCE(passenger_car, 0) +
        COALESCE(lying_down_afternoon, 0) + COALESCE(sitting_talking, 0) +
        COALESCE(sitting_after_lunch, 0) + COALESCE(car_stopped_traffic, 0)
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_epworth_questionnaire ON epworth_scores(questionnaire_id);

-- Parkinson's Disease Sleep Scale (PDSS-1)
CREATE TABLE pdss1_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    -- 15 questions rated 0-10 (visual analog scale)
    q1_sleep_quality SMALLINT CHECK (q1_sleep_quality >= 0 AND q1_sleep_quality <= 10),
    q2_difficulty_falling_asleep SMALLINT CHECK (q2_difficulty_falling_asleep >= 0 AND q2_difficulty_falling_asleep <= 10),
    q3_difficulty_staying_asleep SMALLINT CHECK (q3_difficulty_staying_asleep >= 0 AND q3_difficulty_staying_asleep <= 10),
    q4_restlessness SMALLINT CHECK (q4_restlessness >= 0 AND q4_restlessness <= 10),
    q5_distressing_dreams SMALLINT CHECK (q5_distressing_dreams >= 0 AND q5_distressing_dreams <= 10),
    q6_distressing_hallucinations SMALLINT CHECK (q6_distressing_hallucinations >= 0 AND q6_distressing_hallucinations <= 10),
    q7_nocturia SMALLINT CHECK (q7_nocturia >= 0 AND q7_nocturia <= 10),
    q8_difficulty_turning SMALLINT CHECK (q8_difficulty_turning >= 0 AND q8_difficulty_turning <= 10),
    q9_painful_posturing SMALLINT CHECK (q9_painful_posturing >= 0 AND q9_painful_posturing <= 10),
    q10_tremor_waking SMALLINT CHECK (q10_tremor_waking >= 0 AND q10_tremor_waking <= 10),
    q11_tired_waking SMALLINT CHECK (q11_tired_waking >= 0 AND q11_tired_waking <= 10),
    q12_refreshed_waking SMALLINT CHECK (q12_refreshed_waking >= 0 AND q12_refreshed_waking <= 10),
    q13_daytime_dozing SMALLINT CHECK (q13_daytime_dozing >= 0 AND q13_daytime_dozing <= 10),
    q14_unexpected_dozing SMALLINT CHECK (q14_unexpected_dozing >= 0 AND q14_unexpected_dozing <= 10),
    q15_total_sleep_hours SMALLINT CHECK (q15_total_sleep_hours >= 0 AND q15_total_sleep_hours <= 10),

    total_score INTEGER GENERATED ALWAYS AS (
        COALESCE(q1_sleep_quality, 0) + COALESCE(q2_difficulty_falling_asleep, 0) +
        COALESCE(q3_difficulty_staying_asleep, 0) + COALESCE(q4_restlessness, 0) +
        COALESCE(q5_distressing_dreams, 0) + COALESCE(q6_distressing_hallucinations, 0) +
        COALESCE(q7_nocturia, 0) + COALESCE(q8_difficulty_turning, 0) +
        COALESCE(q9_painful_posturing, 0) + COALESCE(q10_tremor_waking, 0) +
        COALESCE(q11_tired_waking, 0) + COALESCE(q12_refreshed_waking, 0) +
        COALESCE(q13_daytime_dozing, 0) + COALESCE(q14_unexpected_dozing, 0) +
        COALESCE(q15_total_sleep_hours, 0)
    ) STORED,

    average_score DECIMAL(4,2) GENERATED ALWAYS AS (
        (COALESCE(q1_sleep_quality, 0) + COALESCE(q2_difficulty_falling_asleep, 0) +
         COALESCE(q3_difficulty_staying_asleep, 0) + COALESCE(q4_restlessness, 0) +
         COALESCE(q5_distressing_dreams, 0) + COALESCE(q6_distressing_hallucinations, 0) +
         COALESCE(q7_nocturia, 0) + COALESCE(q8_difficulty_turning, 0) +
         COALESCE(q9_painful_posturing, 0) + COALESCE(q10_tremor_waking, 0) +
         COALESCE(q11_tired_waking, 0) + COALESCE(q12_refreshed_waking, 0) +
         COALESCE(q13_daytime_dozing, 0) + COALESCE(q14_unexpected_dozing, 0) +
         COALESCE(q15_total_sleep_hours, 0))::DECIMAL / 15.0
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pdss1_questionnaire ON pdss1_scores(questionnaire_id);

-- REM Sleep Behavior Disorder Screening Questionnaire (RBDSQ)
CREATE TABLE rbdsq_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    -- 8 main diagnostic questions (0-1 each)
    q1_vivid_dreams BOOLEAN DEFAULT FALSE,
    q2_aggressive_content BOOLEAN DEFAULT FALSE,
    q3_dream_enactment BOOLEAN DEFAULT FALSE,
    q4_limb_movements BOOLEAN DEFAULT FALSE,
    q5_injury_potential BOOLEAN DEFAULT FALSE,
    q6_bed_disruption BOOLEAN DEFAULT FALSE,
    q7_awakening_recall BOOLEAN DEFAULT FALSE,
    q8_sleep_disruption BOOLEAN DEFAULT FALSE,

    -- Additional context questions (not counted in score)
    q9_neurological_disorder BOOLEAN DEFAULT FALSE,
    q10_rem_behavior_problem BOOLEAN DEFAULT FALSE,

    total_score INTEGER GENERATED ALWAYS AS (
        (CASE WHEN q1_vivid_dreams THEN 1 ELSE 0 END) +
        (CASE WHEN q2_aggressive_content THEN 1 ELSE 0 END) +
        (CASE WHEN q3_dream_enactment THEN 1 ELSE 0 END) +
        (CASE WHEN q4_limb_movements THEN 1 ELSE 0 END) +
        (CASE WHEN q5_injury_potential THEN 1 ELSE 0 END) +
        (CASE WHEN q6_bed_disruption THEN 1 ELSE 0 END) +
        (CASE WHEN q7_awakening_recall THEN 1 ELSE 0 END) +
        (CASE WHEN q8_sleep_disruption THEN 1 ELSE 0 END)
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rbdsq_questionnaire ON rbdsq_scores(questionnaire_id);

-- ============================================================================
-- ACTIVE TASKS / MOTOR COLLECTION DATA
-- ============================================================================

-- Active task definitions (motor, speech, gait tasks)
CREATE TABLE active_task_definitions (
    id SERIAL PRIMARY KEY,
    task_code VARCHAR(20) UNIQUE NOT NULL,
    task_name VARCHAR(255) NOT NULL,
    task_category VARCHAR(50) CHECK (task_category IN ('MOTOR', 'SPEECH', 'GAIT', 'OTHER')),
    collection_form_type_id INTEGER REFERENCES collection_form_types(id),
    stage INTEGER CHECK (stage >= 1 AND stage <= 3),
    description TEXT,
    instructions TEXT,
    active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_task_def_category ON active_task_definitions(task_category);
CREATE INDEX idx_task_def_stage ON active_task_definitions(stage);

-- Checklist items for each task
CREATE TABLE task_checklist_items (
    id SERIAL PRIMARY KEY,
    task_id INTEGER NOT NULL REFERENCES active_task_definitions(id) ON DELETE CASCADE,
    item_order INTEGER NOT NULL,
    item_description VARCHAR(500) NOT NULL,

    UNIQUE(task_id, item_order)
);

-- Patient task collections (stores which tasks were completed for a questionnaire)
CREATE TABLE patient_task_collections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,
    task_id INTEGER NOT NULL REFERENCES active_task_definitions(id),

    completion_percentage DECIMAL(5,2) DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    completed_items JSONB DEFAULT '[]', -- Array of completed checklist item IDs

    -- Collection metadata
    collected_at TIMESTAMP,
    collector_notes TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(questionnaire_id, task_id)
);

CREATE INDEX idx_patient_tasks_questionnaire ON patient_task_collections(questionnaire_id);
CREATE INDEX idx_patient_tasks_task ON patient_task_collections(task_id);

-- ============================================================================
-- BINARY DATA STORAGE (CSV Collections from Collector App)
-- ============================================================================

-- Binary CSV collections from wearable sensors/devices
CREATE TABLE binary_collections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Patient identification (anonymized via CPF hash)
    patient_cpf_hash VARCHAR(128) NOT NULL,

    -- Collection parameters from collector app
    repetitions_count INTEGER NOT NULL CHECK (repetitions_count > 0),

    -- Task association (optional - may be linked to specific active task)
    task_id INTEGER REFERENCES active_task_definitions(id),

    -- Questionnaire association (optional - if part of a formal assessment)
    questionnaire_id UUID REFERENCES questionnaires(id) ON DELETE SET NULL,

    -- Binary CSV data
    csv_data BYTEA NOT NULL,
    file_size_bytes INTEGER NOT NULL,
    file_checksum VARCHAR(64), -- SHA-256 checksum for integrity verification

    -- Collection metadata
    collection_type VARCHAR(50) CHECK (collection_type IN ('MOTOR', 'GAIT', 'TREMOR', 'SPEECH', 'OTHER')),
    device_type VARCHAR(100),
    device_serial VARCHAR(100),
    sampling_rate_hz DECIMAL(8,2),

    -- Timestamps
    collected_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Additional metadata (flexible JSON for device-specific data)
    metadata JSONB DEFAULT '{}',

    -- Status
    processing_status VARCHAR(20) DEFAULT 'pending' CHECK (processing_status IN ('pending', 'processing', 'completed', 'error')),
    processing_error TEXT,

    -- Audit
    created_by UUID REFERENCES users(id),

    CONSTRAINT chk_collection_date CHECK (collected_at <= CURRENT_TIMESTAMP)
);

CREATE INDEX idx_binary_cpf_hash ON binary_collections(patient_cpf_hash);
CREATE INDEX idx_binary_questionnaire ON binary_collections(questionnaire_id);
CREATE INDEX idx_binary_task ON binary_collections(task_id);
CREATE INDEX idx_binary_collected_at ON binary_collections(collected_at);
CREATE INDEX idx_binary_status ON binary_collections(processing_status);

-- Processed features extracted from binary collections (optional table for ML/analysis)
CREATE TABLE processed_collection_features (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    binary_collection_id UUID UNIQUE NOT NULL REFERENCES binary_collections(id) ON DELETE CASCADE,

    -- Extracted features (stored as JSONB for flexibility)
    features JSONB NOT NULL,

    -- Feature extraction metadata
    extraction_algorithm VARCHAR(100),
    algorithm_version VARCHAR(20),
    extracted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Quality metrics
    data_quality_score DECIMAL(5,4) CHECK (data_quality_score >= 0 AND data_quality_score <= 1),
    completeness_percentage DECIMAL(5,2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_features_binary ON processed_collection_features(binary_collection_id);

-- ============================================================================
-- PDF REPORTS
-- ============================================================================

-- PDF reports associated with questionnaires
CREATE TABLE pdf_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    report_type VARCHAR(50) NOT NULL CHECK (report_type IN ('BIOBIT', 'DELSYS', 'POLYSOMNOGRAPHY', 'OTHER')),

    -- File storage (can be file path or binary data)
    file_path VARCHAR(500),
    file_data BYTEA,
    file_name VARCHAR(255) NOT NULL,
    file_size_bytes INTEGER,
    mime_type VARCHAR(100) DEFAULT 'application/pdf',

    -- Metadata
    uploaded_by UUID REFERENCES users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    notes TEXT,

    CONSTRAINT chk_file_storage CHECK (
        (file_path IS NOT NULL AND file_data IS NULL) OR
        (file_path IS NULL AND file_data IS NOT NULL)
    )
);

CREATE INDEX idx_pdf_questionnaire ON pdf_reports(questionnaire_id);
CREATE INDEX idx_pdf_type ON pdf_reports(report_type);

-- ============================================================================
-- CLINICAL IMPRESSION / FINALIZATION
-- ============================================================================

-- Clinical impressions and final notes
CREATE TABLE clinical_impressions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID UNIQUE NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,

    neurological_exam TEXT,
    resting_tremor_findings TEXT,
    postural_findings TEXT,
    levodopa_response TEXT,
    agonist_response TEXT,

    diagnostic_impression TEXT NOT NULL,
    recommended_conduct TEXT NOT NULL,

    additional_notes TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clinical_impression_questionnaire ON clinical_impressions(questionnaire_id);

-- ============================================================================
-- AUDIT TRAIL
-- ============================================================================

-- Comprehensive audit log for all critical operations
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    table_name VARCHAR(100) NOT NULL,
    record_id UUID,
    operation VARCHAR(20) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE', 'SELECT')),

    -- Who performed the action
    user_id UUID REFERENCES users(id),
    user_role VARCHAR(50),

    -- What changed
    old_values JSONB,
    new_values JSONB,

    -- When and where
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT,

    -- Additional context
    notes TEXT
);

CREATE INDEX idx_audit_table ON audit_log(table_name);
CREATE INDEX idx_audit_record ON audit_log(record_id);
CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_performed ON audit_log(performed_at);

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- Complete patient summary with latest assessment
CREATE VIEW v_patient_summary AS
SELECT
    p.id AS patient_id,
    p.full_name,
    p.date_of_birth,
    EXTRACT(YEAR FROM AGE(p.date_of_birth)) AS current_age,
    g.description AS gender,
    e.description AS ethnicity,
    el.description AS education,
    ms.description AS marital_status,
    p.occupation,
    COUNT(DISTINCT q.id) AS total_assessments,
    MAX(q.collection_date) AS last_assessment_date,
    p.active,
    p.created_at AS patient_since
FROM patients p
LEFT JOIN gender_types g ON p.gender_id = g.id
LEFT JOIN ethnicity_types e ON p.ethnicity_id = e.id
LEFT JOIN education_levels el ON p.education_level_id = el.id
LEFT JOIN marital_status_types ms ON p.marital_status_id = ms.id
LEFT JOIN questionnaires q ON p.id = q.patient_id
GROUP BY p.id, g.description, e.description, el.description, ms.description;

-- Complete questionnaire summary with all scores
CREATE VIEW v_questionnaire_summary AS
SELECT
    q.id AS questionnaire_id,
    q.patient_id,
    p.full_name AS patient_name,
    p.cpf_hash,
    q.collection_date,
    e.full_name AS evaluator_name,
    q.status,

    -- Anthropometric
    a.bmi,

    -- Clinical staging
    ca.age_at_onset,
    EXTRACT(YEAR FROM AGE(p.date_of_birth)) - ca.age_at_onset AS disease_duration_years,
    hy.stage AS hoehn_yahr_stage,
    ca.schwab_england_score,

    -- Scale scores
    u3.total_score AS updrs3_score,
    m.total_score AS meem_score,
    ud.total_score AS udysrs_score,
    fg.total_score AS fogq_score,
    rb.total_score AS rbdsq_score,
    sb.total_score AS stopbang_score,
    ep.total_score AS epworth_score,
    pd.total_score AS pdss1_score,

    -- LED
    (SELECT SUM(led_value) FROM patient_medications pm WHERE pm.questionnaire_id = q.id) AS total_ledd,

    q.created_at,
    q.completed_at

FROM questionnaires q
JOIN patients p ON q.patient_id = p.id
LEFT JOIN users e ON q.evaluator_id = e.id
LEFT JOIN anthropometric_data a ON q.id = a.questionnaire_id
LEFT JOIN clinical_assessments ca ON q.id = ca.questionnaire_id
LEFT JOIN hoehn_yahr_scale hy ON ca.hoehn_yahr_stage_id = hy.id
LEFT JOIN updrs_part3_scores u3 ON q.id = u3.questionnaire_id
LEFT JOIN meem_scores m ON q.id = m.questionnaire_id
LEFT JOIN udysrs_scores ud ON q.id = ud.questionnaire_id
LEFT JOIN fogq_scores fg ON q.id = fg.questionnaire_id
LEFT JOIN rbdsq_scores rb ON q.id = rb.questionnaire_id
LEFT JOIN stopbang_scores sb ON q.id = sb.questionnaire_id
LEFT JOIN epworth_scores ep ON q.id = ep.questionnaire_id
LEFT JOIN pdss1_scores pd ON q.id = pd.questionnaire_id;

-- Binary collections summary
CREATE VIEW v_binary_collections_summary AS
SELECT
    bc.id AS collection_id,
    bc.patient_cpf_hash,
    p.full_name AS patient_name,
    bc.repetitions_count,
    bc.collection_type,
    bc.device_type,
    bc.file_size_bytes,
    bc.collected_at,
    bc.processing_status,
    td.task_name,
    q.collection_date AS questionnaire_date,
    CASE
        WHEN pcf.id IS NOT NULL THEN TRUE
        ELSE FALSE
    END AS has_processed_features
FROM binary_collections bc
LEFT JOIN patients p ON bc.patient_cpf_hash = p.cpf_hash
LEFT JOIN active_task_definitions td ON bc.task_id = td.id
LEFT JOIN questionnaires q ON bc.questionnaire_id = q.id
LEFT JOIN processed_collection_features pcf ON bc.id = pcf.binary_collection_id;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Auto-update timestamp triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_questionnaires_updated_at BEFORE UPDATE ON questionnaires
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clinical_assessments_updated_at BEFORE UPDATE ON clinical_assessments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clinical_impressions_updated_at BEFORE UPDATE ON clinical_impressions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Audit trail trigger
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log (table_name, record_id, operation, old_values, performed_at)
        VALUES (TG_TABLE_NAME, OLD.id, TG_OP, row_to_json(OLD), CURRENT_TIMESTAMP);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log (table_name, record_id, operation, old_values, new_values, performed_at)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(OLD), row_to_json(NEW), CURRENT_TIMESTAMP);
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log (table_name, record_id, operation, new_values, performed_at)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(NEW), CURRENT_TIMESTAMP);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply audit triggers to critical tables
CREATE TRIGGER audit_patients AFTER INSERT OR UPDATE OR DELETE ON patients
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_questionnaires AFTER INSERT OR UPDATE OR DELETE ON questionnaires
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_binary_collections AFTER INSERT OR UPDATE OR DELETE ON binary_collections
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- ============================================================================
-- EXAMPLE QUERIES
-- ============================================================================

-- Example: Find all patients with moderate-severe Parkinson's (H&Y >= 3)
-- SELECT * FROM v_patient_summary
-- WHERE last_assessment_date IS NOT NULL;
--
-- SELECT q.*, hy.description
-- FROM questionnaires q
-- JOIN clinical_assessments ca ON q.id = ca.questionnaire_id
-- JOIN hoehn_yahr_scale hy ON ca.hoehn_yahr_stage_id = hy.id
-- WHERE hy.stage >= 3;

-- Example: Get complete assessment with all scores for a patient
-- SELECT * FROM v_questionnaire_summary
-- WHERE patient_id = 'uuid-here'
-- ORDER BY collection_date DESC;

-- Example: Find binary collections pending processing
-- SELECT * FROM v_binary_collections_summary
-- WHERE processing_status = 'pending'
-- ORDER BY collected_at;

-- ============================================================================
-- INITIAL DATA: ACTIVE TASKS AND CHECKLIST ITEMS
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

-- ============================================================================
-- CHECKLIST ITEMS FOR ALL TASKS
-- ============================================================================
-- The following section contains all checklist items for each active task
-- Items are ordered sequentially within each task
-- ============================================================================

-- TA1: Mãos em repouso (13 items)
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

-- TA2: Dedo ao nariz (13 items)
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

-- TA3: Pronação e supinação das mãos (13 items)
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

-- TA4: Toque alternado dos dedos (13 items)
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

-- TA5: Time Up and Go (TUG) (13 items)
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

-- TA6: Movimentos alternados dos dedos (13 items)
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

-- TA7: Movimento em espiral (13 items)
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

-- TA8: Teste de trilhas (13 items)
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

-- TA9: Escrever uma frase (13 items)
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

-- TA10: Respiração (17 items)
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

-- TA11: Fonação verbal (11 items)
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

-- TA12: Ressonância verbal (14 items)
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

-- TA13: Articulação verbal (22 items)
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

-- TA14: Prosódia verbal (20 items)
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

-- TA15: Desempenho da marcha TC10 (39 items)
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

-- TA16: Congelamento de marcha FoGQ (13 items)
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

-- TA17: Tremor das mãos via Delsys Trigno™ (13 items)
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

-- TA18: Bradicinesia via Delsys Trigno™ (13 items)
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
-- END OF INITIAL DATA INSERTS
-- ============================================================================

-- ============================================================================
-- DATABASE INITIALIZATION COMPLETE
-- ============================================================================

COMMENT ON DATABASE prime IS 'Parkinson Disease Clinical Assessment and Research Database';
COMMENT ON TABLE patients IS 'Anonymized patient records with HMAC-hashed CPF for privacy';
COMMENT ON TABLE binary_collections IS 'Binary CSV data from wearable sensors/collector app with patient CPF hash';
COMMENT ON TABLE questionnaires IS 'Clinical assessment sessions linking patients, users, and all collected data';
