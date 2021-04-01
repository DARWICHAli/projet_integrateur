extends "Case.gd"

var taille
var pos_pions = [[38,8]] #ajouter d'autres positions en fonction du nombre de joueurs
onready var pos = get_node("Pos")

#============== Routines =================
func _ready():
	get_node("../../../../Pion").mettre_case(self) #faudra faire une boucle
	get_node("../../../../Pion").position = self.get_node("Pos").get_child(0).get_global_position()
	
	#ne compile pas dans la scene seule a besoin du pion
	taille = get_node("Sprite").texture.get_size()
	#on a besoin de le faire dans le _ready sinon le sprite n'est pas encore créé
	

#============== Signaux =================
func _on_Start_body_entered(body):
	body.mettre_case(self)
	#print("RECEVEZ 200 ECTS")


#============== Fonctions =================

