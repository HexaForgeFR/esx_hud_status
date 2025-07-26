# 🎯 HUD RP - Statut Faim, Soif & Alcool pour ESX

Ce script HUD immersif pour serveur FiveM (ESX) affiche les jauges de **faim**, **soif** et **alcool**, avec des effets visuels réalistes et des alertes RP. Il est entièrement personnalisable et conçu pour une intégration facile.

## 🧩 Fonctionnalités

- ✅ Affichage des jauges : faim, soif et alcool
- 🥃 Effet "bourré" au-delà de 30% d'alcool (blur + mouvements déséquilibrés)
- ⚠️ Notifications automatiques de faim/soif faible
- 🧠 Sauvegarde SQL automatique (colonne `status` dans `users`)
- 🔄 Diminution dynamique des jauges configurable
- 🔧 Commande `/hud` pour activer/désactiver l'affichage
- 🎨 Interface moderne en NUI (HTML/CSS/JS + SVG)

## 📦 Installation

1. Glissez le dossier du script dans `resources/` de votre serveur.
2. Ajoutez à votre `server.cfg` :
-------------------------------------------------------------------------
3. **⚠️ Si vous avez un ancien HUD ou une colonne `status` existante dans la base de données :**
- Supprimez le dossier de l’ancien HUD.
- Supprimez la colonne `status` dans la table `users` :
  ```sql
  ALTER TABLE users DROP COLUMN status;
  ```
- Puis, appliquez la nouvelle structure SQL fournie dans ce script :
  ```sql
  ALTER TABLE users ADD COLUMN `status` LONGTEXT DEFAULT NULL;
  ```
  4. 🛠️ **La configuration du HUD (fréquence de mise à jour, perte de faim/soif/alcool, etc.) est entièrement modifiable dans le fichier `config.lua`.**

## 🛠️ Dépendances

- ESX Legacy (`es_extended`)
- `oxmysql` pour la base de données
- Framework HTML/CSS/JS pour l’interface NUI



