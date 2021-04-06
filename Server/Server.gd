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

func _ready():
	# Communication avec la base de données
#	var db = SQLite.new();
#	db.path="./database.db"
#	db.verbose_mode = true
#	db.open_db()
#
#	var lines = []
#	var line:Dictionary = Dictionary()
#	line["username"] = "'bbb'"
#	line["password"] = "'123456789'"
#	line["email"] = "'thomas@bogosse.com'"
#	lines.append(line.duplicate())
#	var query = "INSERT INTO UTILISATEUR (username,password,email,pays) VALUES"
#	print(query)
#	var error = db.query(query)
#	print(error)
#	line.clear()
	
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

	if obj.type == Structure.PacketType.INSCRIPTION_PARTIE:
		print('client %d veut rejoindre la partie %d' % [id_client, obj.data])
		if trouver_partie(obj.data) == -1:
			print("Le client crée une partie")
			serveurs_partie.append(Serveur_partie.new());
			serveurs_partie.back().thread.start(self, "thread_function", [serveurs_partie.back(), obj.client])
			serveurs_partie.back().code = obj.data
			sem.wait()

			var structure = Structure.new()
			structure.set_adresse_serveur_jeu(ip, serveurs_partie.back().port, serveurs_partie.back().nb_joueurs)

			envoyer_message(serveur_lobby, structure.to_bytes(), id_client)
		else:
			print("Le client rejoint une partie")
			var id_serveur_partie = trouver_partie(obj.data)
			var structure = Structure.new()
			structure.set_adresse_serveur_jeu(ip, serveurs_partie[id_serveur_partie].port, serveurs_partie[id_serveur_partie].nb_joueurs)
			envoyer_message(serveur_lobby, structure.to_bytes(), id_client)
	else:
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
	serveur_jeu.list_joueurs.erase(id)
	print("SERVEUR PARTIE : Client %d disconnected, clean: %s" % [id, str(was_clean)])

func _on_data_jeu(id_client, serveur_jeu):
	print('le serveur de partie a reçu des données')
	var packet = recevoir_message(serveur_jeu.socket, id_client)

	var structure = Structure.new()
	
	var obj = Structure.from_bytes(packet)
	
	var type = obj.type
	var data = obj.data
	
	serveur_jeu.packet_recu = type

	match type:
		Structure.PacketType.CHAT:
			print('message de chat reçu: %s' % var2str(data))
			structure.set_chat_message(var2str(data))
			for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
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
		Structure.PacketType.VENTE:
			if (serveur_jeu.attente_joueur == serveur_jeu.list_joueurs.find(id_client) and serveur_jeu.packet_attendu == Structure.PacketType.ACTION):
				print('requête vente')
				serveur_jeu.reponse_joueur = true
		Structure.PacketType.BDD:
			print('requête BDD reçue')
		Structure.PacketType.FIN_DE_TOUR:
			print('requête fin de tour reçue')
		Structure.PacketType.INSCRIPTION:
			print('requête Inscription BDD')
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
	return 1
	#return deplacement

func partie(serveur_jeu : Serveur_partie):
	print("Partie Démarré")
	var joueur = -1
	var structure = Structure.new()
	while joueur != serveur_jeu.attente_joueur:
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
		
		while !serveur_jeu.reponse_joueur:
			serveur_jeu.socket.poll()
		# Réponse du dé
		var de_un = lancer_de()
		var de_deux = lancer_de()
		var res = 30#de_un + de_deux
		
		var current_case = serveur_jeu.plateau[serveur_jeu.position_joueur[serveur_jeu.attente_joueur]]
		# current_case -> case sur laquelle le joueur en cours de traitement se trouve
		
		if(current_case.type == Cases.CasesTypes.PRISON and serveur_jeu.joueur_prison[serveur_jeu.attente_joueur] == 1):
		# si on est deja en prison
			if(de_un != de_deux and serveur_jeu.nbr_essai_double[serveur_jeu.attente_joueur] < 3):
				serveur_jeu.nbr_essai_double[serveur_jeu.attente_joueur]+=1
				joueur = serveur_jeu.attente_joueur
				serveur_jeu.next_player()
				continue
			elif(de_un == de_deux):
				# TODO envoi sortie de prison gratuite (broadcast)
				pass
			elif(serveur_jeu.nbr_essai_double[serveur_jeu.attente_joueur] == 3):
				# TODO envoi sortie de prison payante (broadcast)
				pass
		
		serveur_jeu.deplacer_joueur(serveur_jeu.attente_joueur, res)
		structure.set_resultat_lancer_de(res, serveur_jeu.attente_joueur)
		for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
			envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
		
		if(current_case.type == Cases.CasesTypes.ALLER_PRISON):
			serveur_jeu.joueur_prison[serveur_jeu.attente_joueur] = 1
			structure.set_requete_go_prison(serveur_jeu.attente_joueur)
			for client in serveur_jeu.list_joueurs:
				envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
		
		if(current_case.proprio != -1 and current_case.proprio != serveur_jeu.attente_joueur): 
		# si case achetee et pas self-proprio
			var status = serveur_jeu.rente(current_case, serveur_jeu.attente_joueur)
			if(status == 0):
				structure.set_requete_rente(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, current_case.proprio, current_case.prix)
				for client in serveur_jeu.list_joueurs:
					envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
			else:
				# TODO joueur perdu
				pass
		
		print("Attente d'action quelconque ou fin de tour...")

		print(current_case.proprio)
		serveur_jeu.reponse_joueur = false
		serveur_jeu.packet_attendu = Structure.PacketType.ACTION	
		var status
		while serveur_jeu.packet_recu != Structure.PacketType.FIN_DE_TOUR:
			serveur_jeu.socket.poll()
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
				if(status < 0):
					structure.set_requete_maj_construire(status, serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, serveur_jeu.position_joueur[serveur_jeu.attente_joueur], current_case.prix)
					for client in serveur_jeu.list_joueurs:
						envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				else:
					structure.set_requete_erreur(status)
					envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])
				serveur_jeu.reponse_joueur = false
			if serveur_jeu.reponse_joueur == true and serveur_jeu.packet_recu == Structure.PacketType.VENTE:
				status = serveur_jeu.vendre(serveur_jeu.attente_joueur)
				if(status == 0):
					structure.set_requete_maj_vente(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, serveur_jeu.position_joueur[serveur_jeu.attente_joueur], current_case.prix)
					for client in serveur_jeu.list_joueurs:
						envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				else:
					structure.set_requete_erreur(status)
					envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])				
				serveur_jeu.reponse_joueur = false
		serveur_jeu.packet_recu = -1
		
		print("Solde du joueur %d (en cours de jeu) : %d ECTS" % [serveur_jeu.attente_joueur, serveur_jeu.argent_joueur[serveur_jeu.attente_joueur]])
		
		# Passage au prochain joueur
		joueur = serveur_jeu.attente_joueur
		serveur_jeu.next_player()
	print("Player %d win" % joueur)
	emit_signal("fin_partie", serveur_jeu.code)


func _on_Server_fin_partie(code):
	for i in range(0,serveurs_partie.size()):
		if serveurs_partie[i].code == code:
			serveurs_partie.remove(i)
			return
	print("Serveur de partie non trouvé pour finir")
