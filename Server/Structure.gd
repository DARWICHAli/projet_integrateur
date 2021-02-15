extends Node

class_name Structure

enum PacketType {CHAT, JEU, BDD, INSCRIPTION_PARTIE, ADRESSE_SERVEUR_JEU, JOIN_PARTIE}

var type
var data

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

func to_bytes () -> PoolByteArray:
	var obj = {'type' : self.type, 'data' : self.data}
	var string = var2str(obj)
	var bytes = string.to_utf8()
	return bytes


static func from_bytes (bytes : PoolByteArray) -> Object:
	var string = bytes.get_string_from_utf8()
	var obj = str2var(string)
	return obj
