extends Area2D

func _ready():
	pass 

func _on_Prison_body_entered(body):
	get_node("../..").coin = 1
	get_node("../..").move()
	var t_detect = Timer.new()
	t_detect.set_wait_time(2)
	t_detect.set_one_shot(true)
	self.add_child(t_detect)
	t_detect.start()
	yield(t_detect, "timeout")
	if overlaps_body(body):
		if body.prison == 0:
			body.position = get_node("../VisitePrison/CollisionPolygon2D").get_global_position()
#		print("VOUS ETES EN PRISON, PAYEZ 50 ECTS !")
#		body.argent-=50
#		print("Solde : " + str(body.argent))
#		if body.argent <= 0:
#			print("VOUS ETES FAUCHES, C'EST PERDU !")
#			get_tree().quit()


