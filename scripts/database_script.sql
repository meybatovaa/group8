-- Create the database 
CREATE SCHEMA IF NOT EXISTS impc_db;
USE impc_db;

-- Drop existing tables 
DROP TABLE IF EXISTS procedure_descriptions;
DROP TABLE IF EXISTS parameter_descriptions;
DROP TABLE IF EXISTS parameter_groups;
DROP TABLE IF EXISTS phenotype_analysis;
DROP TABLE IF EXISTS disease_associations;

-- Create `phenotype_analysis` table to hold raw experimental analysis data
CREATE TABLE IF NOT EXISTS phenotype_analysis (
    analysis_id VARCHAR(25) NOT NULL,
    gene_accession_id VARCHAR(15) NOT NULL,
    gene_symbol VARCHAR(15) NOT NULL,
    mouse_strain VARCHAR(10) NOT NULL,
    mouse_life_stage VARCHAR(25) NOT NULL,
    parameter_id VARCHAR(25),
    parameter_name VARCHAR(100) NOT NULL,
    pvalue FLOAT NOT NULL,
    PRIMARY KEY (analysis_id)
);

-- Create `parameter_descriptions` table
CREATE TABLE IF NOT EXISTS parameter_descriptions (
    impcParameterOrigId VARCHAR(25) NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `description` VARCHAR(500),
    parameterId VARCHAR(25) NOT NULL,
    group_id INT DEFAULT NULL,
    PRIMARY KEY (impcParameterOrigId)
);

-- Create `procedure_descriptions` table for phenotype procedures
CREATE TABLE IF NOT EXISTS procedure_descriptions (
    id INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `description` VARCHAR(1250),
    isMandatory VARCHAR(7) NOT NULL,
    impcParameterOrigId VARCHAR(25) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (impcParameterOrigId) REFERENCES parameter_descriptions(impcParameterOrigId)
);

-- Create `disease_associations` table
CREATE TABLE IF NOT EXISTS disease_associations (
    id INT NOT NULL AUTO_INCREMENT,
    disease_id VARCHAR(25) NOT NULL,
    disease_term VARCHAR(255) NOT NULL,
    gene_accession_id VARCHAR(25) NOT NULL,
    phenodigm_score FLOAT NOT NULL,
    PRIMARY KEY (id)
);

-- Create `parameter_groups` table for grouping related phenotype test parameters
CREATE TABLE IF NOT EXISTS parameter_groups (
    group_id INT NOT NULL AUTO_INCREMENT,  -- Auto increment the group_id
    group_name VARCHAR(25) NOT NULL,
    `description` VARCHAR(255),
    PRIMARY KEY (group_id)
);

-- Load data into `parameter_descriptions` table
LOAD DATA LOCAL INFILE 'C:/Users/sean2/Documents/KCL/7BBG1003/data2/IMPC_parameter_description.csv'
INTO TABLE parameter_descriptions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS 
(impcParameterOrigId, `name`, `description`, parameterId);

-- Load data into `procedure_descriptions` table
LOAD DATA LOCAL INFILE 'C:/Users/sean2/Documents/KCL/7BBG1003/data2/IMPC_procedure.csv'
INTO TABLE procedure_descriptions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS 
(`name`, `description`, isMandatory, impcParameterOrigId);

-- Load data into `disease_associations` table
LOAD DATA LOCAL INFILE 'C:/Users/sean2/Documents/KCL/7BBG1003/data2/Disease_information.csv'
INTO TABLE disease_associations
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS 
(disease_id, disease_term, gene_accession_id, phenodigm_score);

-- Load data into `phenotype_analysis` table
LOAD DATA LOCAL INFILE 'C:/Users/sean2/Documents/KCL/7BBG1003/data2/merged_data_clean.csv'
INTO TABLE phenotype_analysis
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS 
(analysis_id, gene_accession_id, gene_symbol, mouse_strain, mouse_life_stage, parameter_id, parameter_name, pvalue);

-- Insert groupings of parameters for phenotype tests based on their features
INSERT INTO parameter_groups (group_name, description)
VALUES 
('Weight', 'Parameters related to body and organ weights'),
('Images', 'Parameters related to imaging techniques'),
('Brain', 'Parameters related to the brain and associated structures'),
('Equipment', 'Parameters related to experimental equipment'),
('Vision/Eye', 'Parameters related to the eye and vision'),
('Blood', 'Parameters related to blood composition and collection'),
('Cardiovascular', 'Parameters related to the cardiovascular system'),
('Muscular', 'Parameters related to muscles, strength and movement'),
('Metabolic', 'Parameters related to metabolism'),
('Respiratory', 'Parameters related to the respiratory system'),
('Biochemical', 'Parameters related to biochemical molecules and compounds'),
('Reproductive', 'Parameters related to the male and female reproductive systems'),
('Coat/Skin', 'Parameters related to mouse coat and skin'),
('Housing', 'Parameters related to the housing in which the animals are kept'),
('Conditions', 'Parameters related to the conditioning, context and cues of experimentation'),
('Other', 'Other parameters which did not fall under previous categories');

SET SQL_SAFE_UPDATES = 0;

-- Group 1: Weight
UPDATE parameter_descriptions
SET group_id = 1
WHERE (name LIKE '%weight%' OR description LIKE '%weight%'
   OR name LIKE '%mass%' OR description LIKE '%mass%');

-- Group 2: Images
UPDATE parameter_descriptions
SET group_id = 2
WHERE (name LIKE '%imag%' OR description LIKE '%imag%')
   AND group_id IS NULL;

-- Group 3: Brain
UPDATE parameter_descriptions
SET group_id = 3
WHERE (name LIKE '%brain%' OR description LIKE '%brain%'
   OR name LIKE '%neuro%' OR description LIKE '%neuro%'
   OR name LIKE '%cognitive%' OR description LIKE '%cognitive%')
   AND group_id IS NULL;

-- Group 4: Equipment
UPDATE parameter_descriptions
SET group_id = 4
WHERE (name LIKE '%equipment%' OR description LIKE '%equipment%')
   AND group_id IS NULL;

-- Group 5: Eye
UPDATE parameter_descriptions
SET group_id = 5
WHERE (name LIKE '%eye%' OR description LIKE '%eye%' OR parameterId LIKE '%EYE%')
   AND (name NOT LIKE '%preyer%' OR description NOT LIKE '%preyer%')
   AND group_id IS NULL;
   
-- Group 6: Blood
UPDATE parameter_descriptions
SET group_id = 6
WHERE (name LIKE '%blood%' OR description LIKE '%blood%'
   OR name LIKE '%plasma%' OR description LIKE '%plasma%'
   OR parameterId LIKE '%HEM%')
   AND group_id IS NULL;
   
-- Group 7: Cardiovascular
UPDATE parameter_descriptions
SET group_id = 7
WHERE (name LIKE '%heart%' OR description LIKE '%heart%'
   OR name = 'PR')
   AND group_id IS NULL;

-- Group 8: Muscular
UPDATE parameter_descriptions
SET group_id = 8
WHERE (name LIKE '%muscle%' OR description LIKE '%muscle%'
   OR name LIKE '%strength%' OR description LIKE '%strength%'
   OR name LIKE '%motor%' OR description LIKE '%motor%'
   OR name LIKE '%movement%' OR description LIKE '%movement%')
   AND group_id IS NULL;
   
-- Group 9: Metabolic
UPDATE parameter_descriptions
SET group_id = 9
WHERE (name LIKE '%insulin%' OR description LIKE '%insulin%'
   OR name LIKE '%glucose%' OR description LIKE '%glucose%'
   OR name LIKE '%cholesterol%' OR description LIKE '%cholesterol%'
   OR name LIKE '%metab%' OR description LIKE '%metab%'
   OR name LIKE '%fat%' OR description LIKE '%fat%')
   AND group_id IS NULL;
   
-- Group 10: Respiratory
UPDATE parameter_descriptions
SET group_id = 10
WHERE (name LIKE '%lung%' OR description LIKE '%lung%'
   OR name LIKE '%respirat%' OR description LIKE '%respirat%'
   OR name LIKE '%breath%' OR description LIKE '%breath%'
   OR name LIKE '%hypoxia%' OR description LIKE '%hypoxia%')
   AND group_id IS NULL;
   
-- Group 11: Biochemical
UPDATE parameter_descriptions
SET group_id = 11
WHERE (parameterId LIKE '%CBC%')
   AND group_id IS NULL;

-- Group 12: Reproductive
UPDATE parameter_descriptions
SET group_id = 12
WHERE (name LIKE '%placenta%' OR description LIKE '%placenta%'
   OR name LIKE '%umbilic%' OR description LIKE '%umbilic%'
   OR name LIKE '%penis%' OR description LIKE '%penis%'
   OR name LIKE '%vagina%' OR description LIKE '%vagina%'
   OR name LIKE '%ovary%' OR description LIKE '%ovary%'
   OR name LIKE '%teste%' OR description LIKE '%teste%'
   OR name LIKE '%uterus%' OR description LIKE '%uterus%'
   OR name LIKE '%umbilic%' OR description LIKE '%umbilic%'
   OR name LIKE '%prostate%' OR description LIKE '%prostate%')
   AND group_id IS NULL;

-- Group 13: Coat/Skin
UPDATE parameter_descriptions
SET group_id = 13
WHERE (name LIKE '%coat%' OR description LIKE '%coat%'
   OR name LIKE '%skin%' OR description LIKE '%skin%')
   AND group_id IS NULL;

-- Group 14: Housing
UPDATE parameter_descriptions
SET group_id = 14
WHERE (name LIKE '%housing%' OR description LIKE '%housing%'
   OR name LIKE '%cage%' OR description LIKE '%cage%')
   AND group_id IS NULL;
   
-- Group 15: Conditions
UPDATE parameter_descriptions
SET group_id = 15
WHERE (name LIKE '%condition%' OR description LIKE '%condition%'
   OR name LIKE '%context%' OR description LIKE '%context%'
   OR name LIKE '%cue%' OR description LIKE '%cue%'
   OR parameterId LIKE '%FEA%')
   AND group_id IS NULL;
   
-- Group 16: Other
UPDATE parameter_descriptions
SET group_id = 16
WHERE group_id IS NULL;
   
SET SQL_SAFE_UPDATES = 1;

-- Add a foreign key between parameter description and grouping tables
ALTER TABLE parameter_descriptions
ADD FOREIGN KEY (group_id) REFERENCES parameter_groups(group_id);

-- Verify loading of `disease` data
SELECT * FROM disease_associations LIMIT 10;

-- Verify loading of `analysis_results` data
SELECT * FROM phenotype_analysis LIMIT 10;

-- Verify loading of `experimental_procedure` data
SELECT * FROM procedure_descriptions LIMIT 10;
