# IsaMus

Jeu de Mus Flutter/Riverpod avec Supabase Auth, PostgreSQL et Realtime.

Au premier lancement sans session, l’écran de connexion propose e-mail/mot de passe ou le mode invité. Un écran d’inscription distinct recueille le pseudo et crée automatiquement le profil ; la confirmation e-mail est désactivée pour ouvrir directement l’accueil après inscription. Une session restaurée ouvre directement l’accueil ; la déconnexion réinitialise la navigation et les données locales de session.

Le menu Réglages est accessible depuis le rouage du bandeau global ; le Profil regroupe l’identité, les performances et l’historique.

Le projet comprend le Top 100, les demandes d’amitié et invitations privées, la présence, les graphiques de statistiques globales et par mode, le Peak Elo et l’historique, un éditeur d’avatar par calques et trois bots aux identités fixes — Patxi conservateur, Mikel équilibré et Txomin bluffeur — avec leurs avatars et des signes toujours vérifiés, les cosmétiques, la connexion e-mail avec accès invité explicite, les signes Keinuak animés par Broadcast privé, les effets sonores et les intégrations AdMob/RevenueCat, un tutoriel scripté sans timer, la consultation des profils en jeu et un Pass de Saison en route verticale à 30 paliers avec XP, niveaux, pièces et récompenses, un calendrier mensuel commun au Classé et des cosmétiques de ligue selon le Peak Elo, ainsi que des quêtes hebdomadaires accessibles en modale depuis le bandeau.

**Backend :** les migrations précédentes et les trois fonctions Edge sont déployées sur le projet Supabase existant. Le lot calendrier mensuel / récompenses de ligue est préparé et testé ; ses quatre migrations restent à déployer après rétablissement du connecteur Supabase. Les anciens clients doivent être mis à jour. Consulter [les instructions de mise en service](docs/DEPLOYMENT.md) pour configurer les stores, la publicité et les documents légaux avant publication.

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

Les annonces sont désactivées et la boutique n’effectue aucun achat tant que ses clés ne sont pas configurées. Exemple de paramètres publics : `config.example.json`. Les clés secrètes de validation restent exclusivement dans Supabase Edge Functions.

Les textes juridiques fournis sont des projets à compléter. Le moteur demeure sous autorité de l’hôte : la sécurité du classement contre un hôte malveillant nécessite un arbitre serveur.

Déploiement navigateur : consulter [le guide Web et Vercel](docs/WEB_DEPLOYMENT.md). Le projet contient la configuration CanvasKit et les scripts de build pour Vercel.
