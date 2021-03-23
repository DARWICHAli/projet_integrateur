extends "Case.gd"

onready var taille = get_node("Sprite").texture.get_size()
var pos_pions_continue = [[-35,-35]]
var pos_pions_visite = [[-48,-46]]
onready var visite = get_node("Pos")


#============== Routines =================
func _ready():
	pass 


#============== Signaux =================
func _on_Prison_body_entered(body):
	body.mettre_case(self)


#============== Fonctions =================
