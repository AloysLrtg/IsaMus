# SPEC_MUS.md — Règlement du Mus (FFM, variante Iparralde)

> **Source de vérité absolue** pour tout le développement (moteur, bots, UI, réseau).
> Toute divergence entre le code et ce document est un bug du code.
> Règlement de référence : Fédération Française de Mus (Iparralde / Pays Basque Nord).

---

## 1. Équipes et victoire

- **4 joueurs**, 2 équipes de 2, installés **en croix** (partenaires face à face).
  - Équipe A : **Joueurs 0 et 2**
  - Équipe B : **Joueurs 1 et 3**
- Sens du jeu : l'index croît dans l'ordre de la table (0 → 1 → 2 → 3 → 0).
- **Partie** = **3 manches gagnantes** (premier à 3 manches).
- **Manche** = **40 tantto** (points).
  - 1 **hamarreko** = 5 tantto → 40 tantto = **8 hamarreko**.
- Dès qu'une équipe atteint **40 tantto**, la manche s'arrête immédiatement
  (même en plein décompte, cf. §9).

---

## 2. Paquet de cartes

- Jeu espagnol de **40 cartes** : 4 couleurs × 10 valeurs.
  - Couleurs : **Or (Oros), Coupe (Copas), Épée (Espadas), Bâton (Bastos)**.
  - **Sans 8 ni 9.**
- Valeurs : `1 (As), 2, 3, 4, 5, 6, 7, 10 (Valet/Sota), 11 (Cavalier/Caballo), 12 (Roi/Rey)`.
- ⚠️ **On joue à 4 Rois et 4 As véritables** :
  - les **3 ne sont PAS des Rois** (un 3 reste un 3) ;
  - les **2 ne sont PAS des As** (un 2 reste un 2).
  - Conséquence : seules les cartes de **même valeur faciale** sont identiques
    (pour les Paires et Doubles).
- Chaque joueur reçoit **4 cartes**.

### Valeur « points » d'une carte (pour Jeu / Point)

| Carte | Valeur |
|-------|--------|
| 1 à 7 | leur chiffre |
| 10, 11, 12 (figures) | **10** |

---

## 3. Ordre de parole — Esku

- Le joueur situé **à droite du donneur** est **Esku** (« la main »).
- Index : **Esku = 0**, puis **Joueur 1, Joueur 2, Joueur 3 (= Donneur)**.
  *(Ces indices sont relatifs à la donne : rotation de l'Esku à chaque donne, §3.1.)*
- **Priorité (ordre de parole ET de départage)** :
  `Esku (0) > Joueur 1 > Joueur 2 > Joueur 3 (Donneur)`
- **Égalité parfaite** sur n'importe quelle phase (Grand, Petit, Paires, Jeu, Point) :
  le joueur **le plus proche de l'Esku** (selon l'ordre ci-dessus) **l'emporte dans tous les cas**.
  - Le départage se fait entre les joueurs adverses concernés ; un joueur gagnant
    entraîne la victoire de **son équipe** pour cette phase.
  - ⚠️ Seule exception explicite : règle de l'Article 12 sur les Doubles (§5.3.1).

### 3.1 Rotation du donneur et de l'Esku

- À la **fin de chaque main**, le rôle de **donneur tourne d'un cran vers la droite**
  (sens **inverse des aiguilles d'une montre**).
- L'**Esku** (à droite du donneur) tourne donc **aussi d'un cran vers la droite**.
  (Le nouveau donneur est l'ancien Esku.)
- La rotation **continue de la même manière** au début d'une **nouvelle manche**
  (pas de remise à zéro).

---

## 4. Phase de Mus (échange de cartes)

1. L'**Esku** et son **partenaire** se concertent (« **Zuetan** » / « À vous »)
   pour décider d'aller **« Mus »** ou de parler (**« Mintza »**).
2. Chaque joueur, à son tour, dit **Mus** ou **Mintza**.
3. Si **les 4 joueurs** acceptent le Mus :
   - chacun **se défausse de 0 à 4 cartes** ;
   - les nouvelles cartes sont distribuées **d'un coup** à tous ;
   - la phase de Mus recommence (jusqu'à ce qu'un joueur dise Mintza).
4. Dès qu'**un seul joueur** dit **« Mintza »**, la phase de Mus s'arrête
   et **les enchères commencent**.

### 4.1 Talon épuisé pendant la défausse

- Si le **talon est épuisé** pendant la distribution après défausse, on **ramasse les cartes
  déjà défaussées par les joueurs lors de ce tour**, on les **mélange**, et elles
  constituent le **nouveau talon** pour **terminer la distribution**.

---

## 5. Les 4 phases d'enchères

Toujours dans cet ordre :

1. **Grand (Haundia)**
2. **Petit (Ttiki)**
3. **Paires (Pariak)**
4. **Jeu (Jokoa)** **OU** **Point (Pontua)**

Chaque phase est résolue par ses propres enchères (cf. §8). Les cartes ne sont
révélées / comparées qu'à l'issue des enchères (ou immédiatement en cas de Hordago accepté).

### 5.1 Grand (Haundia)

- Comparaison **carte par carte, de la plus haute à la plus basse**.
- Force des cartes : `12 > 11 > 10 > 7 > 6 > 5 > 4 > 3 > 2 > 1`.
- Le joueur ayant la meilleure main (comparaison lexicographique des 4 cartes triées
  de la plus forte à la plus faible) gagne le Grand.
- Égalité parfaite → départage par proximité de l'Esku (§3).

### 5.2 Petit (Ttiki)

- Comparaison **carte par carte, de la plus basse à la plus haute**.
- Force (la plus petite gagne) : `1 < 2 < 3 < 4 < 5 < 6 < 7 < 10 < 11 < 12`.
- Le joueur dont les 4 cartes triées de la plus faible à la plus forte sont
  lexicographiquement les plus basses gagne le Petit.
- Égalité parfaite → départage par proximité de l'Esku (§3).

### 5.3 Paires (Pariak)

- Chaque joueur annonce **s'il a des paires ou non** (le déclaratif est obligatoire
  et sincère : « Pariak dut » / « Ez dut »).
- Seuls les joueurs **ayant des paires** participent aux enchères de cette phase.
  Si **aucune équipe** n'a de paires, ou si **une seule équipe** en a,
  il n'y a pas d'enchère (cf. §8.7).
- Hiérarchie (de la plus forte à la plus faible) :

| Rang | Nom | Composition | Bonus (tantto) |
|------|-----|-------------|----------------|
| 1 | **Doubles** (Double paire) | 2 paires (ex. 5-5-7-7) **ou** 4 cartes identiques | **3** |
| 2 | **Mediak** (Brelan) | 3 cartes identiques | **2** |
| 3 | **Paire simple** | 2 cartes identiques | **1** |

- Au sein d'un même rang :
  - **Paire simple** : la plus haute paire gagne (ordre Grand : `12 > 11 > 10 > 7 > … > 1`).
  - **Mediak** : le brelan le plus haut gagne.
  - **Doubles** : on compare la **paire haute**, puis la **paire basse**.
    4 cartes identiques = double paire de la même valeur (ex. 7-7-7-7 = paire haute 7, paire basse 7).
- Égalité parfaite → départage par proximité de l'Esku (§3).

#### 5.3.1 Article 12 — Exception sur les Doubles

> Si **deux adversaires** ont des **Doubles** dont la **paire haute est identique**,
> c'est la **paire basse la plus forte** qui l'emporte **dans tous les cas**,
> **même contre l'Esku**.

- Cette règle prime sur la priorité d'Esku : si les paires hautes sont égales,
  la paire basse décide ; la proximité de l'Esku n'intervient qu'en cas d'égalité
  **totale** (paire haute ET paire basse identiques, ce qui n'est possible qu'avec
  des couleurs différentes).

### 5.4 Jeu (Jokoa) ou Point (Pontua)

**Calcul** : somme des 4 cartes avec les valeurs « points » du §2
(figures 10/11/12 = 10 ; 1 à 7 = leur chiffre).

Au début de cette phase, on détermine si **au moins un joueur** a un total **≥ 31**.

#### 5.4.1 Jeu (Jokoa) — si au moins un joueur a un total ≥ 31

- Seuls les joueurs ayant le Jeu (≥ 31) participent (annonce « Jokoa dut » / « Ez dut »).
- **Ordre de force du Jeu** (du plus fort au plus faible) :

  `31 > 32 > 40 > 37 > 36 > 35 > 34 > 33`

- **Bonus de fin de manche** (bonus de décompte) :
  - **31 = 3 tantto**
  - tous les **autres Jeux (32, 33, 34, 35, 36, 37, 40) = 2 tantto**
- Égalité parfaite → départage par proximité de l'Esku (§3).

#### 5.4.2 Point (Pontua) — si PERSONNE n'a un total ≥ 31

- Tous les joueurs participent.
- Le total **le plus proche de 30** l'emporte : `30 > 29 > 28 > 27 > … `
- **Bonus de fin de manche : 1 tantto.**
- Égalité parfaite → départage par proximité de l'Esku (§3).

---

## 6. Enchères : actions, blocages et résolution

### 6.1 Actions possibles

| Terme basque | Français | Effet |
|--------------|----------|-------|
| **Paso** | Passer | Ne mise pas. |
| **Embido** | Miser | Mise **2 tantto** par défaut. **N tantto** : *Hiru Embido* = 3, *Lau Embido* = 4, etc. |
| **Gehiago** | Relancer | Relance de **+N tantto** par-dessus la mise courante. |
| **Hordago** | Tapis | Mise **la manche entière** (40 tantto). |
| **Iduki** | Tenir / Accepter | Accepte la mise (ou le Hordago) courante. |
| **Tira** | Refus de l’équipe | Confirme le refus après celui du partenaire, ou lorsque celui-ci ne participe pas à cette sous-phase. |
| **Nere gatik tira** | « Pour moi, tirez » | Indique à son partenaire que l'on veut jeter, mais **laisse au partenaire le droit de tenir ou de relancer**. |

### 6.2 Blocages (décision d'équipe)

- **Iduki** et **Hordago** engagent toute l’équipe.
- Un premier refus face à une mise, même saisi comme **Tira**, est enregistré comme
  **Nere gatik tira** si le partenaire participe encore à cette sous-phase. La parole
  passe obligatoirement à ce partenaire ; aucun point ni résultat de phase n’est attribué.
- Le partenaire peut accepter (**Iduki**), relancer, ou confirmer **Tira**. Seuls les
  deux refus successifs clôturent l’enchère par abandon. Si le partenaire est exclu
  de la sous-phase (par exemple sans paires), l’unique répondant peut faire **Tira** directement.
- Chaque nouvelle relance recommence ce choix pour l’équipe adverse. Un **Paso**
  d’ouverture ne constitue pas le refus d’une mise annoncée ensuite.
- L’interface présente **Nere gatik tira** au premier répondant et **Tira** au dernier.
  Les refus automatiques des chronomètres suivent exactement la même règle.

### 6.3 Hordago accepté

- Un **Hordago accepté (Hordago Iduki)** **arrête tout**, quelle que soit la phase
  (Grand, Petit, Paires, Jeu ou Point) :
  - les joueurs **abattent leurs cartes immédiatement** ;
  - le joueur qui a la **meilleure combinaison dans la phase concernée**
    (comparaison des cartes, départage Esku inclus, §3 et §5.3.1) fait **gagner la manche
    entière (40 tantto)** à son équipe **sur-le-champ** ;
  - **aucun autre point** n'est comptabilisé (ni bonus, ni mises, ni phases suivantes).

### 6.4 Points de Tira (marqués immédiatement)

Quand une équipe refuse (**Tira**) une enchère, l'équipe adverse marque **immédiatement**
(en cours de jeu, avant le décompte final) :

- **1 tantto** si le Tira répond à un **premier Embido** ou à un **Hordago** ;
- sinon, le **montant de la mise précédente** (celle qui précédait la relance refusée).

*Exemple* : A mise 2, B relance +3 (total 5), A fait Tira → B marque **2** (mise précédente).
*Exemple* : A mise 2, les deux répondants de B refusent successivement → A marque **1** (premier Embido refusé).

### 6.5 Résolution des phases

Pour chaque phase, selon les enchères :

| Situation | Conséquence |
|-----------|-------------|
| Tira à une enchère | Points de Tira immédiats (§6.4) ; la phase est **terminée**, pas de comparaison. |
| Iduki à une mise | Mise acceptée ; le gagnant de la phase (comparaison des cartes) remporte les mises au **décompte final** (§9). |
| Paso de tous | Aucun engagement ; au décompte, **1 tantto** pour le gagnant de Grand/Petit (cf. §9). |
| Hordago accepté | Fin de manche immédiate (§6.3). |

### 6.6 Ordre des tours d'enchère

- L'enchère tourne dans l'ordre de priorité : **Esku (0) → 1 → 2 → 3**.
- Après un Embido / Gehiago, la parole passe à **l'équipe adverse**
  (le joueur adverse le plus proche de l'Esku parle en premier, puis son partenaire
  ne peut décider qu'en respectant les blocages du §6.2).
- La phase s'arrête quand :
  - tout le monde a fait Paso, ou
  - une mise est suivie d'Iduki / Tira de l'équipe adverse, ou
  - un Hordago est lancé puis accepté ou refusé.

### 6.7 Cas particulier Paires / Jeu

- Si **aucun adversaire** n'a de Paires (ou de Jeu) — c'est-à-dire si **une seule équipe**
  en possède — il n'y a **aucune phase d'enchère** : l'équipe concernée marque simplement
  ses **bonus intrinsèques** (de chaque partenaire en ayant) lors du décompte (§9).
- Si **personne** n'a de Paires, la phase est ignorée.
- Pour le **Jeu** : si personne n'a ≥ 31, on bascule vers le **Point** (§5.4.2).
  Si une seule équipe a le Jeu, **pas de Point** : seuls ses bonus de Jeu sont marqués.

### 6.8 Absence de plafond

- Il n'y a **aucun plafond** aux mises : les joueurs peuvent surenchérir (**Gehiago**)
  **indéfiniment**.
- Le seul plafond absolu est le **Hordago** (tapis sur la manche entière, 40 tantto).

### 6.9 Précisions d'implémentation des enchères

**Limites des mises**
- Un **Embido** vaut **au moins 2** tantto ; une relance **Gehiago** vaut **au moins +1**.
- Un **Hordago** ne peut **ni être relancé (Gehiago), ni être contré par un autre Hordago** :
  l'adversaire ne peut que **Iduki**, **Tira** ou **Nere gatik tira**.
- Tant qu'aucune mise n'existe, seuls **Paso / Embido / Hordago** sont possibles ;
  quand une mise est sur la table, seuls **Iduki / Tira / Nere gatik tira / Gehiago / Hordago**
  (Gehiago et Hordago sauf si la mise courante est un Hordago) sont possibles ;
  **Paso** et **Embido** ne sont alors plus permis.
- Si **tous les participants** d'une sous-phase font **Paso**, la sous-phase s'arrête (sans mise).

**Ordre de réponse**
- Après une mise ou une relance, l'**équipe adverse** répond ; son joueur **le plus proche de
  l'Esku** (parmi les participants à la sous-phase) répond en premier.

**Nere gatik tira**
- Le joueur qui le dit **transmet la décision à son partenaire** (s'il participe à la
  sous-phase). Le partenaire choisit alors **Iduki, Tira, Gehiago ou Hordago** ;
  il **ne peut pas** dire à nouveau « Nere gatik tira ».
- S'il **n'y a pas de partenaire** dans la sous-phase (Paires / Jeu), **Nere gatik tira équivaut à Tira**.

**Talon épuisé**
- Si le talon est épuisé pendant la distribution après défausse, seules les cartes **défaussées
  pendant ce tour de Mus** sont remélangées pour former le nouveau talon (§4.1). Les cartes
  défaussées lors de tours de Mus **précédents** restent **hors jeu**.

**Bonus de Paires / Jeu conservés après un Tira**
- Un **Tira** ne supprime **pas** les **bonus intrinsèques** des Paires et du Jeu : au décompte
  final, l'équipe gagnante des Paires (ou du Jeu), déterminée par **comparaison des cartes** de
  tous les participants, marque quand même les bonus de ses joueurs. Seules les **mises** sont
  perdues (les points de Tira ayant déjà été marqués, §6.4).
- Pour le **Grand** et le **Petit**, un Tira vaut **0** au décompte. Pour le **Point**,
  un Tira vaut aussi **0** (pas de Pontua).
- Le point de **Pontua** (1 tantto) est marqué sur **Paso général** ou **mise acceptée**
  (en plus de la mise).

**Fin de manche immédiate**
- Si des points de **Tira** font atteindre **40** à une équipe, la manche se termine
  **immédiatement** (sans décompte ni phases suivantes).
- Au décompte (§9), les gains sont ajoutés **un par un** (mise, puis bonus, phase par phase) et
  la manche s'arrête dès qu'une équipe atteint 40.

---

## 7. Annonces obligatoires

- **Paires** : chaque joueur doit déclarer s'il en possède (type non précisé à ce stade,
  sauf à la révélation au décompte).
- **Jeu** : chaque joueur doit déclarer s'il a le Jeu (≥ 31).
- Les déclarations doivent être **sincères** (le moteur les calcule automatiquement).

---

## 8. Récapitulatif des tantto (hiérarchie des gains)

| Phase | Gain de base sur Paso | Mises acceptées (Iduki) | Bonus de décompte |
|-------|-----------------------|--------------------------|-------------------|
| Grand | **1** | mise totale | — |
| Petit | **1** | mise totale | — |
| Paires | **AUCUN** (0) | mise totale | Doubles **3** / Mediak **2** / Paire **1** *(pour **chaque** partenaire de l'équipe gagnante qui a des paires)* |
| Jeu | **AUCUN** (0) | mise totale | **31 = 3** / autres Jeux = **2** *(pour **chaque** partenaire de l'équipe gagnante qui a le Jeu)* |
| Point | **1** (Pontua) | mise totale | — |

> Sur un **Paso** aux **Paires** ou au **Jeu**, il n'y a **pas** de point de base :
> on ne compte **UNIQUEMENT** que les **bonus** des paires / jeux de l'équipe gagnante
> lors du décompte final.

---

## 9. Décompte final (ordre de tirage des points)

Après les 4 phases (si aucun Hordago accepté n'a terminé la manche), on **tire les points
dans cet ordre strict** :

1. **Grand** :
   - **1 tantto** si tous ont fait **Paso** (au gagnant) ;
   - le montant des **mises** si **Iduki** (au gagnant) ;
   - **0** si **Tira** (les points de Tira ont déjà été marqués en cours de jeu, §6.4).
2. **Petit** : même règle que le Grand.
3. **Paires** :
   - **mises Iduki éventuelles** (au gagnant des Paires) **+**
   - **bonus de toutes les paires des 2 partenaires de l'équipe gagnante des Paires**
     (chaque partenaire de l'équipe gagnante qui possède des paires marque son bonus :
     Doubles 3 / Mediak 2 / Paire 1).
4. **Jeu** ou **Point** :
   - **Jeu** : **mises Iduki éventuelles** + **bonus des jeux des 2 partenaires de l'équipe
     gagnante du Jeu** (31 = 3, autres = 2, pour chaque partenaire ayant le Jeu) ;
   - **Point** : **mises éventuelles** + **1 tantto de Pontua**.

**Arrêt anticipé** : à tout moment du décompte, **dès qu'une équipe atteint 40 tantto**,
la manche **s'arrête immédiatement** (les phases suivantes ne sont pas comptées).

---

## 10. Annexe — Glossaire basque

| Terme | Signification |
|-------|---------------|
| Esku | La main (joueur prioritaire, à droite du donneur) |
| Zuetan | « À vous » (concertation Esku / partenaire pour le Mus) |
| Mintza | « Je parle » (refus du Mus, début des enchères) |
| Mus | Demande d'échange de cartes |
| Haundia | Grand |
| Ttiki | Petit |
| Pariak | Paires |
| Jokoa | Jeu |
| Pontua | Point |
| Tantto | Point (unité de score) |
| Hamarreko | Groupe de 5 tantto |
| Paso | Passer |
| Embido | Miser (2 par défaut) |
| Hiru Embido | Miser 3 |
| Gehiago | Relancer |
| Hordago | Tapis (mise = manche entière) |
| Iduki | Tenir / Accepter |
| Tira | Refuser / Se coucher |
| Nere gatik tira | « Pour moi tirez » (laisse la décision au partenaire) |
| Mediak | Brelan |
| Doubles | Double paire ou carré |

---

## 11. Clarifications officielles (résolues)

> Points initialement non tranchés, désormais validés. Ils sont intégrés dans les sections
> concernées (rappel des références ci-dessous).

1. **Plafond d'une mise** : **aucun plafond**. Gehiago peut être répété indéfiniment ;
   le seul plafond absolu est le **Hordago** (§6.1, §6.8).
2. **Rotation** : voir §3.1.
3. **Gain de base sur Paso** : voir §8 (aucun point de base aux Paires et au Jeu).
4. **Une seule équipe a Paires / Jeu** : aucune enchère, bonus intrinsèques seuls (§6.7).
5. **Talon épuisé pendant le Mus** : voir §4.1.
6. **Hordago Iduki en Paires / Jeu** : voir §6.3.
