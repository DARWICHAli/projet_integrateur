import WebSocket from 'ws';
import WebSocketClient from 'ws';
import express from 'express';
import http from  'http';


export default class Server {

    /**
     * Attributs de la classe dbConnection. Un serveur, son port et une socket d'écoute.
     */
    private server:http.Server;
    private webSocketServer:WebSocket.Server;
    readonly port:number;
    
    /**
     * Constructeur du serveur, avec différents 
     * 
     * @param port Port sur lequel le serveur écoute.
     */
    constructor(port:number) {
        let app = express(); // Variable utilisant expressJS pour créer le serveur

        this.port=port;
        this.server = http.createServer(app);
        this.webSocketServer = new WebSocket.Server({server:this.server});
    }

    /** 
     * @param messageTreatment : fonction callback
     * 
     * Déclare les comportements associés à la nouvelle connexion d'un client, à la femeture d'une connexion
     * et à la réception de messages, puis démarre le serveur sur le port de l'instance.
     * 
     * Sur réception de message, lance la fonction callback en lui passant en paramètre le message reçu et le client qui l'a envoyé.
     * 
     */
    start(messageTreatment:(query:string,client:WebSocketClient) => any):void {
        this.webSocketServer.on("connection", function connection(client:WebSocketClient):void{
            console.log("Connection established");
            client.on("message", function message(msg:string):void {
                console.log("Message received, treatment of it.");
                messageTreatment(msg,client);
            });
        });

        this.webSocketServer.on("closedconnection", function(id) {
            console.log("Connection " + id + " a quitté le server");
        });

        this.server.listen(this.port, function():void {
            console.log("En attente de connection");
        });
    }

    /**
     * 
     * @param message : string, message à envoyer au client
     * @param client : WebSocketClient, client vers lequel envoyer un message
     */
    send(message:string,client:WebSocketClient):void {
        client.send (message);
        console.log(message + " sent to client");
    }

    /**
     * Ferme le serveur.
     */
    finish():void {
        this.server.close();
    }
}