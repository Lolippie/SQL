-- 1. Écrivez une requête qui liste ces personnages (nom, niveau, classe, nombre de sessions terminées). 

WITH nombre_sessions_terminees AS (
SELECT COUNT (s.id) as nombres_sessions, j.id as joueur_id
FROM session s 
JOIN joueur j ON s.joueur_id = j.id 
WHERE s.fin IS NOT NULL
GROUP BY j.id )
SELECT p.nom, p.niveau, c.nom as nom_classe, nombre_sessions_terminees.nombres_sessions as nombre_sessions_terminees, j.id
FROM personnage p 
JOIN classe c ON p.classe_id = c.id
JOIN joueur j ON j.id = p.joueur_id
JOIN nombre_sessions_terminees ON nombre_sessions_terminees.joueur_id = j.id
WHERE p.gold IS NULL 



-- 2. Combien y en a-t-il ? 

-- On en retrouve 44 

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
    JOIN joueur j ON j.id= p.joueur_id
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

-- Des personnages ont été créés avec des noms quasi-identiques à des noms existants : espaces parasites (espace suivi
-- d’un underscore) et variantes de casse (majuscules/minuscules différentes). L’ensemble de ces cas constitue des
-- doublons métier.

-- 1. Écrivez une requête qui détecte les noms en doublon métier. Affichez le nom normalisé, le nombre d’occurrences
-- et les IDs concernés.
WITH doublons AS (
    SELECT
        LOWER(TRIM(REPLACE(nom, ' _', '_'))) AS nom_normalise
    FROM personnage
    GROUP BY LOWER(TRIM(REPLACE(nom, ' _', '_')))
    HAVING COUNT(*) > 1
)
SELECT
    p.id,
    p.nom,
    LOWER(TRIM(REPLACE(p.nom, ' _', '_'))) AS nom_normalise
FROM personnage p
JOIN doublons d
    ON LOWER(TRIM(REPLACE(p.nom, ' _', '_'))) = d.nom_normalise
ORDER BY nom_normalise, p.id;
2. Combien de doublons métier avez-vous identifiés ?
-- n'en ayant eu aucun, j'ai executé les commandes suivantes pour créer au moins un cas
SELECT p.nom, g.nom
FROM personnage p
JOIN guilde g ON p.guilde_id = g.id
WHERE p.nom LIKE 'Cyran _Dup'

UPDATE personnage
SET nom = 'Cyran _Dup'
WHERE nom = 'Cyren _dup';

-- 3. Ces personnages sont-ils rattachés à des guildes ? Justifiez votre réponse avec une requête
-- le hasard faisant bien les choses, l'un des doublons à une guilde et le second n'en a pas
WITH doublons_metier AS (
SELECT
  LOWER(TRIM(REPLACE(nom, ' _', '_'))) AS nom_normalise,
  p.id
FROM personnage p
WHERE  LOWER(TRIM(REPLACE(nom, ' _', '_'))) IN (
  SELECT  LOWER(TRIM(REPLACE(nom, ' _', '_')))
  FROM personnage
  GROUP BY  LOWER(TRIM(REPLACE(nom, ' _', '_')))
  HAVING COUNT(*) > 1
)
ORDER BY nom_normalise
)
SELECT g.nom as nom_guilde, p.nom as nom_personnage, p.id
FROM personnage p
JOIN doublons_metier dm ON p.id = dm.id
JOIN guilde g ON g.id = p.guilde_id


-- 1. Écrivez une requête qui identifie toutes les progressions violant les prérequis : personnage ayant une progression
-- sur une quête dont le prérequis n’est pas au statut 'terminee' .*
WITH progression_prerequis AS (
    SELECT
        pq.personnage_id,
        pq.quete_id AS quete_courante_id,
        q.quete_prerequis_id AS prerequis_id
    FROM progression_quete pq
    JOIN quete q ON q.id = pq.quete_id
    WHERE q.quete_prerequis_id IS NOT NULL
),

etat_prerequis AS (
    SELECT
        pp.personnage_id,
        pp.quete_courante_id,
        pp.prerequis_id,
        pq.statut AS statut_prerequis
    FROM progression_prerequis pp
    LEFT JOIN progression_quete pq
        ON pq.personnage_id = pp.personnage_id
        AND pq.quete_id = pp.prerequis_id
)

SELECT
    p.nom AS personnage,
    q.titre AS quete_bloquee
FROM etat_prerequis e
JOIN personnage p ON p.id = e.personnage_id
JOIN quete q ON q.id = e.quete_courante_id
WHERE e.statut_prerequis IS NULL
   OR e.statut_prerequis <> 'terminee'
-- 2. Combien de violations avez-vous trouvé ?

-- Il y a 200 violations trouvées 

-- 3. Parmi ces violations, combien concernent des progressions au statut 'terminee' (cas les plus graves) ?
WITH progression_prerequis AS (
    SELECT
        pq.personnage_id,
        pq.quete_id AS quete_courante_id,
        q.quete_prerequis_id AS prerequis_id,
        pq.statut as quete_courante_statut
    FROM progression_quete pq
    JOIN quete q ON q.id = pq.quete_id
    WHERE q.quete_prerequis_id IS NOT NULL
),

etat_prerequis AS (
    SELECT
        pp.personnage_id,
        pp.quete_courante_id,
        pp.prerequis_id,
        pq.statut AS statut_prerequis,
        pp.quete_courante_statut
    FROM progression_prerequis pp
    LEFT JOIN progression_quete pq
        ON pq.personnage_id = pp.personnage_id
        AND pq.quete_id = pp.prerequis_id
)

SELECT
    p.nom AS personnage,
    q.titre AS quete_bloquee
FROM etat_prerequis e
JOIN personnage p ON p.id = e.personnage_id
JOIN quete q ON q.id = e.quete_courante_id
WHERE (e.statut_prerequis IS NULL OR e.statut_prerequis <> 'terminee')
  AND e.quete_courante_statut = 'terminee';


-- 79 ont la violation la plus grave

-- 4. Proposez une stratégie de correction : faut-il supprimer ces progressions, les passer en 'abandonnee' , ou autre
-- chose ? Justifiez votre choix et exécutez la correction.

-- Ma proposition est de passer la premiere des prerequis non faite en "en cours"
-- puis de mettre à jour la table progression pour les quetes dont le prerequis ne sont pas remplis en mettant leur statut à abandonné 

WITH prerequis_manquants AS (
    SELECT
        q.quete_prerequis_id AS quete_id,
        pq.personnage_id
    FROM progression_quete pq
    JOIN quete q ON q.id = pq.quete_id
    LEFT JOIN progression_quete pq_pre
        ON pq_pre.personnage_id = pq.personnage_id
        AND pq_pre.quete_id = q.quete_prerequis_id
    WHERE q.quete_prerequis_id IS NOT NULL
      AND (pq_pre.id IS NULL OR pq_pre.statut <> 'terminee')
)

UPDATE progression_quete pq
SET statut = 'en_cours'
FROM prerequis_manquants pm
WHERE pq.personnage_id = pm.personnage_id
  AND pq.quete_id = pm.quete_id;

WITH progression_prerequis AS (
    SELECT
        pq.id AS progression_id,
        pq.personnage_id,
        pq.quete_id AS quete_courante_id,
        q.quete_prerequis_id AS prerequis_id
    FROM progression_quete pq
    JOIN quete q ON q.id = pq.quete_id
    WHERE q.quete_prerequis_id IS NOT NULL
),

etat_prerequis AS (
    SELECT
        pp.progression_id,
        pp.personnage_id,
        pp.quete_courante_id,
        pp.prerequis_id,
        pq.statut AS statut_prerequis
    FROM progression_prerequis pp
    LEFT JOIN progression_quete pq
        ON pq.personnage_id = pp.personnage_id
        AND pq.quete_id = pp.prerequis_id
)

UPDATE progression_quete pq
SET statut = 'abandonnee'
FROM etat_prerequis e
WHERE pq.id = e.progression_id
  AND (e.statut_prerequis IS NULL OR e.statut_prerequis <> 'terminee');

