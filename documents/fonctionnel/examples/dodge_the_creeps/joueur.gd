extends Area2D

signal hit

export (int) var SPEED
var velocity = Vector2()
var screenSize

# Called when the node enters the scene tree for the first time.
func _ready():
	screenSize = get_viewport_rect().size

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
		$AnimatedSprite.play()
		velocity = velocity.normalized() * SPEED
	else:
			$AnimatedSprite.stop()
	position += velocity * delta
	position.x=clamp(position.x, 0, screenSize.x)
	position.y=clamp(position.y, 0, screenSize.y)
	
	if velocity.x != 0:
		$AnimatedSprite.animation = "droite"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "haut"
		$AnimatedSprite.flip_v = velocity.y > 0



func _on_joueur_body_entered(body):
	hide()
	emit_signal("hit")
	call_deferred("set_monitoring",false)
	
func start(pos):
	position=pos
	show()
	monitoring=true
