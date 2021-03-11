import Server from './server'
import dbConnection from './db'

const port = 1234;

const link = new dbConnection('localhost','','','monopunistra');
link.connect();

const server = new Server(port);
server.start();

/* TODO */
// Mettre en place des callbacks dan sle serveur pour les actions à effectuer en fonction des msssages reçus.
// Écrire un readme
// Créer la base de données et régler le problème d'authentification