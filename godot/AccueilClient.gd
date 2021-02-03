extends Node2D

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 5000

func _ready():
	connectToServer()

func connectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeed")

func _on_connection_failed():
	print("Connection failed")

func _on_connection_succeed():
	print("Connection succeed")
