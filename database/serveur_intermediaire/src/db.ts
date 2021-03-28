import mysql from 'mysql';

export default class dbConnection {

    /**
     * Attributs de la classe dbConnection
     */
    readonly host:string;
    readonly user:string;
    readonly password:string;
    readonly db:string;
    connection:mysql.Connection; // Objet de type 'connexion vers une base mysql'.
    
    /**
     * Constructeur de la classe dbConnection
     * @param host 
     * @param user 
     * @param password 
     * @param db 
     * 
     * Créé une connexion à la base de données
     */
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

    /**
     * Démarre la connexion vers la base de données et affiche un message d'erreur
     * ou de confirmation de la connexion
     */
    connect():void {
        this.connection.connect(function(err:Error){
            if (err) {
              return console.error('Erreur: ' + err.message);
            }
            console.log('Connecté au serveur MySQL.');
        });
    }

    /**
     * Ferme la connexion vers la base de données
     */
    close():void {
        this.connection.end();
    }

    /**
     * Effectue une requête vers la base de données avec la méthode query de mysql.Connection
     * Lorsque le résultat de la requête est récupéré, la méthode resolve de la requête est déclenchée
     * (voir méthode then dans l'appel de la fonction).
     * @param query:string la requête à effectuer vers la base de données.
     * @out : promesse
     */
    query(query:string):Promise<string> {
       return  new Promise<string>((resolve,reject) => {
         this.connection.query(query, (err,result)=>{
            if(err) reject(err);
            resolve(result);
         });
       })
    }
}