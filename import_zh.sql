-- créer les tables de nomenclatures (permettra de contrôler que les 
-- nomenclatures remplies dans le template existent bien et sont correctes)
\i nomenclatures.sql
\COPY zh_import.bib_nomenclatures_types (id_type, mnemonique, label_default) FROM 'insert_nomenclature_types.csv' DELIMITER ';' CSV HEADER;
\COPY zh_import.t_nomenclatures (id_nomenclature, id_type, cd_nomenclature, mnemonique, label_default) FROM 'insert_nomenclatures.csv' DELIMITER ';' CSV HEADER;

-- créer autres tables utiles :
\COPY zh_import.cbs (lb_code, lb_hab_fr) FROM 'insert_cbs.csv' DELIMITER ';' CSV HEADER;
\COPY zh_import.org_op (id_org, name, abbrevation) FROM 'insert_orgs_op.csv' DELIMITER ';' CSV HEADER;

