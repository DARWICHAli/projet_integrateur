extends Node

class_name Structure

enum PacketType {CHAT, JEU, BDD, INSCRIPTION_PARTIE, ADRESSE_SERVEUR_JEU,
RESULTAT_LANCER_DE, REQUETE_LANCER_DE, FIN_TOUR, ACHAT}

var type
var data
var client

func set_requete_acheter():
	self.type = PacketType.ACHAT

func set_requete_fin_de_tour():
	self.type = PacketType.FIN_TOUR

func set_requete_lancer_de ():
	self.type = PacketType.REQUETE_LANCER_DE

func set_inscription_partie (code_partie : int = 0):
	self.type = PacketType.INSCRIPTION_PARTIE
	self.data = code_partie

func set_plateau (plateau : Array):
	self.type = PacketType.JEU
	self.data = plateau

func set_chat_message (chat_message : String):
	self.type = PacketType.CHAT
	self.data = chat_message

func set_requete_BDD (requete_BDD : String):
	self.type = PacketType.BDD
	self.data = requete_BDD

func set_adresse_serveur_jeu (ip, port):
	self.type = PacketType.ADRESSE_SERVEUR_JEU
	self.data = str(ip) + ':' + str(port)

func set_resultat_lancer_de (Resultat : int, Client : int):
	self.type = PacketType.RESULTAT_LANCER_DE
	self.data = Resultat
	self.client = Client

func to_bytes () -> PoolByteArray:
	var obj = {'type' : self.type, 'data' : self.data, 'client' : self.client}
	var string = var2str(obj)
	var bytes = string.to_utf8()
	return bytes

static func from_bytes (bytes : PoolByteArray) -> Object:
	var string = bytes.get_string_from_utf8()
	var obj = str2var(string)
	return obj
