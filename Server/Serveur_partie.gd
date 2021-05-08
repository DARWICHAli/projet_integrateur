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
var pseudos : Array = ["","","","","","","",""]
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
# Tableau de ventes selon joueur (pour eviter la concurrence sur les variables)
var ventes = []

func deplacer_joueur(id_joueur : int, nbr_case : int):
	var dep = position_joueur[id_joueur] + nbr_case
	if dep >= plateau.size():
		dep = dep % plateau.size()
	if joueur_prison[id_joueur] == 0:
		position_joueur[id_joueur] = dep

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
		self.argent_joueur.append(1500)
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
			plateau[i].set_depart(200)
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
				plateau[1].set_propriete(60, i, Cases.PropTypes.BRUN, [2,10,30,90,160,250], 50, 50)
				plateau[3].set_propriete(60, i, Cases.PropTypes.BRUN, [4,20,60,180,320,450], 50, 50)
			if i == 5 or i == 15 or i == 25 or i == 35:
				plateau[i].set_propriete(200, i, Cases.PropTypes.GARE, [25,50,100,200], 0, 0)
			if i == 6 or i == 8 or i == 9:
				plateau[6].set_propriete(100, i, Cases.PropTypes.BLEU_CIEL, [6,30,90,270,400,550], 50, 50)
				plateau[8].set_propriete(100, i, Cases.PropTypes.BLEU_CIEL, [6,30,90,270,400,550], 50, 50)
				plateau[9].set_propriete(120, i, Cases.PropTypes.BLEU_CIEL, [8,40,100,300,450,600], 50, 50)
			if i == 11 or i == 13 or i == 14:
				plateau[11].set_propriete(140, i, Cases.PropTypes.VIOLET, [10,50,150,450,625,750], 100, 100)
				plateau[12].set_propriete(140, i, Cases.PropTypes.VIOLET, [10,50,150,450,625,750], 100, 100)
				plateau[14].set_propriete(160, i, Cases.PropTypes.VIOLET, [12,60,180,500,700,900], 100, 100)
			if i == 12 or i == 27:
				plateau[i].set_propriete(150, i, Cases.PropTypes.COMPAGNIE, [], 0, 0)
			if i == 16 or i == 18 or i == 19:
				plateau[16].set_propriete(180, i, Cases.PropTypes.ORANGE, [14,70,200,550,750,950], 100, 100)
				plateau[18].set_propriete(180, i, Cases.PropTypes.ORANGE, [14,70,200,550,750,950], 100, 100)
				plateau[19].set_propriete(200, i, Cases.PropTypes.ORANGE, [16,80,220,600,800,1000], 100, 100)
			if i == 21 or i == 23 or i == 24:
				plateau[21].set_propriete(220, i, Cases.PropTypes.ROUGE, [18,90,250,700,875,1050], 150, 150)
				plateau[23].set_propriete(220, i, Cases.PropTypes.ROUGE, [18,90,250,700,875,1050], 150, 150)
				plateau[24].set_propriete(240, i, Cases.PropTypes.ROUGE, [20,100,300,750,925,1100], 150, 150)
			if i == 26 or i == 28 or i == 29:
				plateau[26].set_propriete(260, i, Cases.PropTypes.JAUNE, [22,110,330,800,975,1150], 150, 150)
				plateau[28].set_propriete(260, i, Cases.PropTypes.JAUNE, [22,110,330,800,975,1150], 150, 150)
				plateau[29].set_propriete(280, i, Cases.PropTypes.JAUNE, [24,120,360,850,1025,1200], 150, 150)
			if i == 31 or i == 33 or i == 34:
				plateau[31].set_propriete(300, i, Cases.PropTypes.VERT, [26,130,390,900,1100,1275], 200, 200)
				plateau[33].set_propriete(300, i, Cases.PropTypes.VERT, [26,130,390,900,1100,1275], 200, 200)
				plateau[34].set_propriete(320, i, Cases.PropTypes.VERT, [28,150,450,1000,1200,1400], 200, 200)
			if i == 37 or i == 39:
				plateau[37].set_propriete(350, i, Cases.PropTypes.BLEU_FONCE, [35,175,500,1100,1300,1500], 200, 200)
				plateau[39].set_propriete(400, i, Cases.PropTypes.BLEU_FONCE, [50,200,600,1400,1700,2000], 200, 200)

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
	
	var temp_niveau = 0
	if case.sous_type == Cases.PropTypes.GARE:
		for case_iter in plateau:
			if case_iter.sous_type == Cases.PropTypes.GARE and case_iter.proprio == id:
				temp_niveau += 1
		print("TEMP NIVEAU : %d" % [temp_niveau])
		for case_iter in plateau:
			if case_iter.sous_type == Cases.PropTypes.GARE and case_iter.proprio == id:
				case_iter.niveau_case = temp_niveau
	
	print("NIVEAU GARE : %d" % [case.niveau_case])
	
	print("La propriete %d est achetee par le joueur %d" % [position_joueur[id], id])
	print("VERIF PROPRIO : %d" % [case.proprio])
	return exception

func rente(case, joueur, res_des):
	var loyer
	if case.hypotheque == 1:
		print("Case hypothequée : rente impossible !")
		return 8
	if case.sous_type == Cases.PropTypes.COMPAGNIE:	
		var temp = res_des * 4
		var indice = case.indice
		if indice == 12:
			indice = 27
		else:
			indice = 12
		if plateau[indice].proprio == case.proprio:
			temp = res_des * 10
		loyer = temp
	loyer = case.loyer[case.niveau_case]
	argent_joueur[case.proprio] += loyer
	argent_joueur[joueur] -= loyer
	print("Joueur %d encaisse la rente de %d ECTS de la part de joueur %d" % [case.proprio, loyer, joueur])
	return 0

func taxe(id):
	var case = plateau[position_joueur[id]]
	argent_joueur[id] -= case.prix

func upgrade(id, case):
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

	if case.sous_type == Cases.PropTypes.GARE:
		for case_iter in plateau:
			if case_iter.sous_type == Cases.PropTypes.GARE and case_iter.proprio == case.proprio:
				case_iter.niveau_case = case_iter.niveau_case - 1
			
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
	argent_joueur[id] = argent_joueur[id] + 0.5*case.prix
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
