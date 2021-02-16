extends Node2D

class_name Jeu

var dep_cases = 5
var coin = 0 # 0 case dep, 1 prison, 2 park, 3 go_prison

func move():
	if dep_cases > 0:
		dep_cases-=1

func _ready():
	pass 
