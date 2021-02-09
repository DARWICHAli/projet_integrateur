extends Node

var ip = "127.0.0.1"
var port = "5000"

# Our WebSocketClient instance
var _client = WebSocketClient.new()

func _ready():
	# Choix des fonctions selon l'ouverture de connection, la fermeture et les erreurs.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")

	# Initiate connection to the given URL.
	var err = _client.connect_to_url(making_url(ip, port))
	if err != OK:
		print("Unable to connect")
		set_process(false)

# Fonction de fermeture de connexion
func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

# Fonction d'ouverture de connexion
func _connected(proto = ""):
	print("Connecté au serveur : " + ip + ":" + port)
	_client.get_peer(1).put_packet("Demande de je sais pas quoi!".to_utf8())

# Fonction de recu de paquet et connexion au nouveau si c'est une ip qu'il recoit
func _on_data():
	var data = _client.get_peer(1).get_packet().get_string_from_utf8()
	print("Got data from server: ", data)
	if is_an_IP(data):
		new_server(data)

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()

# Création de l'url permettant de se connecter au serveur
func making_url(ipu, portu):
	return "ws://" + ipu + ":" + portu

# Connexion au nouveau serveur selon l'ip donné par data, et inscription dans les variables
func new_server(data):
	_client.disconnect_from_host(0, "Pas de problème")
	var data_array = data.rsplit(":", false, 0)
	ip = data_array[0]
	port = data_array[1]
	_client.connect_to_url(making_url(ip, port))
	if _client.CONNECTION_CONNECTED == 2:
		print("Connected to server : " + ip + ":" + port)

# test d'une ip sous le format "x.x.x.x:yyyy"
func is_an_IP(data):
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
