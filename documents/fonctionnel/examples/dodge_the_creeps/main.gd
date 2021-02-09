extends Node

export (PackedScene) var ennemi
var score

func _ready():
	randomize() #obligé pour ne pas avoir la même séquence de nombres à chaque fois qu'on lance le jeu
	
func new_game():
	score = 0
	$joueur.start($StartPosition.position)
	$startTimer.start()
	

func game_over():
	$scoreTimer.stop()
	$mobTimer.stop()


func _on_startTimer_timeout():
	$mobTimer.start()
	$startTimer.start()


func _on_scoreTimer_timeout():
	score += 1

func _on_mobTimer_timeout():
	$mobPath/mobSpawnlocation.set_offset(randi() )
	var mob = ennemi.instance()
	add_child(mob)
	var direction = $mobPath/mobSpawnlocation.rotation
	mob.position=$mobPath/mobSpawnlocation.position
	direction += rand_range(-PI/4,PI/3)
	mob.rotation = direction
	mob.set_linear_velocity(Vector2(rand_range(mob.MIN_SPEED,mob.MAX_SPEED),0).rotated(direction))
