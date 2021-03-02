extends "Case.gd"

onready var taille = get_node("Sprite").texture.get_size()
var pos_pions_continue = [[-35,-35]]
var pos_pions_visite = [[-48,-46]]
onready var visite = get_node("Pos")


#============== Routines =================
func _ready():
#	taille 
	pass 


#============== Signaux =================
func _on_Prison_body_entered(body):
	body.mettre_case(self)
	body.change_direction(0,-1) #desormais on monte en y et ne bouge pas en x
	repositionnement(body)
	print("VOUS ETES EN PRISON HAHAHAHA")


#============== Fonctions =================
func repositionnement(pion):
	var x = position.x + visite.get_child(pion.id).position.x
	var y = position.y + visite.get_child(pion.id).position.y
	pion.change_position(x,y)
	
	
	
	
