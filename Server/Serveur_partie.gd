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
# Packet recu
var packet_recu
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
	for _i in range (1,9):
		plateau.append(Cases.new().set_propriete(0))
	# Visite prison
	plateau.append(Cases.new().set_autre())
	# Propriété
	for _i in range (1,9):
		plateau.append(Cases.new().set_propriete(0))
	# Parking
	plateau.append(Cases.new().set_autre())
	# Propriété
	for _i in range (1,9):
		plateau.append(Cases.new().set_propriete(0))
	# Prison
	plateau.append(Cases.new().set_prison(10))
	# Propriété
	for _i in range (1,9):
		plateau.append(Cases.new().set_propriete(0))

func acheter(id):
	var case = plateau[position_joueur[id]] 
	var exception = 0
	if (case.type != Cases.CasesTypes.PROPRIETE):
		print("La case n'est pas de type propriete")
		exception = 1
	if (case.proprio != -1):
		print("La case est deja achetee")
		exception = 2
	if (argent_joueur[id] < case.prix):
		print("Le joueur n'a pas assez d'argent pour acheter la case")
		exception = 3
	
	if (exception != 0):
		#signal vers le joueur pour lui dire que c'est pas achete
		return
	
	argent_joueur[id] -= case.prix
	case.proprio = id
	print("La propriete %d est achetee par le joueur %d" % [position_joueur[id], id])
	#signal vers le joueur pour lui dire que c'est achete

func upgrade(id):
	var case = plateau[position_joueur[id]]
	if (case.type != Cases.CasesTypes.PROPRIETE):
		print("La case n'est pas de type proprieté")
	elif (case.proprio != id):
		print("Le joueur ne peut pas construire sur une case qui ne vous appartient pas")
	elif (case.niveau != 5):
		match case.niveau:
			(0 or 1 or 2 or 3):
				if(case.prix_maison > argent_joueur[id]):
					print("Le joueur n'a pas assez d'argent pour une maison.")
				else :
					argent_joueur[id] -= case.prix_maison
					
			4:
				if(case.prix_hotel > argent_joueur[id]):
					print("Le joueur n'a pas assez d'argent pour un hotel.")
				else:
					argent_joueur[id] -= case.prix_hotel
	else:
		print("La case est à son niveau maximum.")
		
