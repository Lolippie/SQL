-- =============================================================================
-- ChronicleDB - Données initiales (jeu de référence)
-- Cours SQL Avancé - ESGI 2025
-- Prérequis : avoir exécuté chronicledb_structure.sql au préalable
-- =============================================================================

-- =============================================================================
-- DONNÉES DE RÉFÉRENCE
-- =============================================================================

INSERT INTO classe (nom, role)
VALUES ('Guerrier', 'Tank'),
       ('Mage', 'DPS magique'),
       ('Rôdeur', 'DPS physique'),
       ('Prêtre', 'Healer'),
       ('Paladin', 'Tank / Healer'),
       ('Voleur', 'DPS physique'),
       ('Druide', 'Hybride'),
       ('Nécromancien', 'DPS magique'),
       ('Chaman', 'Hybride'),
       ('Barde', 'Support');

INSERT INTO race (nom, bonus)
VALUES ('Humain', '+5% XP gagné'),
       ('Elfe', '+10 précision, -5 endurance'),
       ('Nain', '+15 endurance, -5 vitesse'),
       ('Orque', '+20 force, -10 intelligence'),
       ('Halfelin', '+10 esquive, -10 force'),
       ('Draconide', '+15 résistance au feu'),
       ('Tieffelin', '+10 magie des ombres'),
       ('Gnome', '+15 intelligence, -10 force'),
       ('Aasimar', '+10 magie sacrée'),
       ('Demi-Elfe', '+5 à toutes les stats');

INSERT INTO zone (nom, niveau_min)
VALUES ('Plaines de Valdris', 1),
       ('Forêt de Sylvara', 10),
       ('Mines de Kharduun', 20),
       ('Marécages de Morbeth', 30),
       ('Cité de Crysthalia', 1),
       ('Désert de Solharr', 40),
       ('Toundra Glacée', 50),
       ('Îles Flottantes', 60),
       ('Abysses de Noirfond', 70),
       ('Citadelle du Néant', 80),
       ('Abysse Infernale', 99),
       ('Village BigBang', 0)
       ;

INSERT INTO guilde (zone_id, nom, niveau)
VALUES (1, 'Les Lames du Soleil', 12),
       (2, 'Cercle des Anciens', 8),
       (3, 'Confrérie des Profondeurs', 15),
       (4, 'Ordre du Marécage', 6),
       (5, 'Alliance Crysthalienne', 20),
       (6, 'Fils du Désert', 10),
       (7, 'Gardiens du Givre', 18),
       (8, 'Navigateurs des Cieux', 14),
       (9, 'Pacte des Abysses', 22),
       (10, 'Hérauts du Néant', 25);

-- =============================================================================
-- COMPTES ET JOUEURS
-- =============================================================================

INSERT INTO compte (email, mot_de_passe, date_inscription)
VALUES ('alberic.vale@mail.com', 'hash_pw_01', '2022-03-15 10:00:00'),
       ('dragan.morin@mail.com', 'hash_pw_02', '2022-05-20 14:30:00'),
       ('thorin.krag@mail.com', 'hash_pw_03', '2021-11-08 09:15:00'),
       ('lirien.dawn@mail.com', 'hash_pw_04', '2023-01-02 18:45:00'),
       ('morrigan.black@mail.com', 'hash_pw_05', '2022-07-19 11:00:00'),
       ('davan.roch@mail.com', 'hash_pw_06', '2023-04-10 08:30:00'),
       ('isolde.venn@mail.com', 'hash_pw_07', '2021-09-25 16:20:00'),
       ('kazrak.gor@mail.com', 'hash_pw_08', '2023-06-01 12:00:00'),
       ('elara.swift@mail.com', 'hash_pw_09', '2022-12-11 20:10:00'),
       ('brom.stone@mail.com', 'hash_pw_10', '2021-08-03 07:45:00'),
       ('sylvana.moon@mail.com', 'hash_pw_11', '2023-02-14 13:30:00'),
       ('grunt.iron@mail.com', 'hash_pw_12', '2022-10-22 09:00:00'),
       ('nessa.fey@mail.com', 'hash_pw_13', '2023-07-07 15:15:00'),
       ('corvin.ash@mail.com', 'hash_pw_14', '2022-04-18 10:45:00'),
       ('yara.flame@mail.com', 'hash_pw_15', '2021-12-30 19:00:00'),
       ('orin.frost@mail.com', 'hash_pw_16', '2023-08-09 11:30:00'),
       ('tamsin.reed@mail.com', 'hash_pw_17', '2022-06-27 14:00:00'),
       ('zephyr.wind@mail.com', 'hash_pw_18', '2023-03-21 08:00:00'),
       ('petra.rok@mail.com', 'hash_pw_19', '2021-10-14 17:30:00'),
       ('idris.vale@mail.com', 'hash_pw_20', '2023-09-05 16:00:00');

INSERT INTO joueur (compte_id, pseudo, derniere_connexion)
VALUES (1, 'AlbericV', '2025-11-20 21:00:00'),
       (2, 'DraganM', '2025-11-18 19:30:00'),
       (3, 'ThorinK', '2025-10-05 22:15:00'),
       (4, 'LirienD', '2025-11-19 20:00:00'),
       (5, 'MorriganB', '2025-09-30 18:45:00'),
       (6, 'DavanR', '2025-11-21 09:00:00'),
       (7, 'IsoldeV', '2025-08-15 17:30:00'),
       (8, 'KazrakG', '2025-11-20 23:00:00'),
       (9, 'ElaraS', '2025-11-17 20:45:00'),
       (10, 'BromS', '2025-07-22 16:00:00'),
       (11, 'SylvanaM', '2025-11-21 11:00:00'),
       (12, 'GruntI', '2025-10-30 08:30:00'),
       (13, 'NessaF', '2025-11-19 22:30:00'),
       (14, 'CorvinA', '2025-06-10 14:00:00'),
       (15, 'YaraF', '2025-11-20 20:00:00'),
       (16, 'OrinFrost', '2025-11-21 07:45:00'),
       (17, 'TamsinR', '2025-11-15 18:00:00'),
       (18, 'ZephyrW', '2025-11-21 10:30:00'),
       (19, 'PetraR', '2025-05-01 13:00:00'),
       (20, 'IdrisV', NULL);

-- =============================================================================
-- PERSONNAGES
-- =============================================================================

INSERT INTO personnage (joueur_id, classe_id, race_id, guilde_id, nom, niveau, xp, gold)
VALUES (1, 1, 1, 1, 'Albéric', 45, 125000, 8500),
       (1, 3, 2, 1, 'Albéric-Ranger', 22, 28000, 1200),
       (2, 4, 9, 5, 'Dragan', 60, 280000, 15000),
       (3, 2, 3, 3, 'Thorindur', 55, 210000, 12000),
       (3, 1, 4, 3, 'Kragmar', 38, 85000, 4500),
       (4, 7, 10, 2, 'Lirien', 50, 175000, 9800),
       (5, 8, 7, NULL, 'Morrigan', 48, 140000, 6200),
       (6, 5, 1, 5, 'Davan', 62, 310000, 22000),
       (7, 6, 5, NULL, 'Isolde', 35, 72000, 2800),
       (8, 1, 4, 3, 'Kazrak', 70, 480000, 35000),
       (9, 3, 2, 7, 'Elara', 44, 118000, 7100),
       (10, 2, 3, 2, 'Bromdar', 52, 195000, 11500),
       (11, 4, 9, 5, 'Sylvana', 58, 250000, 14200),
       (12, 1, 4, 9, 'Gruntok', 75, 560000, 42000),
       (13, 7, 10, 2, 'Nessa', 30, 48000, 1800),
       (14, 8, 7, 10, 'Corvin', 80, 720000, 65000),
       (15, 9, 6, 6, 'Yara', 42, 105000, 5900),
       (16, 2, 3, 7, 'Orin', 65, 360000, 28000),
       (17, 5, 1, 1, 'Tamsin', 28, 40000, 1500),
       (18, 6, 5, 8, 'Zephyr', 55, 215000, 13000),
       (19, 3, 2, 6, 'Petra', 40, 92000, 4100),
       (20, 4, 9, NULL, 'Idris', 1, 0, NULL);

-- =============================================================================
-- SESSIONS
-- =============================================================================

INSERT INTO session (joueur_id, debut, fin)
VALUES (1, '2025-11-20 18:00:00', '2025-11-20 21:00:00'),
       (1, '2025-11-19 20:00:00', '2025-11-19 23:30:00'),
       (2, '2025-11-18 17:00:00', '2025-11-18 19:30:00'),
       (3, '2025-10-05 20:00:00', '2025-10-05 22:15:00'),
       (4, '2025-11-19 18:30:00', '2025-11-19 20:00:00'),
       (5, '2025-09-30 16:00:00', '2025-09-30 18:45:00'),
       (6, '2025-11-21 07:00:00', '2025-11-21 09:00:00'),
       (7, '2025-08-15 15:00:00', '2025-08-15 17:30:00'),
       (8, '2025-11-20 20:00:00', '2025-11-20 23:00:00'),
       (9, '2025-11-17 19:00:00', '2025-11-17 20:45:00'),
       (10, '2025-07-22 14:00:00', '2025-07-22 16:00:00'),
       (11, '2025-11-21 09:00:00', '2025-11-21 11:00:00'),
       (12, '2025-10-30 06:00:00', '2025-10-30 08:30:00'),
       (13, '2025-11-19 20:00:00', '2025-11-19 22:30:00'),
       (14, '2025-06-10 12:00:00', '2025-06-10 14:00:00'),
       (15, '2025-11-20 18:00:00', '2025-11-20 20:00:00'),
       (16, '2025-11-21 06:00:00', '2025-11-21 07:45:00'),
       (17, '2025-11-15 16:00:00', '2025-11-15 18:00:00'),
       (18, '2025-11-21 08:00:00', '2025-11-21 10:30:00'),
       (19, '2025-05-01 11:00:00', '2025-05-01 13:00:00'),
       (1, '2025-11-15 14:00:00', '2025-11-15 17:00:00'),
       (6, '2025-11-20 19:00:00', '2025-11-20 22:00:00'),
       (8, '2025-11-19 21:00:00', '2025-11-19 23:45:00'),
       (11, '2025-11-20 20:00:00', '2025-11-20 22:30:00'),
       (16, '2025-11-20 22:00:00', NULL);

-- =============================================================================
-- DONJONS ET ENNEMIS
-- =============================================================================

INSERT INTO donjon (zone_id, nom, difficulte)
VALUES (1, 'Crypte des Ombres', 'facile'),
       (2, 'Sanctuaire des Anciens', 'normal'),
       (3, 'Abîme de Kharduun', 'difficile'),
       (4, 'Temple de Morbeth', 'normal'),
       (5, 'Tour des Arcanes', 'difficile'),
       (6, 'Tombeau du Pharaon Solaire', 'difficile'),
       (7, 'Forteresse de Glace', 'legendaire'),
       (8, 'Nid des Tempêtes', 'difficile'),
       (9, 'Puits des Âmes', 'legendaire'),
       (10, 'Trône du Néant', 'legendaire');

INSERT INTO ennemi (donjon_id, nom, pv, type)
VALUES (1, 'Squelette Vétéran', 500, 'monstre'),
       (1, 'Spectre Hurlant', 800, 'elite'),
       (1, 'Liche des Ombres', 5000, 'boss'),
       (2, 'Gardien Ancestral', 1200, 'elite'),
       (2, 'Esprit Corrompu', 900, 'monstre'),
       (2, 'Ancien Éveillé', 8000, 'boss'),
       (3, 'Golem de Pierre', 2000, 'elite'),
       (3, 'Kraken des Abysses', 15000, 'boss'),
       (4, 'Cultiste du Marais', 700, 'monstre'),
       (4, 'Hydre des Marécages', 12000, 'boss'),
       (5, 'Apprenti Fou', 600, 'monstre'),
       (5, 'Archimage Renégat', 18000, 'boss'),
       (6, 'Scarabée Géant', 400, 'monstre'),
       (6, 'Anubis Corrompu', 22000, 'boss'),
       (7, 'Yéti des Glaces', 3000, 'elite'),
       (7, 'Dragon de Givre', 50000, 'raid'),
       (8, 'Aigle Foudroyant', 1800, 'elite'),
       (8, 'Seigneur des Tempêtes', 25000, 'boss'),
       (9, 'Âme Damnée', 2500, 'elite'),
       (9, 'Dévoreur d''Âmes', 45000, 'raid'),
       (10, 'Héraut du Néant', 5000, 'elite'),
       (10, 'Seigneur du Néant', 80000, 'raid');

-- =============================================================================
-- OBJETS
-- =============================================================================

INSERT INTO objet (nom, type, rarete, valeur_gold)
VALUES ('Épée de Lumière', 'arme', 'epique', 5000),
       ('Arc Sylvain', 'arme', 'rare', 2500),
       ('Bâton des Arcanes', 'arme', 'legendaire', 12000),
       ('Bouclier de Fer', 'armure', 'commun', 300),
       ('Armure des Anciens', 'armure', 'epique', 8000),
       ('Capuche du Rôdeur', 'armure', 'rare', 1800),
       ('Potion de Soin', 'consommable', 'commun', 50),
       ('Élixir de Force', 'consommable', 'peu_commun', 200),
       ('Parchemin de Téléportation', 'consommable', 'rare', 500),
       ('Fragment de Cristal', 'materiau', 'peu_commun', 150),
       ('Essence de Dragon', 'materiau', 'legendaire', 10000),
       ('Rune de Pouvoir', 'materiau', 'rare', 800),
       ('Amulette de Vitalité', 'arme', 'rare', 2000),
       ('Dague des Ombres', 'arme', 'epique', 4500),
       ('Masse Sacrée', 'arme', 'rare', 2200),
       ('Grimoire Maudit', 'arme', 'legendaire', 15000),
       ('Cape du Vent', 'armure', 'rare', 1500),
       ('Bottes de Sprint', 'armure', 'peu_commun', 600),
       ('Anneau de Feu', 'arme', 'epique', 3500),
       ('Clé du Donjon', 'quete', 'commun', 0);

-- =============================================================================
-- QUÊTES ET ÉTAPES
-- =============================================================================

INSERT INTO quete (zone_id, quete_prerequis_id, titre, type, niveau_requis, date_expiration)
VALUES
  -- Chaîne principale des Plaines de Valdris (quêtes 1 → 2 → 15)
  (1, NULL, 'La menace des plaines', 'principale', 1, NULL),                          -- id 1
  (1, 1, 'Collecte de plantes médicinales', 'quotidienne', 1, '2025-12-01 23:59:00'), -- id 2, prérequis : 1
  -- Chaîne principale de la Forêt de Sylvara (quêtes 3 → 4)
  (2, NULL, 'Le secret de la forêt', 'principale', 10, NULL),                         -- id 3
  (2, 3, 'Protéger les anciens arbres', 'secondaire', 12, NULL),                      -- id 4, prérequis : 3
  -- Chaîne principale des Mines de Kharduun (quêtes 5 → 6)
  (3, NULL, 'Au cœur des mines', 'principale', 20, NULL),                             -- id 5
  (3, 5, 'L''évasion de Kharduun', 'epique', 25, '2025-11-30 23:59:00'),              -- id 6, prérequis : 5
  -- Quête isolée des Marécages
  (4, NULL, 'Les rituels du marécage', 'principale', 30, NULL),                       -- id 7
  -- Chaîne principale de Crysthalia (quêtes 8 → 9)
  (5, NULL, 'Diplomatie à Crysthalia', 'principale', 1, NULL),                        -- id 8
  (5, 8, 'La tour interdite', 'epique', 35, NULL),                                    -- id 9, prérequis : 8
  -- Chaîne du Désert → Toundra → Îles (quêtes 10 → 11 → 12)
  (6, NULL, 'Traversée du désert', 'principale', 40, NULL),                           -- id 10
  (7, 10, 'Survivre à la toundra', 'secondaire', 50, NULL),                           -- id 11, prérequis : 10
  (8, 11, 'Maîtres des vents', 'epique', 60, NULL),                                   -- id 12, prérequis : 11
  -- Chaîne finale des Abysses → Néant (quêtes 13 → 14)
  (9, NULL, 'Pacte avec les abysses', 'principale', 70, NULL),                        -- id 13
  (10, 13, 'La chute du Néant', 'epique', 80, NULL),                                  -- id 14, prérequis : 13
  -- Quête quotidienne isolée
  (1, NULL, 'Patrouille des plaines', 'quotidienne', 1, '2025-12-01 23:59:00'); -- id 15

INSERT INTO etape_quete (quete_id, ordre, description, optionnelle)
VALUES (1, 1, 'Parler au chef du village', FALSE),
       (1, 2, 'Éliminer 10 gobelins dans les plaines', FALSE),
       (1, 3, 'Rapporter la preuve au chef', FALSE),
       (1, 4, 'Escorter les réfugiés', TRUE),
       (3, 1, 'Trouver l''entrée du sanctuaire', FALSE),
       (3, 2, 'Résoudre l''énigme des anciens', FALSE),
       (3, 3, 'Vaincre le gardien', FALSE),
       (6, 1, 'Obtenir la clé du donjon', FALSE),
       (6, 2, 'Traverser les 3 niveaux de Kharduun', FALSE),
       (6, 3, 'Affronter le Golem de Pierre', FALSE),
       (6, 4, 'Trouver la sortie secrète', TRUE),
       (9, 1, 'Infiltrer la Tour des Arcanes', FALSE),
       (9, 2, 'Neutraliser les 5 gardiens magiques', FALSE),
       (9, 3, 'Vaincre l''Archimage Renégat', FALSE),
       (14, 1, 'Rejoindre l''avant-garde', FALSE),
       (14, 2, 'Éliminer le Seigneur du Néant', FALSE),
       (14, 3, 'Fermer le portail du Néant', FALSE);

-- =============================================================================
-- RÉCOMPENSES
-- =============================================================================

INSERT INTO recompense (quete_id, objet_id, gold, xp)
VALUES (1, 4, 200, 500),
       (2, 7, 50, 100),
       (3, 6, 800, 2000),
       (4, NULL, 400, 800),
       (5, 5, 1500, 4000),
       (6, 1, 3000, 8000),
       (7, NULL, 600, 1500),
       (8, NULL, 100, 300),
       (9, 3, 5000, 15000),
       (10, 2, 1000, 3000),
       (11, 17, 500, 1200),
       (12, 19, 2500, 7000),
       (13, 14, 4000, 12000),
       (14, 16, 8000, 25000),
       (15, 7, 50, 100);

-- =============================================================================
-- PROGRESSIONS DE QUÊTE
-- =============================================================================

-- Rappel des chaînes de prérequis :
--   1 → 2       (Plaines : menace → collecte)
--   3 → 4       (Forêt : secret → protéger)
--   5 → 6       (Mines : cœur → évasion)
--   8 → 9       (Crysthalia : diplomatie → tour)
--   10 → 11 → 12 (Désert → Toundra → Îles)
--   13 → 14     (Abysses → Néant)
--   7, 15       (quêtes isolées, sans prérequis)
--
-- Règle : pour chaque personnage, le prérequis doit être inséré en statut
-- 'terminee' AVANT la quête dépendante dans ce même INSERT.

INSERT INTO progression_quete (personnage_id, quete_id, statut, date_debut, date_fin)
VALUES

  -- Personnage 1 (Albéric, niv.45) : chaîne Plaines terminée, Forêt en cours
  (1, 1, 'terminee', '2025-01-10', '2025-01-11'),     -- menace des plaines
  (1, 2, 'terminee', '2025-01-12', '2025-01-12'),     -- collecte (prérequis 1 ✓)
  (1, 3, 'en_cours', '2025-11-18', NULL),             -- secret de la forêt

  -- Personnage 2 (Dragan, niv.60) : Plaines, Crysthalia complètes
  (2, 1, 'terminee', '2023-05-01', '2023-05-02'),     -- menace des plaines
  (2, 2, 'terminee', '2023-05-03', '2023-05-03'),     -- collecte (prérequis 1 ✓)
  (2, 8, 'terminee', '2023-06-15', '2023-06-20'),     -- diplomatie Crysthalia
  (2, 9, 'terminee', '2025-09-01', '2025-09-10'),     -- tour interdite (prérequis 8 ✓)

  -- Personnage 3 (Thorindur, niv.55) : Mines complètes
  (3, 5, 'terminee', '2022-03-01', '2022-03-05'),     -- cœur des mines
  (3, 6, 'terminee', '2022-04-01', '2022-04-03'),     -- évasion (prérequis 5 ✓)

  -- Personnage 4 (Kragmar, niv.38) : Plaines + Forêt, prochaine étape Forêt en cours
  (4, 1, 'terminee', '2023-01-15', '2023-01-16'),     -- menace des plaines
  (4, 3, 'terminee', '2023-02-01', '2023-02-04'),     -- secret de la forêt
  (4, 4, 'en_cours', '2025-11-15', NULL),             -- protéger anciens arbres (prérequis 3 ✓)

  -- Personnage 5 (Morrigan, niv.48) : Marécage terminé (isolé, pas de prérequis)
  (5, 7, 'terminee', '2023-09-10', '2023-09-15'),     -- rituels du marécage

  -- Personnage 6 (Davan, niv.62) : Plaines + Mines + Crysthalia en cours
  (6, 1, 'terminee', '2023-04-20', '2023-04-21'),     -- menace des plaines
  (6, 5, 'terminee', '2023-05-10', '2023-05-12'),     -- cœur des mines
  (6, 6, 'terminee', '2023-06-01', '2023-06-03'),     -- évasion Kharduun (prérequis 5 ✓)
  (6, 8, 'terminee', '2023-07-01', '2023-07-05'),     -- diplomatie Crysthalia
  (6, 9, 'en_cours', '2025-11-01', NULL),             -- tour interdite (prérequis 8 ✓)

  -- Personnage 7 (Isolde, niv.35) : Plaines abandonnée (cas pédagogique)
  (7, 1, 'abandonnee', '2025-06-01', '2025-06-03'),   -- menace des plaines abandonnée

  -- Personnage 8 (Kazrak, niv.70) : Mines + Abysses terminés
  (8, 5, 'terminee', '2022-10-01', '2022-10-04'),     -- cœur des mines
  (8, 6, 'terminee', '2022-11-01', '2022-11-02'),     -- évasion (prérequis 5 ✓)
  (8, 13, 'terminee', '2025-10-01', '2025-10-08'),    -- pacte abysses

  -- Personnage 9 (Elara, niv.44) : Plaines + Forêt terminées
  (9, 1, 'terminee', '2025-01-20', '2025-01-21'),     -- menace des plaines
  (9, 3, 'terminee', '2025-02-10', '2025-02-14'),     -- secret de la forêt

  -- Personnage 10 (Bromdar, niv.52) : Forêt + Mines terminées
  (10, 3, 'terminee', '2022-08-01', '2022-08-05'),    -- secret de la forêt
  (10, 5, 'terminee', '2022-09-01', '2022-09-03'),    -- cœur des mines

  -- Personnage 11 (Sylvana, niv.58) : Crysthalia complète
  (11, 8, 'terminee', '2023-03-01', '2023-03-05'),    -- diplomatie Crysthalia
  (11, 9, 'terminee', '2025-08-15', '2025-08-25'),    -- tour interdite (prérequis 8 ✓)

  -- Personnage 12 (Gruntok, niv.75) : Plaines + Mines + Abysses, Néant en cours
  (12, 1, 'terminee', '2022-05-01', '2022-05-01'),    -- menace des plaines
  (12, 5, 'terminee', '2022-05-15', '2022-05-18'),    -- cœur des mines
  (12, 6, 'terminee', '2022-06-01', '2022-06-02'),    -- évasion (prérequis 5 ✓)
  (12, 13, 'terminee', '2025-10-01', '2025-10-08'),   -- pacte abysses
  (12, 14, 'en_cours', '2025-11-10', NULL),           -- chute du Néant (prérequis 13 ✓)

  -- Personnage 13 (Nessa, niv.30) : Plaines + quotidienne terminées
  (13, 1, 'terminee', '2025-07-10', '2025-07-11'),    -- menace des plaines
  (13, 2, 'terminee', '2025-11-19', '2025-11-19'),    -- collecte (prérequis 1 ✓)

  -- Personnage 14 (Corvin, niv.80) : Abysses + Néant terminés (boss final)
  (14, 13, 'terminee', '2025-04-01', '2025-04-10'),   -- pacte abysses
  (14, 14, 'terminee', '2025-10-15', '2025-10-25'),   -- chute du Néant (prérequis 13 ✓)

  -- Personnage 15 (Yara, niv.42) : Désert terminé, Toundra en cours
  (15, 10, 'terminee', '2025-03-01', '2025-03-07'),   -- traversée du désert
  (15, 11, 'en_cours', '2025-11-15', NULL),           -- survivre toundra (prérequis 10 ✓)

  -- Personnage 16 (Orin, niv.65) : Désert → Toundra → Îles complète
  (16, 10, 'terminee', '2025-07-01', '2025-07-05'),   -- traversée du désert
  (16, 11, 'terminee', '2025-08-01', '2025-08-10'),   -- survivre toundra (prérequis 10 ✓)
  (16, 12, 'terminee', '2025-09-20', '2025-09-30'),   -- maîtres des vents (prérequis 11 ✓)

  -- Personnage 17 (Tamsin, niv.28) : Plaines terminée
  (17, 1, 'terminee', '2025-06-01', '2025-06-02'),    -- menace des plaines

  -- Personnage 18 (Zephyr, niv.55) : Désert → Toundra → Îles en cours
  (18, 10, 'terminee', '2025-05-01', '2025-05-05'),   -- traversée du désert
  (18, 11, 'terminee', '2025-06-01', '2025-06-08'),   -- survivre toundra (prérequis 10 ✓)
  (18, 12, 'en_cours', '2025-11-01', NULL),           -- maîtres des vents (prérequis 11 ✓)

  -- Personnage 19 (Petra, niv.40) : Désert abandonnée (cas pédagogique)
  (19, 10, 'abandonnee', '2025-01-01', '2025-01-05'), -- traversée du désert abandonnée

  -- Personnage 21 (Albéric-Ranger, niv.22) : Plaines échouée (cas pédagogique)
  (21, 1, 'echouee', '2025-10-01', '2025-10-01');
-- menace des plaines échouée

-- =============================================================================
-- INVENTAIRE ET ÉQUIPEMENT
-- =============================================================================

INSERT INTO inventaire (personnage_id, objet_id, quantite)
VALUES (1, 1, 1),
       (1, 7, 5),
       (1, 10, 3),
       (2, 3, 1),
       (2, 7, 2),
       (2, 9, 1),
       (3, 5, 1),
       (3, 11, 2),
       (4, 2, 1),
       (4, 6, 1),
       (4, 7, 10),
       (5, 16, 1),
       (5, 14, 1),
       (6, 1, 1),
       (6, 5, 1),
       (6, 8, 3),
       (7, 14, 1),
       (7, 7, 3),
       (8, 3, 1),
       (8, 11, 5),
       (8, 16, 1),
       (9, 2, 1),
       (9, 17, 1),
       (10, 3, 1),
       (10, 12, 4),
       (11, 5, 1),
       (11, 7, 8),
       (12, 1, 1),
       (12, 11, 3),
       (12, 16, 1),
       (13, 7, 6),
       (14, 16, 1),
       (14, 14, 1),
       (14, 11, 2),
       (15, 19, 1),
       (15, 7, 4),
       (16, 3, 1),
       (16, 12, 2),
       (17, 4, 1),
       (17, 7, 5),
       (18, 14, 1),
       (18, 9, 2),
       (19, 2, 1),
       (19, 7, 3);

INSERT INTO equipement (personnage_id, objet_id, emplacement, equipe_le)
VALUES (1, 1, 'arme_principale', '2025-06-01'),
       (1, 4, 'arme_secondaire', '2025-06-01'),
       (2, 3, 'arme_principale', '2025-03-15'),
       (3, 5, 'torse', '2023-11-01'),
       (4, 2, 'arme_principale', '2025-01-20'),
       (4, 6, 'tete', '2025-01-20'),
       (5, 16, 'arme_principale', '2025-07-10'),
       (6, 1, 'arme_principale', '2025-09-01'),
       (6, 5, 'torse', '2025-09-01'),
       (7, 14, 'arme_principale', '2025-04-15'),
       (8, 3, 'arme_principale', '2023-05-01'),
       (9, 2, 'arme_principale', '2025-02-10'),
       (9, 17, 'torse', '2025-02-10'),
       (10, 3, 'arme_principale', '2023-09-01'),
       (11, 5, 'torse', '2025-05-15'),
       (12, 1, 'arme_principale', '2023-01-01'),
       (12, 16, 'arme_secondaire', '2023-01-01'),
       (14, 16, 'arme_principale', '2025-07-01'),
       (14, 14, 'arme_secondaire', '2025-07-01'),
       (15, 19, 'anneau', '2025-03-10'),
       (16, 3, 'arme_principale', '2025-08-01'),
       (18, 14, 'arme_principale', '2025-05-20'),
       (19, 2, 'arme_principale', '2025-01-15');

-- =============================================================================
-- COMBATS (jeu de référence lisible pour les exercices manuels)
-- =============================================================================

INSERT INTO combat (personnage_id, ennemi_id, date_combat, victoire, degats)
VALUES (1, 1, '2025-01-10 14:00:00', TRUE, 350),
       (1, 2, '2025-01-10 14:30:00', TRUE, 520),
       (1, 3, '2025-01-11 10:00:00', FALSE, 180),
       (1, 3, '2025-01-11 11:00:00', TRUE, 640),
       (2, 11, '2025-03-01 20:00:00', TRUE, 890),
       (2, 12, '2025-03-02 15:00:00', TRUE, 1200),
       (3, 7, '2022-03-03 18:00:00', TRUE, 750),
       (3, 8, '2022-03-04 19:00:00', FALSE, 400),
       (3, 8, '2022-03-05 20:00:00', TRUE, 980),
       (4, 4, '2023-02-01 16:00:00', TRUE, 420),
       (4, 5, '2023-02-01 17:00:00', TRUE, 380),
       (4, 6, '2023-02-02 14:00:00', FALSE, 210),
       (5, 9, '2023-09-10 21:00:00', TRUE, 290),
       (5, 10, '2023-09-12 20:00:00', TRUE, 850),
       (6, 7, '2023-05-10 18:00:00', TRUE, 680),
       (6, 8, '2023-05-11 19:00:00', TRUE, 1100),
       (7, 1, '2025-06-01 10:00:00', TRUE, 310),
       (7, 2, '2025-06-01 10:30:00', FALSE, 120),
       (8, 7, '2022-10-01 22:00:00', TRUE, 900),
       (8, 8, '2022-10-02 21:00:00', TRUE, 1400),
       (8, 19, '2025-10-02 20:00:00', TRUE, 1800),
       (8, 20, '2025-10-05 21:00:00', TRUE, 2500),
       (9, 1, '2025-01-20 15:00:00', TRUE, 280),
       (9, 2, '2025-01-20 16:00:00', TRUE, 430),
       (10, 4, '2022-08-01 17:00:00', TRUE, 560),
       (10, 6, '2022-08-02 18:00:00', TRUE, 820),
       (11, 11, '2023-03-01 19:00:00', TRUE, 710),
       (11, 12, '2023-03-02 20:00:00', TRUE, 950),
       (12, 1, '2022-05-01 09:00:00', TRUE, 1200),
       (12, 8, '2022-06-01 20:00:00', TRUE, 1600),
       (12, 20, '2025-10-08 22:00:00', TRUE, 3000),
       (13, 1, '2025-07-10 14:00:00', TRUE, 180),
       (13, 2, '2025-07-11 15:00:00', FALSE, 90),
       (14, 19, '2025-04-05 21:00:00', TRUE, 2200),
       (14, 20, '2025-04-08 22:00:00', TRUE, 2800),
       (14, 21, '2025-10-20 20:00:00', TRUE, 3500),
       (14, 22, '2025-10-25 21:00:00', TRUE, 4200),
       (15, 13, '2025-03-02 16:00:00', TRUE, 340),
       (15, 14, '2025-03-05 18:00:00', FALSE, 200),
       (16, 17, '2025-09-22 20:00:00', TRUE, 780),
       (16, 18, '2025-09-25 21:00:00', TRUE, 1300),
       (17, 1, '2025-06-01 12:00:00', TRUE, 220),
       (18, 13, '2025-05-01 18:00:00', TRUE, 410),
       (18, 15, '2025-05-02 19:00:00', TRUE, 650),
       (18, 17, '2025-11-01 20:00:00', TRUE, 720),
       (19, 13, '2025-01-02 14:00:00', TRUE, 290),
       (1, 4, '2025-11-18 20:00:00', TRUE, 480),
       (4, 4, '2025-11-15 19:00:00', TRUE, 510),
       (6, 12, '2025-11-01 21:00:00', TRUE, 1150),
       (8, 21, '2025-11-15 22:00:00', FALSE, 800);

-- =============================================================================
-- FIN DU SCRIPT DE DONNÉES
-- =============================================================================
