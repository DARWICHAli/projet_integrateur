extends Node

const port = 5000
const ip = "127.0.0.1"


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

func _ready():
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
			serveurs_partie.back().thread.start(self, "thread_function", [serveurs_partie.back()])
			serveurs_partie.back().code = obj.data
			sem.wait()

			var structure = Structure.new()
			structure.set_adresse_serveur_jeu(ip, serveurs_partie.back().port)

			envoyer_message(serveur_lobby, structure.to_bytes(), id_client)
		else:
			print("Le client rejoint une partie")
			var id_serveur_partie = trouver_partie(obj.data)
			var structure = Structure.new()
			structure.set_adresse_serveur_jeu(ip, serveurs_partie[id_serveur_partie].port)
			envoyer_message(serveur_lobby, structure.to_bytes(), id_client)
			
	else:
		print('autre type de paquet reçu')

# warning-ignore:unused_argument
func _process(delta):
	# Call this in _process or _physics_process.
	# Data transfer, and signals emission will only happen when calling this function.
	serveur_lobby.poll()


# Fonction d'intialisaion des threads
func thread_function (args):
	var serveur_jeu = args[0]

	serveur_jeu.socket.connect("client_connected", self, "_connected_jeu", [serveur_jeu])
	serveur_jeu.socket.connect("client_disconnected", self, "_disconnected_jeu", [serveur_jeu])
	serveur_jeu.socket.connect("client_close_request", self, "_close_request_jeu", [serveur_jeu])
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
	while true: # écoute infinie
		serveur_jeu.socket.poll()



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
	print('SERVEUR PARTIE : client connecté avec IP depuis %d:%d' % [client_IP, client_port])

func _close_request_jeu (id, code, reason):
	print("SERVEUR PARTIE : Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])
	
func _disconnected_jeu (id, was_clean = false):
	print("SERVEUR PARTIE : Client %d disconnected, clean: %s" % [id, str(was_clean)])

func _on_data_jeu(id_client, serveur_jeu):
	print('le jeu a reçu des données')
	var packet = recevoir_message(serveur_jeu.socket, id_client)

	var structure = Structure.new()

	var obj = structure.from_bytes(packet)

	var type = obj.type
	var data = obj.data


	match type:
		Structure.PacketType.CHAT:
			print('message de chat reçu:')
			print(var2str(data))
		Structure.PacketType.JEU:
			print('message de jeu reçu')
			print(var2str(data))
		Structure.PacketType.BDD:
			print('requête BDD reçue')
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
