extends Node2D

class_name Jeu

var dep_cases = 0
var coin = 0 # 0 case dep, 1 prison, 2 park, 3 go_prison
var debut = 0
var cases = []
var nb_joueurs

# ============= Client ==================== #

var ip = "127.0.0.1"
var port = "5000"

var mon_nom = "Client 1"

# Our WebSocketClient instance
var client_lobby  = WebSocketClient.new()
var client_partie = WebSocketClient.new()

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
	nb_joueurs=3
	for i in nb_joueurs:
		if i==0:
			get_node("Pion").show()
		else:
			get_node("Pion"+str(i+1)).show()

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
	var err = client_lobby.connect_to_url('ws://' + str(ip) + ':' + str(port))
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
	print ('données reçues (socket lobby)')
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

# Fonction de recu de paquet et connexion au nouveau si c'est une ip qu'il recoit
func _on_data_partie ():
	print ('données reçues (socket partie)')
	var structure = Structure.new()
	var data_bytes = recevoir_message(client_partie)

	var obj = Structure.from_bytes(data_bytes)

	match obj.type:
		Structure.PacketType.CHAT:
			print(obj.data)
		Structure.PacketType.RESULTAT_LANCER_DE:
			print('reçu résultat lancer dé : ' + str(int(obj.data)))
			emit_signal('signal_resultat_lancer_de', int(obj.data))
		_:
			print('autre paquet reçu')

func _process (delta):
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
	#client_lobby.disconnect_from_host(0, "Pas de problème")
	var parts = URL.rsplit(':')
	ip = parts[0]
	port = parts[1]

	print('connexion au serveur de partie')
	var err = client_partie.connect_to_url('ws://' + URL)
	if err != OK:
		print('la connexion au serveur de partie a échoué')
		set_process(false)


func _on_Pion_signal_clic_gauche():
	print('clic gauche détecté, envoi requête dé')
	var structure = Structure.new()
	structure.set_requete_lancer_de()
	envoyer_message(client_partie, structure.to_bytes())
