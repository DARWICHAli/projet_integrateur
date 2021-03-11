"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const ws_1 = __importDefault(require("ws"));
const express_1 = __importDefault(require("express"));
const http_1 = __importDefault(require("http"));
/**
 * function randomPosition()
 *
 * returns 2 random values, each one between -10 and 10, into an array of numbers.
 *
 * @returns {Array<number>}
 */
function randomPosition() {
    var x = Math.random() * (10 - (-10)) - 10;
    var y = Math.random() * (10 - (-10)) - 10;
    return [x, y];
}
class Server {
    constructor(port) {
        this.port = port;
    }
    start() {
        const app = express_1.default();
        const serveur = http_1.default.createServer(app);
        const webSocket = new ws_1.default.Server({ server: serveur });
        webSocket.on("connection", function connection(client) {
            console.log("Connection established");
            client.send("Bonjour");
            webSocket.on("message", function message() {
                console.log("Message received");
            });
        });
        serveur.listen(this.port, function () {
            console.log("En attente de connection");
        });
    }
}
exports.default = Server;
//# sourceMappingURL=server.js.map