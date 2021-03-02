extends KinematicBody2D
class_name Pion

var id = 0  	#premier joueur
var case = null 	#prendra la node case dessous
var vect_direction = Vector2(-1,0)	#
var step_size = 81
var argent = 0
var dep_cases = 0
var prisonnier = false

#============== Routines =================
func _ready():
	var true_pos = self.id+1
	position = get_node("../Plateau/cases/cote_bas/Start/Pos/Position2D"+str(true_pos)).get_global_position()

func _process(delta):
	if Input.is_action_just_released("ui_button_left"):
		move(3)
	if Input.is_action_just_released("ui_accept"):
		case.affiche_nom() 	 #probablement a changer par case.name

#============== Signaux ================


#============== Fonctions =================
func pos_suivante():
	print((case.id+1)%40)
	print(get_parent().cases[(case.id+1)%40].get_node("Pos").get_child(self.id).get_global_position())
	return get_parent().cases[(case.id+1)%40].get_node("Pos").get_child(self.id).get_global_position()

func move(steps):
#	if (steps <= 0):
#		return
#	dep_cases = steps;
	
#	for i in range(steps):
#		[TODO] deplacements
#		print("hello")
	
	position = pos_suivante()
	
#	position += vect_direction*step_size
	
#	yield(get_tree().create_timer(0.75), "timeout")
	
#	print(case.position)


#============== Setters/Getters =================
func mettre_case(Case):
	case = Case

func change_position(x,y):
	position = Vector2(x,y);

func change_direction(x,y):
	vect_direction = Vector2(x,y)

func change_step_size(steps):
	step_size = steps
