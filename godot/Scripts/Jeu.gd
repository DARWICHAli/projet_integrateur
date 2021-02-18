extends Node2D

class_name Jeu

var dep_cases = 0
var coin = 0 # 0 case dep, 1 prison, 2 park, 3 go_prison
var debut = 0

func lancer_de():
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var deplacement = rand.randi_range(1, 6)
	$nb.text = String(deplacement)
	return deplacement

func move():
	if dep_cases > 0:
		dep_cases-=1

func _ready():
	pass 



