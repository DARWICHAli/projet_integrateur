DROP TRIGGER IF EXISTS default_date_ut;

-- Fonction retournant les statistiques du joueur

CREATE FUNCTION IF NOT EXISTS stats_joueur(pseudo VARCHAR(30))
RETURN VARCHAR
IS
    retour VARCHAR(400);

BEGIN