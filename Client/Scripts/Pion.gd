extends KinematicBody2D
class_name Pion

var id = 0  	#premier joueur
var case = null 	#prendra la node case dessous
var vect_direction = Vector2(-1,0)	#
export (int) var SPEED = 400
var argent = 0
var dep_cases = 0
var prisonnier = false
var new_pos

#============== Routines =================
func _ready():
	if name == "Pion":
		self.id=0
		print(self.id)
	elif name == "Pion2":
		self.id=1
		print(self.id)
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
	print("hide "+str(id))
	var true_pos = self.id+1
	position = get_node("../Plateau/cases/cote_bas/Start/Pos/Position2D"+str(true_pos)).get_global_position()

signal signal_clic_gauche

func _process(delta):
	if Input.is_action_just_released("ui_button_left"):
		if (id == 0):
			move(get_node("../Plateau").lancer_de())
	if Input.is_action_just_released("ui_button_right"):
		if (id == 1):
			move(get_node("../..").lancer_de())
	if Input.is_action_just_released("ui_left"):
		if (id == 0):
			case.acheter(self)      #probablement a changer par case.name
	if Input.is_action_just_released("ui_right"):
		if (id == 1):
			case.acheter(self)

#	if Input.is_action_just_released("ui_accept"):
#		case.affiche_nom() 	 #probablement a changer par case.name
	
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


#============== Fonctions =================
func pos_suivante():
	return get_parent().cases[(case.id+1)%40].get_node("Pos").get_child(self.id).get_global_position()

func move(steps):
	dep_cases = steps;
	if (steps <= 0):
		return
	
	new_pos = pos_suivante()


#yield(get_tree().create_timer(0.75), "timeout")

#============== Setters/Getters =================
func mettre_case(Case):
	case = Case


# je ne sais pas pourquoi, mais cette fonction doit prendre un 2ème argument, sinon erreur
func _on_jeu_signal_resultat_lancer_de(resultat : int, debug):
	move(resultat)
