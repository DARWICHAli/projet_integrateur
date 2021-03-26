import Server from './server'
import dbConnection from './db'
import WebSocketClient from 'ws';

const port = 1234;


const link = new dbConnection('localhost','root','root','monopunistra');
link.connect();

const server = new Server(port);
server.start(queryDb);

function queryDb(query:string,client:WebSocketClient):void{
    link.query(query).then((response) => {
        console.log(response);
        server.send(response,client);
    });
}



/* TODO */
// Résoudre problème de réponse de base de données
// Écrire un readme
// Créer la base de données et régler le problème d'authentification 