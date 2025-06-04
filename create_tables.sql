CREATE SCHEMA IF NOT EXISTS zh_import_:schema_name;

-- creation de la table template0 des données du partenaire
CREATE TABLE zh_import_:schema_name.t_zh(
    id_import_t_zh SERIAL PRIMARY KEY,
    -- Identifiant unique auto-incrémenté
    -- Clé primaire
    id_digitizer INTEGER NOT NULL,
    zh_uuid UUID NOT NULL,
    -- Identifiant UUID unique
    main_name VARCHAR(100) NOT NULL,
    -- Nom principal
    id_org_op INTEGER NOT NULL,
    -- Identifiant de l'organisme opérationnel
    geom public.geometry(geometry, 4326) NOT NULL,
    -- Colonne de géométrie en WKT (PostGIS requis)
    ids_crit_delim TEXT NOT NULL,
    -- Liste des ids criteres de délimitation
    id_sdage INTEGER NOT NULL,
    -- Identifiant SDAGE
    id_sage INTEGER,
    -- Identifiant SAGE,
    id_hydromorphy INTEGER,
    -- Identifiant HYDROMORPHY
    field_create_date TIMESTAMP NOT NULL,
    -- Date de création sur le terrain
    field_obs VARCHAR(255) NOT NULL,
    -- Observateur sur le terrain
    lb_code_cb TEXT NOT NULL,
    -- Liste des codes CB
    id_submersion_freq INTEGER,
    -- Identifiant FREQUENCE DE SUBMERSION
    id_fonctionnalite_hydro INTEGER,
    -- Identifiant FONCTIONNALITE_HYDRO
    CONSTRAINT fk_id_org FOREIGN KEY (id_org_op) REFERENCES zh_import.org_op(id_org),
    CONSTRAINT check_sdage CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(id_sdage, 'SDAGE'::character varying)
    ) NOT VALID,
    CONSTRAINT check_sage CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(id_sage, 'SAGE'::character varying)
    ) NOT VALID,
    CONSTRAINT check_hydromorphy CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(id_hydromorphy, 'HYDROMORPHY'::character varying)
    ) NOT VALID,
    CONSTRAINT check_submersion_freq CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(
            id_submersion_freq,
            'SUBMERSION_FREQ'::character varying
        )
    ) NOT VALID,
    CONSTRAINT check_fonctionnalite_hydro CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(
            id_fonctionnalite_hydro,
            'FONCTIONNALITE_HYDRO'::character varying
        )
    ) NOT VALID
);

CREATE TABLE zh_import_:schema_name.activ_hum(
    id_import_activ_hum SERIAL PRIMARY KEY,
    -- Identifiant unique auto-incrémenté
    -- Clé primaire
    zh_uuid UUID NOT NULL,
    -- Identifiant UUID unique
    main_name VARCHAR(100) NOT NULL,
    -- Nom principal
    id_activ_hum INTEGER NOT NULL,
    -- Identifiant de l'activité humaine
    id_localisation INTEGER NOT NULL,
    -- Identifiant de la localisation de l'activité humaine
    ids_impact TEXT NOT NULL,
    -- Liste des identifiants des impacts de l'activité humaine
    remarque VARCHAR(2000),
    -- remarque sur l'activité humaine
    CONSTRAINT check_activ_hum CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(id_activ_hum, 'ACTIV_HUM'::character varying)
    ) NOT VALID,
    CONSTRAINT check_id_localisation CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(
            id_localisation,
            'LOCALISATION'::character varying
        )
    ) NOT VALID
);

CREATE TABLE zh_import_:schema_name.entree_eau(
    id_import_entree_eau SERIAL PRIMARY KEY,
    -- Identifiant unique auto-incrémenté
    -- Clé primaire
    zh_uuid UUID NOT NULL,
    -- Identifiant UUID unique
    main_name VARCHAR(100) NOT NULL,
    id_entree_eau INTEGER NOT NULL,
    id_permanence_entree INTEGER NOT NULL,
    toponymie VARCHAR(2000),
    CONSTRAINT check_entree_eau CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(id_entree_eau, 'ENTREE_EAU'::character varying)
    ) NOT VALID,
    CONSTRAINT check_permanence_entree CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(
            id_permanence_entree,
            'PERMANENCE_ENTREE'::character varying
        )
    ) NOT VALID
);

CREATE TABLE zh_import_:schema_name.sortie_eau(
    id_import_sortie_eau SERIAL PRIMARY KEY,
    -- Identifiant unique auto-incrémenté
    -- Clé primaire
    zh_uuid UUID NOT NULL,
    -- Identifiant UUID unique
    main_name VARCHAR(100) NOT NULL,
    -- Nom principal
    id_sortie_eau INTEGER NOT NULL,
    id_permanence_sortie INTEGER NOT NULL,
    toponymie VARCHAR(2000),
    CONSTRAINT check_sortie_eau CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(id_sortie_eau, 'SORTIE_EAU'::character varying)
    ) NOT VALID,
    CONSTRAINT check_permanence_sortie CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(
            id_permanence_sortie,
            'PERMANENCE_SORTIE'::character varying
        )
    ) NOT VALID
);

CREATE TABLE zh_import_:schema_name.fonctions_hydro(
    id_import_fct_hydro SERIAL PRIMARY KEY,
    -- Identifiant unique auto-incrémenté
    -- Clé primaire
    zh_uuid UUID NOT NULL,
    -- Identifiant UUID unique
    main_name VARCHAR(100) NOT NULL,
    -- Nom principal
    id_fonction_hydro INTEGER NOT NULL,
    id_fonction_qualif INTEGER NOT NULL,
    id_fonction_connaissance INTEGER NOT NULL,
    justification VARCHAR(2000),
    CONSTRAINT check_fct_hydro CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(id_fonction_hydro, 'FONCTIONS_HYDRO'::character varying)
    ) NOT VALID,
    CONSTRAINT check_fonction_qualif CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(
            id_fonction_qualif,
            'FONCTIONS_QUALIF'::character varying
        )
    ) NOT VALID,
    CONSTRAINT check_fonction_connaissance CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(
            id_fonction_connaissance,
            'FONCTIONS_CONNAISSANCE'::character varying
        )
    ) NOT VALID
);

CREATE TABLE zh_import_:schema_name.fonctions_bio(
    id_import_fct_bio SERIAL PRIMARY KEY,
    -- Identifiant unique auto-incrémenté
    -- Clé primaire
    zh_uuid UUID NOT NULL,
    -- Identifiant UUID unique
    main_name VARCHAR(100) NOT NULL,
    -- Nom principal
    id_fonction_bio INTEGER NOT NULL,
    id_fonction_qualif INTEGER NOT NULL,
    id_fonction_connaissance INTEGER NOT NULL,
    justification VARCHAR(2000),
    CONSTRAINT check_fct_bi CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(id_fonction_bio, 'FONCTIONS_BIO'::character varying)
    ) NOT VALID,
    CONSTRAINT check_fonction_qualif CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(
            id_fonction_qualif,
            'FONCTIONS_QUALIF'::character varying
        )
    ) NOT VALID,
    CONSTRAINT check_fonction_connaissance CHECK (
        zh_import.check_nomenclature_type_by_mnemonique(
            id_fonction_connaissance,
            'FONCTIONS_CONNAISSANCE'::character varying
        )
    ) NOT VALID
);

-- creation d'une vue pour visualiser les données à importer
CREATE VIEW zh_import_:schema_name.visu_zh_to_import AS
SELECT
    t.id_digitizer,
    t.zh_uuid,
    t.main_name,
    (
        SELECT org_op.name
        FROM zh_import.org_op
        WHERE org_op.id_org = t.id_org_op
    ) AS organisme_operateur,
    t.geom,
    cd.criteres_delimitation,
    zh_import.get_mnemonique(t.id_sdage) AS sdage,
    zh_import.get_mnemonique(t.id_sage) AS sage,
    zh_import.get_mnemonique(t.id_hydromorphy) AS hydromorphie,
    t.field_create_date AS date_creation_terrain,
    t.field_obs AS observateur_terrain,
    cb.corine_biotopes,
    cb.pourcentages_recouv,
    zh_import.get_mnemonique(t.id_submersion_freq) AS frequence_submersion,
    zh_import.get_mnemonique(t.id_fonctionnalite_hydro) AS fonctionnalite_hydro,
    ahe.activ_hum_mnemonique as activ_hum,
    ahe.impacts as impacts,
    ahe.localisation_mnemonique as activ_hum_localisation,
    ahe.remarque as activ_hum_remarque,
    ee.entree_eau_mnemonique as entree_eau,
    ee.permanence_entree_mnemonique as permanence_entree,
    ee.toponymie_entree,
    se.sortie_eau_mnemonique as sortie_eau,
    se.permanence_sortie_mnemonique as permanence_sortie,
    se.toponymie_sortie,
    fhe.fonction_hydro_mnemonique as fonction_hydro,
    fhe.fonction_connaissance_mnemonique as fct_hydro_connaissance,
    fhe.fonction_qualif_mnemonique as fct_hydro_qualif,
    fhe.justif_hydro as fct_hydro_justification,
    fbe.fonction_bio_mnemonique as fonction_bio,
    fbe.fonction_connaissance_mnemonique as fct_bio_connaissance,
    fbe.fonction_qualif_mnemonique as fct_bio_qualif,
    fbe.justif_bio as fct_bio_justification
      
FROM zh_import_:schema_name.t_zh t

-- Agrégation des critères de délimitation
LEFT JOIN (
    SELECT
        t1.id_import_t_zh,
        array_agg(n.mnemonique ORDER BY n.mnemonique) AS criteres_delimitation
    FROM zh_import_:schema_name.t_zh t1
    LEFT JOIN LATERAL (
        SELECT id::integer AS id_nomenclature
        FROM unnest(string_to_array(t1.ids_crit_delim, ',')) AS id
    ) AS delim ON TRUE
    LEFT JOIN zh_import.t_nomenclatures n ON delim.id_nomenclature = n.id_nomenclature
    GROUP BY t1.id_import_t_zh
) cd ON cd.id_import_t_zh = t.id_import_t_zh

-- Agrégation des corine biotopes
LEFT JOIN (
    SELECT
        t2.id_import_t_zh,
        array_agg(cbs.lb_hab_fr ORDER BY cbs.lb_hab_fr) AS corine_biotopes,
        array_agg(NULLIF(split_part(id, ':', 2), '')::int ORDER BY cbs.lb_hab_fr) AS pourcentages_recouv
    FROM zh_import_:schema_name.t_zh t2
    LEFT JOIN LATERAL (
        SELECT id
        FROM unnest(string_to_array(t2.lb_code_cb, ', ')) AS id
    ) AS cb_1 ON TRUE
    LEFT JOIN zh_import.cbs cbs ON split_part(cb_1.id, ':', 1) = cbs.lb_code::text
    GROUP BY t2.id_import_t_zh
) cb ON cb.id_import_t_zh = t.id_import_t_zh

-- Agrégation des activités humaines avec mnemonique des impacts
LEFT JOIN (
    SELECT
        ah.zh_uuid,
        array_agg(ah.id_activ_hum ORDER BY ah.id_activ_hum) AS ids_activ_hum,
        array_agg(n1.mnemonique ORDER BY ah.id_activ_hum) AS activ_hum_mnemonique,
        -- Ici : array_agg à plat sur les mnemonique impact
        array_agg(impacts.mnemonique_impact ORDER BY ah.id_activ_hum) AS impacts,
        array_agg(n2.mnemonique ORDER BY ah.id_localisation) AS localisation_mnemonique,
        array_agg(ah.remarque) as remarque
    FROM zh_import_:schema_name.activ_hum ah
    LEFT JOIN zh_import.t_nomenclatures n1 ON ah.id_activ_hum = n1.id_nomenclature
    LEFT JOIN zh_import.t_nomenclatures n2 ON ah.id_localisation = n2.id_nomenclature
    LEFT JOIN LATERAL (
        SELECT string_agg(n.mnemonique, ' / ') as mnemonique_impact
        FROM unnest(string_to_array(ah.ids_impact, ',')) AS id_impact
        LEFT JOIN zh_import.t_nomenclatures n ON id_impact::integer = n.id_nomenclature
    ) impacts ON TRUE
    GROUP BY ah.zh_uuid
) ahe ON ahe.zh_uuid::uuid = t.zh_uuid

-- Agrégation des entrees d'eau avec mnemonique
LEFT JOIN (
    SELECT
        e.zh_uuid,
        array_agg(e.id_entree_eau ORDER BY e.id_entree_eau) AS ids_entree_eau,
        array_agg(n1.mnemonique ORDER BY e.id_entree_eau) AS entree_eau_mnemonique,
        array_agg(n2.mnemonique ORDER BY e.id_entree_eau) AS permanence_entree_mnemonique,
        array_agg(e.toponymie) as toponymie_entree
    FROM zh_import_:schema_name.entree_eau e
    LEFT JOIN zh_import.t_nomenclatures n1 ON e.id_entree_eau = n1.id_nomenclature
    LEFT JOIN zh_import.t_nomenclatures n2 ON e.id_permanence_entree = n2.id_nomenclature
    GROUP BY e.zh_uuid
) ee ON ee.zh_uuid::uuid = t.zh_uuid

-- Agrégation des sorties d'eau avec mnemonique
LEFT JOIN (
    SELECT
        s.zh_uuid,
        array_agg(s.id_sortie_eau ORDER BY s.id_sortie_eau) AS ids_sortie_eau,
        array_agg(n1.mnemonique ORDER BY s.id_sortie_eau) AS sortie_eau_mnemonique,
        array_agg(n2.mnemonique ORDER BY s.id_sortie_eau) AS permanence_sortie_mnemonique,
        array_agg(s.toponymie) as toponymie_sortie
    FROM zh_import_:schema_name.sortie_eau s
    LEFT JOIN zh_import.t_nomenclatures n1 ON s.id_sortie_eau = n1.id_nomenclature
    LEFT JOIN zh_import.t_nomenclatures n2 ON s.id_permanence_sortie = n2.id_nomenclature
    GROUP BY s.zh_uuid
) se ON se.zh_uuid::uuid = t.zh_uuid

-- Agrégation des fonctions hydro
LEFT JOIN (
    SELECT
        fh.zh_uuid,
        array_agg(fh.id_fonction_hydro::integer ORDER BY fh.id_fonction_hydro) AS ids_fonction_hydro,
        array_agg(n1.mnemonique ORDER BY fh.id_fonction_hydro) AS fonction_hydro_mnemonique,
        array_agg(n2.mnemonique ORDER BY fh.id_fonction_hydro) AS fonction_qualif_mnemonique,
        array_agg(n3.mnemonique ORDER BY fh.id_fonction_hydro) AS fonction_connaissance_mnemonique,
        array_agg(fh.justification) as justif_hydro
    FROM zh_import_:schema_name.fonctions_hydro fh
    LEFT JOIN zh_import.t_nomenclatures n1 ON fh.id_fonction_hydro = n1.id_nomenclature
    LEFT JOIN zh_import.t_nomenclatures n2 ON fh.id_fonction_qualif = n2.id_nomenclature
    LEFT JOIN zh_import.t_nomenclatures n3 ON fh.id_fonction_connaissance = n3.id_nomenclature
    GROUP BY fh.zh_uuid
) fhe ON fhe.zh_uuid::uuid = t.zh_uuid

-- Agrégation des fonctions bio
LEFT JOIN (
    SELECT
        fb.zh_uuid,
        array_agg(fb.id_fonction_bio::integer ORDER BY fb.id_fonction_bio) AS ids_fonction_bio,
        array_agg(n1.mnemonique ORDER BY fb.id_fonction_bio) AS fonction_bio_mnemonique,
        array_agg(n2.mnemonique ORDER BY fb.id_fonction_bio) AS fonction_qualif_mnemonique,
        array_agg(n3.mnemonique ORDER BY fb.id_fonction_bio) AS fonction_connaissance_mnemonique,
        array_agg(fb.justification) as justif_bio
    FROM zh_import_:schema_name.fonctions_bio fb
    LEFT JOIN zh_import.t_nomenclatures n1 ON fb.id_fonction_bio = n1.id_nomenclature
    LEFT JOIN zh_import.t_nomenclatures n2 ON fb.id_fonction_qualif = n2.id_nomenclature
    LEFT JOIN zh_import.t_nomenclatures n3 ON fb.id_fonction_connaissance = n3.id_nomenclature
    GROUP BY fb.zh_uuid
) fbe ON fbe.zh_uuid::uuid = t.zh_uuid

order by t.main_name asc;

-- Activer PostGIS si nécessaire
CREATE EXTENSION IF NOT EXISTS postgis;


