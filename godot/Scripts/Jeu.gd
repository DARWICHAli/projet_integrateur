extends Node2D

class_name Jeu
export (PackedScene) var Pion

func _ready():
	var pion = Pion.instance()
	add_child(pion)
	pass 
