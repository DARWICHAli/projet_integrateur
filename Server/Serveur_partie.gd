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
#Nombre de joueur attendu
var nb_joueurs
#tableau de stockage des joueurs 
var list_joueurs=[]
# Booléen si le joueur à répondu
var reponse_joueur
# Booléen si le proprio à répondu
var reponse_proprio
# Booléen si le rentier à déjà réclamer 1 fois
var proprio_a_reclamer
# Packet attendu
var packet_attendu
# Packet recu
var packet_recu
# Numéro du joueur en attente de réponse
var attente_joueur = 0
# Numéro du joueur qui est le propriétaire
var attente_proprio
# Numéro de cases des joueurs
const position_joueur = []
# Argent des joueurs
const argent_joueur = []
# Tableau représentant les cases du jeu
var plateau = [
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new(), 
Cases.new(), Cases.new()
]
# Etat de liberte de chaque joueur (1 si en prison, 0 sinon)
var joueur_prison = []
# Nombre d'essais de double de chaque joueur quand il est en prison
var nbr_essai_double = []
# Prix de la prison
var prix_prison = 50

func deplacer_joueur(id_joueur : int, nbr_case : int):
	position_joueur[id_joueur] = position_joueur[id_joueur] + nbr_case
	if position_joueur[id_joueur] >= plateau.size(): # Tour +1 du joueur
		position_joueur[id_joueur] = position_joueur[id_joueur] % plateau.size()
		payer_joueur(id_joueur, plateau[0].get_prix())

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
		self.argent_joueur.append(10000)
		self.joueur_prison.append(0)
		self.nbr_essai_double.append(0)
	self.attente_joueur = 0

func init_plateau():
	for i in range(40):
		plateau[i].indice = i
		if i == 0:
			plateau[i].set_depart(0)
		elif i == 10:
			plateau[i].set_prison()
		elif i == 30:
			plateau[i].set_aller_prison()
		elif i == 2 or i == 7 or i == 10 or i == 17 or i == 20 or i == 22 or i == 32 or i == 36:
			plateau[i].set_autre()
		elif i == 4 or i == 38:
			plateau[i].set_taxe(i)
		else:
			print(i)
			plateau[i].set_propriete(100, i)
			# TODO1 Regrouper les propriétés par couleurs pour savoir si l'on peut construire

func acheter(id):
	var case = plateau[position_joueur[id]]
	var exception = 0
	if case.type != Cases.CasesTypes.PROPRIETE:
		print("La case n'est pas de type propriete")
		exception = 1
	if case.proprio != -1:
		print("La case est deja achetee")
		exception = 2
	if argent_joueur[id] < case.prix:
		print("Le joueur n'a pas assez d'argent pour acheter la case")
		exception = 3
	if (exception != 0):
		return exception
	for i in position_joueur:
		print(i)
	print(case.indice)
	argent_joueur[id] -= case.prix
	case.proprio = id
	print("La propriete %d est achetee par le joueur %d" % [position_joueur[id], id])
	return exception

func rente(case, joueur, res_des):
	# Gestion du cas des compagnies d'eau et electricite d'abord
	var prix
	if case.compagnie == 1:
		if plateau[12].proprio != -1 and plateau[27].proprio != -1:
			case.prix = res_des * 10
		elif plateau[12].proprio != -1 or plateau[27].proprio != -1:
			case.prix = res_des * 4
		print("********************")
		print("********************")
		print(case.prix)
		print("********************")
		print("********************")
	argent_joueur[case.proprio] += case.prix
	argent_joueur[joueur] -= case.prix
	print("Joueur %d encaisse la rente de %d ECTS de la part de joueur %d" % [case.proprio, case.prix, joueur])
	if argent_joueur[joueur] < 0:
		return -1
	return 0

func taxe(id):
	var case = plateau[position_joueur[id]]
	argent_joueur[id] -= case.prix

func upgrade(id):
	var case = plateau[position_joueur[id]]
	if (case.type != Cases.CasesTypes.PROPRIETE):
		print("La case n'est pas de type proprieté")
		return 1
	elif (case.proprio != id):
		print("Cette case ne vous appartient pas")
		return 4
	# TODO2 Après regroupement des propriètés par couleurs, vérifier si toutes les proprio appartiennent au joueur
	# Si non, erreur return nombre positif + ajouter l'erreur dans le type de paquet erreur (cf client)
	elif (case.niveau_case != 5):
		if(case.niveau_case <= 3):
			if(case.prix_maison > argent_joueur[id]):
				print("Le joueur n'a pas assez d'argent pour une maison.")
				return 5
			else:
				argent_joueur[id] -= case.prix_maison
				print("Maison construite !")
				return -1
		else:
			if(case.prix_hotel > argent_joueur[id]):
				print("Le joueur n'a pas assez d'argent pour un hotel.")
				return 6
			else:
				argent_joueur[id] -= case.prix_hotel
				print("Hotel construit !")
				return -2			
	else:
		print("La case est à son niveau maximum.")
		return 7

func vendre(id):
	print("vendre")
	var case = plateau[position_joueur[id]]
	var exception = 0
	if case.type != Cases.CasesTypes.PROPRIETE:
		print("La case n'est pas de type propriete")
		exception = 1
	if case.proprio != id:
		print("Cette case ne vous appartient pas")
		exception = 4
	if (exception != 0):
		return exception
	for i in position_joueur:
		print(i)
	print(case.indice)
	argent_joueur[id] += case.prix*0.8
	case.proprio = -1
#	for i in range(case.niveau_case):
#		downgrade(id)
	case.niveau_case = 0
	# TODO : VENDRE SELON NIVEAU CASE
	print("La propriete %d est vendue par le joueur %d" % [position_joueur[id], id])
	return 0

func payer_prison(id):
	argent_joueur[id] = argent_joueur[id] - prix_prison

#func downgrade(id):
#	var case = plateau[position_joueur[id]]
#	case.niveau_case -= 1
#	argent_joueur[id] += case.prix_maison*0.8
	
	
	
