extends TileMap
class_name Plateau

#var nb_joueurs
var tour = 0 	#a qui c'est de jouer
var pion = []
var cases = []
var coord 
var soldeCagnotte


#============== Routines =================
func _init():
	pass

func _ready():
	pass 

#============== Signaux =================
#deprecated
func _on_Lancer_pressed(): #[TODO] signal
	pion[tour].move(get_node("..").lancer_de());



