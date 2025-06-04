## Process à executer côté CEN Ariege

- A faire une fois lorsqu'on clone le repo :

  - créer une BDD PostgreSQL avec un user
    (voir scripts template monitoring pour la creation de la base))

  - cloner le depôt

    ```bash
    git clone git@gitlab.com:natural-solutions/geonature/cen-ariege/template_import_zh/template_zh.git
    cd template_zh
    nom_bdd=cendb # indiquer ici le nom de la base de données
    utilisateur_bdd=cenadmin # indiquer ici le nom de l'utilisateur de la base de données
    ```

  - créer les tables de nomenclatures (permettra de contrôler que les nomenclatures remplies dans le template existent bien et sont correctes)
    ```bash
    # se placer dans le dossier tempate_zh si pas déjà fait (cd template_zh)
    psql -U $utilisateur_bdd -d $nom_bdd -f import_zh.sql
    ```
  - créer l'environnement virtuel python (va permettre d'importer facilement les données des différents onglets du xlsx, au lieu de devoir convertir chaque onglet en csv):

    ```bash
    sudo apt update
    sudo apt install python3 python3-venv python3-pip # installation python si nécessaire
    python3 -m venv venv # creation de l'env virtuel
    source venv/bin/activate # activation de l'env virtuel
    pip install -r requirements.txt # installation des librairies pour importer les fichiers xlsx
    ```

- A faire pour chaque fichier à importer :

  - Modifier le nom du partenaire dans la ligne de commande suivante (utilisé comme nom de schema dans la BDD)
  - Cela permet de crééer un schema dédié pour chaque partenaire qui partage ses données
  - Le script create_tables.sql créé donc un schema et les tables dédiées aux données du partenaire

    ```bash
    nom_bdd=cendb # indiquer ici le nom de la base de données
    utilisateur_bdd=cenadmin # indiquer ici le nom de l'utilisateur de la base de données
    chemin_xlsx=/home/path/to/tempate_zh/template_zh.xlsx
    nom_partenaire=organisation1
    psql -U $utilisateur_bdd -d $nom_bdd -v schema_name=$nom_partenaire -f create_tables.sql
    ```

  - importer les données du template xlsx dans le schema du partenaire :
    ```bash # se placer dans le répertoire qui contient le script import_script.py (et avoir un environnement virtuel python actif : source venv/bin/activate)
    python import_script.py \
     fichier=$chemin_xlsx \
     schema=zh_import*$nom_partenaire \
        utilisateur=$utilisateur_bdd \
     base=$nom_bdd \
     --hote=localhost \
     --port=5432
    ```

Cette commande (python import_script.py) permet d'importer les données dans la base de données que vous avez créée en faisant une série de vérification sur la validité des données. Si le fichier contient une erreur (par exemple un uuid inconnu dans les activités humaines), l'erreur sera décrite dans le terminal. S'il n'y a pas d'erreur, le nb de données importées dans la base sera décrit. Ex :
✅ 3 lignes insérées dans zh_import_organisme1.t_zh
✅ 4 lignes insérées dans zh_import_organisme1.activ_hum
✅ 4 lignes insérées dans zh_import_organisme1.entree_eau
✅ 3 lignes insérées dans zh_import_organisme1.sortie_eau
✅ 3 lignes insérées dans zh_import_organisme1.fonctions_hydro
✅ 3 lignes insérées dans zh_import_organisme1.fonctions_bio

En complément de ces vérifications, un contrôle visuel peut-être réalisé à l'aide de la vue "nom_schema_partenaire.visu_zh_to_import". Cette vue permet de visualiser toutes les données importées et décodées (affichage du mnemonique à la place de l'id). Chaque ligne correspond à une zone humide. Lorsque certaines colonnes peuvent contenir plusieurs valeurs pour une même zone humide (par exemple : critères de délimitation, Corine Biotopes, activités humaines, etc.), il est possible de cliquer sur la flèche présente dans la cellule concernée pour dérouler et afficher le détail de ces valeurs.
