// Import des classes 
import Server from './server'
import dbConnection from './db'

// Import depuis les librairies Js
import WebSocketClient from 'ws';

const port = 1234;

/**
 * Création et démarrage de la connexion à la base de donnée (paramètres à adapter en fonction du support)
 */
const link = new dbConnection('localhost','root','root','monopunistra');
link.connect();

/**
 * Création et démarage du serveur de la base de données.
 * La méthode queryDb est passée en callback au démarrage : c'est elle qui sera appelée llors de la réception d'un message.
 * 
 */
const server = new Server(port);
server.start(queryDb);


/**
 * Effectue une requête à l'aide de la méthode query() de link:dbConnection
 * Dès finalisation de la requête dans la méthode query:dbConnection, la méthode resolve de la promesse s'éxécute.
 * Son contenu correspond au .then appelé dans cette fonction. Ici, on envoie la réponse récupérée vers le client passé en argument.
 *
 * @param query : chaîne de caractère correspondant à la requête à effectuer dans la base de données.
 * @param client : webSocketClient, cliet vers lequel envoyer la réponse de la base de données.
 */
function queryDb(query:string,client:WebSocketClient):void {
    link.query(query).then((response) => {
        console.log(JSON.stringify(response));
        server.send(JSON.stringify(response),client);
    });
}
