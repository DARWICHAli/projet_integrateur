extends "Case.gd"

var taille
var pos_pions = [[-48,-46]]
onready var pos = get_node("Pos")
#class_name allerprison


#============== Routines =================
func _ready():
	taille = get_node("Sprite").texture.get_size()
	pass


#============== Signaux =================
func _on_Goto_prison_body_entered(body):
	body.mettre_case(self)


#============== Fonctions =================
