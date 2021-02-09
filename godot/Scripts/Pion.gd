extends KinematicBody2D

export (int) var SPEED
var velocity = Vector2()
var game_size

# Called when the node enters the scene tree for the first time.
func _ready():
	game_size = get_viewport_rect().size # Taille de l'écran,à changer par taille du plateau

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x+=1
	if Input.is_action_pressed("ui_left"):
		velocity.x-=1
	if Input.is_action_pressed("ui_up"):
		velocity.y-=1
	if Input.is_action_pressed("ui_down"):
		velocity.y+=1
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
	position += velocity * delta
	position.x=clamp(position.x, 0, game_size.x)
	position.y=clamp(position.y, 0, game_size.y)
