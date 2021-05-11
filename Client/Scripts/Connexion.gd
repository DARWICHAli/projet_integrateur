extends Node2D


signal retour_connexion
signal retour_connexion_succes
signal inscription_conn
signal connection

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_retour_pressed():
	emit_signal("retour_connexion")


func _on_inscription_pressed():
	emit_signal("inscription_conn")


func _on_connexion_pressed():
	emit_signal("connection")


func _on_TextureButton_pressed():
	$error.hide()


func _on_retour_success_pressed():
	$success.hide()
	emit_signal("retour_connexion_succes")



