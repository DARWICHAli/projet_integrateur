extends Node2D

class_name Jeu

var dep_cases = 0
var coin = 0 # 0 case dep, 1 prison, 2 park, 3 go_prison
var debut = 0
var cases = []

#============== Routines =================
func _ready():
	for i in range(10):
		cases.append(get_node("Plateau/cases/cote_bas").get_child(i))
		cases[i].setId(i)
	for i in range(10):
		cases.append(get_node("Plateau/cases/cote_gauche").get_child(i))
		cases[10+i].setId(10+i)
	for i in range(10):
		cases.append(get_node("Plateau/cases/cote_haut").get_child(i))
		cases[20+i].setId(20+i)
	for i in range(10):
		cases.append(get_node("Plateau/cases/cote_droit").get_child(i))
		cases[30+i].setId(30+i)


#============== Fonctions ==================
func lancer_de():
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var deplacement = rand.randi_range(1, 6)
	deplacement += rand.randi_range(1, 6)
#	return deplacement
	return 1
