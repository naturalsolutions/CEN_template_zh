-- Assurez-vous que le schéma zh_import existe
-- (ici zh_import mais en pratique il pourrait être judicieux de mettre le nom du partenaire en nom de schema)
CREATE SCHEMA IF NOT EXISTS zh_import;
-- Création de la table zh_import.zh_data
CREATE TABLE zh_import.zh_data(
    id_data_zh SERIAL PRIMARY KEY,
    -- Identifiant unique auto-incrémenté
    id_digitizer INTEGER NOT NULL,
    -- Clé primaire unique
    zh_uuid UUID NOT NULL,
    -- Identifiant UUID unique
    main_name VARCHAR(100) NOT NULL,
    -- Nom principal
    id_org_op INTEGER NOT NULL,
    -- Identifiant de l'organisation opérationnelle
    geom public.geometry(geometry, 4326) NOT NULL,
    -- Colonne de géométrie en WKT (PostGIS requis)
    ids_crit_delim TEXT NOT NULL,
    -- Liste des ids criteres de délimitation
    id_sdage INTEGER NOT NULL,
    -- Identifiant du SDAGE
    field_create_date TIMESTAMP NOT NULL,
    -- Date de création du champ
    field_obs VARCHAR(255) NOT NULL,
    -- Observateur du champ
    lb_code_cb TEXT NOT NULL -- Liste des codes CB
);
-- Activer PostGIS si nécessaire
CREATE EXTENSION IF NOT EXISTS postgis;
