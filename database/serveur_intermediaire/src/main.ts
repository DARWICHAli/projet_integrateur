import Server from './server'
import dbConnection from './db'
import mysql from 'mysql';


const port = 1234;


const link = new dbConnection('localhost','root','root','monopunistra');
link.connect();

function queryDb(query:string):string{
    return link.query(query);
}

const server = new Server(port);
server.start(queryDb);

/* TODO */
// Résoudre problème de réponse de base de données
// Écrire un readme
// Créer la base de données et régler le problème d'authentification