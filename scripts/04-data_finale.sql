-- =============================================================================
-- ChronicleDB - Base d'examen (chronicle_finale)
-- Cours SQL Avancé - ESGI 2025
-- Prérequis : chronicle_finale doit exister et avoir la structure de 01_structure.sql
-- Appelé depuis 00_init.sql après \c chronicle_finale
-- =============================================================================
-- Volume cible :
--   personnage  : ~1000
--   guilde      : ~100
--   quete       : ~200
--   combat      : ~2 000 000
--   session     : ~500 000
--   inventaire  : ~3000
--   progression : ~5000
-- =============================================================================
-- Problèmes intentionnellement introduits pour l'audit :
--   1. Doublons métier sur personnage (noms quasi-identiques)
--   2. NULL incohérents sur gold (personnages actifs avec gold NULL)
--   3. Index manquants sur les colonnes les plus requêtées
--   4. Progressions de quêtes sans prérequis respectés
--      (trigger désactivé pendant le chargement)
--   5. Requêtes métier à performances dégradées (pas d'index sur date_combat)
-- =============================================================================

-- Désactivation temporaire des contraintes pour le chargement massif
SET session_replication_role = replica;

-- =============================================================================
-- DONNÉES DE RÉFÉRENCE (classes, races) : réutilisation du jeu standard
-- =============================================================================

INSERT INTO classe (nom, role) VALUES
    ('Guerrier',     'Tank'),
    ('Mage',         'DPS magique'),
    ('Rôdeur',       'DPS physique'),
    ('Prêtre',       'Healer'),
    ('Paladin',      'Tank / Healer'),
    ('Voleur',       'DPS physique'),
    ('Druide',       'Hybride'),
    ('Nécromancien', 'DPS magique'),
    ('Chaman',       'Hybride'),
    ('Barde',        'Support');

INSERT INTO race (nom, bonus) VALUES
    ('Humain',    '+5% XP gagné'),
    ('Elfe',      '+10 précision, -5 endurance'),
    ('Nain',      '+15 endurance, -5 vitesse'),
    ('Orque',     '+20 force, -10 intelligence'),
    ('Halfelin',  '+10 esquive, -10 force'),
    ('Draconide', '+15 résistance au feu'),
    ('Tieffelin', '+10 magie des ombres'),
    ('Gnome',     '+15 intelligence, -10 force'),
    ('Aasimar',   '+10 magie sacrée'),
    ('Demi-Elfe', '+5 à toutes les stats');

-- =============================================================================
-- ZONES : 20 zones
-- =============================================================================

INSERT INTO zone (nom, niveau_min)
SELECT
    'Zone-' || s || ' : ' ||
    (ARRAY [ 'Plaines','Forêt','Mines','Marécage','Cité','Désert','Toundra',
            'Îles','Abysses','Citadelle','Volcan','Glacier','Jungle','Ruines',
            'Cavernes','Falaises','Delta','Steppe','Archipel','Néant'])[s],
    GREATEST(1, ((s - 1) * 5))
FROM generate_series(1, 20) s;

-- =============================================================================
-- GUILDES : 100 guildes réparties sur les 20 zones
-- =============================================================================

INSERT INTO guilde (zone_id, nom, niveau)
SELECT
    1 + ((s - 1) % 20),
    (ARRAY['Les','La','Ordre des','Confrérie des','Alliance des',
            'Pacte des','Cercle des','Gardiens des','Hérauts des','Fils des'])[1 + ((s-1) % 10)]
    || ' ' ||
    (ARRAY['Ombres','Flammes','Cristaux','Tempêtes','Abysses',
            'Lames','Anciens','Cendres','Étoiles','Runes',
            'Dragons','Spectres','Gobelins','Titans','Golems',
            'Phénix','Corbeaux','Loups','Serpents','Aigles'])[1 + ((s-1) % 20)],
    1 + (random() * 29)::int
FROM generate_series(1, 100) s;

-- =============================================================================
-- DONJONS : 40 donjons
-- =============================================================================

INSERT INTO donjon (zone_id, nom, difficulte)
SELECT
    1 + ((s - 1) % 20),
    (ARRAY['Crypte','Sanctuaire','Abîme','Temple','Tour',
            'Tombeau','Forteresse','Nid','Puits','Trône',
            'Gouffre','Antre','Caveau','Bastion','Citadelle',
            'Labyrinthe','Donjon','Repaire','Terrier','Vault'])[1 + ((s-1) % 20)]
    || ' de ' ||
    (ARRAY['Malkhor','Sylvaris','Kharduun','Morbeth','Crysth',
            'Solharr','Glacius','Tempestus','Noirfond','Néantis',
            'Pyranox','Frostheim','Umbrath','Stoneguard','Dreadmoor',
            'Ashveil','Ironhold','Shadowfen','Voidspire','Ruinmark'])[1 + ((s-1) % 20)],
    (ARRAY['facile','normal','difficile','legendaire'])[1 + ((s-1) % 4)]
FROM generate_series(1, 40) s;

-- =============================================================================
-- ENNEMIS : 120 ennemis (3 par donjon)
-- =============================================================================

INSERT INTO ennemi (donjon_id, nom, pv, type)
SELECT
    1 + ((s - 1) % 40),
    (ARRAY['Gardien','Spectre','Golem','Cultiste','Archimage',
            'Scarabée','Yéti','Aigle','Âme','Héraut',
            'Squelette','Hydre','Kraken','Anubis','Dragon',
            'Dévoreur','Seigneur','Chimère','Liche','Titan'])[1 + ((s-1) % 20)]
    || ' ' ||
    (ARRAY['Vétéran','Hurlant','de Pierre','du Marais','Renégat',
            'Géant','des Glaces','Foudroyant','Damnée','du Néant',
            'Corrompu','des Marécages','des Abysses','Corrompu','de Givre',
            'd''Âmes','des Tempêtes','Maudit','des Ombres','Ancestral'])[1 + ((s-1) % 20)],
    GREATEST(200, (random() * 80000)::int),
    (ARRAY['monstre','monstre','monstre','elite','elite','boss','raid'])[1 + ((s-1) % 7)]
FROM generate_series(1, 120) s;

-- =============================================================================
-- OBJETS : 50 objets
-- =============================================================================

INSERT INTO objet (nom, type, rarete, valeur_gold)
SELECT
    (ARRAY['Épée','Arc','Bâton','Bouclier','Armure','Dague','Masse',
            'Grimoire','Amulette','Anneau','Cape','Bottes','Gants',
            'Heaume','Ceinture','Potion','Élixir','Parchemin',
            'Fragment','Essence','Rune','Orbe','Cristal','Gemme','Totem'])[1 + ((s-1) % 25)]
    || ' ' ||
    (ARRAY['de Lumière','Sylvain','des Arcanes','de Fer','des Anciens',
            'des Ombres','Sacrée','Maudit','de Vitalité','de Feu',
            'du Vent','de Sprint','de Fer','Runique','Enchanté',
            'de Soin','de Force','de Téléportation','de Cristal','de Dragon',
            'de Pouvoir','du Néant','Ardent','Glacial','Maudit'])[1 + ((s-1) % 25)],
    (ARRAY['arme','arme','armure','armure','consommable','materiau','quete'])[1 + ((s-1) % 7)],
    (ARRAY['commun','commun','peu_commun','rare','rare','epique','legendaire'])[1 + ((s-1) % 7)],
    (ARRAY[0,50,150,300,500,800,1500,2500,5000,10000,15000])[1 + ((s-1) % 11)]
FROM generate_series(1, 50) s;

-- =============================================================================
-- QUÊTES : 200 quêtes avec chaînes de prérequis
-- Les quêtes paires ont la quête précédente comme prérequis (chaînes de 2)
-- Les quêtes multiples de 10 pointent vers une quête "maître" (chaînes de 3)
-- =============================================================================

INSERT INTO quete (zone_id, quete_prerequis_id, titre, type, niveau_requis, date_expiration)
SELECT
    1 + ((s - 1) % 20),
    -- Prérequis : quêtes paires → quête précédente, multiples de 10 → quête -9
    CASE
        WHEN s % 10 = 0 THEN s - 9   -- fin de chaîne longue
        WHEN s % 2 = 0  THEN s - 1   -- fin de chaîne courte
        ELSE NULL                     -- quête de départ
    END,
    (ARRAY['La menace de','Le secret de','Au cœur de','Les rituels de',
            'La tour de','La traversée de','Survivre à','Maîtres de',
            'Le pacte de','La chute de','L''éveil de','Les ombres de',
            'La quête de','Le chemin de','L''épreuve de','Les gardiens de',
            'Le trésor de','La légende de','La malédiction de','Le dernier bastion de'])[1 + ((s-1) % 20)]
    || ' ' ||
    (ARRAY['Valdris','Sylvara','Kharduun','Morbeth','Crysthalia',
            'Solharr','la Toundra','les Vents','les Abysses','Noirfond',
            'l''Ombre','la Flamme','l''Ancienne','la Tempête','la Glace',
            'la Rune','le Néant','l''Abysse','la Cendre','la Pierre'])[1 + ((s-1) % 20)],
    (ARRAY['principale','principale','secondaire','epique','quotidienne'])[1 + ((s-1) % 5)],
    GREATEST(1, ((s - 1) / 5 * 2)),
    CASE WHEN s % 5 = 0
        THEN NOW() + (random() * INTERVAL '60 days') - INTERVAL '30 days'
        ELSE NULL
    END
FROM generate_series(1, 200) s;

-- =============================================================================
-- RÉCOMPENSES : une par quête
-- =============================================================================

INSERT INTO recompense (quete_id, objet_id, gold, xp)
SELECT
    s,
    CASE WHEN random() < 0.7 THEN 1 + (random() * 49)::int ELSE NULL END,
    (random() * 5000)::int,
    GREATEST(100, (random() * 20000)::int)
FROM generate_series(1, 200) s;

-- =============================================================================
-- COMPTES, JOUEURS, PERSONNAGES : ~1000 personnages
-- =============================================================================

INSERT INTO compte (email, mot_de_passe, date_inscription)
SELECT
    'joueur' || s || '@chronicle.game',
    'hash_' || md5(s::text),
    '2020-01-01'::timestamp + (random() * INTERVAL '1800 days')
FROM generate_series(1, 1000) s;

INSERT INTO joueur (compte_id, pseudo, derniere_connexion)
SELECT
    s,
    (ARRAY['Aldric','Seraph','Thorin','Lirien','Morrig','Davan',
            'Isolde','Kazrak','Elara','Brom','Sylvan','Grunt',
            'Nessa','Corvin','Yara','Orin','Tamsin','Zephyr',
            'Petra','Idris','Valdris','Kharr','Morbeth','Crysth',
            'Solharr'])[1 + ((s-1) % 25)]
    || '_' || s,
    CASE
        WHEN random() < 0.1 THEN NULL  -- 10% de joueurs jamais connectés
        ELSE '2024-01-01'::timestamp + (random() * INTERVAL '325 days')
    END
FROM generate_series(1, 1000) s;

-- Personnages principaux (un par joueur)
INSERT INTO personnage (joueur_id, classe_id, race_id, guilde_id, nom, niveau, xp, gold)
SELECT
    s,
    1 + (random() * 9)::int,
    1 + (random() * 9)::int,
    CASE WHEN random() < 0.15 THEN NULL  -- 15% sans guilde
         ELSE 1 + (random() * 99)::int
    END,
    (ARRAY['Aldric','Seraph','Thorin','Lirien','Morrig','Davan',
            'Isolde','Kazrak','Elara','Brom','Sylvan','Grunt',
            'Nessa','Corvin','Yara','Orin','Tamsin','Zephyr',
            'Petra','Idris','Valdris','Kharr','Morbeth','Crysth',
            'Solharr'])[1 + ((s-1) % 25)]
    || '_' || s,
    1 + (random() * 99)::int,
    (random() * 800000)::int,
    -- PROBLÈME 1 : gold NULL sur 8% des personnages actifs (incohérence métier)
    CASE WHEN random() < 0.08 THEN NULL
         ELSE (random() * 50000)::int
    END
FROM generate_series(1, 1000) s;

-- =============================================================================
-- PROBLÈME 2 : DOUBLONS MÉTIER
-- ~50 personnages dont le nom est quasi-identique à un existant
-- (espace en trop, majuscule différente, caractère accentué manquant)
-- =============================================================================

INSERT INTO personnage (joueur_id, classe_id, race_id, guilde_id, nom, niveau, xp, gold)
SELECT
    1 + (random() * 999)::int,
    1 + (random() * 9)::int,
    1 + (random() * 9)::int,
    CASE WHEN random() < 0.2 THEN NULL ELSE 1 + (random() * 99)::int END,
    -- Doublon métier : même base de nom, légère variation
    (ARRAY['Aldric','Seraph','Thorin','Lirien','Morrig','Davan',
            'Isolde','Kazrak','Elara','Brom','Sylvan','Grunt',
            'Nessa','Corvin','Yara','Orin','Tamsin','Zephyr',
            'Petra','Idris','Valdris','Kharr','Morbeth','Crysth',
            'Solharr'])[1 + ((s-1) % 25)]
    || ' _' || s || '_dup',  -- espace parasite = doublon métier
    1 + (random() * 30)::int,
    (random() * 10000)::int,
    CASE WHEN random() < 0.3 THEN NULL ELSE (random() * 2000)::int END
FROM generate_series(1, 50) s;

-- =============================================================================
-- SESSIONS : ~500 000 lignes
-- =============================================================================

INSERT INTO session (joueur_id, debut, fin)
SELECT
    1 + (random() * 999)::int,
    '2022-01-01'::timestamp + (random() * INTERVAL '1095 days'),
    CASE
        WHEN random() < 0.05 THEN NULL  -- 5% de sessions non fermées
        ELSE '2022-01-01'::timestamp
             + (random() * INTERVAL '1095 days')
             + (INTERVAL '5 minutes' + (random() * INTERVAL '355 minutes'))
    END
FROM generate_series(1, 500000) s;

UPDATE session
SET fin = debut + (INTERVAL '10 minutes' + (random() * INTERVAL '120 minutes'))
WHERE fin IS NOT NULL AND fin <= debut;

-- =============================================================================
-- COMBATS : ~2 000 000 lignes
-- PROBLÈME 3 : pas d'index sur date_combat dans ce script
-- (les index du script de structure existent, mais on en supprime certains
--  après le chargement pour simuler une base non optimisée)
-- =============================================================================

INSERT INTO combat (personnage_id, ennemi_id, date_combat, victoire, degats)
SELECT
    1 + (random() * 1049)::int,  -- 1050 personnages (1000 + 50 doublons)
    1 + (random() * 119)::int,
    '2022-01-01'::timestamp + (random() * INTERVAL '1095 days'),
    random() < 0.68,
    GREATEST(10, LEAST(8000, (50 + random() * 500 + random() * random() * 7000)::int))
FROM generate_series(1, 2000000) s;

-- =============================================================================
-- INVENTAIRE : ~3000 lignes
-- =============================================================================

INSERT INTO inventaire (personnage_id, objet_id, quantite)
SELECT DISTINCT ON (pid, oid)
    pid, oid,
    1 + (random() * 9)::int
FROM (
    SELECT
        1 + (random() * 1049)::int AS pid,
        1 + (random() * 49)::int  AS oid
    FROM generate_series(1, 5000) s
) sub
LIMIT 3000;

-- =============================================================================
-- PROGRESSIONS DE QUÊTES : ~5000 lignes
-- PROBLÈME 4 : certaines progressions violent les prérequis
-- (trigger désactivé via session_replication_role = replica)
-- On génère des progressions sur des quêtes avec prérequis
-- sans s'assurer que le prérequis est terminé
-- =============================================================================

INSERT INTO progression_quete (personnage_id, quete_id, statut, date_debut, date_fin)
SELECT DISTINCT ON (pid, qid)
    pid,
    qid,
    (ARRAY['terminee','terminee','en_cours','abandonnee','echouee'])[1 + (random() * 4)::int],
    '2022-01-01'::timestamp + (random() * INTERVAL '1000 days'),
    CASE WHEN random() < 0.3 THEN NULL
         ELSE '2022-01-01'::timestamp + (random() * INTERVAL '1095 days')
    END
FROM (
    SELECT
        1 + (random() * 1049)::int AS pid,
        1 + (random() * 199)::int  AS qid
    FROM generate_series(1, 8000) s
) sub
LIMIT 5000;

UPDATE progression_quete
SET date_fin = date_debut + (INTERVAL '1 hour' + (random() * INTERVAL '20 days'))
WHERE date_fin IS NOT NULL AND date_fin < date_debut;

UPDATE progression_quete
SET date_fin = NULL
WHERE statut = 'en_cours' AND date_fin IS NOT NULL;

-- =============================================================================
-- PROBLÈME 3 : SUPPRESSION D'INDEX STRATÉGIQUES
-- Simule une base non optimisée pour les cas de perf dégradées
-- Les étudiants doivent les identifier avec EXPLAIN ANALYZE et les recréer
-- =============================================================================

DROP INDEX IF EXISTS idx_combat_date;
DROP INDEX IF EXISTS idx_session_joueur;
DROP INDEX IF EXISTS idx_progression_statut;

-- =============================================================================
-- Réactivation des contraintes
-- =============================================================================

SET session_replication_role = DEFAULT;

-- =============================================================================
-- VÉRIFICATION DES VOLUMES ET DES PROBLÈMES INTRODUITS
-- =============================================================================

SELECT 'personnage'       AS table_name, COUNT(*) AS nb_lignes FROM personnage
UNION ALL SELECT 'guilde',               COUNT(*) FROM guilde
UNION ALL SELECT 'quete',                COUNT(*) FROM quete
UNION ALL SELECT 'combat',               COUNT(*) FROM combat
UNION ALL SELECT 'session',              COUNT(*) FROM session
UNION ALL SELECT 'inventaire',           COUNT(*) FROM inventaire
UNION ALL SELECT 'progression_quete',    COUNT(*) FROM progression_quete
ORDER BY nb_lignes DESC;

-- Vérification des problèmes introduits
SELECT '-- PROBLÈME 1 : gold NULL sur personnages actifs' AS audit;
SELECT COUNT(*) AS nb_gold_null
FROM personnage p
JOIN session s ON s.joueur_id = p.joueur_id
WHERE p.gold IS NULL AND s.fin IS NOT NULL;

SELECT '-- PROBLÈME 2 : doublons métier (noms avec espace parasite)' AS audit;
SELECT COUNT(*) AS nb_doublons_metier
FROM personnage
WHERE nom LIKE '% _%';

SELECT '-- PROBLÈME 3 : index manquants' AS audit;
SELECT indexname
FROM pg_indexes
WHERE tablename IN ('combat','session','progression_quete')
AND schemaname = 'public'
ORDER BY tablename, indexname;

SELECT '-- PROBLÈME 4 : progressions sans prérequis respectés' AS audit;
SELECT COUNT(*) AS nb_violations_prerequis
FROM progression_quete pq
JOIN quete q ON q.id = pq.quete_id
WHERE q.quete_prerequis_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM progression_quete pq2
    WHERE pq2.personnage_id = pq.personnage_id
    AND pq2.quete_id = q.quete_prerequis_id
    AND pq2.statut = 'terminee'
);

-- =============================================================================
-- FIN DU SCRIPT D'EXAMEN
-- =============================================================================
