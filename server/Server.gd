extends Node

const port = 5000
const ip = "127.0.0.1"

# Our WebSocketServer instance
var _server = WebSocketServer.new()
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
	_server.connect("client_connected", self, "_connected")
	_server.connect("client_disconnected", self, "_disconnected")
	_server.connect("client_close_request", self, "_close_request")
	# This signal is emitted when not using the Multiplayer API every time a
	# full packet is received.
	# Alternatively, you could check get_peer(PEER_ID).get_available_packets()
	# in a loop for each connected peer.
	_server.connect("data_received", self, "_on_data")
	# Start listening on the given port.
	var err = _server.listen(port)
	if err != OK:
		print("Unable to start server")
		set_process(false)
	else:
		print("Server startd with port : " + String(port))
	rng.randomize()

func _connected(id, proto):
	# This is called when a new peer connects, "id" will be the assigned peer id,
	print("Client %d connected" % id)

func _close_request(id, code, reason):
	# This is called when a client notifies that it wishes to close the connection,
	# providing a reason string and close code.
	print("Client %d disconnecting with code: %d with reason : %s" % [id, code, reason])

func _disconnected(id, was_clean = false):
	# This is called when a client disconnects, "id" will be the one of the
	# disconnecting client, "was_clean" will tell you if the disconnection
	# was correctly notified by the remote peer before closing the socket.
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])

# Lancement d'un nouveau thread, puis envoie du nouveau ip et port
func _on_data(id):
	# Print the received packet, you MUST always use get_peer(id).get_packet to receive data,
	# and not get_packet directly when not using the MultiplayerAPI.
	var pkt = _server.get_peer(id).get_packet()
	print("Got data from client %d: %s " % [id, pkt.get_string_from_utf8()])
	threads.append(Thread.new())
	threads.back().start(self, "thread_function", [id, pkt])
	sem.wait()
	pkt = ip + ":" + String(portThread.back())
	_server.get_peer(id).put_packet(pkt.to_utf8())

func _process(delta):
	# Call this in _process or _physics_process.
	# Data transfer, and signals emission will only happen when calling this function.
	_server.poll()

# Fonction d'intialisaion des threads
func thread_function(args):
	var my_server = WebSocketServer.new()
	my_server.connect("client_connected", self, "_connected")
	my_server.connect("client_disconnected", self, "_disconnected")
	my_server.connect("client_close_request", self, "_close_request")
	my_server.connect("data_received", self, "_on_data")
	var client = args[0]
	var demande = args[1]
	var find = false
	var myPort
	while !find:
		myPort = rng.randi_range(5001, 65353)
		while portThread.has(myPort):
			myPort = rng.randi_range(5001, 65353)
		var err = my_server.listen(myPort)
		if err != OK:
			print("Unable to start server")
			set_process(false)
		else:
			print("Server startd with port : " + String(myPort))
			portThread.append(myPort)
			find = true
	sem.post()
