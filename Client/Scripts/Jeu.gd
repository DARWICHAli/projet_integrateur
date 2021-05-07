extends Node2D

class_name Jeu

onready var hist = get_node("historique")

var dep_cases = 0
var debut = 0
var cases = []
var nb_joueurs
var ip = "localhost"
var port = "5000"
var joueur

var mon_nom = "Client 1"
var pseudos : Array = ["","","","","","","",""]

var code_partie

# Our WebSocketClient instance
var client_lobby  = WebSocketClient.new()
var client_partie = WebSocketClient.new()

var cert = load("res://unistrapoly_certif.crt")

#============== Routines =================

func _ready():

	for i in range(10):
		cases.append(get_node("Plateau/cases/cote_gauche").get_child(i))	
		cases[i].setId(i)
	for i in range(10):
		cases.append(get_node("Plateau/cases/cote_haut").get_child(i))
		cases[10+i].setId(10+i)
	for i in range(10):
		cases.append(get_node("Plateau/cases/cote_droit").get_child(i))
		cases[20+i].setId(20+i)
	for i in range(10):
		cases.append(get_node("Plateau/cases/cote_bas").get_child(i))
		cases[30+i].setId(30+i)
	# Choix du nombre de joueur
	nb_joueurs=0
	#print('ready')
	ready_connection()

# ============= Client ==================== #

func ready_connection():
	client_lobby.set_trusted_ssl_certificate(cert)
	# signaux client lobby
	
	client_lobby.connect("connection_closed", self, "_closed_lobby")
	client_lobby.connect("connection_error", self, "_closed_lobby")
	client_lobby.connect("connection_established", self, "_connected_lobby")
	client_lobby.connect("data_received", self, "_on_data_lobby")

	# signaux client partie
	client_partie.connect("connection_closed", self, "_closed_partie")
	client_partie.connect("connection_error", self, "_closed_partie")
	client_partie.connect("connection_established", self, "_connected_partie")
	client_partie.connect("data_received", self, "_on_data_partie")

	# Initiate connection to the given URL.
	var err = client_lobby.connect_to_url('wss://' + str(ip) + ':' + str(port))
	if err != OK:
		print("la connexion au lobby a échoué")
		set_process(false)


# Fonction de fermeture de connexion
func _closed_lobby (was_clean = false):
	print("déconnexion du lobby, clean: ", was_clean)
	set_process(false)


# Fonction d'ouverture de connexion
func _connected_lobby (_proto = ""):
	print("connecté au serveur lobby à l'adresse %s:%s" % [str(ip), str(port)])


# Fonction de recu de paquet et connexion au nouveau si c'est une ip qu'il recoit
func _on_data_lobby ():
	print ('données reçues (socket lobby)')
	var structure = Structure.new()
	var data_bytes = recevoir_message(client_lobby)

	var obj = structure.from_bytes(data_bytes)

	match obj.type:
		Structure.PacketType.ADRESSE_SERVEUR_JEU:
			print('reçu adresse du serveur de jeu: ', obj.data)
			mon_nom = "Joueur " + str(obj.data2)
			if (obj.data2 == 0):
				joueur = get_node("Pion")
			else:
				joueur = get_node("Pion"+str(obj.data2+1))
			rejoindre_partie(obj.data)
			nb_joueurs = obj.client
			affiche_joueur(nb_joueurs)
		Structure.PacketType.ERREUR:
			match obj.data:
				0:# 0 = pas d'erreur, insertion effectuée avec succès
					print("Inscription confirmée")
					$menu/Form/success.popup()
				1:
					print("Erreur lors de l'inscription, réessayez ultérieurement")
					$menu/Form/error.popup()
					
		Structure.PacketType.REPONSE_LOGIN:
			match obj.data:
				1:
					print("Erreur lors de l'inscription, réessayez ultérieurement")
					$menu/connexion/error.popup_centered()
				
				_: #pas d'erreur, connexion effectuée avec succès, data est le pseudo du joueur
					print("Connecté sous le nom de "+obj.data)
					self.mon_nom = obj.data
					$menu/connexion/success.popup()
					$menu/background/deconnexion.show()

		_:
			print('autre paquet reçu')


# Fonction de fermeture de connexion
func _closed_partie (was_clean = false):
	print("PARTIE : Closed, clean: ", was_clean)
	set_process(false)


# Fonction d'ouverture de connexion
func _connected_partie (_proto = ""):
	print("connecté au serveur de partie à l'adresse %s:%s" % [str(ip), str(port)])
	send_pseudo(mon_nom)

#	var structure = Structure.new()
#
#	print('envoi message chat')
#	structure.set_chat_message(mon_nom + " : " + "Bonjour")
#	envoyer_message(client_partie, structure.to_bytes())
#
#	print('envoi message jeu')
#	structure.set_plateau([555, 666, 777])
#	envoyer_message(client_partie, structure.to_bytes())

signal signal_resultat_lancer_de(resultat)
signal signal_resultat_lancer_de2(resultat)
signal signal_resultat_lancer_de3(resultat)
signal signal_resultat_lancer_de4(resultat)
signal signal_resultat_lancer_de5(resultat)
signal signal_resultat_lancer_de6(resultat)
signal signal_resultat_lancer_de7(resultat)
signal signal_resultat_lancer_de8(resultat)


# Fonction de recu de paquet et connexion au nouveau si c'est une ip qu'il recoit
func _on_data_partie ():
	print ('données reçues (socket partie)')
	var structure = Structure.new()
	var data_bytes = recevoir_message(client_partie)
	# change tous les Structure en structure
	var obj = structure.from_bytes(data_bytes)

	match obj.type:
		Structure.PacketType.ERREUR:
			match obj.data:
				1:
					$annonce.text = "La case n'est pas de type propriete."
					print("La case n'est pas de type propriete.")
					hist.add_hist($annonce.text)
				2:
					$annonce.text = "La case est deja achetee."
					print("La case est deja achetee.")
					hist.add_hist($annonce.text)
				3:
					$annonce.text = "Le joueur n'a pas assez d'argent pour acheter la case."
					print("Le joueur n'a pas assez d'argent pour acheter la case.")
					hist.add_hist($annonce.text)
				4:
					$annonce.text = "Cette case ne vous appartient pas !"
					print("Cette case ne vous appartient pas !")
					hist.add_hist($annonce.text)
				5:
					$annonce.text = "Le joueur n'a pas assez d'argent pour une maison."
					print("Le joueur n'a pas assez d'argent pour une maison.")
					hist.add_hist($annonce.text)
				6:
					$annonce.text = "Le joueur n'a pas assez d'argent pour un hotel."
					print("Le joueur n'a pas assez d'argent pour un hotel.")
					hist.add_hist($annonce.text)
				7:
					$annonce.text = "La case est à son niveau maximum."
					print("La case est à son niveau maximum.")
					hist.add_hist($annonce.text)
				8:
					$annonce.text = "Case hypothequée : construction impossible !"
					print("Case hypothequée : construction impossible !")
					hist.add_hist($annonce.text)
				9:
					$annonce.text = "Case non eligible."
					print("Case non eligible.")
					hist.add_hist($annonce.text)
				10:
					$annonce.text = "Vous ne pouvez pas hypothequer une case avec construction !"
					print("Vous ne pouvez pas hypothequer une case avec construction !")
					hist.add_hist($annonce.text)
				11:
					$annonce.text = "Vous ne possedez pas toutes les propriètés de la couleur !"
					print("Vous ne possedez pas toutes les propriètés de la couleur !")
					hist.add_hist($annonce.text)
				12:
					$annonce.text = "Vous devez contruire uniformement !"
					print("Vous devez contruire uniformement !")
					hist.add_hist($annonce.text)
				13:
					$annonce.text = "Vous devez détruire uniformement !"
					print("Vous devez détruire uniformement !")
					hist.add_hist($annonce.text)
				14:
					$annonce.text = "La case est à son niveau minimum."
					print("La case est à son niveau minimum.")
					hist.add_hist($annonce.text)
				_:
					$annonce.text = "Erreur inconnue !"
					print("Erreur inconnue !")
					hist.add_hist($annonce.text)
		Structure.PacketType.MAJ_TOUR:
			if(self.joueur.id == obj.client):
				print("A VOTRE TOUR DE JOUER !")
				get_node("fond_bouton/annonce_tour").text = "A VOTRE TOUR !"
			else:
				print("Joueur %d joue son tour !" % [obj.client])
				var phrase 
				if(pseudos[obj.client] != ""):
					phrase= pseudos[obj.client] + " joue !" 
				else:
					phrase = "Le premier joueur joue !" 
				get_node("fond_bouton/annonce_tour").text = phrase
		Structure.PacketType.MAJ_ARGENT:
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
			joueur.argent[obj.client] = str(obj.data)
		Structure.PacketType.MAJ_ACHAT:
			$annonce.text = "ACHAT REUSSI ! La propriete %d est achetee par le joueur %d pour %d ECTS" % [obj.data2, obj.client, obj.data3]
			hist.add_hist($annonce.text)
			print("ACHAT REUSSI !")
			print("La propriete %d est achetee par le joueur %d pour %d ECTS" % [obj.data2, obj.client, obj.data3])
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
			joueur.argent[obj.client] = str(obj.data)
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/prop"+ str(obj.data2)).show()
		Structure.PacketType.RENTE:
			$annonce.text = "RENTE ! Joueur %d encaise la rente de %d ECTS de la part de joueur %d" % [obj.data, obj.data2, obj.client]
			hist.add_hist($annonce.text)
			print("RENTE !")
			print("Joueur %d encaise la rente de %d ECTS de la part de joueur %d" % [obj.data, obj.data2, obj.client])
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data3])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data3)
			joueur.argent[obj.client] = str(obj.data3)
		Structure.PacketType.MAJ_CONSTRUCTION:
			print("CONSTRUCTION !")
			if(obj.data == -1):
				$annonce.text = "CONSTRUCTION ! %s construit une maison pour %d ECTS sur le terrain %d"  % [pseudos[obj.client], obj.data4, obj.data3]
				hist.add_hist($annonce.text)
				print("Joueur %d construit une maison pour %d ECTS sur le terrain %d"  % [obj.client, obj.data4, obj.data3])
			elif(obj.data == -2):
				$annonce.text = "CONSTRUCTION ! %s construit un hotel pour %d ECTS sur le terrain %d"  % [pseudos[obj.client], obj.data4, obj.data3]
				hist.add_hist($annonce.text)
				print("Joueur %d construit un hotel pour %d ECTS sur le terrain %d"  % [obj.client, obj.data4, obj.data3])
			cases[obj.data3].show_upgrade()
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data2])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data2)
			joueur.argent[obj.client] = str(obj.data2)
		Structure.PacketType.MAJ_VENTE:
			$annonce.text = "VENTE REUSSITE ! La propriete %d est vendue par le %s pour %d ECTS" % [obj.data2, pseudos[obj.client], obj.data3]
			hist.add_hist($annonce.text)
			print("VENTE REUSSITE !")
			print("La propriete %d est vendue par le joueur %d pour %d ECTS" % [obj.data2, obj.client, obj.data3])
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data])
			cases[obj.data2].hypotheque = 0
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
			joueur.argent[obj.client] = str(obj.data)
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/prop"+ str(obj.data2)).hide()
		Structure.PacketType.MAJ_HYPOTHEQUE:
			if(obj.data4 == 0):
				$annonce.text = "HYPOTHEQUE ! La propriete %d est hypothequee par le %s et gagne %d ECTS" % [obj.data2, pseudos[obj.client], obj.data3]
				hist.add_hist($annonce.text)
				print("HYPOTHEQUE !")
				print("La propriete %d est hypothequee par le joueur %d et gagne %d ECTS" % [obj.data2, obj.client, obj.data3])
				cases[obj.data2].hypotheque = 1
			else:
				$annonce.text = "DE-HYPOTHEQUE ! La propriete %d est de-hypothequee par le %s et paye %d ECTS" % [obj.data2, pseudos[obj.client], obj.data3]
				hist.add_hist($annonce.text)
				print("DE-HYPOTHEQUE !")
				print("La propriete %d est de-hypothequee par le joueur %d et paye %d ECTS" % [obj.data2, obj.client, obj.data3])
				cases[obj.data2].hypotheque = 0
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
			joueur.argent[obj.client] = str(obj.data)
		Structure.PacketType.MAJ_DESTRUCTION:
			print("DESTRUCTION !")
			if(obj.data4 == -1):
				$annonce.text = "DESTRUCTION ! Une maison sur la propriété %d est détruite par %s et gagne %d ECTS" % [obj.data2, pseudos[obj.client], obj.data3]
				hist.add_hist($annonce.text)
				print("Une maison sur la propriété %d est détruite par le joueur %d et gagne %d ECTS" % [obj.data2, obj.client, obj.data3])
			else:
				$annonce.text = "DESTRUCTION ! Un hôtel sur la propriété %d est détruit par %s et gagne %d ECTS" % [obj.data2,pseudos[obj.client], obj.data3]
				hist.add_hist($annonce.text)
				print("Un hôtel sur la propriété %d est détruit par le joueur %d et gagne %d ECTS" % [obj.data2, obj.client, obj.data3])
			cases[obj.data2].show_downgrade()
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
			joueur.argent[obj.client] = str(obj.data)
		Structure.PacketType.GO_PRISON:
			$annonce.text = pseudos[obj.client] + " est deroute en prison !" 
			hist.add_hist($annonce.text)
			print(pseudos[obj.client] + " est deroute en prison !" )
			if obj.client == 0:
				get_node("Pion").goto_pos_prison()
			else:
				get_node("Pion"+str(obj.client+1)).goto_pos_prison()
		Structure.PacketType.OUT_PRISON:
			$annonce.text = pseudos[obj.client] + " sort de prison et paie %d ECTS !" % [obj.data]
			hist.add_hist($annonce.text)
			print("Joueur %d sort de prison et paie %d ECTS !" % [obj.client, obj.data])
			var money = str(int(get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text) - obj.data)
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = money
			joueur.argent[obj.client] = money
		Structure.PacketType.FREE_OUT_PRISON:
			if(obj.data == 0):
				$annonce.text = "DOUBLE !" + pseudos[obj.client] + " sort de prison !"
				hist.add_hist($annonce.text)
				print("DOUBLE !")
			else:
				$annonce.text = "CARTE SORTIE DE PRISON !"+ pseudos[obj.client] + "sort de prison !"
				hist.add_hist($annonce.text)
				get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client +1) +"/jailbreak").hide()
				print("CARTE SORTIE DE PRISON !")
			print("Joueur %d sort de prison !" % [obj.client])
		Structure.PacketType.TAXE:
			$annonce.text = pseudos[obj.client] + " paye une taxe !"
			hist.add_hist($annonce.text)
			print("Joueur %d paye une taxe !" % [obj.client])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
			joueur.argent[obj.client] = str(obj.data)
		Structure.PacketType.CHAT:
#			print(obj.data)
			get_node("chatbox").add_message(obj.data, obj.data2, obj.data3)
		Structure.PacketType.REP_STATS:
			print("stats")
			print(obj.data)
			$info_joueur/ScrollContainer/panelInfos/ColorRect/nb_victoires/nb_victoires.text = str(obj.data["nbWin"])
			$info_joueur/ScrollContainer/panelInfos/ColorRect/nb_defaites/nb_defaites.text = str(obj.data["nbLose"])
			$info_joueur/ScrollContainer/panelInfos/ColorRect/case_pref/case_pref.text = obj.data["bestCase"]
			$info_joueur/ScrollContainer/panelInfos/ColorRect/dernier_trophe/dernier_trophee.text = obj.data["lastTrophy"]
			$info_joueur/ScrollContainer/panelInfos/ColorRect/dernier_trophe/description.text = obj.data["descTrophy"]
			$info_joueur/ScrollContainer/panelInfos.show()
		
		Structure.PacketType.BCAST_PSEUDOS:
			for i in range(0,nb_joueurs):
				print(obj.data[i])
				get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+str(i+1)+"/nom_joueur").text = obj.data[i]
				get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+str(i+1)+"/LinkButton/nom_joueur2").text = obj.data[i]
			pseudos = obj.data
			joueur.pseudo = pseudos[joueur.id]
			joueur.chat.set_player_name(joueur)
		Structure.PacketType.ARGENT_NOUV_TOUR:
			$annonce.text = "%s vient de passer par la case départ ! Il reçoit 500 ECTS !" % [pseudos[obj.client]]
			hist.add_hist($annonce.text)
			print("Joueur %d vient de passer par la case départ ! Il reçoit 500 ECTS !" % [obj.client])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
			joueur.argent[obj.client] = str(obj.data)
		Structure.PacketType.RESULTAT_LANCER_DE:
			$annonce.text = "Lancé de dé : %d (dé 1), %d (dé 2) pour %s" % [obj.data, obj.data2, pseudos[obj.client]]
			hist.add_hist($annonce.text)
			print('reçu résultat lancer dé 1: ' + str(int(obj.data)) + 'résultat lancer dé 2 : '+ str(int(obj.data2)) +' pour le client : ' + str(int(obj.client)))
			var res = int(obj.data) + int(obj.data2)
			if(obj.client == joueur.id):
				joueur.pos_pion += res
			print('VERIF NOUV POS : %d' % [joueur.pos_pion])
			match int(obj.client):
				0:
					emit_signal("signal_resultat_lancer_de", res)
				1:
					emit_signal("signal_resultat_lancer_de2", res)
				2:
					emit_signal("signal_resultat_lancer_de3", res)
				3:
					emit_signal("signal_resultat_lancer_de4", res)
				4:
					emit_signal("signal_resultat_lancer_de5", res)
				5:
					emit_signal("signal_resultat_lancer_de6", res)
				6:
					emit_signal("signal_resultat_lancer_de7", res)
				7:
					emit_signal("signal_resultat_lancer_de8", res)
		Structure.PacketType.CACHE_JOUEUR:
			print("Suppression du joueur %d." % obj.data)
			supprimer_joueur(obj.data)
		Structure.PacketType.TIRER_CARTE:
			match obj.data3:
				1:
					print("Le joueur %d reçoit une carte sortie de prison !" % [obj.client])
					$annonce.text = "%s recevez une carte sortie de prison !" % [pseudos[obj.client]]
					get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client +1) +"/jailbreak").show()
				2:
					print("Le joueur %d paie une amende de %d ECTS pour petite triche !" % [obj.client, obj.data2])
					$annonce.text = pseudos[obj.client] + " paie une amende de "+str(obj.data2)+" ECTS pour petite triche !" 
					get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
					joueur.argent[obj.client] = str(obj.data)
				3:
					print("Le joueur %d reçoit %d ECTS, favorisé par un prof !" % [obj.client, obj.data2])
					$annonce.text = "%s reçoit %d ECTS, favorisé par un prof !" % [pseudos[obj.client], obj.data2]
					get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
					joueur.argent[obj.client] = str(obj.data)
				4:
					print("Le joueur %d paie le restaurant pour tout l'amphitheatre, soit %d ECTS !" % [obj.client, obj.data2])
					$annonce.text = "%s paie le restaurant pour tout l'amphitheatre, soit %d ECTS !" % [pseudos[obj.client], obj.data2]
					get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
					joueur.argent[obj.client] = str(obj.data)
				5:
					print("Le joueur %d, chef du groupe, reçoit une somme de %d ECTS pour participation avec le groupe de TD !" % [obj.client, obj.data2])
					$annonce.text = "%s, chef du groupe, reçoit une somme de %d ECTS pour participation avec le groupe de TD !" % [pseudos[obj.client], obj.data2]
					get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
					joueur.argent[obj.client] = str(obj.data)
				-1:
					print("Le joueur %d va en prison sans passer par la case départ !" % [obj.client])
					$annonce.text = "%s va en prison sans passer par la case départ !" % [pseudos[obj.client]]
					if obj.client == 0:
						get_node("Pion").goto_pos_prison()
						get_node("Pion").dep_cases = 0
					else:
						get_node("Pion"+str(obj.client+1)).goto_pos_prison()
						get_node("Pion"+str(obj.client+1)).dep_cases = 0
					get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
					joueur.argent[obj.client] = str(obj.data)
				-2:
					print("Le joueur %d va en conseil de discipline et paie %d ECTS pour l'ensemble des construction du plateau !" % [obj.client, obj.data2])
					$annonce.text = "%s va en conseil de discipline et paie %d ECTS pour l'ensemble des construction du plateau !" % [pseudos[obj.client], obj.data2]
					get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
					joueur.argent[obj.client] = str(obj.data)
				-3:
					print("Etant donné qu'il a fait un double, le joueur %d reçoit 20 fois la valeur de son double, soit %d ECTS !" % [obj.client, obj.data2])
					$annonce.text = "Etant donné qu'il a fait un double, %s reçoit 20 fois la valeur de son double, soit %d ECTS !" % [pseudos[obj.client], obj.data2]
					get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
					joueur.argent[obj.client] = str(obj.data)
				-4:
					print("Etant donné qu'il n'a pas fait de double, le joueur %d paie 10 fois la valeur multipliée de ses dés, soit %d ECTS !" % [obj.client, obj.data2])
					$annonce.text = "Etant donné qu'il n'a pas fait de double, %s paie 10 fois la valeur multipliée de ses dés, soit %d ECTS !" % [pseudos[obj.client], obj.data2]
					get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
					joueur.argent[obj.client] = str(obj.data)
				-5:
					print("OUPS ! Joueur %d est controllé par la CTS. Il paie %d ECTS pour défault de présentation de titre de transport !" % [obj.client, obj.data2])
					$annonce.text = "OUPS ! %s est controllé par la CTS. Il paie %d ECTS pour défault de présentation de titre de transport !" % [pseudos[obj.client], obj.data2]
					get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
					joueur.argent[obj.client] = str(obj.data)
				_:
					print("Carte inconnue !")
			hist.add_hist($annonce.text)
		Structure.PacketType.PERDRE:
			print("ID : " + str(self.joueur.id))
			if(self.joueur.id == obj.client):
				print("VOUS AVEZ PERDU !")
				if(obj.data == -1):
					$gagne.text = "VOUS AVEZ PERDU ! La banque vous a mis en faillite !"
					print("La banque vous a mis en faillite !")
				else:
					$gagne.text = "VOUS AVEZ PERDU ! %s vous a mis en faillite !" % [pseudos[obj.data]]
					print("Le joueur %d vous a mis en faillite !" % [obj.data])
					for i in range(0, len(obj.data2)):
						get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+str(obj.data+1)+"/prop"+ str(obj.data2[i])).show()
						#cases[i].hypotheque = 0
					print(obj.data2)
				joueur.present = 0
			else:
				print("Le joueur %d a perdu !" % [obj.client])
				if(obj.data == -1):
					$annonce.text = "%s a perdu ! La banque l'a mis en faillite !" % [pseudos[obj.client]]
					print("La banque l'a mis en faillite !")
				else:
					$annonce.text = "%s a perdu ! Le joueur %d l'a mis en faillite !" % [pseudos[obj.client], obj.data]
					print("Le joueur %d l'a mis en faillite !" % [obj.data])
					
					print(obj.data2)
		Structure.PacketType.GAGNE:
			$annonce.text = "VOUS AVEZ GAGNE ! FELICITATION !"
			print("VOUS AVEZ GAGNE ! FELICITATION !")
		_:
			print('autre paquet reçu')

func update_money(client, argent):
	pass
	

func _process (_delta):
	client_lobby.poll()
	client_partie.poll()


#envoie de données au serveur
func envoyer_message (client : WebSocketClient, bytes : PoolByteArray):
	client.get_peer(1).put_packet(bytes)
	#put_packet return mais on utilise pas le retour


#reception de données depuis le serveur
func recevoir_message (client : WebSocketClient) -> PoolByteArray:
	return  client.get_peer(1).get_packet()


# Connexion au serveur de partie
func rejoindre_partie (URL : String):
	#client_lobby.disconnect_from_host(0, "Pas de problème")
	var parts = URL.rsplit(':')
	ip = parts[0]
	port = parts[1]
	print('connexion au serveur de partie')
	var err = client_partie.connect_to_url('ws://' + URL)
	if err != OK:
		print('la connexion au serveur de partie a échoué')
		set_process(false)

func affiche_joueur(nb_joueurs):
	for i in nb_joueurs:
		if i==0:
			get_node("Pion").show()
			$"info_joueur/ScrollContainer/VBoxContainer/infobox1".show()
			$"info_joueur/ScrollContainer/VBoxContainer/infobox1/montant".text = "10000"
		else:
			get_node("Pion"+str(i+1)).show()
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(i+1)).show()
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(i+1)+"/montant").text = "10000"

func _on_lancer_des_pressed():
	print('envoi requête dé')
	var structure = Structure.new()
	structure.set_requete_lancer_de()
	envoyer_message(client_partie, structure.to_bytes())

func _on_fin_de_tour_pressed():
	print('envoi requête fin de tour')
	var structure = Structure.new()
	structure.set_requete_fin_de_tour()
	envoyer_message(client_partie, structure.to_bytes())

func _on_acheter_pressed():
#	if (joueur.case.acheter(joueur) == 0):
#		return
	print('envoi requête acheter')
	var structure = Structure.new()
	structure.set_requete_acheter()
	envoyer_message(client_partie, structure.to_bytes())

func _on_start_pressed():
	print('ready')
	$menu.hide()
	$join_party.show()

func _on_start2_pressed():
	var structure = Structure.new()
	# une fois connecté au lobby on demande un serveur de jeu
	code_partie = int($join_party/code_partie.text)
	nb_joueurs = int($join_party/nbjoueurs.text)
	if(code_partie == 0):
		$join_party/error/texte_erreur.text = "Code invalide ! Veuillez entrez un code valide (nombre entier non nul)."
		$join_party/error.show()
		return
	if($join_party/creer_partie.is_pressed()):
		if(nb_joueurs <= 1 or nb_joueurs > 8):
			$join_party/error/texte_erreur.text = "Nombre de joueurs invalide ! Veuillez entrez un nombre de joueurs valide (supérieur ou égale à 2 et inférieur à 8)."
			$join_party/error.show()
			return
	structure.set_inscription_partie(code_partie, nb_joueurs)
	print('envoi de la demande de partie')
	envoyer_message(client_lobby, structure.to_bytes())
	$join_party.hide()

func _on_sign_in_pressed():
	$menu/background.hide()
	$menu/connexion.show()

func _on_Form_inscription():
	var mail = $"menu/Form/formule/mail".text
	var username = $"menu/Form/formule/username".text
	var mdp = $"menu/Form/formule/passwd".text
	var pays = $"menu/Form/formule/choix pays".text
	var structure = Structure.new()
	structure.set_requete_inscription(mail,username,mdp,pays)
	envoyer_message(client_lobby, structure.to_bytes())

func sig_msg(text, username, index):
	var structure = Structure.new()
	structure.set_chat_message(text, username, index)
	print(structure.data)
	envoyer_message(client_partie, structure.to_bytes())

####### Fonctions pour boutons de l'infobox ########

func hypothequer(id_case):
	print('envoi requête hypotheque')
	print("ID CASE : " + str(id_case))
	var structure = Structure.new()
	structure.set_requete_hypothequer(id_case)
	envoyer_message(client_partie, structure.to_bytes())

func vendre(id_case):
	print('envoi requête de vente')
	var structure = Structure.new()
	structure.set_requete_vendre(id_case)
	envoyer_message(client_partie, structure.to_bytes())

func destruction(id_case):
	print('envoi requete de destruction')
	var structure = Structure.new()
	structure.set_requete_detruire(id_case)
	envoyer_message(client_partie, structure.to_bytes())

func construire(id_case):
	print('envoi requête de construction')
	var structure = Structure.new()
	structure.set_requete_construire(id_case)
	envoyer_message(client_partie, structure.to_bytes())


####################################

func fin_dep_go_prison():
	print('envoi requête de fin dep go prison')
	var structure = Structure.new()
	structure.set_fin_dep_go_prison()
	envoyer_message(client_partie, structure.to_bytes())

func _on_reclamer_pressed():
	print('envoi requête de demande de rente')
	var structure = Structure.new()
	structure.set_requete_reclamer()
	envoyer_message(client_partie, structure.to_bytes())

func _on_connexion_retour_connexion():
	$menu/connexion.hide()
	$menu/background/sign_in.hide()
	$menu/background/deconnexion.show()
	$menu/background.show()
	

func _on_connexion_inscription_conn():
	$menu/connexion.hide()
	$menu/Form.show()

func _on_Form_retour_form():
	$menu/Form.hide()
	$menu/connexion.show()

func _on_connexion_connection():
	var mail = $"menu/connexion/formule/mail".text
	var mdp = $"menu/connexion/formule/mdp".text
	var structure = Structure.new()
	structure.set_requete_connexion(mail,mdp)
	envoyer_message(client_lobby, structure.to_bytes())

func tour_plus_un():
	print('envoi requête de plus un tour')
	var structure = Structure.new()
	structure.set_requete_tour_plus_un()
	envoyer_message(client_partie, structure.to_bytes())

func _on_deconnexion_pressed():
	print("Déconnecté")
	$menu/connexion.show()
	$menu/background/sign_in.show()
	$menu/background/deconnexion.hide()
	self.mon_nom = "Client 1"

func _on_Form_exit_on_success():
	$menu/Form/success.hide()
	$menu/Form.hide()
	$menu/connexion.show()

func supprimer_joueur(n_pion):
	print(n_pion)
	if n_pion==0:
		get_node("Pion/Sprite").hide()
		$"info_joueur/ScrollContainer/VBoxContainer/infobox1/montant".text = "-1"
	else:
		print(n_pion)
		get_node("Pion"+str(n_pion+1)+"/Sprite").hide()
		get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(n_pion+1)+"/montant").text = "-1"

func carte_sortie_prison():
	print('envoi requête carte sortie prison')
	var structure = Structure.new()
	structure.set_requete_carte_sortie_prison()
	envoyer_message(client_partie, structure.to_bytes())

func send_pseudo(pseudo):
	print('envoi requête envoi de pseudo')
	var structure = Structure.new()
	structure.set_requete_send_pseudo(pseudo)
	envoyer_message(client_partie, structure.to_bytes())

func _on_abandon_pressed(): 
	var structure = Structure.new()
	if (joueur.present == 1):
		structure.set_requete_abandonner()
		client_partie.disconnect_from_host(0, "Pas de problème")
	$menu.show()

func _on_info_joueur_sig_stats_infos_joueur(player, infobox):
	var structure = Structure.new()
	structure.set_requete_consult_stats(player)
	envoyer_message(client_partie, structure.to_bytes())

func _on_retour2_pressed():
	$join_party.hide()
	$menu.show()

func _on_retour_err_join_pressed():
	$join_party/error.hide()

func _on_creer_partie_toggled(button_pressed):
	if(button_pressed):
		$join_party/nbjoueurs.show()
		$join_party/text_nbjoueurs.show()
	else:
		$join_party/nbjoueurs.hide()
		$join_party/text_nbjoueurs.hide()
