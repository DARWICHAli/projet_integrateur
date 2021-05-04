extends Node2D

onready var panel = $ScrollContainer/panelPlayer
signal sig_stats_infos_joueur (player,infobox)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_infobox1_sig_stats(infobox, player):
	emit_signal("sig_stats_infos_joueur",player,infobox)


func _on_infobox2_sig_stats(infobox, player):
	emit_signal("sig_stats_infos_joueur",player,infobox)


func _on_infobox3_sig_stats(infobox, player):
	emit_signal("sig_stats_infos_joueur",player,infobox)


func _on_infobox4_sig_stats(infobox, player):
	emit_signal("sig_stats_infos_joueur",player,infobox)


func _on_infobox5_sig_stats(infobox, player):
	emit_signal("sig_stats_infos_joueur",player,infobox)


func _on_infobox6_sig_stats(infobox, player):
	emit_signal("sig_stats_infos_joueur",player,infobox)


func _on_infobox7_sig_stats(infobox, player):
	emit_signal("sig_stats_infos_joueur",player,infobox)


func _on_infobox8_sig_stats(infobox, player):
	emit_signal("sig_stats_infos_joueur",player,infobox)
