extends Node

class_name Serveur_partie

# Objet thread utilisé
var thread = Thread.new()
# Objet utilisé pour la socket
var socket = WebSocketServer.new()
# Ports utilisé par le thread
var port
# Code utile pour rejoindre le thread
var code
#tableau de stockage des joueurs 
var list_joueurs=[]
# Booléen si le joueur à répondu
var reponse_joueur
# Packet attendu
var packet_attendu
# Numéro du joueur en attente de réponse
var attente_joueur = 0
# Numéro de cases des joueurs
const position_joueur = []
# Argent des joueurs
const argent_joueur = []
# Tableau représentant les cases du jeu
const plateau = []

func deplacer_joueur(id_joueur : int, nbr_case : int):
	position_joueur[id_joueur] = position_joueur[id_joueur] + nbr_case
	var case = Cases.new()
	if position_joueur[id_joueur] >= plateau.size(): # Tour +1 du joueur
		position_joueur[id_joueur] = position_joueur[id_joueur] % plateau.size()
		payer_joueur(id_joueur, plateau[0].get_prix())
	if plateau[position_joueur[id_joueur]].type == case.CasesTypes.PRISON : # Tombé dans la prison
		position_joueur[id_joueur] = plateau[position_joueur[id_joueur]].case_goto

func payer_joueur(id_joueur : int, prix : int):
	argent_joueur[id_joueur] = argent_joueur[id_joueur] + prix

func next_player():
	var i = (attente_joueur+1) % list_joueurs.size()
	var find = false
	while !find :
		if argent_joueur[i] < 0:
			i = i+1 % list_joueurs.size()
		else:
			find = true
			attente_joueur = i
	return attente_joueur

func init_partie():
	init_plateau()
	for i in list_joueurs:
		self.position_joueur.append(0)
		self.argent_joueur.append(500)
	self.attente_joueur = 0

func init_plateau():
	# Case de départ 0
	plateau.append(Cases.new().set_depart(0))
	# Propriété
	for i in range (1,9):
		plateau.append(Cases.new().set_propriete(0))
	# Visite prison
	plateau.append(Cases.new().set_autre())
	# Propriété
	for i in range (1,9):
		plateau.append(Cases.new().set_propriete(0))
	# Parking
	plateau.append(Cases.new().set_autre())
	# Propriété
	for i in range (1,9):
		plateau.append(Cases.new().set_propriete(0))
	# Prison
	plateau.append(Cases.new().set_prison(10))
	# Propriété
	for i in range (1,9):
		plateau.append(Cases.new().set_propriete(0))
