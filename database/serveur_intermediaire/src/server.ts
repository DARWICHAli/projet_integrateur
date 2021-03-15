import WebSocket from 'ws';
import WebSocketClient from 'ws';
import express from 'express';
import http from  'http';


export default class Server {

    readonly port:number;
    constructor(port:number) {
        this.port=port;
    }

    start(receiveFunction:(query:string) => string):void {
        const app = express();
        const serveur = http.createServer(app);
        const webSocketServer = new WebSocket.Server({server:serveur});

        webSocketServer.on("connection", function connection(client:WebSocketClient):void{
            console.log("Connection established");
            client.on("message", function message(msg:string):void {
                console.log("Message received");
                var response :string = receiveFunction(msg);
                console.log(response);
                client.send(response);
            });
        });

        webSocketServer.on("closedconnection", function(id) {
            console.log("Connection " + id + " a quitté le serveur");
        });

        serveur.listen(this.port, function():void {
            console.log("En attente de connection");
        });
    }
}