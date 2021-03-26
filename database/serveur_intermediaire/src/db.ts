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

    close():void {
        this.connection.end();
    }

    query(query:string):Promise<string> {
       return  new Promise<string>((resolve,reject) => {
         this.connection.query(query, (err,result)=>{
            if(err) reject(err);
            resolve(result);
         });
       })
    }
}