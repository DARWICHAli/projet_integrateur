import mysql from 'mysql';

export default class dbConnection {
    readonly host:string;
    readonly user:string;
    readonly password:string;
    readonly db:string;
    
    constructor(host:string,user:string,password:string,db:string) {
        this.host=host;
        this.db=db;
        this.user=user;
        this.password=password;
    }

    connect():void {
        var connection = mysql.createConnection({
            host: this.host,
            user: this.user,
            password:this.password,
            database: this.db
        })

        connection.connect(function(err:Error){
            if (err) {
              return console.error('Erreur: ' + err.message);
            }
          
            console.log('Connecté au serveur MySQL.');
        });
    }
}