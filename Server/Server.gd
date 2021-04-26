extends Node

const port = 5000
const ip = "localhost"

# connection BDD
const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
# Our WebSocketServer instance
var serveur_lobby = WebSocketServer.new()

# Pour le nombre random
var rng = RandomNumberGenerator.new()
# Permet d'attendre le thread créant le port
var sem = Semaphore.new()
# Serveurs des parties de jeu
const serveurs_partie = []
#tableau de stockage des clients qui se connectent sur le lobby
var list_clients=[]

var key = load("res://unistrapoly_key.key")
var cert = load("res://unistrapoly_certif.crt")

var db # db connection

func _ready():
	#Communication avec la base de données
	#db = SQLite.new();
	#db.path="./database.db"
	#db.verbose_mode = true
	#db.open_db()
	
	#stats("tthirtle2o")
	
	serveur_lobby.set_private_key(key)
	serveur_lobby.set_ssl_certificate(cert)
	# Connect base signals to get notified of new client connections,
	# disconnections, and disconnect requests.
	serveur_lobby.connect("client_connected", self, "_connected_lobby")
	serveur_lobby.connect("client_disconnected", self, "_disconnected_lobby")
	serveur_lobby.connect("client_close_request", self, "_close_request_lobby")
	# This signal is emitted when not using the Multiplayer API every time a
	# full packet is received.
	# Alternatively, you could check get_peer(PEER_ID).get_available_packets()
	# in a loop for each connected peer.
	serveur_lobby.connect("data_received", self, "_on_data_lobby")
	# Start listening on the given port.
	var err = serveur_lobby.listen(port)
	if err != OK:
		print("erreur de démarrage du serveur lobby")
		set_process(false)
	else:
		print("Serveur de lobby démarré avec port: " + String(port))
	rng.randomize()

func stats(pseudo):
	var err = db.query("SELECT U.idU FROM UTILISATEUR U WHERE U.username LIKE '"+pseudo+"';") # À faire hors de la fonction
	
	var array = db.select_rows("UTILISATEUR","username  like '"+pseudo+"'", ["tempsJeu","nbWin", "nbLose", "dateInscr"])
	var row_dict : Dictionary = {}
	if(len(array[0]) > 0):
		var date = array[0].dateInscr
		var temps = array[0].tempsJeu	
		var win = array[0].nbWin	
		var lose = array[0].nbLose

		var array2 = db.select_rows("(SELECT id, np, max(nb_ut) FROM (SELECT UP.idU AS id, UP.nomPion AS np, (SELECT count(UP2.nomPion) FROM UTILISE_PION UP2 WHERE UP2.nomPion LIKE UP.nomPion AND UP2.idU = UP.idU) AS nb_ut FROM UTILISE_PION UP WHERE UP.idU = id GROUP BY UP.nomPion))","",["np"])
		
		if(len(array2) > 0):
			var np = array2[0].np
			var array3 = db.select_rows("(SELECT id, nc, max(nb_ac) FROM (SELECT AC.idU AS id, AC.nomCase AS nc, (SELECT count(AC2.nomCase) FROM ACHETE_CASE AC2 WHERE AC2.nomCase LIKE AC.nomCase AND AC2.idU = AC.idU) AS nb_ac FROM ACHETE_CASE AC WHERE AC.idU = id GROUP BY AC.nomCase))","",["nc"])
			
			if(len(array3[0]) > 0):
				var nc = array3[0].nc
				row_dict = {"dateInscr":date, "nbLose":lose, "nbWin": win, "tempsJeu": temps, "bestPion":np, "bestCase":nc}
	return row_dict.duplicate()
	
# warning-ignore:unused_argument
func _connected_lobby (id, proto):
	var client_IP   = serveur_lobby.get_peer_address(id)
	var client_port = serveur_lobby.get_peer_port(id)
	#tableau de stockage des clients qui se connecte sur le lobby 
	if list_clients.has(id):
		print("le client est déjà present")
	else:
		list_clients.append(id)	
		print('Un client est ajouté')
	print('client connecté au lobby, numéro %d, adresse : %s:%d' % [id, client_IP, client_port])

func _close_request_lobby (id, code, reason):
	# This is called when a client notifies that it wishes to close the connection,
	# providing a reason string and close code.
	print("Client %d disconnecting from lobby with code: %d with reason : %s" % [id, code, reason])
	#supprimer son id après deconnection du client sur le lobby (si necessaire)
	if list_clients.has(id):
		list_clients.erase(id)

func _disconnected_lobby (id, was_clean = false):
	# This is called when a client disconnects, "id" will be the one of the
	# disconnecting client, "was_clean" will tell you if the disconnection
	# was correctly notified by the remote peer before closing the socket.
	print("Client %d disconnected from lobby , clean: %s" % [id, str(was_clean)])
	#vider le tableau apres la deconnection du lobby 
	for id in list_clients:
		list_clients.erase(id)

# Lancement d'un nouveau thread, puis envoie du nouveau ip et port
func _on_data_lobby (id_client : int):
	var paquet = recevoir_message(serveur_lobby, id_client)

	var obj = Structure.from_bytes(paquet)
	var structure = Structure.new()

	match obj.type:
		Structure.PacketType.INSCRIPTION_PARTIE:
			print('client %d veut rejoindre la partie %d' % [id_client, obj.data])
			if trouver_partie(obj.data) == -1:
				print("Le client crée une partie")
				serveurs_partie.append(Serveur_partie.new());
				serveurs_partie.back().thread.start(self, "thread_function", [serveurs_partie.back(), obj.client])
				serveurs_partie.back().code = obj.data
				sem.wait()
				structure.set_adresse_serveur_jeu(ip, serveurs_partie.back().port, serveurs_partie.back().nb_joueurs)

				envoyer_message(serveur_lobby, structure.to_bytes(), id_client)
			else:
				print("Le client rejoint une partie")
				var id_serveur_partie = trouver_partie(obj.data)
				structure.set_adresse_serveur_jeu(ip, serveurs_partie[id_serveur_partie].port, serveurs_partie[id_serveur_partie].nb_joueurs)
				envoyer_message(serveur_lobby, structure.to_bytes(), id_client)
		Structure.PacketType.INSCRIPTION:
			var error = db.query("INSERT INTO UTILISATEUR (username,password,email,pays) VALUES"+obj.data)
			print(error)
			if error == false: # false = l'insertion n'a pas eu lieu
				structure.set_requete_erreur(1) # !=0 -> une erreur a eu lieu
			else:
				structure.set_requete_erreur(0) # 0 = aucune erreur
			envoyer_message(serveur_lobby, structure.to_bytes(), id_client)
		Structure.PacketType.LOGIN:
			var array = db.select_rows("UTILISATEUR","email  like '"+obj.data.mail+"'", ["username"])
			if(len(array) == 0):
				structure.set_requete_reponse_login(1)
			else:
				structure.set_requete_reponse_login(array[0].username)
				
			envoyer_message(serveur_lobby, structure.to_bytes(), id_client)
		_:
			print('autre type de paquet reçu')	

# warning-ignore:unused_argument
func _process(delta):
	# Call this in _process or _physics_process.
	# Data transfer, and signals emission will only happen when calling this function.
	serveur_lobby.poll()

signal fin_partie(code)

# Fonction d'intialisaion des threads
func thread_function (args):
	var serveur_jeu = args[0]
	serveur_jeu.nb_joueurs = args[1]	
	serveur_jeu.socket.connect("client_connected", self, "_connected_jeu", [serveur_jeu])
	serveur_jeu.socket.connect("client_disconnected", self, "_disconnected_jeu", [serveur_jeu])
	serveur_jeu.socket.connect("client_close_request", self, "_close_request_jeu")
	serveur_jeu.socket.connect("data_received", self, "_on_data_jeu", [serveur_jeu])
	var find = false
	var port_serveur_jeu
	while !find:
		port_serveur_jeu = rng.randi_range(5001, 65353)
		var err = serveur_jeu.socket.listen(port_serveur_jeu)
		if err != OK:
			print("Unable to start server")
			set_process(false)
		else:
			print("Serveur de partie démarré avec port: " + String(port_serveur_jeu))
			serveur_jeu.port = port_serveur_jeu
			find = true

	sem.post()
	while serveur_jeu.list_joueurs.size() < serveur_jeu.nb_joueurs:
		serveur_jeu.socket.poll()
	serveur_jeu.socket.disconnect("client_connected", self, "_connected_jeu") # Ne détecte plus de nouveau client
	serveur_jeu.init_partie()
	partie(serveur_jeu)

# warning-ignore:unused_argument
func _connected_jeu (id, proto, serveur_jeu):
	var client_IP   = serveur_jeu.socket.get_peer_address(id)
	var client_port = serveur_jeu.socket.get_peer_port(id)
	#ajout de l'id du joueurs dans le tableau list_joueurs
	if serveur_jeu.list_joueurs.has(id):
		print('le id joueur est déja present')
	else :
		serveur_jeu.list_joueurs.append(id)	
		print('un id de joueur est ajouté ')
	#fonctionne pas ou pas tout le temps ? manque probablement une valeur (IP chaine de char ?)
	print("SERVEUR PARTIE : client connecté avec IP depuis %s:%d" % [client_IP, client_port])

func _close_request_jeu (id, code, reason):
	print("SERVEUR PARTIE : Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])
	
func _disconnected_jeu (id, was_clean = false, serveur_jeu = null):
	supprimer_joueur(id, serveur_jeu)
	print("SERVEUR PARTIE : Client %d disconnected, clean: %s" % [id, str(was_clean)])
	if serveur_jeu.list_joueurs.size() == 0:
		emit_signal("fin_partie", serveur_jeu.code)

func _on_data_jeu(id_client, serveur_jeu):
	print('le serveur de partie a reçu des données')
	var packet = recevoir_message(serveur_jeu.socket, id_client)

	var structure = Structure.new()
	
	var obj = Structure.from_bytes(packet)
	
	var type = obj.type
	var data = obj.data
	
	serveur_jeu.packet_recu = type

	print("match %s" % type)
	match type:
		Structure.PacketType.CHAT:
			print('test %d' % serveur_jeu.list_joueurs.find(id_client))
			print('message de chat reçu: %s' % var2str(data))
			structure.set_chat_message(data, obj.data2, serveur_jeu.list_joueurs.find(id_client))
			for client in serveur_jeu.list_joueurs: # Broadcast sur tous les joueurs
				envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
		Structure.PacketType.JEU:
			if (serveur_jeu.attente_joueur == serveur_jeu.list_joueurs.find(id_client) and serveur_jeu.packet_jeu == type):
				print('message de jeu reçu')
				print(var2str(data))
		Structure.PacketType.REQUETE_LANCER_DE:
			if (serveur_jeu.attente_joueur == serveur_jeu.list_joueurs.find(id_client) and serveur_jeu.packet_attendu == type):
				print('requête de dé reçue')
				serveur_jeu.reponse_joueur = true
		Structure.PacketType.ACHAT:
			if (serveur_jeu.attente_joueur == serveur_jeu.list_joueurs.find(id_client) and serveur_jeu.packet_attendu == Structure.PacketType.ACTION):
				print('requête achat')
				serveur_jeu.reponse_joueur = true
		Structure.PacketType.CONSTRUCTION:
			if (serveur_jeu.attente_joueur == serveur_jeu.list_joueurs.find(id_client) and serveur_jeu.packet_attendu == Structure.PacketType.ACTION):
				print('requête construction')
				serveur_jeu.reponse_joueur = true
		Structure.PacketType.VENTE: #####
			#if (serveur_jeu.attente_joueur == serveur_jeu.list_joueurs.find(id_client) and serveur_jeu.packet_attendu == Structure.PacketType.ACTION):
			print('requête vente')
			vente_res(serveur_jeu.list_joueurs.find(id_client), obj.data, serveur_jeu)
			#serveur_jeu.reponse_joueur = true
		Structure.PacketType.STATS_CONSULT:
			var stats = stats(obj.data)
			if(stats == null):
				stats = {}
			structure.set_requete_reponse_stats(stats.duplicate())
			envoyer_message(serveur_jeu.socket, structure.to_bytes(), id_client)
			serveur_jeu.reponse_joueur = true
		Structure.PacketType.BDD:
			print('requête BDD reçue')
		Structure.PacketType.FIN_DEP_GO_PRISON:
			if (serveur_jeu.attente_joueur == serveur_jeu.list_joueurs.find(id_client) and serveur_jeu.packet_attendu == Structure.PacketType.FIN_DEP_GO_PRISON):
				print('requête fin_dep_go_prison')
				serveur_jeu.reponse_joueur = true
		Structure.PacketType.FIN_DE_TOUR:
			print('requête fin de tour reçue')
		Structure.PacketType.HYPOTHEQUE:
			print('requête hypotheque reçue')
			hypotheque_res(serveur_jeu.list_joueurs.find(id_client), obj.data, serveur_jeu)
		Structure.PacketType.RECLAMER:
			print(serveur_jeu.attente_proprio)
			if (serveur_jeu.attente_proprio == serveur_jeu.list_joueurs.find(id_client)):
				print("requête reclamer reçue")
				serveur_jeu.reponse_proprio = true
		_:
			print("type de données inconnu")

#envoie les octets au client identifié par client_id
func envoyer_message (server : WebSocketServer, bytes : PoolByteArray, client_id : int):
# warning-ignore:return_value_discarded
	server.get_peer(client_id).put_packet(bytes)

func recevoir_message (server : WebSocketServer, id_client : int) -> PoolByteArray:
	return server.get_peer(id_client).get_packet()

# Renvoie l'index de la position du code dans le tableau serveur_parties s'il existe, sinon il renvoie -1
func trouver_partie(code : int) :
	for index in range(0, len(serveurs_partie)):
		 if serveurs_partie[index].code == code:
			 return index
	return -1

func lancer_de():
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var deplacement = rand.randi_range(1, 6)
	return deplacement

func partie(serveur_jeu : Serveur_partie):
	print("Partie Démarré")
	var joueur = -1
	var structure = Structure.new()
	var timer
	var timer_reclamation
	while joueur != serveur_jeu.attente_joueur:
		var double = 1
		var nb_double = 0
		var goto_prison = 0
		while double:
			print("\n\n")
			print("AU TOUR DU JOUEUR %d !" % [serveur_jeu.attente_joueur])
			
			# Attente d'une demande de dé
			serveur_jeu.reponse_joueur = false
			serveur_jeu.packet_attendu = Structure.PacketType.REQUETE_LANCER_DE
			print("Solde du joueur %d (en cours de jeu) : %d ECTS" % [serveur_jeu.attente_joueur, serveur_jeu.argent_joueur[serveur_jeu.attente_joueur]])
			structure.set_requete_maj_argent(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur)
			for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
				envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
			
			print("Attente de lancement de dé...")
			timer = get_tree().create_timer(10.0)
			while !serveur_jeu.reponse_joueur:
				serveur_jeu.socket.poll()
				
			# Réponse du dé
			var de_un = 1#lancer_de()
			var de_deux = 0#lancer_de()
			var res = de_un + de_deux
			
			if de_un != de_deux:
				double = 0
			else:
				nb_double += 1	
			if nb_double == 3:
				goto_prison = 1
			
			var current_case = serveur_jeu.plateau[serveur_jeu.position_joueur[serveur_jeu.attente_joueur]]
			# current_case -> case sur laquelle le joueur en cours de traitement se trouve
			
			if(serveur_jeu.joueur_prison[serveur_jeu.attente_joueur] == 1):
			# si on est deja en prison
				# TODO Choix de payer directement sans faire de double
				serveur_jeu.plateau[serveur_jeu.position_joueur[serveur_jeu.attente_joueur]] = serveur_jeu.plateau[10]
				print("DE NUMERO 1: %d pour joueur %d" % [de_un, serveur_jeu.attente_joueur])
				print("DE NUMERO 2: %d" % [de_deux])
				if(de_un != de_deux and serveur_jeu.nbr_essai_double[serveur_jeu.attente_joueur] < 3):
					print("TOUJOURS PAS SORTI !")
					serveur_jeu.nbr_essai_double[serveur_jeu.attente_joueur]+=1
					joueur = serveur_jeu.attente_joueur
					serveur_jeu.next_player()
					continue
				elif(de_un == de_deux):
					structure.set_requete_free_out_prison(serveur_jeu.attente_joueur)
					for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
						envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				elif(serveur_jeu.nbr_essai_double[serveur_jeu.attente_joueur] == 3):
					serveur_jeu.payer_prison(serveur_jeu.attente_joueur)
					structure.set_requete_out_prison(serveur_jeu.attente_joueur, serveur_jeu.prix_prison)
					for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
						envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
			
			if(goto_prison != 1):
				serveur_jeu.deplacer_joueur(serveur_jeu.attente_joueur, res)
				structure.set_resultat_lancer_de(res, serveur_jeu.attente_joueur)
				for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
					envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				print(serveur_jeu.attente_joueur)

			timer_reclamation = get_tree().create_timer(10.0)
			serveur_jeu.reponse_proprio = false
			serveur_jeu.proprio_a_reclamer = false

			current_case = serveur_jeu.plateau[serveur_jeu.position_joueur[serveur_jeu.attente_joueur]]
			# RAFRAICHISSEMENT DE CURRENT_CASE
			
			print("------------------")
			print(current_case.indice)
			print(current_case.type)
			print(current_case.sous_type)
			print("------------------")
			
			if(current_case.type == Cases.CasesTypes.TAXE):
				serveur_jeu.taxe(serveur_jeu.attente_joueur)
				structure.set_requete_taxe(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur)
				for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
					envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
			
			# ALLER EN PRISON POUR TRIPLE DOUBLE
			if(goto_prison == 1):
				structure.set_requete_go_prison(serveur_jeu.attente_joueur)
				for client in serveur_jeu.list_joueurs:
					envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				serveur_jeu.reponse_joueur = false
				joueur = serveur_jeu.attente_joueur
				serveur_jeu.next_player()
				continue
			
			# ALLER EN PRISON POUR CASE GO_PRISON
			if(current_case.type == Cases.CasesTypes.ALLER_PRISON):
				serveur_jeu.joueur_prison[serveur_jeu.attente_joueur] = 1
				serveur_jeu.reponse_joueur = false
				serveur_jeu.packet_attendu = Structure.PacketType.FIN_DEP_GO_PRISON
				while(serveur_jeu.packet_recu != Structure.PacketType.FIN_DEP_GO_PRISON):
					serveur_jeu.socket.poll()
				structure.set_requete_go_prison(serveur_jeu.attente_joueur)
				for client in serveur_jeu.list_joueurs:
					envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				serveur_jeu.reponse_joueur = false
				joueur = serveur_jeu.attente_joueur
				serveur_jeu.next_player()
				continue
				
#			if(current_case.proprio != -1 and current_case.proprio != serveur_jeu.attente_joueur): 
#			# si case achetee et pas self-proprio
#				var status = serveur_jeu.rente(current_case, serveur_jeu.attente_joueur, res)
#				if(status == 0):
#					structure.set_requete_rente(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, current_case.proprio, current_case.prix)
#					for client in serveur_jeu.list_joueurs:
#						envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
#				else:
#					# TODO joueur perdu
#					pass

			print("Attente d'action quelconque ou fin de tour...")

			print(current_case.proprio)
			serveur_jeu.reponse_joueur = false
			serveur_jeu.packet_attendu = Structure.PacketType.ACTION	
			var status
			serveur_jeu.attente_proprio = current_case.proprio
			timer = get_tree().create_timer(15.0)

			while serveur_jeu.packet_recu != Structure.PacketType.FIN_DE_TOUR and timer.get_time_left() > 0:
				serveur_jeu.socket.poll()
				
	#			if serveur_jeu.reponse_joueur == true and serveur_jeu.packet_recu == Structure.PacketType.CHAT:
	#				var obj = serveur_jeu.packet_recu
	#				print('test')
	#				print('message de chat reçu: %s' % var2str(data))
	#				structure.set_chat_message(obj.data, obj.data2, obj.data3)
	#				for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
	#					envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				if serveur_jeu.reponse_joueur == true and serveur_jeu.packet_recu == Structure.PacketType.ACHAT:
					status = serveur_jeu.acheter(serveur_jeu.attente_joueur)
					if(status == 0):
						structure.set_requete_maj_achat(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, serveur_jeu.position_joueur[serveur_jeu.attente_joueur], current_case.prix)
						for client in serveur_jeu.list_joueurs:
							envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
					else:
						structure.set_requete_erreur(status)
						envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])							
					serveur_jeu.reponse_joueur = false
				if serveur_jeu.reponse_joueur == true and serveur_jeu.packet_recu == Structure.PacketType.CONSTRUCTION:
					status = serveur_jeu.upgrade(serveur_jeu.attente_joueur)
					print("3333333333333333333")
					if(status < 0):
						structure.set_requete_maj_construire(status, serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, serveur_jeu.position_joueur[serveur_jeu.attente_joueur], current_case.prix)
						for client in serveur_jeu.list_joueurs:
							envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
					else:
						structure.set_requete_erreur(status)
						envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])
					serveur_jeu.reponse_joueur = false
#				if serveur_jeu.reponse_joueur == true and serveur_jeu.packet_recu == Structure.PacketType.VENTE:
#					status = serveur_jeu.vendre(serveur_jeu.attente_joueur)
#					if(status == 0):
#						structure.set_requete_maj_vente(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, serveur_jeu.position_joueur[serveur_jeu.attente_joueur], current_case.prix)
#						for client in serveur_jeu.list_joueurs:
#							envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
#					else:
#						structure.set_requete_erreur(status)
#						envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])				
					serveur_jeu.reponse_joueur = false
				if serveur_jeu.reponse_proprio == true and serveur_jeu.packet_recu == Structure.PacketType.RECLAMER:
					if (timer_reclamation.get_time_left() > 0):
							if (!serveur_jeu.proprio_a_reclamer):
								serveur_jeu.proprio_a_reclamer = true
								status = serveur_jeu.rente(current_case, serveur_jeu.attente_joueur, res)
								if(status == 0):
									structure.set_requete_rente(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, current_case.proprio, current_case.prix)
									for client in serveur_jeu.list_joueurs:
										envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
								else:
									structure.set_requete_erreur(status)
									envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])
			serveur_jeu.packet_recu = -1
			
			while (current_case.proprio != -1 and current_case.proprio != serveur_jeu.attente_joueur and serveur_jeu.reponse_proprio == false and timer_reclamation.get_time_left() > 0):
				serveur_jeu.socket.poll()
				if (serveur_jeu.reponse_proprio == true and serveur_jeu.packet_recu == Structure.PacketType.RECLAMER):
							if (!serveur_jeu.proprio_a_reclamer):
								serveur_jeu.proprio_a_reclamer = true
								status = serveur_jeu.rente(current_case, serveur_jeu.attente_joueur, res)
								if(status == 0):
									structure.set_requete_rente(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, current_case.proprio, current_case.prix)
									for client in serveur_jeu.list_joueurs:
										envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
								else:
									structure.set_requete_erreur(status)
									envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])
			print("Test de propiete : %d" % serveur_jeu.plateau[0].proprio)
			print("Solde du joueur %d (en cours de jeu) : %d ECTS" % [serveur_jeu.attente_joueur, serveur_jeu.argent_joueur[serveur_jeu.attente_joueur]])
			
			# Passage au prochain joueur
			if(double == 0):
				joueur = serveur_jeu.attente_joueur
				serveur_jeu.next_player()
	print("Player %d win" % joueur)
	emit_signal("fin_partie", serveur_jeu.code)

func vente_res(id, id_case, serveur_jeu):
	var case = serveur_jeu.plateau[id_case]
	var structure = Structure.new()
	var status = serveur_jeu.vendre(id, case)
	if(status == 0):
		structure.set_requete_maj_vente(serveur_jeu.argent_joueur[id], id, case.indice, case.prix)
		for client in serveur_jeu.list_joueurs:
			envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
	else:
		structure.set_requete_erreur(status)
		envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])

func hypotheque_res(id, id_case, serveur_jeu):
	print("2222222222222222222")
	var case = serveur_jeu.plateau[id_case]
	var structure = Structure.new()
	var status = serveur_jeu.hypothequer(id, case)
	print("33333333333333333333")
	if(status <= 0):
		var price
		if (status == -1):
			price = 1.1*case.prix
		else:
			price = 0.9*case.prix
		structure.set_requete_maj_hypotheque(serveur_jeu.argent_joueur[id], id, case.indice, price, status)
		print("444444444444444444")
		for client in serveur_jeu.list_joueurs:
			envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
	else:
		structure.set_requete_erreur(status)
		envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])

func _on_Server_fin_partie(code):
	for i in range(0,serveurs_partie.size()):
		if serveurs_partie[i].code == code:
			serveurs_partie.remove(i)
			return
	print("Serveur de partie non trouvé pour finir")

func supprimer_joueur(id, serveur_jeu):
	var structure = Structure.new()
	structure.set_requete_cache_joueur(serveur_jeu.list_joueurs.find(id))
	serveur_jeu.list_joueurs.erase(id)
	for client in serveur_jeu.list_joueurs: # Broadcast sur tous les joueurs
		envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
