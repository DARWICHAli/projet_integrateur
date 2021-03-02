extends "Case.gd"

var proprio = null
var prixCase
var loyer
var hypotheque
var estHypothequee = false

#var nom = "case basique"
onready var pos = get_node("Pos")
# Called when the node enters the scene tree for the first time.


#============== Routines =================
func _ready():
	pass # Replace with function body.


#============== Signaux =================
func _on_case_basique_body_entered(body):
#	print(nom)
	body.mettre_case(self)
	repositionnement(body)


#============== Fonctions =================
func affiche_nom(): 	#Probablement inutile maintenant avec case.name
	print(self.name)

func repositionnement(pion):
	print(pos.get_child(pion.id).position)
	var x = position.x + pos.get_child(pion.id).position.x
	var y = position.y + pos.get_child(pion.id).position.y
#	pion.change_position(x,y)
	pion.position = pos.get_child(pion.id).get_global_position()
