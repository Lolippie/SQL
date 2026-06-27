-- 1. Écrivez une requête qui liste ces personnages (nom, niveau, classe, nombre de sessions terminées). 

WITH nombre_sessions_terminees AS (
SELECT COUNT (s.id) as nombres_sessions, j.id as joueur_id
FROM session s JOIN joueur j ON s.joueur_id = j.id 
WHERE s.fin IS NOT NULL
GROUP BY j.id ) 
SELECT p.nom, p.niveau, c.nom, nombre_sessions_terminees.nombres_sessions as nombre_sessions_terminees
FROM personnage p 
JOIN classe c ON p.classe_id = c.id
JOIN joueur j ON j.personnage_id = p.id
JOIN nombre_sessions_terminees ON nombre_sessions_terminees.joueur_id = j.id
WHERE p.gold IS NULL 



-- 2. Combien y en a-t-il ? 

-- x 

-- 3. Proposez et exécutez un UPDATE pour corriger ce problème en remplaçant les NULL par 0.
WITH nombre_sessions_terminees AS (
    SELECT
        COUNT(s.id) AS nombres_sessions,
        j.id AS joueur_id
    FROM session s
    JOIN joueur j ON s.joueur_id = j.id
    WHERE s.fin IS NOT NULL
    GROUP BY j.id
),
personnages_a_corriger AS (
    SELECT p.id
    FROM personnage p
    JOIN classe c ON p.classe_id = c.id
    JOIN joueur j ON j.personnage_id = p.id
    JOIN nombre_sessions_terminees nst
        ON nst.joueur_id = j.id
    WHERE p.gold IS NULL
)
UPDATE personnage
SET gold = 0
WHERE id IN (
    SELECT id
    FROM personnages_a_corriger
);