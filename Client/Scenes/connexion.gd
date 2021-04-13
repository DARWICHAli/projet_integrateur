extends Node2D


signal retour_connexion
signal inscription_conn


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_retour_pressed():
	emit_signal("retour_connexion");


func _on_inscription_pressed():
	emit_signal("inscription_conn")
