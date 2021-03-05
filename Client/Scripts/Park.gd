extends "Case.gd"

var taille
var pos_pions = [[-48,-46]]
onready var pos = get_node("Pos")

#============== Routines =================
func _ready():
	taille = get_node("Sprite").texture.get_size()
	pass 


#============== Signaux =================
func _on_Parking_body_entered(body):
	body.mettre_case(self)
	var x = pos_pions[0][0] + position[0]
	var y = pos_pions[0][1] + position[1]
#	body.change_position(x,y)
#	body.change_direction(1,0) #desormais on avance en x et ne bouge pas en y
	print("RAFLEZ LA MISE !")

#============== Fonctions =================



