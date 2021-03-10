"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const server_1 = __importDefault(require("./server"));
const db_1 = __importDefault(require("./db"));
const port = 1234;
const link = new db_1.default('localhost', '', '', 'monopunistra');
link.connect();
const server = new server_1.default(port);
server.start();
/* TODO */
// Mettre en place des callbacks dan sle serveur pour les actions à effectuer en fonction des msssages reçus.
// Écrire un readme
// Créer la base de données et régler le problème d'authentification
//# sourceMappingURL=main.js.map