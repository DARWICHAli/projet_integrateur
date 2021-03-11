"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mysql_1 = __importDefault(require("mysql"));
class dbConnection {
    constructor(host, user, password, db) {
        this.host = host;
        this.db = db;
        this.user = user;
        this.password = password;
    }
    connect() {
        var connection = mysql_1.default.createConnection({
            host: this.host,
            user: this.user,
            password: this.password,
            database: this.db
        });
        connection.connect(function (err) {
            if (err) {
                return console.error('Erreur: ' + err.message);
            }
            console.log('Connecté au serveur MySQL.');
        });
    }
}
exports.default = dbConnection;
//# sourceMappingURL=db.js.map