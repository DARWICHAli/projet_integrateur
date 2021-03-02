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
	print(cases)
	for i in range(40):
		print(cases[i].id)





#============== Fonctions ==================
func lancer_de():
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var deplacement = rand.randi_range(1, 6)
	return deplacement

#func move():
#	if dep_cases > 0:
#		print(dep_cases)
#		dep_cases-=1
#		if dep_cases == 0:
#			return false
#		return true
#	return false
	
	
#func _ready():
#	if get_node("Pion").id == 1: #Placer le pion au bon endroit au début du jeu
#		get_node("Pion").position = get_node("Plateau/Start/startPosition1").get_global_position()



