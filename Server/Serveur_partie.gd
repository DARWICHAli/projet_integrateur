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
# pseudo des joueurs
var pseudos = []
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
# Booléen si le proprio à répondu
var reponse_proprio
# Booléen si le rentier à déjà réclamer 1 fois
var proprio_a_reclamer
# Numéro du joueur qui est le propriétaire
var attente_proprio
# Tableau de booléen indiquant si le joueur possède une carte sortie de prison
var sortie_prison = []
# Stocke le resultat variable pour la carte tirée
var temp_carte
# Warning dernière chance faillite
var warning = []
# Tableau de ventes selon joueur
var ventes = []

func deplacer_joueur(id_joueur : int, nbr_case : int):
	position_joueur[id_joueur] = position_joueur[id_joueur] + nbr_case
	if position_joueur[id_joueur] >= plateau.size(): # Tour +1 du joueur
		position_joueur[id_joueur] = position_joueur[id_joueur] % plateau.size()
		#payer_joueur(id_joueur, plateau[0].get_prix())

func payer_joueur(id_joueur : int, prix : int):
	argent_joueur[id_joueur] = argent_joueur[id_joueur] + prix

func salaire_nouv_tour(id):
	argent_joueur[id] = argent_joueur[id] + plateau[0].prix

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
		self.sortie_prison.append(0)
		self.warning.append(0)
		self.ventes.append(0)
	self.attente_joueur = 0

func init_plateau():
	for i in range(40):
		plateau[i].indice = i
		if i == 0:
			plateau[i].set_depart(500)
		elif i == 10:
			plateau[i].set_prison()
		elif i == 30:
			plateau[i].set_aller_prison()
		elif i == 2 or i == 17 or i == 32:
			plateau[i].set_comm()
		elif i == 7 or i == 22 or i == 36:
			plateau[i].set_chance()
		elif i == 20:
			plateau[i].set_autre()
		elif i == 4 or i == 38:
			plateau[i].set_taxe(i)
		else:
			print(i)
			if i == 1 or i == 3:
				plateau[i].set_propriete(100, i, Cases.PropTypes.BRUN)
			if i == 5 or i == 15 or i == 25 or i == 35:
				plateau[i].set_propriete(100, i, Cases.PropTypes.GARE)
			if i == 6 or i == 8 or i == 9:
				plateau[i].set_propriete(100, i, Cases.PropTypes.BLEU_CIEL)
			if i == 11 or i == 13 or i == 14:
				plateau[i].set_propriete(100, i, Cases.PropTypes.VIOLET)
			if i == 12 or i == 27:
				plateau[i].set_propriete(100, i, Cases.PropTypes.COMPAGNIE)
			if i == 16 or i == 18 or i == 19:
				plateau[i].set_propriete(100, i, Cases.PropTypes.ORANGE)
			if i == 21 or i == 23 or i == 24:
				plateau[i].set_propriete(100, i, Cases.PropTypes.ROUGE)
			if i == 26 or i == 28 or i == 29:
				plateau[i].set_propriete(100, i, Cases.PropTypes.JAUNE)
			if i == 31 or i == 33 or i == 34:
				plateau[i].set_propriete(100, i, Cases.PropTypes.VERT)
			if i == 37 or i == 39:
				plateau[i].set_propriete(100, i, Cases.PropTypes.BLEU_FONCE)
			# TODO1 Regrouper les propriétés par couleurs pour savoir si l'on peut construire

func pos_prison(id):
	position_joueur[id] = 10

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
	if case.hypotheque == 1:
		print("Case hypothequée : rente impossible !")
		return 8
	if case.sous_type == Cases.PropTypes.COMPAGNIE:
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

func upgrade(id, case):
	#var case = plateau[position_joueur[id]]
	if (case.type != Cases.CasesTypes.PROPRIETE):
		print("La case n'est pas de type proprieté")
		return 1
	elif (case.proprio != id):
		print("Cette case ne vous appartient pas")
		return 4
	elif (case.sous_type == Cases.PropTypes.GARE or case.sous_type == Cases.PropTypes.COMPAGNIE):
		print("Case non eligible")
		return 9
	elif case.hypotheque == 1:
		print("Case hypothequée : construction impossible !")
		return 8
	var cases_tmp = []
	for i in range(40):
		if (plateau[i].sous_type == case.sous_type):
			if plateau[i].proprio != case.proprio:
				print("Vous ne possedez pas toutes les propriètés de la couleur")
				return 11
			else:
				cases_tmp.append(plateau[i])
	if (case.niveau_case != 5):
		if(case.niveau_case <= 3):
			if(case.prix_maison > argent_joueur[id]):
				print("Le joueur n'a pas assez d'argent pour une maison.")
				return 5
			else:
				for case_iter in cases_tmp:
					if abs(case_iter.niveau_case - (case.niveau_case + 1)) >= 2:
						print("Vous devez contruire uniformement")
						return 12
				argent_joueur[id] -= case.prix_maison
				case.niveau_case += 1
				print("Maison construite !")
				return -1
		else:
			if(case.prix_hotel > argent_joueur[id]):
				print("Le joueur n'a pas assez d'argent pour un hotel.")
				return 6
			else:
				for case_iter in cases_tmp:
					if abs(case_iter.niveau_case - (case.niveau_case + 1)) >= 2:
						print("Vous devez contruire uniformement")
						return 12
				argent_joueur[id] -= case.prix_hotel
				case.niveau_case += 1
				print("Hotel construit !")
				return -2			
	else:
		print("La case est à son niveau maximum.")
		return 7

func vendre(id, case):
	print("vendre")
	var exception = 0
	if case.type != Cases.CasesTypes.PROPRIETE:
		print("La case n'est pas de type propriete")
		exception = 1
	if case.proprio != id:
		print("Cette case ne vous appartient pas")
		exception = 4
	if (exception != 0):
		return exception

	ventes[id] = case.prix*0.8
	for i in range(0, case.niveau_case):
		if i == 1 or i == 2 or i == 3:
			ventes[id] += 0.5*case.prix_maison
		elif i == 4:
			ventes[id] += 0.5*case.prix_hotel
	argent_joueur[id] += ventes[id]
	
	case.proprio = -1
	case.niveau_case = 0
	case.hypotheque = 0
	print("La propriete %d est vendue par le joueur %d" % [position_joueur[id], id])
	return 0

func payer_prison(id):
	argent_joueur[id] = argent_joueur[id] - prix_prison

func hypothequer(id, case):
	if case.type != Cases.CasesTypes.PROPRIETE:
		print("La case n'est pas de type propriete")
		return 1
	print("PROPRIO : %d" % [case.proprio])
	if case.proprio != id:
		print("Cette case ne vous appartient pas")
		return 4
	if case.niveau_case != 0:
		print("Vous ne pouvez pas hypothequer une case avec construction")
		return 10
	if case.hypotheque == 1:
		print("Case de-hypothequer !")
		case.hypotheque = 0
		argent_joueur[id] = argent_joueur[id] - 1.1*case.prix
		return -1
	case.hypotheque = 1
	argent_joueur[id] = argent_joueur[id] + 0.9*case.prix
	return 0

func remise_a_zero(id):
	for i in range(40):
		if (plateau[i].type == Cases.CasesTypes.PROPRIETE and plateau[i].proprio == id):
			plateau[i].proprio = -1
			plateau[i].niveau_case = 0

func downgrade(id, case):
	if (case.type != Cases.CasesTypes.PROPRIETE):
		print("La case n'est pas de type proprieté")
		return 1
	elif (case.proprio != id):
		print("Cette case ne vous appartient pas")
		return 4
	elif (case.sous_type == Cases.PropTypes.GARE or case.sous_type == Cases.PropTypes.COMPAGNIE):
		print("Case non eligible")
		return 9
	var cases_tmp = []
	for i in range(40):
		if (plateau[i].sous_type == case.sous_type):
			cases_tmp.append(plateau[i])
	if (case.niveau_case != 0):
		if(case.niveau_case <= 3):
			for case_iter in cases_tmp:
				if abs(case_iter.niveau_case - (case.niveau_case - 1)) >= 2:
					print("Vous devez détruire uniformement")
					return 13
			argent_joueur[id] += 0.5*case.prix_maison
			case.niveau_case -= 1
			print("Maison détruite !")
			return -1
		else:
			for case_iter in cases_tmp:
				if abs(case_iter.niveau_case - (case.niveau_case - 1)) >= 2:
					print("Vous devez détruire uniformement")
					return 13
			argent_joueur[id] += 0.5*case.prix_hotel
			case.niveau_case -= 1
			print("Hotel détruit !")
			return -2	
	else:
		print("La case est à son niveau minimum.")
		return 14

func tirer_carte(id, comm_or_chance, double_verif):
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var carte = rand.randi_range(1, 5)
	if(comm_or_chance):
		match carte:
			1: # Carte sortie de prison
				if(sortie_prison[id] == 1):
					return 0 # Carte deja possedee
				sortie_prison[id] = 1
			2: # Amende petite triche
				temp_carte = 50
				argent_joueur[id] -= temp_carte
			3: # Favoriser par un prof
				temp_carte = 150
				argent_joueur[id] += temp_carte
			4: # Payer restaurant pour tout l'amphitheatre
				temp_carte = list_joueurs.size() * 20
				argent_joueur[id] -= temp_carte
			5: # Le chef reçoit une somme pour participation avec le groupe de TD
				temp_carte = list_joueurs.size() * 20
				argent_joueur[id] += temp_carte
	else:
		match carte:
			1: # Carte sortie de prison
				if(sortie_prison[id] == 1):
					return 0 # Carte deja possedee
				sortie_prison[id] = 1
			2: # Aller prison
				return -1
			3: # Amende conseil de discipline triche de propriétés
				temp_carte = 0
				for i in range(40):
					if (plateau[i].type == Cases.CasesTypes.PROPRIETE):
						temp_carte += plateau[i].niveau_case
				argent_joueur[id] -= temp_carte*30
				return -2
			4: # Si double avec cette carte, il touche 20 fois son double, sinon il paie 2
				#if(double_verif == 1 or double_verif == 4)	
				for i in [1,4,9,16,25,36]:
					if(i == double_verif):
						temp_carte = 20*sqrt(double_verif)*2
						argent_joueur[id] += temp_carte
						return -3
					else:
						temp_carte = 10*double_verif
						argent_joueur[id] -= temp_carte
						return -4
			5: # Controleur du tram -> amende
				temp_carte = 90
				argent_joueur[id] -= temp_carte
				return -5
	return carte

func leguer(donneur, receveur):
	var list_prop = []
	for i in range(40):
		if (plateau[i].type == Cases.CasesTypes.PROPRIETE and plateau[i].proprio == donneur):
			plateau[i].proprio = receveur
			if (plateau[i].hypotheque == 1):
				plateau[i].hypotheque = 0
			for j in range(0, plateau[i].niveau_case):
				downgrade(receveur, plateau[i])
			list_prop.append(plateau[i].indice)
	return list_prop
