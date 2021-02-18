extends KinematicBody2D
class_name Pion

export (int) var SPEED = 5

var nb_cases = 3 # Par côté
var case_side = 12


var side = 30

#var velocity = Vector2()
var game_size
var x_counter = side
var y_counter = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(387.202,294.449)
	game_size = get_viewport_rect().size # Taille de l'écran,à changer par taille du plateau
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2()
	#print(get_node("..").dep_cases)
	if get_node("..").dep_cases > 0:
		#if Input.is_mouse_button_pressed( 1 ):
#		if ((x_counter == 0) && (y_counter >= 0) && (y_counter < side)):
#			y_counter+=1
#			velocity.y-=1
#		elif ((x_counter >= 0) && (x_counter < side) && (y_counter == side)):
#			x_counter+=1
#			velocity.x+=1
#		elif ((x_counter == side) && (y_counter <= 100) && (y_counter > 0)):
#			y_counter-=1
#			velocity.y+=1
#		elif ((x_counter <= side) && (x_counter > 0) && (y_counter == 0)) :
#			x_counter-=1
#			velocity.x-=1
		if get_node("..").coin == 0:
			velocity.x-=1
		elif get_node("..").coin == 1:
			velocity.y-=1
		elif get_node("..").coin == 2:
			velocity.x+=1
		elif get_node("..").coin == 3:
			velocity.y+=1
		#print(get_node("..").coin)
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
	position += velocity * delta
	position.x=clamp(position.x, 0, game_size.x)
	position.y=clamp(position.y, 0, game_size.y)


func _on_Lancer_pressed():
	get_node("..").dep_cases = get_node("..").lancer_de()
	
