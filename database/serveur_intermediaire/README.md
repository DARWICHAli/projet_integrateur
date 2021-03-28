# Serveur intermédiraire de communication avec la base de donnnées

## Pré-requis 
Installer NodeJs, npm 

## Utilisation

### Compilation
```
npx tsc
```
Cette commande va traduire les fichiers TypeScript contenus dans `src/`, en fichiers JavaScript dans le dossier `dist/`. Voir détails dans le fichier `tsconfig.json`. 

`node_modules/` contient des packages de types et de classes JavaScript, utilisés dans les différents fichiers à l'aide de la commande `import`, ainsi que fichiers et packages de build.

### Lancement des programmes 
```
Node dist/main.js
```
Un programme exemple client est également disponible, il effectue une simple requête de sélection dans une base de données.