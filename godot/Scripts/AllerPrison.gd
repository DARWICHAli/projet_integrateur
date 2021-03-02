extends Area2D

class_name allerprison

func _ready():
	pass

func _on_AllerPrison_body_entered(body):
	get_node("../..").coin = 3
	get_node("../..").move()
	var t_detect = Timer.new()
	t_detect.set_wait_time(1)
	t_detect.set_one_shot(true)
	self.add_child(t_detect)
	t_detect.start()
	yield(t_detect, "timeout")
	if overlaps_body(body):
		get_node("../..").coin = 1
		body.prison = 1
		get_node("../../Pion").position = get_node("../Prison/CollisionShape2D").position
		print("VOUS ETES EN PRISON, PAYEZ 50 ECTS !")
		body.argent-=50
		print("Solde : " + str(body.argent))
		if body.argent <= 0:
			print("VOUS ETES FAUCHES, C'EST PERDU !")
			get_tree().quit()
