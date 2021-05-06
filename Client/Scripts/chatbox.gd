extends Node

onready var chat_log = get_node("VBoxContainer/RichTextLabel")
onready var player_tag = get_node("VBoxContainer/HBoxContainer/Label")
onready var input_line = get_node("VBoxContainer/HBoxContainer/LineEdit")

var groups = [
	{'name': 'Joueur1', 'color': '#4cacfe'},
	{'name': 'Joueur2', 'color': '#ff4e4e'},
	{'name': 'Joueur3', 'color': '#30a10d'},
	{'name': 'Joueur4', 'color': '#f7780c'},
	{'name': 'Joueur5', 'color': '#0260b1'},
	{'name': 'Joueur6', 'color': '#bd2525'},
	{'name': 'Joueur7', 'color': '#f2f200'},
	{'name': 'Joueur8', 'color': '#3ce906'},
	{'name': 'JoueurX', 'color': '#ffffff'}
]

var player_index = 0
var user_name = "Player"

#============== Routines =================

func _ready():
#	set_player_name(0)
#	input_line.connect("text_entered", self, "text_entered")
#	connecte des signaux a certaines fonctions
	pass # Replace with function body.

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			input_line.grab_focus()
		if event.pressed and event.scancode == KEY_ESCAPE:
			input_line.release_focus()

#============== Signaux =================

func _on_LineEdit_text_entered(text):
	if text != '':
		send_message(text)
	
	pass # Replace with function body.

#============== Fonctions =================

func send_message(text):
	input_line.text = ''
	get_parent().sig_msg(text, user_name, player_index)

func add_message(text, username, index=8):
	chat_log.bbcode_text += '\n'
	chat_log.bbcode_text += '[color=' + groups[index]['color'] + ']'
	chat_log.bbcode_text += username
	chat_log.bbcode_text += '[/color]'
	print (text[1])
	chat_log.bbcode_text += ': ' + text

func set_player_name(player):
	player_index = player.id
	user_name = player.pseudo
	player_tag.text = '[' + user_name + ']'
	print(player_index)
	player_tag.set('custom_colors/font_color', Color(groups[player_index]['color']))

