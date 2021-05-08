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
# Semaphore faillite
#var sem_faillite = Semaphore.new()

var key = load("res://unistrapoly_key.key")
var cert = load("res://unistrapoly_certif.crt")

var db # db connection

func _ready():
	#Communication avec la base de données
#	db = SQLite.new();
#	db.path="./database.db"
#	db.verbose_mode = false
#	db.open_db()

#	stats("tthirtle2o")
#	var pseudo = "aaa@bbb.com"
#	print(stats(pseudo))
	
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

#######
#	Fonctions relatives à la base de données
#######
func stats(pseudo):
	var err = db.query("SELECT U.idU FROM UTILISATEUR U WHERE U.username LIKE '"+pseudo+"';") # À faire hors de la fonction
	
	var array = db.select_rows("UTILISATEUR","username  like '"+pseudo+"'", ["nbWin", "nbLose", "dateInscr"])
	var row_dict : Dictionary = {"dateInscr":" ", "nbLose":" ", "nbWin": " ", "bestCase":" ", "lastTrophy":" ","descTrophy":" "}
	if(len(array[0]) > 0):
		var date = array[0].dateInscr
		var win = array[0].nbWin
		var lose = array[0].nbLose

		var array3 = db.select_rows("(SELECT id, nc, max(nb_ac) FROM (SELECT AC.idU AS id, AC.nomCase AS nc, (SELECT count(AC2.nomCase) FROM ACHETE_CASE AC2 WHERE AC2.nomCase LIKE AC.nomCase AND AC2.idU = AC.idU) AS nb_ac FROM ACHETE_CASE AC WHERE AC.idU = id GROUP BY AC.nomCase))","",["nc"])
		
		if(len(array3[0]) > 0):
			var nc = array3[0].nc
			
			var last_trophy = last_trophy(pseudo)
			
			row_dict = {"dateInscr":date, "nbLose":lose, "nbWin": win, "bestCase":case_fav(pseudo), "lastTrophy":last_trophy[0],"descTrophy":last_trophy[1]}
				
	return row_dict.duplicate()

func case_fav(pseudo):
	var result = "Aucune"
	var idU = db.select_rows("UTILISATEUR U","username  like '"+pseudo+"'", ["idU"])
	if(len(idU) > 0):
		var id = idU[0].idU
		var best = db.select_rows("(SELECT AC.idU, AC.nomCase AS propriete, count(*) AS NB_ACHAT FROM ACHETE_CASE AC WHERE AC.idU = "+str(idU)+" GROUP BY AC.nomCase)","",["propriete,max(NB_ACHAT)"])
		if(len(best) > 0):
			result = best[0].propriete
	return result
	
func last_trophy(pseudo):
	var id =  db.select_rows("UTILISATEUR U","username  like '"+pseudo+"'", ["idU"])
	var name ="Aucun"
	var descr = "Aucune"
	if(len(id)>0):
		var idU = id[0].idU
		var last_trophy = db.select_rows("TROPHEE_JOUEUR TJ","TJ.idU = "+str(idU),["min(TJ.dateT) AS date","idT"])
		if(len(last_trophy) > 0):
			var date = last_trophy[0].date
			var idT  = last_trophy[0].idT
		
			var trophy = db.select_rows("TROPHEE T","T.idT = "+str(idT),["nomT","descrT"])
			if(len(trophy)>0):
				name=trophy[0].nomT
				descr=trophy[0].descrT
			
	return [name, descr]
	
func passages_prison(pseudo):
	var id = db.select_rows("UTILISATEUR U","U.username = "+pseudo,["idU"])
	var count = db.select_rows("(SELECT count(*) as passages FROM PASSAGE_PRISON PP WHERE PP.idU = "+str(id[0].idU)+")","",["passages"])
	if(count[0].passages == 100):
		var err = db.query("INSERT INTO TROPHEE_JOUEUR VALUES("+str(id)+",1);")
		
		
func passages_park(pseudo):
	var id = db.select_rows("UTILISATEUR U","U.username = "+pseudo,["idU"])
	var count = db.select_rows("(SELECT count(*) as passages FROM PASSAGE_PARK PP WHERE PP.idU = "+str(id[0].idU)+")","",["passages"])
	if(count[0].passages == 100):
		var err = db.query("INSERT INTO TROPHEE_JOUEUR VALUES("+str(id)+",2);")

func pas_le_temps_de_niaiser(pseudo):
	var id = db.select_rows("UTILISATEUR U","U.username = "+pseudo,["idU"])
	var is_trophy = db.select_rows("TROPHEE_JOUEUR TJ","TJ.idT=6 AND TJ.idU="+str(id[0].idu),["idU"])
	if(len(is_trophy) == 0):
		var err = db.query("INSERT INTO TROPHEE_JOUEUR VALUES("+str(id)+",6);")


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
				structure.set_adresse_serveur_jeu(ip, serveurs_partie.back().port, serveurs_partie.back().nb_joueurs, 0)
				envoyer_message(serveur_lobby, structure.to_bytes(), id_client)
			else:
				var id_serveur_partie = trouver_partie(obj.data)
				var temp = serveurs_partie[id_serveur_partie].list_joueurs.size()
				print("Le client %d rejoint une partie" % temp)
				structure.set_adresse_serveur_jeu(ip, serveurs_partie[id_serveur_partie].port, serveurs_partie[id_serveur_partie].nb_joueurs, serveurs_partie[id_serveur_partie].list_joueurs.size())
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
				
				db.query("UPDATE UTILISATEUR U SET lastCo = CURRENT_TIMESTAMP WHERE U.username like "+array[0].username)
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
	serveur_jeu.socket.set_refuse_new_connections(true)
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
		serveur_jeu.pseudos.append("")
		print('un id de joueur est ajouté ')
	#fonctionne pas ou pas tout le temps ? manque probablement une valeur (IP chaine de char ?)
	print("SERVEUR PARTIE : client connecté avec IP depuis %s:%d" % [client_IP, client_port])

func _close_request_jeu (id, code, reason):
	print("SERVEUR PARTIE : Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])
	
func _disconnected_jeu (id, was_clean = false, serveur_jeu = null):
	if(serveur_jeu.list_joueurs.find(id) == -1):
		return
	supprimer_joueur(id, serveur_jeu)
	print("SERVEUR PARTIE : Client %d disconnected, clean: %s" % [id, str(was_clean)])
	if serveur_jeu.list_joueurs.size() == 0:
		emit_signal("fin_partie", serveur_jeu.code)


func everybody_is_here(serveur_partie):
	var retour = true
	for i in range(0,serveur_partie.nb_joueurs):
		if serveur_partie.pseudos[i]=="":
			return false
	return true
	
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
		Structure.PacketType.SEND_PSEUDO:
			var indice = serveur_jeu.list_joueurs.find(id_client)
			serveur_jeu.pseudos[indice] = obj.data
			if everybody_is_here(serveur_jeu) == true:
				for i in range (0, len(serveur_jeu.pseudos)):
					print("un pseudo :" + serveur_jeu.pseudos[i])
					structure.set_requete_bcast_pseudos(serveur_jeu.pseudos)
					for client in serveur_jeu.list_joueurs:
						envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
#			print("PSEUDO : " + str(obj.data))
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
			#if (serveur_jeu.attente_joueur == serveur_jeu.list_joueurs.find(id_client) and serveur_jeu.packet_attendu == Structure.PacketType.ACTION):
			print('requête construction')
			construction_res(serveur_jeu.list_joueurs.find(id_client), obj.data, serveur_jeu)
			#serveur_jeu.reponse_joueur = true
		Structure.PacketType.VENTE: #####
			#if (serveur_jeu.attente_joueur == serveur_jeu.list_joueurs.find(id_client) and serveur_jeu.packet_attendu == Structure.PacketType.ACTION):
			print('requête vente')
			vente_res(serveur_jeu.list_joueurs.find(id_client), obj.data, serveur_jeu)
			#serveur_jeu.reponse_joueur = true
		Structure.PacketType.STATS_CONSULT:
			print("Demande de stats")
			var stats = stats(obj.data)
			if(stats == null):
				stats 	= {"dateInscr":"Aucune ", "nbLose":0, "nbWin": 0, "bestCase":"Aucune ", "lastTrophy":"Aucun","descTrophy":"Aucune"}
			print(stats)
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
		Structure.PacketType.DESTRUCTION:
			print("requête reclamer reçue")
			destruction_res(serveur_jeu.list_joueurs.find(id_client), obj.data, serveur_jeu)
		Structure.PacketType.CARTE_SORTIE_PRISON:
			print("requête carte sortie prison reçue")
#			if (serveur_jeu.attente_joueur == serveur_jeu.list_joueurs.find(id_client)):
			carte_sortie_prison(serveur_jeu.list_joueurs.find(id_client), serveur_jeu)
		Structure.PacketType.TOUR_PLUS_UN:
			print('requete tour_plus_un reçue')
			if(serveur_jeu.attente_joueur == serveur_jeu.list_joueurs.find(id_client)):
				tourplusun_res(serveur_jeu.list_joueurs.find(id_client), serveur_jeu)
		Structure.PacketType.ABANDONNER:
			supprimer_joueur(id_client, serveur_jeu)
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
		if(serveur_jeu.list_joueurs.size() == 1):
			break
		while double:
			print("\n\n")
			print("AU TOUR DU JOUEUR %d !" % [serveur_jeu.attente_joueur])
			structure.set_requete_maj_tour(serveur_jeu.attente_joueur)
			for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
				envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
			
			print("ETAT JOUEUR PRISON : " + str(serveur_jeu.joueur_prison[serveur_jeu.attente_joueur]))
			
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
				serveur_jeu.pos_prison(serveur_jeu.attente_joueur)
				print("POS : " + str(serveur_jeu.plateau[serveur_jeu.position_joueur[serveur_jeu.attente_joueur]].indice))
				print("DE NUMERO 1: %d pour joueur %d" % [de_un, serveur_jeu.attente_joueur])
				print("DE NUMERO 2: %d" % [de_deux])
				if(de_un != de_deux and serveur_jeu.nbr_essai_double[serveur_jeu.attente_joueur] < 3):
					print("TOUJOURS PAS SORTI !")
					serveur_jeu.nbr_essai_double[serveur_jeu.attente_joueur]+=1
					joueur = serveur_jeu.attente_joueur
					serveur_jeu.next_player()
					continue
				elif(de_un == de_deux):
					serveur_jeu.joueur_prison[serveur_jeu.attente_joueur] = 0
					structure.set_requete_free_out_prison(serveur_jeu.attente_joueur, 0)
					for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
						envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				elif(serveur_jeu.nbr_essai_double[serveur_jeu.attente_joueur] == 3):
					serveur_jeu.joueur_prison[serveur_jeu.attente_joueur] = 0
					serveur_jeu.payer_prison(serveur_jeu.attente_joueur)
					structure.set_requete_out_prison(serveur_jeu.attente_joueur, serveur_jeu.prix_prison)
					for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
						envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
					action_faillite(serveur_jeu.attente_joueur, -1, serveur_jeu)
					
			if(goto_prison != 1):
				serveur_jeu.deplacer_joueur(serveur_jeu.attente_joueur, res)
				structure.set_resultat_lancer_de(de_un, de_deux, serveur_jeu.attente_joueur)
				for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
					envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				print(serveur_jeu.attente_joueur)
					
			timer_reclamation = get_tree().create_timer(10.0)
			serveur_jeu.reponse_proprio = false
			serveur_jeu.proprio_a_reclamer = false
			
			current_case = serveur_jeu.plateau[serveur_jeu.position_joueur[serveur_jeu.attente_joueur]]
			# RAFRAICHISSEMENT DE CURRENT_CASE
			
			if(current_case.indice == 20):
				passages_park(serveur_jeu.pseudos[serveur_jeu.attente_joueur])
				

			
			print("------------------")
			print(current_case.indice)
			print(current_case.type)
			print(current_case.sous_type)
			print("------------------")
			
			if(current_case.type == Cases.CasesTypes.COMM or current_case.type == Cases.CasesTypes.CHANCE):
				var status
				if(current_case.type == Cases.CasesTypes.COMM):
					status = serveur_jeu.tirer_carte(serveur_jeu.attente_joueur, 0, de_un*de_deux)
					if (status == -1):
						goto_prison = 1
				else:
					status = serveur_jeu.tirer_carte(serveur_jeu.attente_joueur, 1, de_un*de_deux)
				structure.set_requete_tirer_carte(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, serveur_jeu.temp_carte, status)
				for client in serveur_jeu.list_joueurs:
					envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				action_faillite(serveur_jeu.attente_joueur, -1, serveur_jeu)
				
				current_case = serveur_jeu.plateau[serveur_jeu.position_joueur[serveur_jeu.attente_joueur]]
				
			if(current_case.type == Cases.CasesTypes.TAXE):
				serveur_jeu.taxe(serveur_jeu.attente_joueur)
				structure.set_requete_taxe(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur)
				for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
					envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				action_faillite(serveur_jeu.attente_joueur, -1, serveur_jeu)
				
				current_case = serveur_jeu.plateau[serveur_jeu.position_joueur[serveur_jeu.attente_joueur]]
				
			# ALLER EN PRISON POUR TRIPLE DOUBLE OU CARTE ALLER PRISON
			if(goto_prison == 1):
				passages_prison(serveur_jeu.pseudos[joueur])
				serveur_jeu.pos_prison(serveur_jeu.attente_joueur)
				serveur_jeu.joueur_prison[serveur_jeu.attente_joueur] = 1
				structure.set_requete_go_prison(serveur_jeu.attente_joueur)
				for client in serveur_jeu.list_joueurs:
					envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				serveur_jeu.reponse_joueur = false
				nb_double = 0
				goto_prison = 0
				joueur = serveur_jeu.attente_joueur
				serveur_jeu.next_player()
				continue
				
				current_case = serveur_jeu.plateau[serveur_jeu.position_joueur[serveur_jeu.attente_joueur]]
				
			# ALLER EN PRISON POUR CASE GO_PRISON
			if(current_case.type == Cases.CasesTypes.ALLER_PRISON):
				print("testttttt")
				passages_prison(serveur_jeu.pseudos[joueur])
				serveur_jeu.pos_prison(serveur_jeu.attente_joueur)
				print("POS : " + str(serveur_jeu.plateau[serveur_jeu.position_joueur[serveur_jeu.attente_joueur]].indice))
				serveur_jeu.reponse_joueur = false
				serveur_jeu.packet_attendu = Structure.PacketType.FIN_DEP_GO_PRISON
				while(serveur_jeu.packet_recu != Structure.PacketType.FIN_DEP_GO_PRISON):
					serveur_jeu.socket.poll()
				serveur_jeu.joueur_prison[serveur_jeu.attente_joueur] = 1
				structure.set_requete_go_prison(serveur_jeu.attente_joueur)
				for client in serveur_jeu.list_joueurs:
					envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
				serveur_jeu.reponse_joueur = false
				nb_double = 0
				goto_prison = 0
				joueur = serveur_jeu.attente_joueur
				serveur_jeu.next_player()
				continue
				
				current_case = serveur_jeu.plateau[serveur_jeu.position_joueur[serveur_jeu.attente_joueur]]
				
			print("Attente d'action quelconque ou fin de tour...")
				
			print(current_case.proprio)
			serveur_jeu.reponse_joueur = false
			serveur_jeu.packet_attendu = Structure.PacketType.ACTION
			var status
			serveur_jeu.attente_proprio = current_case.proprio
			timer = get_tree().create_timer(15.0)
				
			while serveur_jeu.packet_recu != Structure.PacketType.FIN_DE_TOUR and timer.get_time_left() > 0:
				serveur_jeu.socket.poll()
				if serveur_jeu.reponse_joueur == true and serveur_jeu.packet_recu == Structure.PacketType.ACHAT:
					status = serveur_jeu.acheter(serveur_jeu.attente_joueur)
					if(status == 0):
						structure.set_requete_maj_achat(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, serveur_jeu.position_joueur[serveur_jeu.attente_joueur], current_case.prix)
						for client in serveur_jeu.list_joueurs:
							envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
						
						# Maj de l'achat de la case dans la BDD
#						var indice = serveur_jeu.position_joueur[serveur_jeu.attente_joueur]
#						var pseudo = serveur_jeu.pseudos[joueur]
#						var id = db.select_rows("UTILISATEUR U","U.username ='"+pseudo+"'",["idU"])
#						var idU = id[0].idU
#						var nomCase = db.select_rows("PROPRIETE P","P.idC ="+str(indice),["nomCase"])
#						var nom_case = nomCase[0].nomCase
#						db.query("INSERT INTO ACHETE_CASE (idU,nomCase) VALUES('"+str(idU)+"','"+nom_case+"');")
					else:
						structure.set_requete_erreur(status)
						envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])							
					serveur_jeu.reponse_joueur = false
				if serveur_jeu.reponse_proprio == true and serveur_jeu.packet_recu == Structure.PacketType.RECLAMER:
					if (timer_reclamation.get_time_left() > 0):
						if (!serveur_jeu.proprio_a_reclamer):
							serveur_jeu.proprio_a_reclamer = true
							status = serveur_jeu.rente(current_case, serveur_jeu.attente_joueur, res)
							if(status == 0):
								structure.set_requete_rente(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, current_case.proprio, current_case.loyer[current_case.niveau_case])
								for client in serveur_jeu.list_joueurs:
									envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
								action_faillite(serveur_jeu.attente_joueur, current_case.proprio, serveur_jeu)
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
							structure.set_requete_rente(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur], serveur_jeu.attente_joueur, current_case.proprio, current_case.loyer[current_case.niveau_case])
							for client in serveur_jeu.list_joueurs:
								envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
							action_faillite(serveur_jeu.attente_joueur, current_case.proprio, serveur_jeu)
						else:
							structure.set_requete_erreur(status)
							envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])
			print("Test de propiete : %d" % serveur_jeu.plateau[0].proprio)
			print("Solde du joueur %d (en cours de jeu) : %d ECTS" % [serveur_jeu.attente_joueur, serveur_jeu.argent_joueur[serveur_jeu.attente_joueur]])
			
			# Passage au prochain joueur
			if(double == 0):
				 #Fin de partie d'un joueur -> maj de sa statistique de défaites et d'argent perdu
				if(serveur_jeu.argent_joueur[serveur_jeu.attente_joueur] <= 0):
					var pseudo    = serveur_jeu.pseudos[joueur]
					var nbLoses   = db.select_rows("UTILISATEUR U","U.username ='"+pseudo+"'",["nbLose"])
					var error     = db.query("UPDATE UTILISATEUR SET nbLose='"+str(nbLoses[0].nbLose+1)+"' WHERE username like '"+pseudo+"';")
					var moneyLose = db.select_rows("UTILISATEUR U","U.username ='"+pseudo+"'",["moneyLose"])
					error     = db.query("UPDATE UTILISATEUR SET moneyLose='"+str(moneyLose[0].moneyLose + 10000)+"' WHERE username = '"+pseudo+"';")
				
				nb_double = 0
				goto_prison = 0
				joueur = serveur_jeu.attente_joueur
				serveur_jeu.next_player()
			
	print("Player %d win" % joueur)
	structure.set_requete_gagne()
	envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])
	# Maj de la statistique de victoires du joueur
	var pseudo = serveur_jeu.pseudos[joueur]
	var nbWins = db.select_rows("UTILISATEUR U","U.username ='"+pseudo+"'",["nbWin"])
	db.query("UPDATE UTILISATEUR SET nbWin='"+str(nbWins[0].nbWin+1)+"' WHERE username like '"+pseudo+"';")
	var moneyWin = db.select_rows("UTILISATEUR U","U.username ='"+pseudo+"'",["moneyWin"])
	var error     = db.query("UPDATE UTILISATEUR SET moneyWin='"+str(moneyWin[0].moneyWin + serveur_jeu.argent_joueur[joueur])+"' WHERE username = '"+pseudo+"';")
					
	emit_signal("fin_partie", serveur_jeu.code)

func vente_res(id, id_case, serveur_jeu):
	var case = serveur_jeu.plateau[id_case]
	var structure = Structure.new()
	var status = serveur_jeu.vendre(id, case)
	if(status == 0):
		structure.set_requete_maj_vente(serveur_jeu.argent_joueur[id], id, case.indice, serveur_jeu.ventes[id])
		for client in serveur_jeu.list_joueurs:
			envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
	else:
		structure.set_requete_erreur(status)
		envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])

func hypotheque_res(id, id_case, serveur_jeu):
	var case = serveur_jeu.plateau[id_case]
	var structure = Structure.new()
	var status = serveur_jeu.hypothequer(id, case)
	print(status)
	print(id_case)
	if(status <= 0):
		var price
		if (status == -1):
			price = 1.1*case.prix
		else:
			price = 0.9*case.prix
		structure.set_requete_maj_hypotheque(serveur_jeu.argent_joueur[id], id, case.indice, price, status)
		for client in serveur_jeu.list_joueurs:
			envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
	else:
		structure.set_requete_erreur(status)
		envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])

func tourplusun_res(id, serveur_jeu):
	serveur_jeu.salaire_nouv_tour(id)
	var structure = Structure.new()
	print(serveur_jeu.argent_joueur[id])
	structure.set_requete_argent_nouv_tour(serveur_jeu.argent_joueur[id], id)
	for client in serveur_jeu.list_joueurs:
		envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)

func construction_res(id, id_case, serveur_jeu):
	var case = serveur_jeu.plateau[id_case]
	var structure = Structure.new()
	var status = serveur_jeu.upgrade(id, case)
	if(status < 0):
		var price
		if(status == -1):
			price = case.prix_maison
		else:
			price = case.prix_hotel
		structure.set_requete_maj_construire(status, serveur_jeu.argent_joueur[id], id, case.indice, price)
		for client in serveur_jeu.list_joueurs:
			envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)
	else:
		structure.set_requete_erreur(status)
		envoyer_message(serveur_jeu.socket, structure.to_bytes(), serveur_jeu.list_joueurs[serveur_jeu.attente_joueur])

func destruction_res(id, id_case, serveur_jeu):
	var case = serveur_jeu.plateau[id_case]
	var structure = Structure.new()
	var status = serveur_jeu.downgrade(id, case)
	if(status < 0):
		var price
		if (status == -1):
			price = 0.5*case.prix_maison
		else:
			price = 0.5*case.prix_hotel
		structure.set_requete_maj_destruction(serveur_jeu.argent_joueur[id], id, case.indice, price, status)
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
	serveur_jeu.remise_a_zero(serveur_jeu.list_joueurs.find(id))
	structure.set_requete_cache_joueur(serveur_jeu.list_joueurs.find(id))
	serveur_jeu.list_joueurs.erase(id)
	for client in serveur_jeu.list_joueurs: # Broadcast sur tous les joueurs
		envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)

func carte_sortie_prison(id, serveur_jeu):
	print("Possession carte : " + str(serveur_jeu.sortie_prison[id]) + " joueur en prison ? " + str(serveur_jeu.joueur_prison[id]))
	if(serveur_jeu.sortie_prison[id] == 1 and serveur_jeu.joueur_prison[id] == 1):
		var structure = Structure.new()
		serveur_jeu.joueur_prison[id] = 0
		structure.set_requete_free_out_prison(id, 1)
		for client in serveur_jeu.list_joueurs: # Brodacast sur tous les joueurs
			envoyer_message(serveur_jeu.socket, structure.to_bytes(), client)

func action_faillite(id, cause, serveur_jeu):
	if serveur_jeu.argent_joueur[id] < 0 and serveur_jeu.warning[id] == 0:
		serveur_jeu.warning[id] = 1
		var structure = Structure.new()
		var list_prop = []
		if cause != -1:
			list_prop = serveur_jeu.leguer(id, cause)
		structure.set_requete_perdre(id, cause, list_prop)
		for iter_client in serveur_jeu.list_joueurs:
			envoyer_message(serveur_jeu.socket, structure.to_bytes(), iter_client)
		supprimer_joueur(serveur_jeu.list_joueurs[id], serveur_jeu)
