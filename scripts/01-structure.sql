-- =============================================================================
-- ChronicleDB - Structure de la base de données
-- Cours SQL Avancé - ESGI 2025
-- Compatible PostgreSQL (syntaxe standard avec extensions PostgreSQL)
-- Exécuter en premier, avant 02-data_basics.sql
-- =============================================================================

-- =============================================================================
-- SUPPRESSION DES TABLES (ordre inverse des dépendances)
-- =============================================================================

DROP TABLE IF EXISTS equipement CASCADE;
DROP TABLE IF EXISTS inventaire CASCADE;
DROP TABLE IF EXISTS recompense CASCADE;
DROP TABLE IF EXISTS progression_quete CASCADE;
DROP TABLE IF EXISTS etape_quete CASCADE;
DROP TABLE IF EXISTS combat CASCADE;
DROP TABLE IF EXISTS ennemi CASCADE;
DROP TABLE IF EXISTS quete CASCADE;
DROP TABLE IF EXISTS donjon CASCADE;
DROP TABLE IF EXISTS session CASCADE;
DROP TABLE IF EXISTS personnage CASCADE;
DROP TABLE IF EXISTS guilde CASCADE;
DROP TABLE IF EXISTS zone CASCADE;
DROP TABLE IF EXISTS objet CASCADE;
DROP TABLE IF EXISTS classe CASCADE;
DROP TABLE IF EXISTS race CASCADE;
DROP TABLE IF EXISTS joueur CASCADE;
DROP TABLE IF EXISTS compte CASCADE;

DROP FUNCTION IF EXISTS fn_check_prerequis_quete() CASCADE;

-- =============================================================================
-- CRÉATION DES TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Compte : accès à la plateforme (email / mot de passe)
-- -----------------------------------------------------------------------------
CREATE TABLE compte
(
  id               SERIAL PRIMARY KEY,
  email            VARCHAR(150) NOT NULL UNIQUE,
  mot_de_passe     VARCHAR(255) NOT NULL,
  date_inscription TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- Joueur : profil de jeu associé à un compte (1 compte = 1 joueur)
-- -----------------------------------------------------------------------------
CREATE TABLE joueur
(
  id                 SERIAL PRIMARY KEY,
  compte_id          INT         NOT NULL UNIQUE REFERENCES compte (id) ON DELETE CASCADE,
  pseudo             VARCHAR(50) NOT NULL UNIQUE,
  derniere_connexion TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- Session : historique des connexions d'un joueur
-- -----------------------------------------------------------------------------
CREATE TABLE session
(
  id        SERIAL PRIMARY KEY,
  joueur_id INT       NOT NULL REFERENCES joueur (id) ON DELETE CASCADE,
  debut     TIMESTAMP NOT NULL DEFAULT NOW(),
  fin       TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- Classe : archétype de personnage (Guerrier, Mage, Rôdeur...)
-- -----------------------------------------------------------------------------
CREATE TABLE classe
(
  id   SERIAL PRIMARY KEY,
  nom  VARCHAR(50) NOT NULL UNIQUE,
  role VARCHAR(50) NOT NULL
);

-- -----------------------------------------------------------------------------
-- Race : origine du personnage (Humain, Elfe, Nain...)
-- -----------------------------------------------------------------------------
CREATE TABLE race
(
  id    SERIAL PRIMARY KEY,
  nom   VARCHAR(50) NOT NULL UNIQUE,
  bonus VARCHAR(150)
);

-- -----------------------------------------------------------------------------
-- Zone : région du monde de jeu
-- -----------------------------------------------------------------------------
CREATE TABLE zone
(
  id         SERIAL PRIMARY KEY,
  nom        VARCHAR(100) NOT NULL UNIQUE,
  niveau_min INT          NOT NULL DEFAULT 1
);

-- -----------------------------------------------------------------------------
-- Guilde : association de personnages, ancrée dans une zone
-- -----------------------------------------------------------------------------
CREATE TABLE guilde
(
  id      SERIAL PRIMARY KEY,
  zone_id INT          NOT NULL REFERENCES zone (id),
  nom     VARCHAR(100) NOT NULL UNIQUE,
  niveau  INT          NOT NULL DEFAULT 1
);

-- -----------------------------------------------------------------------------
-- Personnage : avatar en jeu, appartient à un joueur
-- -----------------------------------------------------------------------------
CREATE TABLE personnage
(
  id        SERIAL PRIMARY KEY,
  joueur_id INT         NOT NULL REFERENCES joueur (id) ON DELETE CASCADE,
  classe_id INT         NOT NULL REFERENCES classe (id),
  race_id   INT         NOT NULL REFERENCES race (id),
  guilde_id INT         REFERENCES guilde (id) ON DELETE SET NULL,
  nom       VARCHAR(80) NOT NULL UNIQUE,
  niveau    INT         NOT NULL DEFAULT 1 CHECK (niveau BETWEEN 1 AND 100),
  xp        INT         NOT NULL DEFAULT 0 CHECK (xp >= 0),
  gold      INT                  DEFAULT 0 CHECK (gold >= 0)
);

-- -----------------------------------------------------------------------------
-- Donjon : zone de combat difficile, rattachée à une zone
-- -----------------------------------------------------------------------------
CREATE TABLE donjon
(
  id         SERIAL PRIMARY KEY,
  zone_id    INT          NOT NULL REFERENCES zone (id),
  nom        VARCHAR(100) NOT NULL UNIQUE,
  difficulte VARCHAR(20)  NOT NULL CHECK (difficulte IN ('facile', 'normal', 'difficile', 'legendaire'))
);

-- -----------------------------------------------------------------------------
-- Ennemi : monstre ou boss présent dans un donjon
-- -----------------------------------------------------------------------------
CREATE TABLE ennemi
(
  id        SERIAL PRIMARY KEY,
  donjon_id INT          NOT NULL REFERENCES donjon (id) ON DELETE CASCADE,
  nom       VARCHAR(100) NOT NULL,
  pv        INT          NOT NULL CHECK (pv > 0),
  type      VARCHAR(50)  NOT NULL CHECK (type IN ('monstre', 'elite', 'boss', 'raid'))
);

-- -----------------------------------------------------------------------------
-- Combat : log d'un affrontement entre un personnage et un ennemi
-- -----------------------------------------------------------------------------
CREATE TABLE combat
(
  id            SERIAL PRIMARY KEY,
  personnage_id INT       NOT NULL REFERENCES personnage (id) ON DELETE CASCADE,
  ennemi_id     INT       NOT NULL REFERENCES ennemi (id) ON DELETE CASCADE,
  date_combat   TIMESTAMP NOT NULL DEFAULT NOW(),
  victoire      BOOLEAN   NOT NULL DEFAULT FALSE,
  degats        INT       NOT NULL DEFAULT 0 CHECK (degats >= 0)
);

-- -----------------------------------------------------------------------------
-- Quête : mission proposée dans une zone
-- Une quête peut avoir un prérequis : une autre quête devant être terminée
-- avant que le personnage puisse commencer celle-ci.
-- La cohérence est assurée par le trigger trg_check_prerequis_quete.
-- -----------------------------------------------------------------------------
CREATE TABLE quete
(
  id                 SERIAL PRIMARY KEY,
  zone_id            INT          NOT NULL REFERENCES zone (id),
  quete_prerequis_id INT          REFERENCES quete (id) ON DELETE SET NULL,
  titre              VARCHAR(150) NOT NULL,
  type               VARCHAR(30)  NOT NULL CHECK (type IN ('principale', 'secondaire', 'epique', 'quotidienne')),
  niveau_requis      INT          NOT NULL DEFAULT 1,
  date_expiration    TIMESTAMP,
  -- Empêche une quête d'être son propre prérequis
  CHECK (quete_prerequis_id <> id)
);

-- -----------------------------------------------------------------------------
-- Étape de quête : décomposition d'une quête en étapes ordonnées
-- -----------------------------------------------------------------------------
CREATE TABLE etape_quete
(
  id          SERIAL PRIMARY KEY,
  quete_id    INT          NOT NULL REFERENCES quete (id) ON DELETE CASCADE,
  ordre       INT          NOT NULL,
  description VARCHAR(255) NOT NULL,
  optionnelle BOOLEAN      NOT NULL DEFAULT FALSE,
  UNIQUE (quete_id, ordre)
);

-- -----------------------------------------------------------------------------
-- Objet : item du jeu (arme, armure, consommable, etc.)
-- -----------------------------------------------------------------------------
CREATE TABLE objet
(
  id          SERIAL PRIMARY KEY,
  nom         VARCHAR(100) NOT NULL UNIQUE,
  type        VARCHAR(50)  NOT NULL CHECK (type IN ('arme', 'armure', 'consommable', 'materiau', 'quete')),
  rarete      VARCHAR(20)  NOT NULL CHECK (rarete IN ('commun', 'peu_commun', 'rare', 'epique', 'legendaire')),
  valeur_gold INT          NOT NULL DEFAULT 0 CHECK (valeur_gold >= 0)
);

-- -----------------------------------------------------------------------------
-- Récompense : objet ou ressources obtenus en terminant une quête
-- -----------------------------------------------------------------------------
CREATE TABLE recompense
(
  id       SERIAL PRIMARY KEY,
  quete_id INT NOT NULL REFERENCES quete (id) ON DELETE CASCADE,
  objet_id INT REFERENCES objet (id) ON DELETE SET NULL,
  gold     INT NOT NULL DEFAULT 0 CHECK (gold >= 0),
  xp       INT NOT NULL DEFAULT 0 CHECK (xp >= 0)
);

-- -----------------------------------------------------------------------------
-- Progression de quête : suivi de l'avancement d'un personnage sur une quête
-- -----------------------------------------------------------------------------
CREATE TABLE progression_quete
(
  id            SERIAL PRIMARY KEY,
  personnage_id INT         NOT NULL REFERENCES personnage (id) ON DELETE CASCADE,
  quete_id      INT         NOT NULL REFERENCES quete (id) ON DELETE CASCADE,
  statut        VARCHAR(20) NOT NULL DEFAULT 'en_cours'
    CHECK (statut IN ('en_cours', 'terminee', 'abandonnee', 'echouee')),
  date_debut    TIMESTAMP   NOT NULL DEFAULT NOW(),
  date_fin      TIMESTAMP,
  UNIQUE (personnage_id, quete_id)
);

-- -----------------------------------------------------------------------------
-- Inventaire : objets possédés par un personnage
-- -----------------------------------------------------------------------------
CREATE TABLE inventaire
(
  id            SERIAL PRIMARY KEY,
  personnage_id INT NOT NULL REFERENCES personnage (id) ON DELETE CASCADE,
  objet_id      INT NOT NULL REFERENCES objet (id) ON DELETE CASCADE,
  quantite      INT NOT NULL DEFAULT 1 CHECK (quantite > 0),
  UNIQUE (personnage_id, objet_id)
);

-- -----------------------------------------------------------------------------
-- Équipement : objets actuellement portés par un personnage
-- -----------------------------------------------------------------------------
CREATE TABLE equipement
(
  id            SERIAL PRIMARY KEY,
  personnage_id INT         NOT NULL REFERENCES personnage (id) ON DELETE CASCADE,
  objet_id      INT         NOT NULL REFERENCES objet (id) ON DELETE CASCADE,
  emplacement   VARCHAR(30) NOT NULL CHECK (emplacement IN
                                            ('tete', 'torse', 'jambes', 'pieds', 'mains', 'anneau', 'amulette',
                                             'arme_principale', 'arme_secondaire')),
  equipe_le     TIMESTAMP   NOT NULL DEFAULT NOW(),
  UNIQUE (personnage_id, emplacement)
);

-- =============================================================================
-- TRIGGER : vérification du prérequis avant insertion dans progression_quete
-- =============================================================================
-- Ce trigger s'exécute avant chaque INSERT sur progression_quete.
-- Si la quête demandée a un prérequis, il vérifie que ce prérequis est bien
-- au statut 'terminee' pour ce personnage. Si ce n'est pas le cas, l'insertion
-- est bloquée avec un message d'erreur explicite.
-- Cas couverts :
--   - quête sans prérequis       → insertion autorisée
--   - prérequis terminé          → insertion autorisée
--   - prérequis non commencé     → insertion bloquée
--   - prérequis en cours         → insertion bloquée
--   - prérequis abandonné/échoué → insertion bloquée
-- =============================================================================

CREATE OR REPLACE FUNCTION fn_check_prerequis_quete()
  RETURNS TRIGGER AS
$$
DECLARE
  v_prerequis_id  INT;
  v_statut_prereq VARCHAR(20);
BEGIN
  -- Récupération du prérequis de la quête demandée
  SELECT quete_prerequis_id
  INTO v_prerequis_id
  FROM quete
  WHERE id = NEW.quete_id;

  -- Pas de prérequis : on laisse passer
  IF v_prerequis_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Récupération du statut du prérequis pour ce personnage
  SELECT statut
  INTO v_statut_prereq
  FROM progression_quete
  WHERE personnage_id = NEW.personnage_id
    AND quete_id = v_prerequis_id;

  -- Prérequis non commencé (aucune ligne trouvée)
  IF NOT FOUND THEN
    RAISE EXCEPTION
      'Prérequis non satisfait : le personnage % n''a pas encore commencé la quête % (id=%).',
      NEW.personnage_id, v_prerequis_id, v_prerequis_id;
  END IF;

  -- Prérequis commencé mais pas terminé
  IF v_statut_prereq <> 'terminee' THEN
    RAISE EXCEPTION
      'Prérequis non satisfait : la quête % (id=%) est au statut "%" pour le personnage %. Elle doit être "terminee".',
      v_prerequis_id, v_prerequis_id, v_statut_prereq, NEW.personnage_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_prerequis_quete
  BEFORE INSERT
  ON progression_quete
  FOR EACH ROW
EXECUTE FUNCTION fn_check_prerequis_quete();

-- Index sur quete_prerequis_id pour accélérer les lookups du trigger
CREATE INDEX idx_quete_prerequis ON quete (quete_prerequis_id);

-- =============================================================================
-- INDEX
-- =============================================================================

CREATE INDEX idx_personnage_joueur ON personnage (joueur_id);
CREATE INDEX idx_personnage_guilde ON personnage (guilde_id);
CREATE INDEX idx_personnage_classe ON personnage (classe_id);
CREATE INDEX idx_combat_personnage ON combat (personnage_id);
CREATE INDEX idx_combat_date ON combat (date_combat);
CREATE INDEX idx_session_joueur ON session (joueur_id);
CREATE INDEX idx_progression_perso ON progression_quete (personnage_id);
CREATE INDEX idx_progression_statut ON progression_quete (statut);
CREATE INDEX idx_inventaire_perso ON inventaire (personnage_id);

-- =============================================================================
-- FIN DU SCRIPT DE STRUCTURE
-- =============================================================================
