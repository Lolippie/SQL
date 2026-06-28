-- Suppression des index existants
DROP INDEX IF EXISTS idx_personnage_joueur;
DROP INDEX IF EXISTS idx_personnage_guilde;
DROP INDEX IF EXISTS idx_personnage_classe;
DROP INDEX IF EXISTS idx_combat_personnage;
DROP INDEX IF EXISTS idx_combat_date;
DROP INDEX IF EXISTS idx_session_joueur;
DROP INDEX IF EXISTS idx_progression_perso;
DROP INDEX IF EXISTS idx_progression_statut;
DROP INDEX IF EXISTS idx_inventaire_perso;

-- 2.1 Classement des guildes par activité

EXPLAIN (ANALYZE,BUFFERS) SELECT g.nom, COUNT(c.id) AS nb_combats, AVG(c.degats) AS degats_moyens
FROM guilde g
         JOIN personnage p ON g.id = p.guilde_id
         JOIN combat c ON c.personnage_id = p.id
WHERE c.date_combat >= NOW() - INTERVAL '2 years' -- Filtrage sur les combats des 2 dernières années car il n'existe pas de combat entre 2025 et 2026
GROUP BY g.id, g.nom
ORDER BY nb_combats DESC
LIMIT 10;

-- Analyse avant optimisation :
    -- Cost : 32238
    -- Actual time : 159
    -- Remarques :
        -- Le goulot d'étranglement si situe au niveau du filtrage sur la date des combats.

-- Optimisations :
    -- index sur la colonne date_combat de la table combat pour accélérer le filtrage des combats récents.
CREATE INDEX idx_combat_date ON combat(date_combat);

-- Analyse après optimisation :
    -- Cost : 26414
    -- Actual time : 129
    -- Remarques :
        -- La requete reste lourde car elle implique un grand nombre de lignes à traiter, mais l'index sur la date des combats permet de réduire le temps d'exécution.

-- 2.2 Historique de connexion d’un joueur

EXPLAIN (ANALYZE,BUFFERS) SELECT joueur_id, debut, fin, EXTRACT(EPOCH FROM (fin - debut)) / 60 AS duree_minutes
FROM session
WHERE joueur_id = 42
AND fin IS NOT NULL
ORDER BY debut DESC
LIMIT 20;

-- Analyse avant optimisation :
    -- Cost : 8294
    -- Actual time : 79
    -- Remarques :
        -- Le goulot d'étranglement se situe le tri par date de début de session.
        -- LA requete réalise d'abord le filtre sur le joueur_id, puis le tri sur la date de début de session.

-- Optimisations : index sur la colonne joueur_id, fin pour optimiser la clause du where et debut pour accélérer le tri des sessions d'un joueur.
CREATE INDEX idx_session_joueur_fin_debut ON session(joueur_id, fin, debut DESC);
DROP INDEX IF EXISTS idx_session_joueur_fin_debut;

-- Analyse après optimisation :
    -- Cost : 70
    -- Actual time : 0.492

-- 2.3  Pagination du journal de combat
EXPLAIN (ANALYZE,BUFFERS) SELECT p.id, p.nom AS personnage, e.nom AS ennemi, c.date_combat, c.victoire, c.degats
FROM combat c
       JOIN personnage p ON p.id = c.personnage_id
       JOIN ennemi e ON e.id = c.ennemi_id
ORDER BY c.date_combat DESC
LIMIT 20 OFFSET 9980;

-- Analyse avant optimisation :
    -- Cost : 1052
    -- Actual time : 202
    -- Remarques :
        -- La ligne qui trahit le cout est offset est la suivante car on voit car la requete lit l'ensemble des données précédentes visibles dans le buffer.
                -- ->  Index Scan Backward using idx_combat_date on combat c  (cost=0.43..110770.50 rows=2000000 width=21) (actual time=0.052..100.920 rows=10000.00 loops=1)
                    -- Index Searches: 1
                    --Buffers: shared hit=2771 read=7259

        -- Le offset 9980 implique que la requete doit parcourir 9 980 lignes avant de retourner les 20 lignes demandées, ce qui est explique pourquoi elle est plus couteuse que le offset 0.
        --
-- Optimisations :
    -- Utilisation d'une pagination avec keyset.
EXPLAIN (ANALYZE,BUFFERS) SELECT p.nom AS personnage, e.nom AS ennemi, c.date_combat, c.victoire, c.degats
FROM combat c
    JOIN personnage p ON p.id = c.personnage_id
    JOIN ennemi e ON e.id = c.ennemi_id
WHERE c.date_combat < '2024-12-25 13:28:55.604167'
       OR (c.date_combat < '2024-12-25 13:28:55.604167' AND c.id < 345 )
ORDER BY c.date_combat DESC, c.id DESC
LIMIT 20;

-- Analyse après optimisation :
    -- Cost : 4.04
    -- Actual time : 0.600