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
	print("RAFLEZ LA MISE !")


#============== Fonctions =================



