import pandas as pd
from sqlalchemy import create_engine, inspect
import getpass
import sys
from sqlalchemy import text  # ajoute ça en haut du script

# Fonction pour parser les arguments clé=valeur
def parse_args_kv(args):
    params = {}
    for arg in args:
        if '=' not in arg:
            raise ValueError(f"Argument invalide : {arg} (utilise la forme clé=valeur)")
        k, v = arg.split("=", 1)
        params[k.strip()] = v.strip()
    return params

# Lecture des arguments
try:
    args = parse_args_kv(sys.argv[1:])
except ValueError as e:
    print(e)
    sys.exit(1)

# Vérifier les paramètres requis
obligatoires = ["fichier", "schema", "utilisateur", "base"]
manquants = [k for k in obligatoires if k not in args]
if manquants:
    print(f"❌ Arguments manquants : {', '.join(manquants)}")
    sys.exit(1)

# Paramètres optionnels
hote = args.get("hote", "localhost")
port = int(args.get("port", 5432))

# Mot de passe
mot_de_passe = getpass.getpass("Mot de passe PostgreSQL : ")

# Connexion SQLAlchemy
url = f"postgresql://{args['utilisateur']}:{mot_de_passe}@{hote}:{port}/{args['base']}"
engine = create_engine(url)


# 1- IMPORT DES DONNEES DE L'ONGLET template_t_zh

try:
    df_t_zh = pd.read_excel(args["fichier"], sheet_name="template_t_zh")
except Exception as e:
    print(f"❌ Erreur lecture fichier Excel : {e}")
    sys.exit(1)

if df_t_zh.empty:
    print("⚠️ Le fichier Excel est vide.")
    sys.exit(0)

if "zh_uuid" not in df_t_zh.columns:
    print("❌ La colonne 'zh_uuid' est manquante dans le fichier.")
    sys.exit(1)

# Vérifier si la table existe et récupérer les UUID :

insp = inspect(engine)
with engine.connect() as conn:
    if insp.has_table("t_zh", schema=args["schema"]):
        existing_uuids = pd.read_sql_query(
            f"SELECT zh_uuid FROM {args['schema']}.t_zh", conn
        )
    else:
        existing_uuids = pd.DataFrame(columns=["zh_uuid"])

## Nettoyage des types (UUID en str si nécessaire)
df_t_zh["zh_uuid"] = df_t_zh["zh_uuid"].astype(str)
existing_uuids["zh_uuid"] = existing_uuids["zh_uuid"].astype(str)

## Filtrage uuid
uuids_source = set(df_t_zh["zh_uuid"])
uuids_existant = set(existing_uuids["zh_uuid"])
uuids_doublons = uuids_source.intersection(uuids_existant)
df_t_zh_filtered = df_t_zh[~df_t_zh["zh_uuid"].isin(uuids_existant)]

## Résumé
print(f"📄 Lignes dans le fichier Excel : {len(df_t_zh)}")
print(f"🧹 Nouvelles lignes à importer : {len(df_t_zh_filtered)}")
print(f"🛑 UUIDs ignorés (déjà présents) : {len(uuids_doublons)}")

if uuids_doublons:
    print("🔁 UUIDs doublons détectés :")
    for u in sorted(uuids_doublons):
        print(f" - {u}")

if df_t_zh_filtered.empty:
    print("✅ Aucun nouvel enregistrement à insérer.")
    sys.exit(0)

# check id_crit_delim valide et filtrage si nécessaire :

## Charger les ID valides depuis la base
with engine.connect() as conn:
    result = conn.execute(text("SELECT id_nomenclature FROM zh_import.t_nomenclatures where id_type = 126"))
    ids_valides = {row[0] for row in result.fetchall()}
print(ids_valides)

def valider_ids(ch):
    try:
        ids = [int(x.strip()) for x in str(ch).split(',') if x.strip()]
        ids_invalides = [i for i in ids if i not in ids_valides]
        return ids_invalides
    except Exception as e:
        return ["Erreur de parsing"]

## Appliquer la validation ligne par ligne
df_t_zh_filtered['crit_ids_invalides'] = df_t_zh_filtered['ids_crit_delim'].apply(valider_ids)
print(df_t_zh_filtered['crit_ids_invalides'])

## Filtrer les lignes qui posent problème
lignes_invalides_crit_ids = df_t_zh_filtered[df_t_zh_filtered['crit_ids_invalides'].apply(lambda x: len(x) > 0)]

## Résultat
if not lignes_invalides_crit_ids.empty:
    print("❌ Des lignes contiennent des ids_crit_delim invalides :")
    for index, row in lignes_invalides_crit_ids.iterrows():
        print(f" - Ligne {index + 2} (zh_uuid={row['zh_uuid']}) : IDs invalides = {row['crit_ids_invalides']}")
    print(f"⚠️ {len(lignes_invalides_crit_ids)} lignes ignorées.")
    df_t_zh_filtered = df_t_zh_filtered[df_t_zh_filtered['crit_ids_invalides'].apply(lambda x: len(x) == 0)]

# Supprimer les colonnes temporaires non présentes dans la table cible
colonnes_temp = ['crit_ids_invalides']
df_t_zh_filtered = df_t_zh_filtered.drop(columns=[col for col in colonnes_temp if col in df_t_zh_filtered.columns])

# Insertion
try:
    df_t_zh_filtered.to_sql(
        "t_zh", engine,
        schema=args["schema"],
        if_exists="append",
        index=False
    )
    print(f"✅ {len(df_t_zh_filtered)} lignes insérées dans {args['schema']}.t_zh")
except Exception as e:
    print(f"❌ Erreur lors de l'import des données de l'onglet template_t_zh : {e}")
    sys.exit(1)


# 3- IMPORT DES DONNEES DES ONGLET template_ENTREE_EAU, _SORTIE_EAU, FONCTIONS_HYDRO, FONCTIONS_BIO

for template in ['activ_hum', 'entree_eau', 'sortie_eau', 'fonctions_hydro', 'fonctions_bio']:
    try:
        df_template = pd.read_excel(args["fichier"], sheet_name=f"template_{template.upper()}")
    except Exception as e:
        print(f"❌ Erreur lecture fichier Excel onglet template_{template.upper()} : {e}")
        sys.exit(1)

    if df_template.empty:
        print(f"⚠️ Le fichier Excel onglet template_{template.upper()} est vide.")
        sys.exit(0)

    if "zh_uuid" not in df_template.columns:
        print(f"❌ La colonne 'zh_uuid' est manquante dans le fichier onglet template_{template.upper()}.")
        sys.exit(1)

    # Recharger les UUID insérés dans t_zh depuis la base
    with engine.connect() as conn:
        existing_uuids = pd.read_sql_query(
            f"SELECT zh_uuid FROM {args['schema']}.t_zh", conn
        )
    existing_uuids["zh_uuid"] = existing_uuids["zh_uuid"].astype(str)

    # Nettoyage UUID
    df_template["zh_uuid"] = df_template["zh_uuid"].astype(str)
    zh_uuids_tzh = existing_uuids["zh_uuid"].astype(str)

    # Filtrage des lignes dont le zh_uuid est bien référencé dans t_zh
    df_template_valid = df_template[df_template["zh_uuid"].isin(zh_uuids_tzh)]

    # Détection des UUID orphelins
    uuids_template = set(df_template["zh_uuid"])
    uuids_valides = set(zh_uuids_tzh)
    uuids_orphelins = uuids_template - uuids_valides

    if uuids_orphelins:
        print(f"❌ Certains zh_uuid dans l'onglet template_{template.upper()} n'existent pas dans t_zh :")
        for u in sorted(uuids_orphelins):
            print(f" - {u}")
        print(f"⚠️ {len(uuids_orphelins)} lignes ignorées car elles référencent un zh_uuid inconnu.")

    if df_template_valid.empty:
        print(f"✅ Aucun enregistrement valide à insérer dans {template}.")
        sys.exit(0)

    if template == 'activ_hum':

        # check ids_impact valide et filtrage si nécessaire :

        ## Charger les ID valides depuis la base
        with engine.connect() as conn:
            result = conn.execute(text("SELECT id_nomenclature FROM zh_import.t_nomenclatures where id_type = 132"))
            ids_valides = {row[0] for row in result.fetchall()}

        ## Appliquer la validation ligne par ligne
        df_template_valid['ids_impact_invalides'] = df_template_valid['ids_impact'].apply(valider_ids)
        #print(df_t_zh_filtered['crit_ids_invalides'])

        ## Filtrer les lignes qui posent problème
        lignes_invalides_ids_impact = df_template_valid[df_template_valid['ids_impact_invalides'].apply(lambda x: len(x) > 0)]

        ## Résultat
        if not lignes_invalides_ids_impact.empty:
            print("❌ Des lignes contiennent des ids_impact invalides :")
            for index, row in lignes_invalides_ids_impact.iterrows():
                print(f" - Ligne {index + 2} (zh_uuid={row['zh_uuid']}) : IDs invalides = {row['ids_impact_invalides']}")
            print(f"⚠️ {len(lignes_invalides_ids_impact)} lignes ignorées.")
            df_template_valid = df_template_valid[df_template_valid['ids_impact_invalides'].apply(lambda x: len(x) == 0)]

        # Supprimer les colonnes temporaires non présentes dans la table cible
        colonnes_temp = ['ids_impact_invalides']
        df_template_valid = df_template_valid.drop(columns=[col for col in colonnes_temp if col in df_template_valid.columns])

    # Insertion
    try:
        df_template_valid.to_sql(
            f"{template}", engine,
            schema=args["schema"],
            if_exists="append",
            index=False
        )
        print(f"✅ {len(df_template_valid)} lignes insérées dans {args['schema']}.{template}")
    except Exception as e:
        print(f"❌ Erreur lors de l'import des données de l'onglet template_{template.upper()} : {e}")
        sys.exit(1)
