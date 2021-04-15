DROP TABLE IF EXISTS ACHETE_CASE;
DROP TABLE IF EXISTS UTILISE_PION;
DROP TABLE IF EXISTS AMIS;
DROP TABLE IF EXISTS OPPOSITION;
DROP TABLE IF EXISTS TROPHEE_JOUEUR;
DROP TABLE IF EXISTS DIFFICULTE_TROPHEE;
DROP TABLE IF EXISTS DIFFICULTE;
DROP TABLE IF EXISTS TROPHEE;
DROP TABLE IF EXISTS UTILISATEUR;

CREATE TABLE  IF NOT EXISTS UTILISATEUR(
idU INTEGER AUTO_INCREMENT,
username VARCHAR(30) NOT NULL,
password VARCHAR(30) NOT NULL,
email VARCHAR(50) NOT NULL,
pays VARCHAR(30),
tempsJeu INTEGER DEFAULT 0,
nbWin INTEGER DEFAULT 0,
nbLose INTEGER DEFAULT 0,
moneyWin INTEGER DEFAULT 0,
moneyLose INTEGER DEFAULT 0,
dateInscr DATE DEFAULT CURRENT_TIMESTAMP,
lastCo DATE DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT Pk_U PRIMARY KEY (idU),
CONSTRAINT Un_us UNIQUE(username),
CONSTRAINT Un_ml UNIQUE (email),
CONSTRAINT Ln_pswd CHECK(LENGTH(password) >= 8),
CONSTRAINT Form_ml CHECK (email LIKE '%@%.%')
);


CREATE  TABLE IF NOT EXISTS  TROPHEE ( 
idT INTEGER,
nomT VARCHAR(20) NOT NULL,
descrT  VARCHAR(500) NOT NULL,
CONSTRAINT Pk_T PRIMARY KEY (idT),
CONSTRAINT Nom_unique UNIQUE(nomT),
CONSTRAINT Lg_name CHECK(LENGTH(nomT) >= 5),
CONSTRAINT Descr_unique UNIQUE(descrT)
);

CREATE  TABLE IF NOT EXISTS  DIFFICULTE   (
idD INTEGER,
nomD VARCHAR(15),
CONSTRAINT Pk_D PRIMARY KEY (idD),
CONSTRAINT Nom_unique UNIQUE(nomD)
);

CREATE  TABLE IF NOT EXISTS DIFFICULTE_TROPHEE  (
idT INTEGER,
idD INTEGER,
CONSTRAINT Pk_DT PRIMARY KEY (idT,idD),
CONSTRAINT Fkt_DT FOREIGN KEY (idT) REFERENCES TROPHEE(idT),
CONSTRAINT Fkd_DT FOREIGN KEY (idD) REFERENCES DIFFICULTE (idD)
);

-- Voir pour unicité des trophées par joueur ?
CREATE  TABLE IF NOT EXISTS TROPHEE_JOUEUR(
idU INTEGER,
idT INTEGER,
CONSTRAINT Pk_TJ PRIMARY KEY (idU,idT),
CONSTRAINT Fkt_TJ FOREIGN KEY (idT) REFERENCES TROPHEE(idT),
CONSTRAINT Fkd_TJ FOREIGN KEY (idU) REFERENCES UTILISATEUR (idU)
);

CREATE  TABLE IF NOT EXISTS OPPOSITION  (
idU1 INTEGER,
idU2 INTEGER,
ecart INTEGER DEFAULT 0,
echange INTEGER DEFAULT 0,
date DATE DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT Fki1_OPP FOREIGN KEY (idU1)  REFERENCES UTILISATEUR (idU),
CONSTRAINT Fki2_OPP FOREIGN KEY (idU2)  REFERENCES UTILISATEUR (idU),
CONSTRAINT Diff_id_OPP CHECK(idU1 <> idU2)
);

CREATE  TABLE IF NOT EXISTS  UTILISE_PION(
idU INTEGER NOT NULL,
nomPion VARCHAR(20) NOT NULL,
date DATE DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT Fki1_UP FOREIGN KEY (idU) REFERENCES UTILISATEUR(idU)
);

CREATE  TABLE AMIS (
idU1 INTEGER,
idU2 INTEGER,
date DATE DEFAULT CURRENT_TIMESTAMP ,
CONSTRAINT Fki1_AM FOREIGN KEY (idU1)  REFERENCES UTILISATEUR (idU),
CONSTRAINT  Fki2_AM FOREIGN KEY (idU2)  REFERENCES UTILISATEUR (idU)
);

CREATE  TABLE IF NOT EXISTS  ACHETE_CASE(
idU INTEGER,
nomCase VARCHAR(20) NOT NULL,
date DATE DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT  Fki1_AC FOREIGN KEY (idU) REFERENCES UTILISATEUR(idU)
);
