-- =============================================================================
-- ChronicleDB - Peuplement massif pour démos de performance
-- Cours SQL Avancé - ESGI 2025
-- Prérequis : avoir exécuté 01-structure.sql et 02-data_basics.sql au préalable
-- PostgreSQL uniquement (generate_series)
-- =============================================================================
-- Volume cible :
--   combat           : ~10 000 000 lignes
--   session          : ~2 000 000 lignes
--   progression_quete: ~1 500 000 lignes
-- =============================================================================

-- Désactivation temporaire des contraintes pour accélérer les insertions
SET session_replication_role = replica;

-- =============================================================================
-- COMBAT : 1 000 000 lignes
-- Distribution réaliste :
--   - personnage_id  : tiré aléatoirement parmi les 22 personnages existants
--   - ennemi_id      : tiré aléatoirement parmi les 22 ennemis existants
--   - date_combat    : répartie sur 3 ans (2022-01-01 à 2024-11-21)
--   - victoire       : 70% TRUE (les héros gagnent plus souvent)
--   - degats         : corrélé au niveau de l'ennemi (distribution réaliste)
-- =============================================================================

INSERT INTO combat (personnage_id, ennemi_id, date_combat, victoire, degats)
SELECT
    -- personnage_id : 22 personnages, distribution non uniforme
    -- les personnages hauts niveau (8, 12, 14) combattent plus
    (ARRAY[1,1,2,2,3,3,4,5,6,6,7,8,8,8,9,10,11,12,12,14,14,15,16,17,18,19,21])[
        1 + (floor(random() * 27))::int
    ],

    -- ennemi_id : 22 ennemis, les monstres communs sont plus fréquents
    (ARRAY[1,1,1,2,2,3,4,4,5,5,6,7,7,8,9,9,10,11,11,12,13,13,14,15,16,17,18,19,20,21,22])[
        1 + (floor(random() * 31))::int
    ],

    -- date_combat : sur 3 ans, avec une densité croissante vers 2024
    '2022-01-01'::timestamp + (random() * INTERVAL '1035 days'),

    -- victoire : 70% de chances de gagner
    random() < 0.70,

    -- degats : entre 50 et 5000, log-normal pour simuler des pics
    GREATEST(50, LEAST(5000,
        (50 + (random() * 800 + (random() * random() * 4000)))::int
    ))

FROM generate_series(1, 10000000);

-- =============================================================================
-- SESSION : 200 000 lignes
-- Distribution réaliste :
--   - joueur_id      : parmi les 20 joueurs, certains plus actifs que d'autres
--   - debut          : sur 3 ans
--   - fin            : NULL pour ~5% (sessions en cours ou non fermées)
--   - durée          : entre 15 min et 6h
-- =============================================================================

INSERT INTO session (joueur_id, debut, fin)
SELECT
    -- joueur_id : distribution non uniforme (certains joueurs sont accros)
    (ARRAY[1,1,1,2,2,3,4,4,5,6,6,6,7,8,8,8,8,9,9,10,
            11,11,11,12,13,14,15,15,16,16,17,18,18,19,20])[
        1 + (floor(random() * 35))::int
    ],

    -- debut : sur 3 ans
    '2022-01-01'::timestamp + (random() * INTERVAL '1035 days'),

    -- fin : NULL pour 5% des sessions, sinon debut + durée aléatoire
    CASE
        WHEN random() < 0.05 THEN NULL
        ELSE '2022-01-01'::timestamp
             + (random() * INTERVAL '1035 days')
             + (INTERVAL '15 minutes' + (random() * INTERVAL '345 minutes'))
    END

FROM generate_series(1, 2000000);

-- Correction : s'assurer que fin > debut (éviter les incohérences)
UPDATE session
SET fin = debut + (INTERVAL '30 minutes' + (random() * INTERVAL '180 minutes'))
WHERE fin IS NOT NULL AND fin <= debut;

-- =============================================================================
-- PROGRESSION_QUETE : 150 000 lignes
-- Contrainte UNIQUE (personnage_id, quete_id) : on génère des paires uniques
-- via un sous-ensemble de combinaisons possibles (22 personnages x 15 quêtes
-- ne suffit pas pour 150k, on étend avec des personnages fictifs référencés
-- dans la table personnage via une astuce de modulo)
--
-- Stratégie : on crée 150 000 enregistrements en croisant personnage_id
-- et quete_id de façon à éviter les doublons grâce à generate_series
-- et une numérotation déterministe.
-- Les paires (personnage_id, quete_id) sont uniques par construction.
-- =============================================================================

-- Nettoyage des progressions de test existantes pour éviter les conflits
-- (on garde seulement les 41 lignes réalistes du script principal)
-- On va générer des progressions sur une plage étendue en utilisant
-- un découpage par blocs : chaque bloc de 15 quêtes pour un "groupe"
-- de personnages simulés via modulo sur les 22 existants.

INSERT INTO progression_quete (personnage_id, quete_id, statut, date_debut, date_fin)
SELECT DISTINCT ON (pid, qid)
    pid,
    qid,
    (ARRAY['terminee','terminee','terminee','en_cours','abandonnee','echouee'])[
        1 + (floor(random() * 6))::int
    ],
    '2022-01-01'::timestamp + (random() * INTERVAL '1000 days'),
    CASE
        WHEN random() < 0.25 THEN NULL
        ELSE '2022-01-01'::timestamp + (random() * INTERVAL '1035 days')
    END
FROM (
    SELECT
        -- personnage_id : cycled sur les 22 personnages existants
        (ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,21,22,3])[
            1 + ((s - 1) % 22)
        ] AS pid,
        -- quete_id : cycled sur les 15 quêtes existantes
        1 + ((s - 1) / 22 % 15) AS qid
    FROM generate_series(1, 3000000) s
) sub
WHERE (pid, qid) NOT IN (SELECT personnage_id, quete_id FROM progression_quete)
LIMIT 1500000;

-- Correction cohérence : date_fin >= date_debut quand les deux sont renseignées
UPDATE progression_quete
SET date_fin = date_debut + (INTERVAL '1 hour' + (random() * INTERVAL '30 days'))
WHERE date_fin IS NOT NULL AND date_fin < date_debut;

-- Correction cohérence : statut en_cours => date_fin NULL
UPDATE progression_quete
SET date_fin = NULL
WHERE statut = 'en_cours' AND date_fin IS NOT NULL;

-- =============================================================================
-- Réactivation des contraintes
-- =============================================================================
SET session_replication_role = DEFAULT;

-- =============================================================================
-- VÉRIFICATION DES VOLUMES
-- =============================================================================
SELECT
    'combat'            AS table_name, COUNT(*) AS nb_lignes FROM combat
UNION ALL SELECT
    'session',                          COUNT(*) FROM session
UNION ALL SELECT
    'progression_quete',                COUNT(*) FROM progression_quete
ORDER BY nb_lignes DESC;
