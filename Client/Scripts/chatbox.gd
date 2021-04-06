extends Node

onready var chat_log = get_node("VBoxContainer/RichTextLabel")
onready var player_tag = get_node("VBoxContainer/HBoxContainer/Label")
onready var input_line = get_node("VBoxContainer/HBoxContainer/LineEdit")

var groups = [
	{'name': 'Joueur1', 'color': '#34c5f1'},
	{'name': 'Joueur2', 'color': '#f1c234'},
	{'name': 'Joueur3', 'color': '#ffffff'},
	{'name': 'Joueur4', 'color': '#34c5f1'},
	{'name': 'Joueur5', 'color': '#f1c234'},
	{'name': 'Joueur6', 'color': '#ffffff'},
	{'name': 'Joueur7', 'color': '#ffffff'},
	{'name': 'Joueur8', 'color': '#ffffff'}
]

var group_index = 0
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
		add_message(text, group_index)
		input_line.text = ''
	
	pass # Replace with function body.

#============== Fonctions =================

func add_message(text, index=0):
	chat_log.bbcode_text += '\n'
	chat_log.bbcode_text += '[color=' + groups[group_index]['color'] + ']'
	chat_log.bbcode_text += user_name
	chat_log.bbcode_text += '[/color]'
	chat_log.bbcode_text += ': ' + text

func set_player_name(player):
	group_index = 0 #player.id
	user_name = player.pseudo
	player_tag.text = '[' + user_name + ']'
	print(group_index)
	player_tag.set('custom_colors/font_color', Color(groups[0]['color']))

