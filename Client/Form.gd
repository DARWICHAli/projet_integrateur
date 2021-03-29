extends Node2D

var dbsocket
var client
var websocket_url
func _ready():
	var websocket_url = "ws://localhost:1234"
	client = WebSocketClient.new()
	var err =client.connect_to_url(websocket_url)
	var countries = json_parse("countries.json")
	var i = 1;
	while(i <= 241):
		$"formule/choix pays".add_item(countries[i].name,i)
		i += 1;
	
	
	

func json_parse(filename):
	var file = File.new()
	file.open(filename,File.READ)
	var text = file.get_as_text()
	var data = parse_json(text)
	file.close()
	return data
	

	
func _on_confirm_pressed():
	var file = File.new()
	var username = $formule/username.text
	var mdp = $formule/passwd
	var conf_mdp = $formule/confirm
	var mail = $formule/confirm
	var pays = $"formule/choix pays".text
	if mdp != conf_mdp:
		$formule/error_mdp.show()
	var query = "insert into UTILISATEUR (email,username, password, pays) values ('" + str(mail) +"','"+str(username)+"','"+str(mdp)+"','"+str(pays)+"');"
	var err_2 = client.put_packet(query.to_utf8())
	print(err_2)
	print("envoyé")
	file.open("bdd.json", File.WRITE)
	
