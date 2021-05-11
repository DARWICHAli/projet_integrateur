extends Node2D

var dbsocket
var client
signal inscription
signal retour_form
signal exit_on_success
 

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
	var mdp = $"formule/passwd".text
	var conf_mdp = $"formule/passwdconf".text	
	if mdp != conf_mdp:
		$formule/error_mdp.show()
	else:
		emit_signal("inscription")

func _on_retour_pressed():
	emit_signal("retour_form")


func _on_TextureButton_pressed():
	$error.hide()


func _on_retour_success_pressed():
	emit_signal("exit_on_success")

