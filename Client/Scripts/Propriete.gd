extends "Case.gd"

var proprio = null
var prixCase = 100
var loyer = 50
var hypotheque = 25
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
	if (proprio != null && proprio != body):
		var string = "%s est sur la case %s possedee par %s"
		string = string % [body.name, self.name, proprio.name]
		print(string)
		#rente(body)
	elif (proprio == body):
		if(self.upgrade(body) == true ):
			print("Proprieté upgradée")
		else:
			print("Vous ne pouvez pas construire ici")


#============== Fonctions =================
func upgrade(joueur):
	return false
	
func affiche_nom(): 	#Probablement inutile maintenant avec case.name
	print(self.name)

#func acheter(pion):
#	if (proprio != null):
#		print("La propriete est deja possedee par %s" % proprio.name)
#	else :
#		if (! pion.payer(prixCase)):
#			print("Vous n'avez pas assez d'argent pour acheter la case")
#		else :
#			proprio = pion
#			print("achete !")
#
#func rente(pion):
#	if (! pion.payer(prixCase)):
#		print("vous avez perdu")
#	proprio.encaisser(prixCase)
#	var string = "%s encaise la rente sur la case %s de la part de %s"
#	string = string % [proprio.name, self.name, pion.name]
#	print(string)
