CREATE SCHEMA IF NOT EXISTS zh_import;
CREATE TABLE zh_import.bib_nomenclatures_types (
    id_type INTEGER NOT NULL,
    mnemonique VARCHAR(255) NOT NULL,
    label_default VARCHAR(255) NOT NULL,
    CONSTRAINT pk_bib_nomenclatures_types2 PRIMARY KEY (id_type),
    CONSTRAINT unique_bib_nomenclatures_types_mnemonique2 UNIQUE (mnemonique)
);
CREATE TABLE zh_import.t_nomenclatures (
    id_nomenclature INTEGER NOT NULL,
    id_type INTEGER NOT NULL,
    cd_nomenclature VARCHAR(255) NOT NULL,
    mnemonique VARCHAR(255) NULL,
    label_default VARCHAR(255) NOT NULL,
    CONSTRAINT pk_t_nomenclatures2 PRIMARY KEY (id_nomenclature),
    CONSTRAINT unique_id_type_cd_nomenclature2 UNIQUE (id_type, cd_nomenclature),
    CONSTRAINT fk_t_nomenclatures_id_type2 FOREIGN KEY (id_type) REFERENCES zh_import.bib_nomenclatures_types(id_type) ON UPDATE CASCADE
);
CREATE TABLE zh_import.cbs (
    lb_code VARCHAR(10) NOT NULL,
    lb_hab_fr VARCHAR(255) NOT NULL,
    CONSTRAINT pk_cbs PRIMARY KEY (lb_code)
);
CREATE TABLE zh_import.org_op (
    id_org INTEGER,
    "name" VARCHAR(255) NOT NULL,
    abbrevation VARCHAR(6) NOT NULL,
    CONSTRAINT pk_orgs PRIMARY KEY (id_org)
);
CREATE OR REPLACE FUNCTION zh_import.get_id_nomenclature_type(mytype character varying) RETURNS integer LANGUAGE plpgsql IMMUTABLE AS $function$ --Function which return the id_type from the mnemonique of a nomenclature type
DECLARE theidtype character varying;
BEGIN
SELECT INTO theidtype id_type
FROM zh_import.bib_nomenclatures_types
WHERE mnemonique = mytype;
return theidtype;
END;
$function$;
CREATE OR REPLACE FUNCTION zh_import.check_nomenclature_type_by_mnemonique(id integer, mytype character varying) RETURNS boolean LANGUAGE plpgsql IMMUTABLE AS $function$ --Function that checks if an id_nomenclature matches with wanted nomenclature type (use mnemonique type)
    BEGIN IF (
        id IN (
            SELECT id_nomenclature
            FROM zh_import.t_nomenclatures
            WHERE id_type = zh_import.get_id_nomenclature_type(mytype)
        )
        OR id IS NULL
    ) THEN RETURN true;
ELSE RAISE EXCEPTION 'Error : id_nomenclature --> (%) and nomenclature --> (%) type didn''t match. Use id_nomenclature in corresponding type (mnemonique field). See zh_import.t_nomenclatures.id_type.',
id,
mytype;
END IF;
RETURN false;
END;
$function$;
CREATE OR REPLACE FUNCTION zh_import.get_mnemonique(myidnomenclature integer) RETURNS character varying LANGUAGE plpgsql IMMUTABLE AS $function$ --Function which return the mnemonique from an id_nomenclature
DECLARE themnemonique character varying;
BEGIN
SELECT INTO themnemonique mnemonique
FROM zh_import.t_nomenclatures n
WHERE myidnomenclature = n.id_nomenclature;
return themnemonique;
END;
$function$;