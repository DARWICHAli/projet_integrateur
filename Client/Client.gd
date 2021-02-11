extends Node

var ip = "127.0.0.1"
var port = "5000"


# Our WebSocketClient instance
var client_lobby  = WebSocketClient.new()
var client_partie = WebSocketClient.new()

func _ready():
	print('ready')
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
	var err = client_lobby.connect_to_url(making_url(ip, port))
	if err != OK:
		print("la connexion au lobby a échoué")
		set_process(false)



# Fonction de fermeture de connexion
func _closed_lobby (was_clean = false):
	print("déconnexion du lobby, clean: ", was_clean)
	set_process(false)


# Fonction d'ouverture de connexion
func _connected_lobby (proto = ""):
	print("connecté au serveur lobby à l'adresse %s:%s" % [str(ip), str(port)])

	var structure = Structure.new()
	# une fois connecté au lobby on demande un serveur de jeu
	structure.set_inscription_partie(444)
	print('envoi de la demande de partie')
	envoyer_message(client_lobby, structure.to_bytes())

# Fonction de recu de paquet et connexion au nouveau si c'est une ip qu'il recoit
func _on_data_lobby ():
	print ('données reçues')
	var structure = Structure.new()
	var data_bytes = recevoir_message(client_lobby)

	var obj = structure.from_bytes(data_bytes)

	match obj.type:
		Structure.PacketType.ADRESSE_SERVEUR_JEU:
			print('reçu adresse du serveur de jeu: ', obj.data)
			rejoindre_partie(obj.data)
		_:
			print('autre paquet reçu')


# Fonction de fermeture de connexion
func _closed_partie (was_clean = false):
	print("PARTIE : Closed, clean: ", was_clean)
	set_process(false)


# Fonction d'ouverture de connexion
func _connected_partie (proto = ""):
	print("connecté au serveur de partie à l'adresse %s:%s" % [str(ip), str(port)])

	var structure = Structure.new()

	print('envoi message chat')
	structure.set_chat_message('message chat')
	envoyer_message(client_partie, structure.to_bytes())

	print('envoi message chat')
	structure.set_plateau([555, 666, 777])
	envoyer_message(client_partie, structure.to_bytes())


# Fonction de recu de paquet et connexion au nouveau si c'est une ip qu'il recoit
func _on_data_partie ():
	print ('données reçues')
	var structure = Structure.new()
	var data_bytes = recevoir_message(client_partie)

	var obj = structure.from_bytes(data_bytes)

	match obj.type:
		Structure.PacketType.CHAT:
			print('message de chat reçu')
		_:
			print('autre paquet reçu')


func _process (delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	client_lobby.poll()
	client_partie.poll()





#envoie de données au serveur
func envoyer_message (client : WebSocketClient, bytes : PoolByteArray):
		client.get_peer(1).put_packet(bytes)

#reception de données depuis le serveur
func recevoir_message (client : WebSocketClient) -> PoolByteArray:
	return  client.get_peer(1).get_packet()




# Connexion au serveur de partie
func rejoindre_partie (URL : String):
	client_lobby.disconnect_from_host(0, "Pas de problème")
	var parts = URL.rsplit(':')
	ip = parts[0]
	port = parts[1]

	print('connexion au serveur de partie')
	var err = client_partie.connect_to_url('ws://' + URL)
	if err != OK:
		print('la connexion au serveur de partie a échoué')
		set_process(false)












# Création de l'url permettant de se connecter au serveur
func making_url (ip, port):
	return "ws://" + ip + ":" + port

# test d'une ip sous le format "x.x.x.x:yyyy"
func is_an_IP (data):
	var data_array1 = data.rsplit(":", false, 0)
	var ip_array = data.rsplit(".", false, 0)
	if data_array1.size() != 2:
		return false
	elif ip_array.size() != 4:
		return false
	elif !data_array1[1].is_valid_integer():
		return false
	elif 1024 > data_array1[1].to_int() or data_array1[1].to_int() > 65353:
		return false
	for i in range(0,3):
		if ip_array[i].to_int() < 0 or ip_array[i].to_int() > 255:
			return false
	return true
