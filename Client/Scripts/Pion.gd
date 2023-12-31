extends KinematicBody2D
class_name Pion

var id = 0  	#premier joueur
var case = null 	#prendra la node case dessous
var vect_direction = Vector2(-1,0)	#
export (int) var SPEED = 400
var argent = [0,0,0,0,0,0,0,0]
var dep_cases = 0
var prisonnier = false
var new_pos
var pseudo = ""
var present = 1
var pos_pion = 0
var prop

onready var chat = get_node("../chatbox")

#============== Routines =================
func _ready():
	if name == "Pion":
		self.id=0
	elif name == "Pion2":
		self.id=1
	elif name == "Pion3":
		self.id=2
	elif name == "Pion4":
		self.id=3
	elif name == "Pion5":
		self.id=4
	elif name == "Pion6":
		self.id=5
	elif name == "Pion7":
		self.id=6
	elif name == "Pion8":
		self.id=7
	self.hide()
	var true_pos = self.id+1
	position = get_node("../Plateau/cases/cote_gauche/Start/Pos/Position2D"+str(true_pos)).get_global_position()
	
	chat.set_player_name(self)
#signal signal_clic_gauche

func _process(delta):
#	if Input.is_action_just_released("ui_button_left"):
#		if (id == 0):
#			emit_signal('signal_clic_gauche')
#	if Input.is_action_just_released("ui_button_right"):
#		if (id == 1):
#			emit_signal('signal_clic_gauche')
#	if Input.is_action_just_released("ui_left"):
#		if (id == 0):
#			case.acheter(self)      #probablement a changer par case.name
#	if Input.is_action_just_released("ui_right"):
#		if (id == 1):
#			case.acheter(self)
	
	if (dep_cases != 0):
		var velocity = Vector2(0,0)
		var cur_pos = self.get_global_position()
		
		#2*delta*SPEED c'est l'erreur sur la position acceptee
		if (cur_pos.x > new_pos.x+2*delta*SPEED):
			velocity.x = -1
		elif (cur_pos.x < new_pos.x-2*delta*SPEED):
			velocity.x = 1
		if (cur_pos.y > new_pos.y+2*delta*SPEED):
			velocity.y = -1
		elif (cur_pos.y < new_pos.y-2*delta*SPEED):
			velocity.y = 1
		
		position += velocity*delta*SPEED
		if ((abs(cur_pos.x-new_pos.x) < 2*delta*SPEED) && (abs(cur_pos.y-new_pos.y) < 2*delta*SPEED)):
			move(dep_cases-1)	#on change la position2D target
	
	
#============== Signaux ================

func _on_jeu_signal_resultat_lancer_de(resultat : int):
	move(resultat)
func _on_jeu_signal_resultat_lancer_de2(resultat : int):
	move(resultat)
func _on_jeu_signal_resultat_lancer_de3(resultat : int):
	move(resultat)
func _on_jeu_signal_resultat_lancer_de4(resultat : int):
	move(resultat)
func _on_jeu_signal_resultat_lancer_de5(resultat : int):
	move(resultat)
func _on_jeu_signal_resultat_lancer_de6(resultat : int):
	move(resultat)
func _on_jeu_signal_resultat_lancer_de7(resultat : int):
	move(resultat)
func _on_jeu_signal_resultat_lancer_de8(resultat : int):
	move(resultat)

#============== Fonctions =================
func pos_suivante():
	return get_parent().cases[(case.id+1)%40].get_node("Pos").get_child(self.id).get_global_position()

func goto_pos_prison():
	var pos_prison = get_parent().get_node("Plateau/cases/cote_haut/Prison/Pos_prison").get_child(self.id).get_global_position()
	position = pos_prison
	pos_pion = 10

func move(steps):
	self.dep_cases = steps;
	if (steps <= 0):
		return
	
	new_pos = pos_suivante()

#func payer(prix):
#	argent -= prix
##yield(get_tree().create_timer(0.75), "timeout")

#============== Setters/Getters =================
func mettre_case(Case):
	case = Case

#func encaisser(Argent):
#	argent += Argent
	

