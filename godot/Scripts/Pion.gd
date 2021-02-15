extends KinematicBody2D

export (int) var SPEED = 10

var nb_cases  = 3 # Par côté
var case_side = 12

var side = 12

var velocity = Vector2()
var game_size
var x_counter = side
var y_counter = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(180,230)
	game_size = get_viewport_rect().size # Taille de l'écran,à changer par taille du plateau


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector2()
	if Input.is_mouse_button_pressed( 1 ):
		if ((x_counter == 0) && (y_counter >= 0) && (y_counter < side)):
			y_counter+=1
			velocity.y-=1
		elif ((x_counter >= 0) && (x_counter < side) && (y_counter == side)):
			x_counter+=1
			velocity.x+=1
		elif ((x_counter == side) && (y_counter <= 100) && (y_counter > 0)):
			y_counter-=1
			velocity.y+=1
		elif ((x_counter <= side) && (x_counter > 0) && (y_counter == 0)) :
			x_counter-=1
			velocity.x-=1
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
	position += velocity * delta
	position.x=clamp(position.x, 0, game_size.x)
	position.y=clamp(position.y, 0, game_size.y)

func lancer_de():
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var deplacement = rand.randi_range(1, 6)
	return deplacement
