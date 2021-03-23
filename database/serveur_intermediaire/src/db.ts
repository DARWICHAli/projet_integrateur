import mysql from 'mysql';

export default class dbConnection {
    readonly host:string;
    readonly user:string;
    readonly password:string;
    readonly db:string;
    connection:mysql.Connection;
    
    constructor(host:string,user:string,password:string,db:string) {
        this.host=host;
        this.db=db;
        this.user=user;
        this.password=password;
        this.connection = mysql.createConnection({
            host: this.host,
            user: this.user,
            password:this.password,
            database: this.db
        });
    }

    connect():void {
        this.connection.connect(function(err:Error){
            if (err) {
              return console.error('Erreur: ' + err.message);
            }
          
            console.log('Connecté au serveur MySQL.');
        });
    }

    query(query:string):string {
        var response:string="No response";
        this.connection.query(query, function (err:string, result:string) {
            if (err) result=err;
            response=result;
        });
        return response;
    }
}