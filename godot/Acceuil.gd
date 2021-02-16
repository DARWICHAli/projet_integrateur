extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func init_game():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	init_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartButton_pressed():
	init_game()
	$"Acceuil".hide()


func _on_TextureButton_pressed():
	$"Acceuil".show()
	
