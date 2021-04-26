extends Node2D

signal stats_pressed(player)

func _ready():
	pass # Replace with function body.



func _on_bouton_stats_pressed():
	var nom = $"ScrollContainer/VBoxContainer/infobox1/bouton_stats/HBoxContainer/VBoxContainer/nom_joueur".text
	emit_signal("stats_pressed",nom)
