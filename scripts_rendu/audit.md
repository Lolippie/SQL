Voici la section Performance pour ton rapport d'audit :

---

## Performance

### Méthodologie

Les métriques ont été collectées via `EXPLAIN (ANALYZE, BUFFERS)` avant et après chaque optimisation et toujours à froid.

---

### 2.1 — Classement des guildes par activité

**Optimisation appliquée :** Création d'un index sur `combat(date_combat)`

```sql
CREATE INDEX idx_combat_date ON combat(date_combat);
```

| Métrique | Avant optimisation | Après optimisation | Gain |
|---|---|---|---|
| Coût estimé (cost) | 32 238 | 26 414 | −18 % |
| Temps réel | 159 ms | 129 ms | −19 % |

**Remarques :** Le goulot d'étranglement était le filtrage sur `date_combat >= NOW() - INTERVAL '2 years'`, qui déclenchait un sequential scan sur l'ensemble de la table `combat`. L'index permet à PostgreSQL de restreindre la plage de lignes lues. La requête reste relativement coûteuse en raison du volume de données impliqué (jointures sur trois tables et agrégation).

---

### 2.2 — Historique de connexion d'un joueur

**Optimisation appliquée :** Création d'un index composite couvrant le filtre, la condition `fin IS NOT NULL` et le tri

```sql
CREATE INDEX idx_session_joueur_fin_debut ON session(joueur_id, fin, debut DESC);
```

| Métrique | Avant optimisation | Après optimisation | Gain |
|---|---|---|---|
| Coût estimé (cost) | 8 294 | 70 | −99 % |
| Temps réel | 79 ms | 0,49 ms | −99 % |

**Remarques :** L'index composite `(joueur_id, fin, debut DESC)` permet à PostgreSQL de satisfaire en une seule passe le filtre sur `joueur_id`, l'exclusion des valeurs `NULL` sur `fin`, et le tri sur `debut DESC`. Le gain est spectaculaire car la requête passe d'un scan séquentiel complet à une recherche d'index directe ne retournant que 20 lignes.

---

### 2.3 — Pagination du journal de combat

**Optimisation appliquée :** Remplacement de la pagination par `OFFSET` par une pagination par keyset (curseur)

```sql
-- Avant (OFFSET)
... ORDER BY c.date_combat DESC LIMIT 20 OFFSET 9980;

-- Après (keyset)
... WHERE c.date_combat < '2024-12-25 13:28:55.604167'
ORDER BY c.date_combat DESC, c.id DESC LIMIT 20;
```

| Métrique | Avant optimisation (OFFSET 9 980) | Après optimisation (keyset) | Gain |
|---|---|---|---|
| Coût estimé (cost) | 1 052 | 4 | −99 % |
| Temps réel | 202 ms | 0,60 ms | −99 % |
| Buffers hit | 2 771 | — | — |
| Buffers read | 7 259 | — | — |

**Remarques :** Avec `OFFSET 9980`, PostgreSQL était contraint de lire et de jeter les 9 980 premières lignes avant de retourner les 20 lignes demandées, comme en attestent les buffers (7 259 blocs lus depuis le disque). La pagination par keyset court-circuite ce comportement : PostgreSQL utilise directement l'index `idx_combat_date` pour positionner le curseur à la bonne date, sans parcourir les pages précédentes. Cette approche est toutefois contraignante côté application (il faut conserver le curseur de la dernière ligne affichée).

---