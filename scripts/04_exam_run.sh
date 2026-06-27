#!/bin/bash
# =============================================================================
# ChronicleDB - Lancement du générateur Python pour chronicle_finale
# Cours SQL Avancé - ESGI 2025
# Python3 est préinstallé via le Dockerfile.
# =============================================================================

set -e

PGUSER="${POSTGRES_USER:-mj}"
PGDB="chronicle_finale"
SCRIPT_DIR="/scripts"

echo "[chronicle_finale] Python3 : $(python3 --version)" >&2
echo "[chronicle_finale] Génération du SQL (seed = UUID machine)..." >&2

python3 "${SCRIPT_DIR}/04_exam_generate.py" \
    | psql -U "${PGUSER}" -d "${PGDB}" -v ON_ERROR_STOP=1

echo "[chronicle_finale] Base chronicle_finale initialisée avec succès." >&2
