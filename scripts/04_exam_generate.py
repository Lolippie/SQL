#!/usr/bin/env python3
"""
ChronicleDB - Générateur de base d'examen
Cours SQL Avancé - ESGI 2025

Génère un script SQL unique par conteneur basé sur l'UUID machine.
Aucune dépendance externe : stdlib Python uniquement.

Volumes générés :
  - 20 zones
  - 30 guildes (réparties sur les zones)
  - 10 à 20 personnages par guilde + ~50 sans guilde
  - donjons, ennemis, quêtes, objets, sessions, combats, progressions

Problèmes intentionnels pour l'audit :
  1. ~8% des personnages actifs ont gold NULL
  2. ~50 doublons métier (noms avec espace parasite)
  3. Index manquants sur combat.date_combat, session.joueur_id, progression_quete.statut
  4. Progressions de quêtes sans prérequis respectés (trigger bypassé)
"""

import random
import sys
import uuid
import os
from itertools import product

# =============================================================================
# SEED : UUID du conteneur pour unicité garantie
# =============================================================================

def get_seed():
    """Lit l'UUID machine du conteneur ou génère un UUID aléatoire."""
    try:
        with open('/etc/machine-id', 'r') as f:
            machine_id = f.read().strip()
            return int(machine_id[:16], 16)
    except Exception:
        return uuid.uuid4().int & 0xFFFFFFFF

SEED = get_seed()
rng = random.Random(SEED)

print(f"-- ChronicleDB Exam Generator | seed={SEED}", file=sys.stderr)

# =============================================================================
# GÉNÉRATEUR DE NOMS FANTASY
# =============================================================================

# Syllabes pour les noms de personnages (courts, mémorables)
PERSO_PREFIXES  = ["Ald","Mor","Thal","Kaz","Lyr","Drav","Ser","Brom","Eld","Vor",
                   "Zeph","Kor","Mal","Neth","Rav","Sol","Tar","Vel","Wyr","Xan",
                   "Aran","Bael","Cyr","Dusk","Evr","Faer","Gath","Hael","Izur","Jael"]
PERSO_SUFFIXES  = ["ic","ath","yn","rix","or","en","ara","iel","us","an",
                   "rak","mir","dor","wen","thas","ion","alis","orn","eth","yr",
                   "oc","ash","ven","dur","ael","ris","mon","tar","xis","oth"]

# Syllabes pour les noms de guildes (évocateurs)
GUILDE_ADJS     = ["Ardent","Sombre","Glacial","Céleste","Infernal","Éternel","Maudit",
                   "Sacré","Oublié","Ancien","Sanglant","Radieux","Obscur","Brillant",
                   "Mystique","Brisé","Forgé","Maudit","Exilé","Renégat"]
GUILDE_NOUNS    = ["Cendres","Flammes","Cristaux","Tempêtes","Abysses","Lames","Ombres",
                   "Phénix","Corbeaux","Loups","Serpents","Aigles","Dragons","Spectres",
                   "Titans","Golems","Runes","Étoiles","Voiles","Âmes"]
GUILDE_TYPES    = ["Ordre des","Confrérie des","Alliance des","Pacte des","Cercle des",
                   "Gardiens des","Hérauts des","Fils des","Lames des","Frères des"]

# Syllabes pour les zones
ZONE_ADJS       = ["Plaines","Forêt","Mines","Marécages","Désert","Toundra","Îles",
                   "Abysses","Citadelle","Volcan","Glacier","Jungle","Ruines","Cavernes",
                   "Falaises","Delta","Steppes","Archipel","Vallée","Cratère"]
ZONE_PREPS      = ["de","du","des","de la","d'","aux"]
ZONE_NAMES      = ["Valdris","Sylvara","Kharduun","Morbeth","Solharr","Noirfond","Crysthalia",
                   "Pyranox","Frostheim","Umbrath","Stoneguard","Dreadmoor","Ashveil",
                   "Ironhold","Shadowfen","Voidspire","Ruinmark","Grimholt","Bleakwater","Thornwall"]

# Syllabes pour les donjons
DONJON_TYPES    = ["Crypte","Sanctuaire","Abîme","Temple","Tour","Tombeau","Forteresse",
                   "Nid","Puits","Trône","Gouffre","Antre","Caveau","Bastion","Labyrinthe"]
DONJON_NAMES    = ["Malkhor","Sylvaris","Grimshaw","Nethara","Valdrak","Pyrath","Frostmaw",
                   "Umbral","Stonecrypt","Dreadhold","Ashveil","Ironspire","Shadowmere",
                   "Voidgate","Thornwall"]

# Syllabes pour les ennemis
ENNEMI_TYPES    = ["Gardien","Spectre","Golem","Cultiste","Archimage","Scarabée","Yéti",
                   "Hydre","Dévoreur","Héraut","Squelette","Chimère","Liche","Titan","Kraken"]
ENNEMI_QUALS    = ["Vétéran","Corrompu","Maudit","Ancestral","Renégat","Enragé","Géant",
                   "des Glaces","des Ombres","du Néant","Hurlant","Infernal","Glacial","Ardent","Brisé"]

# Adjectifs pour les objets
OBJET_ADJS      = ["de Lumière","Sylvain","des Arcanes","de Fer","des Anciens","des Ombres",
                   "Sacré","Maudit","de Vitalité","de Feu","du Vent","Runique","Enchanté",
                   "Glacial","Ardent","Brisé","Forgé","Céleste","Infernal","Éternel"]
OBJET_TYPES_ARME   = ["Épée","Arc","Bâton","Dague","Masse","Hache","Lance","Fléau","Arbalète","Sceptre"]
OBJET_TYPES_ARMURE = ["Armure","Bouclier","Heaume","Jambières","Gantelets","Cape","Bottes","Ceinture","Épaulières","Plastron"]
OBJET_TYPES_CONSO  = ["Potion","Élixir","Parchemin","Onguent","Fiole","Talisman"]
OBJET_TYPES_MAT    = ["Fragment","Essence","Rune","Orbe","Cristal","Gemme","Poudre","Lingot"]

def gen_perso_nom(used: set) -> str:
    for _ in range(1000):
        n = rng.choice(PERSO_PREFIXES) + rng.choice(PERSO_SUFFIXES)
        if n not in used:
            used.add(n)
            return n
    # Fallback avec suffixe numérique
    base = rng.choice(PERSO_PREFIXES) + rng.choice(PERSO_SUFFIXES)
    n = f"{base}_{len(used)}"
    used.add(n)
    return n

def gen_guilde_nom(used: set) -> str:
    for _ in range(1000):
        n = rng.choice(GUILDE_TYPES) + " " + rng.choice(GUILDE_ADJS) + "s"
        if n not in used:
            used.add(n)
            return n
    n = rng.choice(GUILDE_TYPES) + " " + rng.choice(GUILDE_NOUNS) + f"_{len(used)}"
    used.add(n)
    return n

def gen_zone_nom(idx: int) -> str:
    return ZONE_ADJS[idx % len(ZONE_ADJS)] + " " + ZONE_PREPS[idx % len(ZONE_PREPS)] + " " + ZONE_NAMES[idx % len(ZONE_NAMES)]

def gen_donjon_nom(used: set) -> str:
    for _ in range(1000):
        n = rng.choice(DONJON_TYPES) + " de " + rng.choice(DONJON_NAMES)
        if n not in used:
            used.add(n)
            return n
    n = rng.choice(DONJON_TYPES) + f"_{len(used)}"
    used.add(n)
    return n

def gen_ennemi_nom(used: set) -> str:
    for _ in range(1000):
        n = rng.choice(ENNEMI_TYPES) + " " + rng.choice(ENNEMI_QUALS)
        if n not in used:
            used.add(n)
            return n
    n = rng.choice(ENNEMI_TYPES) + f"_{len(used)}"
    used.add(n)
    return n

def gen_objet_nom(type_cat: str, used: set) -> str:
    if type_cat == 'arme':
        bases = OBJET_TYPES_ARME
    elif type_cat == 'armure':
        bases = OBJET_TYPES_ARMURE
    elif type_cat == 'consommable':
        bases = OBJET_TYPES_CONSO
    else:
        bases = OBJET_TYPES_MAT
    for _ in range(1000):
        n = rng.choice(bases) + " " + rng.choice(OBJET_ADJS)
        if n not in used:
            used.add(n)
            return n
    n = rng.choice(bases) + f"_{len(used)}"
    used.add(n)
    return n

def esc(s: str) -> str:
    return s.replace("'", "''")

def rand_ts(start_year=2022, end_year=2024) -> str:
    y = rng.randint(start_year, end_year)
    m = rng.randint(1, 12)
    d = rng.randint(1, 28)
    h = rng.randint(0, 23)
    mi = rng.randint(0, 59)
    return f"{y}-{m:02d}-{d:02d} {h:02d}:{mi:02d}:00"

# =============================================================================
# GÉNÉRATION DU SCRIPT SQL
# =============================================================================

lines = []
w = lines.append

w("-- =============================================================================")
w("-- ChronicleDB - Base d'examen générée dynamiquement")
w(f"-- Seed : {SEED}")
w("-- Cours SQL Avancé - ESGI 2025")
w("-- =============================================================================")
w("")
w("SET session_replication_role = replica;")
w("")

# =============================================================================
# CLASSES ET RACES (identiques pour tout le monde)
# =============================================================================

w("-- Classes")
classes = [
    ("Guerrier","Tank"), ("Mage","DPS magique"), ("Rôdeur","DPS physique"),
    ("Prêtre","Healer"), ("Paladin","Tank / Healer"), ("Voleur","DPS physique"),
    ("Druide","Hybride"), ("Nécromancien","DPS magique"), ("Chaman","Hybride"), ("Barde","Support")
]
vals = ", ".join(f"('{esc(n)}', '{esc(r)}')" for n, r in classes)
w(f"INSERT INTO classe (nom, role) VALUES {vals};")
w("")

w("-- Races")
races = [
    ("Humain","+5% XP gagné"), ("Elfe","+10 précision, -5 endurance"),
    ("Nain","+15 endurance, -5 vitesse"), ("Orque","+20 force, -10 intelligence"),
    ("Halfelin","+10 esquive, -10 force"), ("Draconide","+15 résistance au feu"),
    ("Tieffelin","+10 magie des ombres"), ("Gnome","+15 intelligence, -10 force"),
    ("Aasimar","+10 magie sacrée"), ("Demi-Elfe","+5 à toutes les stats")
]
vals = ", ".join(f"('{esc(n)}', '{esc(b)}')" for n, b in races)
w(f"INSERT INTO race (nom, bonus) VALUES {vals};")
w("")

# =============================================================================
# ZONES : 20 zones
# =============================================================================

NB_ZONES = 20
zone_noms = [gen_zone_nom(i) for i in range(NB_ZONES)]

w("-- Zones")
vals = ", ".join(f"('{esc(nom)}', {max(1, i * 5)})" for i, nom in enumerate(zone_noms))
w(f"INSERT INTO zone (nom, niveau_min) VALUES {vals};")
w("")

# =============================================================================
# GUILDES : 30 guildes réparties sur les zones
# =============================================================================

NB_GUILDES = 30
guilde_used = set()
guildes = []  # (nom, zone_id_1based, niveau)
for i in range(NB_GUILDES):
    nom = gen_guilde_nom(guilde_used)
    zone_id = (i % NB_ZONES) + 1
    niveau = rng.randint(1, 30)
    guildes.append((nom, zone_id, niveau))

w("-- Guildes")
vals = ", ".join(f"({g[1]}, '{esc(g[0])}', {g[2]})" for g in guildes)
w(f"INSERT INTO guilde (zone_id, nom, niveau) VALUES {vals};")
w("")

# =============================================================================
# DONJONS : 2 par zone = 40 donjons
# =============================================================================

donjon_used = set()
donjons = []
for zone_id in range(1, NB_ZONES + 1):
    for _ in range(2):
        nom = gen_donjon_nom(donjon_used)
        diff = rng.choice(["facile","normal","difficile","legendaire"])
        donjons.append((zone_id, nom, diff))

w("-- Donjons")
vals = ", ".join(f"({d[0]}, '{esc(d[1])}', '{d[2]}')" for d in donjons)
w(f"INSERT INTO donjon (zone_id, nom, difficulte) VALUES {vals};")
w("")

# =============================================================================
# ENNEMIS : 3 par donjon
# =============================================================================

ennemi_used = set()
ennemis = []
for donjon_id in range(1, len(donjons) + 1):
    types = ["monstre","monstre","boss"]
    for t in types:
        nom = gen_ennemi_nom(ennemi_used)
        pv = rng.randint(200, 80000)
        ennemis.append((donjon_id, nom, pv, t))

w("-- Ennemis")
vals = ", ".join(f"({e[0]}, '{esc(e[1])}', {e[2]}, '{e[3]}')" for e in ennemis)
w(f"INSERT INTO ennemi (donjon_id, nom, pv, type) VALUES {vals};")
w("")

# =============================================================================
# OBJETS : 120 objets variés, couvrant tous les emplacements d'équipement
# =============================================================================

objet_used = set()
objets = []  # (nom, type, rarete, valeur_gold)
rarete_par_type = {
    'arme':        [("commun",100),("peu_commun",300),("rare",800),("epique",3000),("legendaire",10000)],
    'armure':      [("commun",80), ("peu_commun",250),("rare",600),("epique",2500),("legendaire",8000)],
    'consommable': [("commun",20), ("peu_commun",80), ("rare",200)],
    'materiau':    [("commun",10), ("peu_commun",50), ("rare",150),("epique",500)],
    'quete':       [("commun",0)],
}
# Distribution : plus d'armes et d'armures pour avoir des équipements variés
cats = (['arme'] * 4 + ['armure'] * 4 + ['consommable'] * 2 + ['materiau'] * 2)
for i in range(120):
    cat = cats[i % len(cats)]
    nom = gen_objet_nom(cat, objet_used)
    pool = rarete_par_type[cat]
    rarete, gold = rng.choice(pool)
    gold_jitter = gold + rng.randint(-int(gold * 0.1), int(gold * 0.1) + 1)
    objets.append((nom, cat, rarete, max(0, gold_jitter)))

# Objets de quête
for i in range(5):
    nom = gen_objet_nom('materiau', objet_used)
    objets.append((nom, 'quete', 'commun', 0))

# Index des objets équipables par emplacement pour gen_equipement
# On associe les armes aux emplacements arme_principale/arme_secondaire
# et les armures aux autres emplacements
EMPLACEMENTS = ['tete','torse','jambes','pieds','mains','anneau','amulette',
                'arme_principale','arme_secondaire']
EMPLACEMENTS_ARMURE = ['tete','torse','jambes','pieds','mains','anneau','amulette']
EMPLACEMENTS_ARME   = ['arme_principale','arme_secondaire']

w("-- Objets")
vals = ", ".join(f"('{esc(o[0])}', '{o[1]}', '{o[2]}', {o[3]})" for o in objets)
w(f"INSERT INTO objet (nom, type, rarete, valeur_gold) VALUES {vals};")
w("")

# =============================================================================
# QUÊTES : ~200 quêtes avec chaînes de prérequis
# =============================================================================

NB_QUETES = 200
TYPES_QUETE = ["principale","principale","secondaire","epique","quotidienne"]
TITRES_DEBUT = ["La menace de","Le secret de","Au cœur de","Les rituels de","La tour de",
                "La traversée de","Survivre à","Maîtres de","Le pacte de","La chute de",
                "L'éveil de","Les ombres de","La quête de","Le chemin de","L'épreuve de",
                "Les gardiens de","Le trésor de","La légende de","La malédiction de","Le dernier bastion de"]
TITRES_FIN   = ["Valdris","Sylvara","Kharduun","Morbeth","Crysthalia","Solharr","la Toundra",
                "les Vents","les Abysses","Noirfond","l'Ombre","la Flamme","l'Ancienne",
                "la Tempête","la Glace","la Rune","le Néant","l'Abysse","la Cendre","la Pierre"]

quetes = []
quete_used_titres = set()
for i in range(NB_QUETES):
    titre = rng.choice(TITRES_DEBUT) + " " + rng.choice(TITRES_FIN)
    # Garantir l'unicité du titre
    base_titre = titre
    attempt = 0
    while titre in quete_used_titres:
        attempt += 1
        titre = base_titre + f" {attempt}"
    quete_used_titres.add(titre)
    zone_id = rng.randint(1, NB_ZONES)
    type_q = rng.choice(TYPES_QUETE)
    niveau = rng.randint(1, 80)
    # Prérequis : quêtes paires → quête précédente (chaînes de 2)
    if i > 0 and i % 2 == 1:
        prerequis = i  # id de la quête précédente (1-based = i)
    else:
        prerequis = None
    expiration = None
    if type_q == 'quotidienne':
        expiration = f"2025-{rng.randint(1,12):02d}-{rng.randint(1,28):02d} 23:59:00"
    quetes.append((zone_id, prerequis, titre, type_q, niveau, expiration))

w("-- Quêtes")
rows = []
for q in quetes:
    zone_id, prerequis, titre, type_q, niveau, exp = q
    prereq_sql = str(prerequis) if prerequis else "NULL"
    exp_sql = f"'{exp}'" if exp else "NULL"
    rows.append(f"({zone_id}, {prereq_sql}, '{esc(titre)}', '{type_q}', {niveau}, {exp_sql})")
vals = ", ".join(rows)
w(f"INSERT INTO quete (zone_id, quete_prerequis_id, titre, type, niveau_requis, date_expiration) VALUES {vals};")
w("")

# Récompenses : une par quête
w("-- Récompenses")
rows = []
for i in range(NB_QUETES):
    quete_id = i + 1
    objet_id = rng.randint(1, len(objets)) if rng.random() < 0.7 else "NULL"
    gold = rng.randint(50, 8000)
    xp = rng.randint(100, 25000)
    rows.append(f"({quete_id}, {objet_id}, {gold}, {xp})")
vals = ", ".join(rows)
w(f"INSERT INTO recompense (quete_id, objet_id, gold, xp) VALUES {vals};")
w("")

# =============================================================================
# ÉTAPES DE QUÊTE : 2 à 4 étapes par quête
# =============================================================================

ETAPES_DESCRIPTIONS = [
    "Parler au chef du village",
    "Éliminer les ennemis dans la zone",
    "Rapporter la preuve au commandant",
    "Escorter les survivants jusqu'au camp",
    "Trouver l'entrée secrète du donjon",
    "Résoudre l'énigme des anciens",
    "Vaincre le gardien de la salle",
    "Récupérer l'artefact maudit",
    "Détruire le cristal de contrôle",
    "Libérer les prisonniers",
    "Activer le portail magique",
    "Neutraliser les sentinelles",
    "Collecter les matériaux nécessaires",
    "Infiltrer la forteresse ennemie",
    "Survivre aux vagues d'ennemis",
    "Trouver la sortie secrète",
    "Parlementer avec l'ancien sage",
    "Désamorcer le piège runique",
    "Escorter le messager jusqu'à destination",
    "Purifier la source corrompue",
]

w("-- Étapes de quête")
etapes_rows = []
for i in range(NB_QUETES):
    quete_id = i + 1
    nb_etapes = rng.randint(2, 4)
    etapes_dispo = rng.sample(ETAPES_DESCRIPTIONS, min(nb_etapes, len(ETAPES_DESCRIPTIONS)))
    for ordre, desc in enumerate(etapes_dispo, start=1):
        optionnelle = 'TRUE' if (ordre == nb_etapes and rng.random() < 0.3) else 'FALSE'
        etapes_rows.append(f"({quete_id}, {ordre}, '{esc(desc)}', {optionnelle})")

# Insertion par blocs pour éviter les requêtes trop longues
for i in range(0, len(etapes_rows), 500):
    batch = etapes_rows[i:i+500]
    w(f"INSERT INTO etape_quete (quete_id, ordre, description, optionnelle) VALUES {', '.join(batch)};")
w("")

# =============================================================================
# COMPTES, JOUEURS, PERSONNAGES
# Structure : 10-20 personnages par guilde + ~50 sans guilde
# =============================================================================

perso_used = set()
comptes = []
joueurs = []
personnages = []  # (joueur_idx_1based, classe_id, race_id, guilde_id_or_None, nom, niveau, xp, gold)

joueur_idx = 0

# Personnages par guilde
for guilde_id in range(1, NB_GUILDES + 1):
    nb = rng.randint(10, 20)
    for _ in range(nb):
        joueur_idx += 1
        email = f"joueur{joueur_idx}@chronicle.game"
        date_insc = rand_ts(2020, 2023)
        comptes.append((email, f"hash_{joueur_idx}", date_insc))
        last_co = rand_ts(2024, 2024) if rng.random() > 0.05 else None
        joueurs.append((joueur_idx, last_co))
        nom = gen_perso_nom(perso_used)
        classe_id = rng.randint(1, 10)
        race_id = rng.randint(1, 10)
        niveau = rng.randint(1, 100)
        xp = niveau * rng.randint(800, 1500)
        # PROBLÈME 1 : ~8% gold NULL
        gold = None if rng.random() < 0.08 else rng.randint(0, 50000)
        personnages.append((joueur_idx, classe_id, race_id, guilde_id, nom, niveau, xp, gold))

# Personnages sans guilde (~50)
NB_SANS_GUILDE = 50
for _ in range(NB_SANS_GUILDE):
    joueur_idx += 1
    email = f"joueur{joueur_idx}@chronicle.game"
    date_insc = rand_ts(2020, 2023)
    comptes.append((email, f"hash_{joueur_idx}", date_insc))
    last_co = rand_ts(2024, 2024) if rng.random() > 0.1 else None
    joueurs.append((joueur_idx, last_co))
    nom = gen_perso_nom(perso_used)
    classe_id = rng.randint(1, 10)
    race_id = rng.randint(1, 10)
    niveau = rng.randint(1, 60)
    xp = niveau * rng.randint(500, 1200)
    gold = None if rng.random() < 0.08 else rng.randint(0, 20000)
    personnages.append((joueur_idx, classe_id, race_id, None, nom, niveau, xp, gold))

NB_JOUEURS = joueur_idx
NB_PERSO   = len(personnages)

w("-- Comptes")
vals = ", ".join(f"('{esc(c[0])}', '{c[1]}', '{c[2]}')" for c in comptes)
w(f"INSERT INTO compte (email, mot_de_passe, date_inscription) VALUES {vals};")
w("")

w("-- Joueurs")
rows = []
for j_id, last_co in joueurs:
    lc = f"'{last_co}'" if last_co else "NULL"
    pseudo = f"player_{j_id}_{SEED % 9999:04d}"
    rows.append(f"({j_id}, '{pseudo}', {lc})")
vals = ", ".join(rows)
w(f"INSERT INTO joueur (compte_id, pseudo, derniere_connexion) VALUES {vals};")
w("")

w("-- Personnages")
rows = []
for p in personnages:
    j_id, cls, race, guilde, nom, niv, xp, gold = p
    g_sql = str(guilde) if guilde else "NULL"
    gold_sql = str(gold) if gold is not None else "NULL"
    rows.append(f"({j_id}, {cls}, {race}, {g_sql}, '{esc(nom)}', {niv}, {xp}, {gold_sql})")
vals = ", ".join(rows)
w(f"INSERT INTO personnage (joueur_id, classe_id, race_id, guilde_id, nom, niveau, xp, gold) VALUES {vals};")
w("")

# =============================================================================
# PROBLÈME 2 : DOUBLONS MÉTIER (~50 personnages avec espace parasite)
# =============================================================================

w("-- PROBLÈME 2 : doublons métier (noms avec espace parasite)")
perso_noms_liste = list(perso_used)
rows = []
dup_used = set()
for i in range(50):
    base_nom = rng.choice(perso_noms_liste)
    # Espace parasite = doublon métier non détecté par UNIQUE (nom différent)
    dup_nom = base_nom + " _dup"
    if dup_nom in dup_used:
        dup_nom = base_nom + f" _dup{i}"
    dup_used.add(dup_nom)
    joueur_id = rng.randint(1, NB_JOUEURS)
    classe_id = rng.randint(1, 10)
    race_id   = rng.randint(1, 10)
    guilde_id = rng.randint(1, NB_GUILDES) if rng.random() > 0.3 else "NULL"
    niveau = rng.randint(1, 30)
    xp = niveau * rng.randint(200, 600)
    gold = None if rng.random() < 0.3 else rng.randint(0, 2000)
    gold_sql = str(gold) if gold is not None else "NULL"
    rows.append(f"({joueur_id}, {classe_id}, {race_id}, {guilde_id}, '{esc(dup_nom)}', {niveau}, {xp}, {gold_sql})")
vals = ", ".join(rows)
w(f"INSERT INTO personnage (joueur_id, classe_id, race_id, guilde_id, nom, niveau, xp, gold) VALUES {vals};")
w("")

NB_PERSO_TOTAL = NB_PERSO + 50

# =============================================================================
# SESSIONS : ~500 000 lignes via generate_series
# =============================================================================

w("-- Sessions (volume via generate_series)")
w(f"""INSERT INTO session (joueur_id, debut, fin)
SELECT
    1 + (random() * {NB_JOUEURS - 1})::int,
    '2022-01-01'::timestamp + (random() * INTERVAL '1095 days'),
    CASE WHEN random() < 0.05 THEN NULL
         ELSE '2022-01-01'::timestamp + (random() * INTERVAL '1095 days')
              + (INTERVAL '5 minutes' + (random() * INTERVAL '355 minutes'))
    END
FROM generate_series(1, 500000);""")
w("")
w("""UPDATE session
SET fin = debut + (INTERVAL '10 minutes' + (random() * INTERVAL '120 minutes'))
WHERE fin IS NOT NULL AND fin <= debut;""")
w("")

# =============================================================================
# COMBATS : ~2 000 000 lignes via generate_series
# =============================================================================

NB_ENNEMIS = len(ennemis)
w("-- Combats (volume via generate_series)")
w(f"""INSERT INTO combat (personnage_id, ennemi_id, date_combat, victoire, degats)
SELECT
    1 + (random() * {NB_PERSO_TOTAL - 1})::int,
    1 + (random() * {NB_ENNEMIS - 1})::int,
    '2022-01-01'::timestamp + (random() * INTERVAL '1095 days'),
    random() < 0.68,
    GREATEST(10, LEAST(8000, (50 + random() * 500 + random() * random() * 7000)::int))
FROM generate_series(1, 2000000);""")
w("")

# =============================================================================
# INVENTAIRE : ~3 lignes par personnage en moyenne
# =============================================================================

NB_OBJETS = len(objets)

# Index des objets par type pour l'équipement
ids_armes   = [i+1 for i, o in enumerate(objets) if o[1] == 'arme']
ids_armures = [i+1 for i, o in enumerate(objets) if o[1] == 'armure']

w("-- Inventaire")
w(f"""INSERT INTO inventaire (personnage_id, objet_id, quantite)
SELECT DISTINCT ON (pid, oid) pid, oid, 1 + (random() * 9)::int
FROM (
    SELECT 1 + (random() * {NB_PERSO_TOTAL - 1})::int AS pid,
           1 + (random() * {NB_OBJETS - 1})::int AS oid
    FROM generate_series(1, {NB_PERSO_TOTAL * 5})
) sub;""")
w("")

# =============================================================================
# ÉQUIPEMENT : 2 à 5 emplacements par personnage
# Règles :
#   - arme_principale et arme_secondaire → objets de type 'arme'
#   - autres emplacements → objets de type 'armure'
#   - un personnage ne peut avoir qu'un objet par emplacement (UNIQUE)
#   - ~70% des personnages ont de l'équipement
# =============================================================================

w("-- Équipement")
equip_rows = []
equip_seen = set()  # (personnage_id, emplacement) pour garantir l'unicité

for perso_idx in range(NB_PERSO_TOTAL):
    perso_id = perso_idx + 1
    if rng.random() > 0.70:
        continue

    # Choisir aléatoirement 2 à 5 emplacements distincts
    nb_emplacements = rng.randint(2, 5)
    emplacements_choisis = rng.sample(EMPLACEMENTS, nb_emplacements)

    for emplacement in emplacements_choisis:
        key = (perso_id, emplacement)
        if key in equip_seen:
            continue
        equip_seen.add(key)

        if emplacement in EMPLACEMENTS_ARME:
            if not ids_armes:
                continue
            objet_id = rng.choice(ids_armes)
        else:
            if not ids_armures:
                continue
            objet_id = rng.choice(ids_armures)

        date_equipe = rand_ts(2022, 2024)
        equip_rows.append(f"({perso_id}, {objet_id}, '{emplacement}', '{date_equipe}')")

for i in range(0, len(equip_rows), 500):
    batch = equip_rows[i:i+500]
    w(f"INSERT INTO equipement (personnage_id, objet_id, emplacement, equipe_le) VALUES {', '.join(batch)};")
w("")

# =============================================================================
# PROGRESSIONS : générées en Python avec cohérence métier
#
# Règles appliquées :
#   - Un personnage ne peut progresser que sur des quêtes dont le niveau_requis
#     est <= son niveau
#   - Les quêtes avec prérequis ne sont ajoutées que si le prérequis est déjà
#     au statut 'terminee' pour ce personnage (chaîne respectée)
#   - Distribution réaliste des statuts selon le niveau du personnage :
#     haut niveau → plus de 'terminee', bas niveau → plus 'en_cours'/'abandonnee'
#   - ~5 progressions par personnage en moyenne
#
# PROBLÈME 4 (intentionnel) : ~15% des progressions violent les prérequis
#   On insère directement sans respecter la contrainte (trigger bypassé)
#   Ces violations doivent être détectées par les étudiants
# =============================================================================

# Index des quêtes pour la génération cohérente
# quetes[i] = (zone_id, prerequis_id_or_None, titre, type, niveau_requis, expiration)
# prerequis est l'index 0-based dans quetes[] (pas le id SQL qui est i+1)

def statut_pour_niveau(niveau_perso: int) -> str:
    """Retourne un statut réaliste selon le niveau du personnage."""
    if niveau_perso >= 60:
        return rng.choices(
            ['terminee', 'terminee', 'terminee', 'en_cours', 'abandonnee'],
            weights=[60, 60, 60, 15, 5]
        )[0]
    elif niveau_perso >= 30:
        return rng.choices(
            ['terminee', 'en_cours', 'abandonnee', 'echouee'],
            weights=[45, 30, 20, 5]
        )[0]
    else:
        return rng.choices(
            ['terminee', 'en_cours', 'abandonnee', 'echouee'],
            weights=[20, 45, 25, 10]
        )[0]

progressions_reelles = []   # (perso_id, quete_id, statut, date_debut, date_fin)
progressions_violations = []  # idem mais sans respecter les prérequis

for perso_idx, perso in enumerate(personnages):
    perso_id = perso_idx + 1
    j_id, cls, race, guilde, nom, niveau, xp, gold = perso

    # Quêtes accessibles : niveau_requis <= niveau du personnage
    quetes_accessibles = [
        (i, q) for i, q in enumerate(quetes)
        if q[4] <= niveau  # q[4] = niveau_requis
    ]
    if not quetes_accessibles:
        continue

    # Nombre de progressions pour ce personnage (~3 à 8)
    # min() pour éviter randint(3, x) avec x < 3
    nb_max = min(8, len(quetes_accessibles))
    nb_prog = rng.randint(min(3, nb_max), nb_max)
    quetes_choisies = rng.sample(quetes_accessibles, min(nb_prog, len(quetes_accessibles)))

    # Trier par niveau requis pour faciliter la résolution des prérequis
    quetes_choisies.sort(key=lambda x: x[1][4])

    # Ensemble des quêtes terminées pour ce personnage (pour vérifier les prérequis)
    terminees = set()
    perso_progs = []

    for q_idx, q in quetes_choisies:
        quete_id = q_idx + 1
        prerequis_idx = q[1]  # index 0-based du prérequis dans quetes[], ou None

        # Vérification du prérequis
        if prerequis_idx is not None:
            prerequis_id = prerequis_idx + 1
            if prerequis_id not in terminees:
                # Prérequis non satisfait → on saute cette quête pour les progressions réalistes
                continue

        statut = statut_pour_niveau(niveau)
        date_debut = rand_ts(2022, 2024)

        if statut == 'terminee':
            date_fin = rand_ts(2022, 2024)
            terminees.add(quete_id)
        elif statut == 'en_cours':
            date_fin = None
        else:
            date_fin = rand_ts(2022, 2024)

        perso_progs.append((perso_id, quete_id, statut, date_debut, date_fin))

    progressions_reelles.extend(perso_progs)

# PROBLÈME 4 : ~15% de violations intentionnelles
# On prend des quêtes avec prérequis et on les insère sans vérifier
nb_violations = len(progressions_reelles) // 7
quetes_avec_prereq = [(i, q) for i, q in enumerate(quetes) if q[1] is not None]
paires_existantes = {(p[0], p[1]) for p in progressions_reelles}

for _ in range(nb_violations * 3):  # tenter 3x plus pour compenser les collisions
    if len(progressions_violations) >= nb_violations:
        break
    perso_id = rng.randint(1, NB_PERSO_TOTAL)
    if not quetes_avec_prereq:
        break
    q_idx, q = rng.choice(quetes_avec_prereq)
    quete_id = q_idx + 1
    if (perso_id, quete_id) in paires_existantes:
        continue
    paires_existantes.add((perso_id, quete_id))
    statut = rng.choice(['terminee', 'en_cours', 'abandonnee'])
    date_debut = rand_ts(2022, 2024)
    date_fin = rand_ts(2022, 2024) if statut != 'en_cours' else None
    progressions_violations.append((perso_id, quete_id, statut, date_debut, date_fin))

toutes_progressions = progressions_reelles + progressions_violations

# Dédoublonnage final sur (personnage_id, quete_id) — sécurité supplémentaire
seen_pairs = set()
progressions_finales = []
for p in toutes_progressions:
    key = (p[0], p[1])
    if key not in seen_pairs:
        seen_pairs.add(key)
        progressions_finales.append(p)

w(f"-- Progressions de quêtes ({len(progressions_reelles)} réalistes + {len(progressions_violations)} violations intentionnelles)")
rows = []
for p in progressions_finales:
    perso_id, quete_id, statut, date_debut, date_fin = p
    date_fin_sql = f"'{date_fin}'" if date_fin else "NULL"
    rows.append(f"({perso_id}, {quete_id}, '{statut}', '{date_debut}', {date_fin_sql})")

# Insérer par blocs de 500 pour éviter les requêtes trop longues
BATCH = 500
for i in range(0, len(rows), BATCH):
    batch = rows[i:i+BATCH]
    w(f"INSERT INTO progression_quete (personnage_id, quete_id, statut, date_debut, date_fin) VALUES {', '.join(batch)};")
w("")

# =============================================================================
# PROBLÈME 3 : INDEX MANQUANTS
# =============================================================================

w("-- PROBLÈME 3 : suppression d'index pour simuler une base non optimisée")
w("DROP INDEX IF EXISTS idx_combat_date;")
w("DROP INDEX IF EXISTS idx_session_joueur;")
w("DROP INDEX IF EXISTS idx_progression_statut;")
w("")

# =============================================================================
# FIN
# =============================================================================

w("SET session_replication_role = DEFAULT;")
w("")
w("-- Vérification des volumes")
w("""SELECT 'personnage'       AS table_name, COUNT(*) AS nb_lignes FROM personnage
UNION ALL SELECT 'guilde',               COUNT(*) FROM guilde
UNION ALL SELECT 'quete',                COUNT(*) FROM quete
UNION ALL SELECT 'combat',               COUNT(*) FROM combat
UNION ALL SELECT 'session',              COUNT(*) FROM session
UNION ALL SELECT 'inventaire',           COUNT(*) FROM inventaire
UNION ALL SELECT 'progression_quete',    COUNT(*) FROM progression_quete
ORDER BY nb_lignes DESC;""")
w("")
w("-- Vérification des problèmes intentionnels")
w("""SELECT '-- gold NULL sur personnages actifs' AS audit, COUNT(*) AS nb
FROM personnage p
JOIN session s ON s.joueur_id = p.joueur_id
WHERE p.gold IS NULL AND s.fin IS NOT NULL
UNION ALL
SELECT '-- doublons metier (espace parasite)', COUNT(*)
FROM personnage WHERE nom LIKE '% _dup%'
UNION ALL
SELECT '-- violations de prerequis', COUNT(*)
FROM progression_quete pq
JOIN quete q ON q.id = pq.quete_id
WHERE q.quete_prerequis_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM progression_quete pq2
    WHERE pq2.personnage_id = pq.personnage_id
    AND pq2.quete_id = q.quete_prerequis_id
    AND pq2.statut = 'terminee'
);""")

# =============================================================================
# SORTIE
# =============================================================================

print("\n".join(lines))
