extends TileMap
class_name Plateau

var nb_joueurs
var tour = 0;	#a qui c'est de jouer
var pion = []
var cases = []
var coord #Vector2
var soldeCagnotte


#============== Routines =================
func _init():
	nb_joueurs = 0 #temp
	pass

func _ready():
	pass 

#============== Signaux =================
func _on_Lancer_pressed(): #[TODO] signal
	pion[tour].move(get_node("..").lancer_de());



