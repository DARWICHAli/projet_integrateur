import WebSocket from 'ws';
import WebSocketClient from 'ws';
import express from 'express';
import http from  'http';


export default class Server {

    readonly port:number;
    constructor(port:number) {
        this.port=port;
    }

    start(messageTreatment:(query:string,client:WebSocketClient) => any):void {
        const app = express();
        const serveur = http.createServer(app);
        const webSocketServer = new WebSocket.Server({server:serveur});

        webSocketServer.on("connection", function connection(client:WebSocketClient):void{
            console.log("Connection established");
            client.on("message", function message(msg:string):void {
                console.log("Message received, treatment of it.");
                messageTreatment(msg,client);
            });
        });

        webSocketServer.on("closedconnection", function(id) {
            console.log("Connection " + id + " a quitté le serveur");
        });

        serveur.listen(this.port, function():void {
            console.log("En attente de connection");
        });
    }

    send(message:string,client:WebSocketClient):void {
        client.send (message);
        console.log(message + " sent to client");
    }
}