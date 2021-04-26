extends Node2D

class_name Jeu

var dep_cases = 0
var debut = 0
var cases = []
var nb_joueurs
var ip = "localhost"
var port = "5000"


var mon_nom = "Client 1"

# Our WebSocketClient instance
var client_lobby  = WebSocketClient.new()
var client_partie = WebSocketClient.new()

var cert = load("res://unistrapoly_certif.crt")

#============== Routines =================

func _ready():

	for i in range(10):
		cases.append(get_node("Plateau/cases/cote_bas").get_child(i))
		cases[i].setId(i)
	for i in range(10):
		cases.append(get_node("Plateau/cases/cote_gauche").get_child(i))
		cases[10+i].setId(10+i)
	for i in range(10):
		cases.append(get_node("Plateau/cases/cote_haut").get_child(i))
		cases[20+i].setId(20+i)
	for i in range(10):
		cases.append(get_node("Plateau/cases/cote_droit").get_child(i))
		cases[30+i].setId(30+i)
	# Choix du nombre de joueur
	nb_joueurs=2

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
	#change tous les Structure en structure
	var obj = structure.from_bytes(data_bytes)

	match obj.type:
		Structure.PacketType.ERREUR:
			match obj.data:
				1:
					print("La case n'est pas de type propriete.")
				2:
					print("La case est deja achetee.")
				3:
					print("Le joueur n'a pas assez d'argent pour acheter la case.")
				4:
					print("Cette case ne vous appartient pas.")
				5:
					print("Le joueur n'a pas assez d'argent pour une maison.")
				6:
					print("Le joueur n'a pas assez d'argent pour un hotel.")
				7:
					print("La case est à son niveau maximum.")
				8:
					print("La case est hypothequée !")
				9:
					print("Construction impossible, case non eligible.")
				10:
					print("Vous ne possedez pas toutes les propriètés de la couleur")
				11:
					print("Vous devez contruire uniformement")
				_:
					print("Erreur inconnue !")
		Structure.PacketType.MAJ_ARGENT:
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
		Structure.PacketType.MAJ_ACHAT:
			print("ACHAT REUSSI !")
			print("La propriete %d est achetee par le joueur %d pour %d ECTS" % [obj.data2, obj.client, obj.data3])
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/prop"+ str(obj.data2)).show()
		Structure.PacketType.RENTE:
			print("Joueur %d encaisse la rente de %d ECTS de la part de joueur %d" % [obj.data, obj.data2, obj.client])
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data3])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data3)
		Structure.PacketType.MAJ_CONSTRUCTION:
			if(obj.data == -1):
				print("Joueur %d construit une maison pour %d ECTS sur le terrain %d"  % [obj.client, obj.data4, obj.data3])
			elif(obj.data == -2):
				print("Joueur %d construit un hotel pour %d ECTS sur le terrain %d"  % [obj.client, obj.data4, obj.data3])
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data2])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data2)
		Structure.PacketType.MAJ_VENTE:
			print("VENTE REUSSITE !")
			print("La propriete %d est vendue par le joueur %d pour %d ECTS" % [obj.data2, obj.client, obj.data3])
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/prop"+ str(obj.data2)).hide()
		Structure.PacketType.MAJ_HYPOTHEQUE:
			if(obj.data4 == 0):
				print("HYPOTHEQUE !")
				print("La propriete %d est hypothequee par le joueur %d et gagne %d ECTS" % [obj.data2, obj.client, obj.data3])
			else:
				print("DE-HYPOTHEQUE !")
				print("La propriete %d est de-hypothequee par le joueur %d et paye %d ECTS" % [obj.data2, obj.client, obj.data3])
			print("Solde du joueur %d : %d ECTS" % [obj.client, obj.data])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
		Structure.PacketType.GO_PRISON:
			print("Joueur %d est deroute en prison !" % [obj.client])
			if obj.client == 0:
				get_node("Pion").goto_pos_prison()
			else:
				get_node("Pion"+str(obj.client+1)).goto_pos_prison()
		Structure.PacketType.OUT_PRISON:
			print("Joueur %d sort de prison et paie %d ECTS !" % [obj.client, obj.data])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(int(get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text) - obj.data)
		Structure.PacketType.FREE_OUT_PRISON:
			print("DOUBLE !")
			print("Joueur %d sort de prison !" % [obj.client])
		Structure.PacketType.TAXE:
			print("Joueur %d paye une taxe de %d ECTS !" % [obj.client, obj.data])
			get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(obj.client+1)+"/montant").text = str(obj.data)
		Structure.PacketType.CHAT:
#			print(obj.data)
			get_node("chatbox").add_message(obj.data, obj.data2, obj.data3)
			
		Structure.PacketType.REP_STATS:
			print("stats")
			print(obj.data)
			# Mettre à jour le contenu des fentres
			
		Structure.PacketType.RESULTAT_LANCER_DE:
			print('reçu résultat lancer dé : ' + str(int(obj.data)) + ' pour le client : ' + str(int(obj.client)))
			match int(obj.client):
				0:
					emit_signal("signal_resultat_lancer_de", int(obj.data))
				1:
					emit_signal("signal_resultat_lancer_de2", int(obj.data))
				2:
					emit_signal("signal_resultat_lancer_de3", int(obj.data))
				3:
					emit_signal("signal_resultat_lancer_de4", int(obj.data))
				4:
					emit_signal("signal_resultat_lancer_de5", int(obj.data))
				5:
					emit_signal("signal_resultat_lancer_de6", int(obj.data))
				6:
					emit_signal("signal_resultat_lancer_de7", int(obj.data))
				7:
					emit_signal("signal_resultat_lancer_de8", int(obj.data))
		Structure.PacketType.CACHE_JOUEUR:
			print("Suppression du joueur %d." % obj.data)
			supprimer_joueur(obj.data)
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
	print('envoi requête acheter')
	var structure = Structure.new()
	structure.set_requete_acheter()
	envoyer_message(client_partie, structure.to_bytes())

func _on_construire_pressed():
	print('envoi requête de construction')
	var structure = Structure.new()
	structure.set_requete_construire()
	envoyer_message(client_partie, structure.to_bytes())
	
func _on_vente_pressed():
	print('envoi requête de vente')
	var structure = Structure.new()
	structure.set_requete_vendre()
	envoyer_message(client_partie, structure.to_bytes())

func _on_start_pressed():
	print('ready')

	$menu.hide()
	var structure = Structure.new()
	# une fois connecté au lobby on demande un serveur de jeu
	structure.set_inscription_partie(444, nb_joueurs)
	print('envoi de la demande de partie')
	envoyer_message(client_lobby, structure.to_bytes())
	
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
	
func fin_dep_go_prison():
	print('envoi requête de fin dep go prison')
	var structure = Structure.new()
	structure.set_fin_dep_go_prison()
	envoyer_message(client_partie, structure.to_bytes())

func _on_reclamer_pressed():
	var structure = Structure.new()
	structure.set_requete_reclamer()
	envoyer_message(client_partie, structure.to_bytes())

func _on_connexion_retour_connexion():
	$menu/connexion.hide()
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




func _on_deconnexion_pressed():
	pass # Replace with function body.


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
		get_node("Pion"+str(n_pion+1)+"/Sprite").hide()
		get_node("info_joueur/ScrollContainer/VBoxContainer/infobox"+ str(n_pion+1)+"/montant").text = "-1"

func _on_hypotheque_pressed():
	print('envoi requête hypotheque')
	var structure = Structure.new()
	structure.set_requete_hypothequer(1)
	envoyer_message(client_partie, structure.to_bytes())

func _on_info_joueur_stats_pressed(player):
	var structure = Structure.new()
	structure.set_requete_consult_stats(player)
	envoyer_message(client_partie, structure.to_bytes())
