-- =============================================================================
-- ChronicleDB - Point d'entrée unique d'initialisation
-- Cours SQL Avancé - ESGI 2025
-- Note : PostgreSQL 18 utilise ICU pour les locales (plus de locale système)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Base chronicle_dev : structure + données de référence uniquement
-- -----------------------------------------------------------------------------

\echo '========================================='
\echo 'Création de chronicle_simple...'
\echo '========================================='

-- CREATE DATABASE chronicle_simple
--   WITH ENCODING = 'UTF8'
--   LOCALE_PROVIDER = 'icu'
--   ICU_LOCALE = 'fr-FR'
--   TEMPLATE = template0;
--
-- \c chronicle_simple
-- \echo '=== Initialisation de la structure...'
-- \i /scripts/01-structure.sql
-- \echo '=== Initialisation des données...'
-- \i /scripts/02-data_basics.sql

-- -----------------------------------------------------------------------------
-- Base chronicle_prod : structure + données de référence + données massives
-- -----------------------------------------------------------------------------
\echo '========================================='
\echo 'Création de chronicle_massive...'
\echo '========================================='

-- CREATE DATABASE chronicle_massive
--   WITH ENCODING = 'UTF8'
--   LOCALE_PROVIDER = 'icu'
--   ICU_LOCALE = 'fr-FR'
--   TEMPLATE = template0;
--
-- \c chronicle_massive
-- \echo '=== Initialisation de la structure...'
-- \i /scripts/01-structure.sql
-- \echo '=== Initialisation des données...'
-- \i /scripts/02-data_basics.sql
-- \echo '=== Plus de données !'
-- \i /scripts/03-data_massive.sql

-- -----------------------------------------------------------------------------
-- Base chronicle_finale : générée dynamiquement via Python
-- Chaque démarrage produit une base unique (seed = UUID machine du conteneur)
-- -----------------------------------------------------------------------------

\echo '========================================='
\echo 'Création de chronicle_finale...'
\echo '========================================='

CREATE DATABASE chronicle_finale
  WITH ENCODING = 'UTF8'
  LOCALE_PROVIDER = 'icu'
  ICU_LOCALE = 'fr-FR'
  TEMPLATE = template0;

\c chronicle_finale
\echo '=== Initialisation de la structure...'
\i /scripts/01-structure.sql
\echo '=== Grand random de la donnée...'
\! bash /scripts/04_exam_run.sh


\echo '========================================='
\echo 'Initialisation terminée !'
\echo '========================================='
