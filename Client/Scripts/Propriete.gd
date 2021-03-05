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
	body.mettre_case(self)


#============== Fonctions =================
func affiche_nom(): 	#Probablement inutile maintenant avec case.name
	print(self.name)
