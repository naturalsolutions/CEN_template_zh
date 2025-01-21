## Process à executer côté CEN Ariege

- créer une bdd postgresql avec user
  (à faire avec le client si solution ok pour lui)

- créer la table intermédiaire :

```bash
git clone git@gitlab.com:natural-solutions/geonature/cen-ariege/template_import_zh/template_zh.git
cd template_zh
psql -U geonatadmin -d geonature2db-zh2 -f create_tables.sql
```

- utiliser le template disponible dans template_zh.xlsx pour saisir les données
- enregistrer ce template en csv (séparateur ;)
- importer le csv dans la table intermédiaire :

```bash
psql -U geonatadmin -d geonature2db-zh2 -c "\COPY zh_import.zh_data (id_digitizer, zh_uuid, main_name, id_org_op, geom, ids_crit_delim, id_sdage, field_create_date, field_obs, lb_code_cb) FROM 'test_import_zh.csv' DELIMITER ';' CSV HEADER;"
```
