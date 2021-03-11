import WebSocket from 'ws';
import WebSocketClient from 'ws';
import express from 'express';
import http from  'http';

/**
 * function randomPosition() 
 * 
 * returns 2 random values, each one between -10 and 10, into an array of numbers.
 * 
 * @returns {Array<number>}
 */
function randomPosition ():Array<number> {
    var x = Math.random() * (10 - (-10)) -10; 
    var y = Math.random() * (10 - (-10)) -10;
    return [x,y];
}

export default class Server {

    readonly port:number;

    constructor(port:number) {
        this.port=port;
    }

    start():void {
        const app = express();
        const serveur = http.createServer(app);
        const webSocket = new WebSocket.Server({server:serveur});

        webSocket.on("connection", function connection(client:WebSocketClient):void{
            console.log("Connection established");

            client.send("Bonjour");

            webSocket.on("message", function message():void {
                console.log("Message received");
            });
        });

        serveur.listen(this.port, function():void {
            console.log("En attente de connection");
        });
    }
}