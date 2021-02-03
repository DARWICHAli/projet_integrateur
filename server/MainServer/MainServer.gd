extends Node

var network = NetworkedMultiplayerENet.new()
var port = 5000
var max_player = 2

func _ready():
	startServer()

func startServer():
	network.create_server(port, max_player)
	get_tree().set_network_peer(network)
	print("Serveur démarré")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(playerID):
	print("Player : " + str(playerID) + " connected.")

func _peer_disconnected(playerID):
	print("Player : " + str(playerID) + " disconnected.")
