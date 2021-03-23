extends Node

class_name Structure

enum PacketType {CHAT, JEU, BDD, INSCRIPTION_PARTIE, ADRESSE_SERVEUR_JEU,
RESULTAT_LANCER_DE, REQUETE_LANCER_DE, FIN_DE_TOUR, ACHAT, MAJ_ARGENT, MAJ_ACHAT, 
RENTE, ERREUR}

var type
var data
var data2
var client

func set_requete_rente(argent, id, proprio, prix):
	self.type = PacketType.RENTE
	self.data = proprio
	self.client = id
	self.data2 = prix

func set_requete_erreur(code):
	self.type = PacketType.ERREUR
	self.data = code

func set_requete_maj_argent(argent, id):
	self.type = PacketType.MAJ_ARGENT
	self.data = argent
	self.client = id
	
func set_requete_maj_achat(argent, proprio, nbr_prop):
	self.type = PacketType.MAJ_ACHAT
	self.data = argent
	self.data2 = nbr_prop
	self.client = proprio
	
	
func set_requete_acheter():
	self.type = PacketType.ACHAT

func set_requete_fin_de_tour ():
	self.type = PacketType.FIN_DE_TOUR

func set_requete_lancer_de ():
	self.type = PacketType.REQUETE_LANCER_DE

func set_inscription_partie (code_partie : int = 0, nb_joueurs : int = 1):
	self.type = PacketType.INSCRIPTION_PARTIE
	self.data = code_partie
	self.client = nb_joueurs

func set_plateau (plateau : Array):
	self.type = PacketType.JEU
	self.data = plateau

func set_chat_message (chat_message : String):
	self.type = PacketType.CHAT
	self.data = chat_message

func set_requete_BDD (requete_BDD : String):
	self.type = PacketType.BDD
	self.data = requete_BDD

func set_adresse_serveur_jeu (ip, port, nb_joueurs):
	self.type = PacketType.ADRESSE_SERVEUR_JEU
	self.data = str(ip) + ':' + str(port)
	self.client = nb_joueurs

func set_resultat_lancer_de (Resultat : int, Client : int):
	self.type = PacketType.RESULTAT_LANCER_DE
	self.data = Resultat
	self.client = Client

func to_bytes () -> PoolByteArray:
	var obj = {'type' : self.type, 'data' : self.data, 'data2' : self.data2, 'client' : self.client}
	var string = var2str(obj)
	var bytes = string.to_utf8()
	return bytes


static func from_bytes (bytes : PoolByteArray) -> Object:
	var string = bytes.get_string_from_utf8()
	var obj = str2var(string)
	return obj
