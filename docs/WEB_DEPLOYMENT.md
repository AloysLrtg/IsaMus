# IsaMus — tests multijoueurs sur le Web

## Fichiers Web et CanvasKit

Le dossier `web/` existe : il ne faut pas régénérer les plateformes. Pour un autre checkout où il manquerait, la commande exacte est :

```sh
flutter create . --platforms web
```

`web/index.html` utilise le titre **IsaMus** et charge `flutter_bootstrap.js`. Le bootstrap sélectionne explicitement `renderer: "canvaskit"`. Le manifeste reprend le nom et le fond sombre de l’application.

Le SDK de référence est Flutter **3.47.6**, fixé dans `.flutter-version`. Cette version n’expose plus l’ancienne commande `flutter build web --web-renderer canvaskit`. Utiliser :

```sh
flutter pub get
flutter build web --release
```

Ce build JavaScript utilise CanvasKit ; ne pas ajouter `--wasm`, qui sélectionne un autre moteur. Le choix du moteur ne garantit pas à lui seul les performances : les tests ci-dessous restent nécessaires. Voir [l’initialisation Flutter Web](https://docs.flutter.dev/platform-integration/web/initialization).

Pour lancer un test local à une adresse stable :

```sh
flutter run -d chrome --web-port 7357
```

Pour tester le dossier compilé, sans recompiler :

```sh
python3 -m http.server 7357 --directory build/web
```

Ouvrir `http://localhost:7357/`. Un simple double-clic sur `index.html` ne remplace pas un serveur HTTP.

## Supabase : redirections Auth et CORS

Dans le projet **IsaMus**, ouvrir **Authentication → URL Configuration** :

- Pendant les tests locaux, **Site URL** : `http://localhost:7357/`.
- Une fois Vercel déployé, **Site URL** : l’adresse HTTPS stable réelle, par exemple `https://isamus-votre-equipe.vercel.app/` (exemple à remplacer).
- Dans **Redirect URLs**, conserver `http://localhost:7357/` et `http://localhost:7357/**` ; ajouter aussi `http://127.0.0.1:7357/` et `http://127.0.0.1:7357/**` si cette adresse est utilisée.
- Ajouter l’URL HTTPS de production exacte avec son chemin de retour, actuellement `/`. Ajouter les adresses de prévisualisation explicitement pour les tester. Éviter d’autoriser tous les projets `*.vercel.app`.
- Conserver les éventuelles redirections mobiles déjà configurées.

Les URL incluent le protocole et le port : `localhost` seul ne suffit pas. Un futur appel OAuth, lien magique ou récupération de mot de passe devra fournir un `redirectTo` correspondant à cette liste. **Site URL** est la destination par défaut, notamment pour les e-mails. Le parcours actuel e-mail/mot de passe et le mode invité n’utilisent pas de redirection externe ; l’ajout à la liste ne corrige donc pas à lui seul un refus de connexion.

Cette liste protège les **redirections Auth** ; ce n’est pas une liste CORS. Les API Supabase hébergées gèrent les appels navigateur. Si une fonction Edge personnalisée est appelée, son traitement `OPTIONS` et ses en-têtes CORS doivent également autoriser l’origine du site. Les règles RLS et les droits Realtime restent applicables.

La configuration Supabase publique est actuellement intégrée à `lib/main.dart`. Elle cible le projet existant. Ne jamais intégrer une clé `service_role` au build Web. Voir la [documentation Supabase des redirections](https://supabase.com/docs/guides/auth/redirect-urls).

## Connexion du dépôt GitHub à Vercel

1. Pousser sur GitHub les sources et les nouveaux fichiers de configuration, dont `web/flutter_bootstrap.js`, `.flutter-version`, `vercel.json` et les deux scripts Web. Les changements locaux non poussés ne seront pas déployés.
2. Dans Vercel, choisir **Add New → Project**, connecter GitHub et autoriser l’accès au dépôt IsaMus, puis **Import**.
3. Choisir **Framework Preset : Other** et le répertoire racine du dépôt, celui contenant `pubspec.yaml`. Ne pas choisir `web/` ou `build/web` comme racine du projet.
4. Utiliser les paramètres déjà enregistrés dans `vercel.json` :
   - **Install Command** : `bash scripts/install_flutter_web.sh`.
   - **Build Command** : `bash scripts/build_web.sh`.
   - **Output Directory** : `build/web`.
5. Le script d’installation récupère Flutter à la version fixée, prépare les outils Web et les dépendances. Le script de build ajoute ce SDK au chemin puis exécute **`flutter build web --release`**. Vercel ne doit pas supposer Flutter préinstallé.
6. Cliquer sur **Deploy**, relever l’URL HTTPS attribuée, puis configurer Supabase comme indiqué ci-dessus. Aucun changement distant de ces URL n’est effectué automatiquement par le dépôt.
7. Vérifier la branche de production dans les réglages Git de Vercel. Les prochains push sur cette branche redéploient la production ; les autres branches et pull requests peuvent créer des prévisualisations.

Le résultat servi est uniquement `build/web`, jamais les sources Flutter. La configuration prévoit le retour vers `index.html` pour les routes de l’application et la revalidation des fichiers de démarrage pour limiter les anciennes versions après déploiement. Voir les [réglages de build Vercel](https://vercel.com/docs/builds/configure-a-build) et les [déclencheurs Git](https://vercel.com/docs/builds).

## Vérification multijoueur après déploiement

Ouvrir le site dans quatre profils de navigateur ou sur plusieurs appareils, avec des comptes distincts. Vérifier connexion, création/rejoindre un salon, quatre places, actions synchronisées, reconnexion et fin de partie. Observer les requêtes Realtime dans les outils réseau du navigateur. Vérifier les animations et l’audio après une interaction utilisateur, les navigateurs pouvant bloquer la lecture automatique.

AdMob et les achats natifs sont désactivés sur le Web par les gardes de plateforme existantes. Leur absence ne doit pas empêcher le test du jeu. La compilation seule ne valide pas une partie multijoueur réelle ni les performances sur tous les appareils.
