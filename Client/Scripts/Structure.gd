extends Node

class_name Structure

enum PacketType {CHAT, JEU, BDD, INSCRIPTION_PARTIE, ADRESSE_SERVEUR_JEU, RESULTAT_LANCER_DE, CONSTRUCTION, DESTRUCTION, 
REQUETE_LANCER_DE, FIN_DE_TOUR, ACHAT, MAJ_TOUR, MAJ_ARGENT, MAJ_ACHAT, RENTE, MAJ_CONSTRUCTION, MAJ_DESTRUCTION, VENTE, MAJ_VENTE, ACTION, 
TAXE, FIN_DEP_GO_PRISON, CARTE_SORTIE_PRISON, GO_PRISON, FREE_OUT_PRISON, TOUR_PLUS_UN, ARGENT_NOUV_TOUR, HYPOTHEQUE, MAJ_HYPOTHEQUE, OUT_PRISON, 
ERREUR, PERDRE, INSCRIPTION, LOGIN, GAGNE, RECLAMER, REPONSE_LOGIN, TIRER_CARTE, CACHE_JOUEUR, STATS_CONSULT, REP_STATS, SEND_PSEUDO, ABANDONNER,BCAST_PSEUDOS}

var type
var data
var data2
var data3
var data4
var client

func set_requete_maj_tour(id):
	self.type = PacketType.MAJ_TOUR
	self.client = id

func set_requete_abandonner():
	self.type = PacketType.ABANDONNER

func set_requete_rente(argent, id, proprio, prix):
	self.type = PacketType.RENTE
	self.data = proprio
	self.client = id
	self.data2 = prix
	self.data3 = argent

func set_requete_erreur(code):
	self.type = PacketType.ERREUR
	self.data = code

func set_requete_reponse_login(code):
	self.type = PacketType.REPONSE_LOGIN
	self.data = code

func set_requete_consult_stats(player):
	self.type = PacketType.STATS_CONSULT
	self.data = player

func set_requete_maj_argent(argent, id):
	self.type = PacketType.MAJ_ARGENT
	self.data = argent
	self.client = id

func set_requete_maj_achat(argent, proprio, nbr_prop, prix):
	self.type = PacketType.MAJ_ACHAT
	self.data = argent
	self.data2 = nbr_prop
	self.data3 = prix
	self.client = proprio

func set_requete_maj_vente(argent, id, nbr_prop, prix):
	self.type = PacketType.MAJ_VENTE
	self.data = argent
	self.data2 = nbr_prop
	self.data3 = prix
	self.client = id

func set_requete_tirer_carte(argent, id, prix_gain, carte):
	self.type = PacketType.TIRER_CARTE
	self.data = argent
	self.data2 = prix_gain
	self.data3 = carte
	self.client = id

func set_requete_go_prison(id):
	self.type = PacketType.GO_PRISON
	self.client = id

func set_requete_out_prison(id, prix):
	self.type = PacketType.OUT_PRISON
	self.client = id
	self.data = prix
	
func set_requete_free_out_prison(id, type_sortie):
	self.type = PacketType.FREE_OUT_PRISON
	self.data = type_sortie # 0 si double, 1 si carte sortie de prison
	self.client = id

func set_fin_dep_go_prison():
	self.type = PacketType.FIN_DEP_GO_PRISON

func set_requete_carte_sortie_prison():
	self.type = PacketType.CARTE_SORTIE_PRISON

func set_requete_vendre(id_case):
	self.type = PacketType.VENTE
	self.data = id_case
	
func set_requete_acheter():
	self.type = PacketType.ACHAT

func set_requete_maj_construire(type_cons, argent, id, nbr_prop, prix):
	self.type = PacketType.MAJ_CONSTRUCTION
	self.data = type_cons # -1 pour maison, -2 pour hotel
	self.data2 = argent
	self.data3 = nbr_prop
	self.data4 = prix
	self.client = id
	
func set_requete_taxe(argent, id):
	self.type = PacketType.TAXE
	self.data = argent
	self.client = id

func set_requete_construire():
	self.type = PacketType.CONSTRUCTION

func set_requete_detruire(id_case):
	self.type = PacketType.DESTRUCTION
	self.data = id_case

func set_requete_fin_de_tour (): # click sur bouton "fin de tour"
	self.type = PacketType.FIN_DE_TOUR
	
func set_requete_tour_plus_un (): # case depart passée (plus un tour)
	self.type = PacketType.TOUR_PLUS_UN

func set_requete_argent_nouv_tour(argent, id):
	self.type = PacketType.ARGENT_NOUV_TOUR
	self.client = id
	self.data = argent
	
func set_requete_lancer_de ():
	self.type = PacketType.REQUETE_LANCER_DE
	
func set_requete_hypothequer(id_case):
	self.type = PacketType.HYPOTHEQUE
	self.data = id_case
	
func set_requete_maj_hypotheque(argent, id, nbr_prop, gain, status):
	self.type = PacketType.MAJ_HYPOTHEQUE
	self.data = argent
	self.data2 = nbr_prop
	self.data3 = gain
	self.data4 = status
	self.client = id

func set_requete_maj_destruction(argent, id, nbr_prop, gain, status):
	self.type = PacketType.MAJ_DESTRUCTION
	self.data = argent
	self.data2 = nbr_prop
	self.data3 = gain
	self.data4 = status
	self.client = id

func set_requete_gagne():
	self.type = PacketType.GAGNE

func set_requete_perdre(id, cause, list_prop):
	self.type = PacketType.PERDRE
	self.data = cause
	self.data2 = list_prop
	self.client = id

func set_inscription_partie (code_partie : int = 0, nb_joueurs : int = 1):
	self.type = PacketType.INSCRIPTION_PARTIE
	self.data = code_partie
	self.client = nb_joueurs

func set_plateau (plateau : Array):
	self.type = PacketType.JEU
	self.data = plateau

func set_chat_message (chat_message : String, joueur : String, playerId : int):
	self.type = PacketType.CHAT
	self.data = chat_message
	self.data2 = joueur
	self.data3 = playerId

func set_requete_BDD (requete_BDD : String):
	self.type = PacketType.BDD
	self.data = requete_BDD

func set_adresse_serveur_jeu (ip, port, nb_joueurs, id_joueur):
	self.type = PacketType.ADRESSE_SERVEUR_JEU
	self.data = str(ip) + ':' + str(port)
	self.data2 = id_joueur
	self.client = nb_joueurs

func set_resultat_lancer_de (Resultat : int, Client : int):
	self.type = PacketType.RESULTAT_LANCER_DE
	self.data = Resultat
	self.client = Client

func set_requete_inscription(mail, username, mdp, pays):
	self.type = PacketType.INSCRIPTION
	self.data = "('"+username+"','"+mdp+"','"+mail+"','"+pays+"');"

func set_requete_reclamer():
	self.type = PacketType.RECLAMER

func set_requete_connexion(mail,mdp):
	self.type = PacketType.LOGIN
	self.data = { 'mail' : mail, 'pwd' : mdp}

func set_requete_cache_joueur(num):
	self.type = PacketType.CACHE_JOUEUR
	self.data = num

func to_bytes () -> PoolByteArray:
	var obj = {'type' : self.type, 'data' : self.data, 'data2' : self.data2, 'data3' : self.data3, 'data4' : self.data4, 'client' : self.client}
	var string = var2str(obj)
	var bytes = string.to_utf8()
	return bytes


static func from_bytes (bytes : PoolByteArray) -> Object:
	var string = bytes.get_string_from_utf8()
	var obj = str2var(string)
	return obj
