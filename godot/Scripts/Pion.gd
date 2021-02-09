extends KinematicBody2D

export (int) var SPEED
var side = 50
var velocity = Vector2()
var game_size
var x_counter = 0
var y_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var initialPosition = Vector2(150,150)
	position = initialPosition
	game_size = get_viewport_rect().size # Taille de l'écran,à changer par taille du plateau

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector2()
	if Input.is_mouse_button_pressed( 1 ): # Clic gauche
		if ((x_counter == 0) && (y_counter >= 0) && (y_counter < side)):
			y_counter+=1
			velocity.y+=1
		elif ((x_counter >= 0) && (x_counter < side) && (y_counter == side)):
			x_counter+=1
			velocity.x+=1
		elif ((x_counter == side) && (y_counter <= 100) && (y_counter > 0)):
			y_counter-=1
			velocity.y-=1
		elif ((x_counter <= side) && (x_counter > 0) && (y_counter == 0)) :
			x_counter-=1
			velocity.x-=1
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
	position += velocity * delta
	position.x=clamp(position.x, 0, game_size.x)
	position.y=clamp(position.y, 0, game_size.y)
