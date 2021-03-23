import Server from './server'
import dbConnection from './db'
import { Subscription } from 'rxjs';
import promises from 'fs';

const port = 1234;


const link = new dbConnection('localhost','root','root','monopunistra');
link.connect();


// function queryDb(query:string):string {
//     link.query(query).then();
// }
var whateverImDoing = async() => {
    const result = await link.query("SELECT * FROM pions");
    // Do your thing with the result
    return result;
}

console.log(whateverImDoing());

// const server = new Server(port);
// server.start(queryDb);

/* TODO */
// Résoudre problème de réponse de base de données
// Écrire un readme
// Créer la base de données et régler le problème d'authentification 