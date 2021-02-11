extends Node

const port = 5000
const ip = "127.0.0.1"


# Our WebSocketServer instance
var serveur_lobby = WebSocketServer.new()

var serveur_jeu # il faudra trouver un autre moyen
# Tableau des threads
var threads = []
# Pour le nombre random
var rng = RandomNumberGenerator.new()
# Tableau des ports utilisé (ne comptant pas le thread principal)
var portThread = []
# Permet d'attendre le thread créant le port
var sem = Semaphore.new()

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

func _connected_lobby (id, proto):
	var client_IP   = serveur_lobby.get_peer_address(id)
	var client_port = serveur_lobby.get_peer_port(id)
	print('client connecté au lobby, numéro %d, adresse : %s:%d' % [id, client_IP, client_port])

func _close_request_lobby (id, code, reason):
	# This is called when a client notifies that it wishes to close the connection,
	# providing a reason string and close code.
	print("Client %d disconnecting from lobby with code: %d with reason : %s" % [id, code, reason])

func _disconnected_lobby (id, was_clean = false):
	# This is called when a client disconnects, "id" will be the one of the
	# disconnecting client, "was_clean" will tell you if the disconnection
	# was correctly notified by the remote peer before closing the socket.
	print("Client %d disconnected from lobby , clean: %s" % [id, str(was_clean)])

# Lancement d'un nouveau thread, puis envoie du nouveau ip et port
func _on_data_lobby (id_client : int):
	var paquet = recevoir_message(serveur_lobby, id_client)

	var obj = Structure.from_bytes(paquet)

	if obj.type == Structure.PacketType.INSCRIPTION_PARTIE:
		print('client %d veut rejoindre la partie %d' % [id_client, obj.data])

		threads.append(Thread.new())
		threads.back().start(self, "thread_function", [])
		sem.wait()

		var structure = Structure.new()
		structure.set_adresse_serveur_jeu(ip, portThread.back())

		envoyer_message(serveur_lobby, structure.to_bytes(), id_client)
	else:
		print('autre type de paquet reçu')

func _process(delta):
	# Call this in _process or _physics_process.
	# Data transfer, and signals emission will only happen when calling this function.
	serveur_lobby.poll()


# Fonction d'intialisaion des threads
func thread_function (args):
	serveur_jeu = WebSocketServer.new()

	serveur_jeu.connect("client_connected", self, "_connected_jeu")
	serveur_jeu.connect("client_disconnected", self, "_disconnected_jeu")
	serveur_jeu.connect("client_close_request", self, "_close_request_jeu")
	serveur_jeu.connect("data_received", self, "_on_data_jeu")

	var find = false
	var port_serveur_jeu
	while !find:
		port_serveur_jeu = rng.randi_range(5001, 65353)
		while portThread.has(port_serveur_jeu):
			port_serveur_jeu = rng.randi_range(5001, 65353)
		var err = serveur_jeu.listen(port_serveur_jeu)
		if err != OK:
			print("Unable to start server")
			set_process(false)
		else:
			print("Serveur de partie démarré avec port: " + String(port_serveur_jeu))
			portThread.append(port_serveur_jeu)
			find = true

	sem.post()
	while true: # écoute infinie
		serveur_jeu.poll()



func _connected_jeu (id, proto):
	var client_IP   = serveur_jeu.get_peer_address(id)
	var client_port = serveur_jeu.get_peer_port(id)
	print('SERVEUR PARTIE : client connecté avec IP depuis %d:%d' % [client_IP, client_port])

func _close_request_jeu (id, code, reason):

	print("SERVEUR PARTIE : Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _disconnected_jeu (id, was_clean = false):

	print("SERVEUR PARTIE : Client %d disconnected, clean: %s" % [id, str(was_clean)])

func _on_data_jeu(id_client):
	print('le jeu a reçu des données')
	var packet = serveur_jeu.get_peer(id_client).get_packet()

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
	server.get_peer(client_id).put_packet(bytes)

func recevoir_message (server : WebSocketServer, id_client : int) -> PoolByteArray:
	return server.get_peer(id_client).get_packet()



