extends Area2D

func _ready():
	pass 

func _on_Rouge_body_entered(body):
	get_node("../..").move()
	var t_detect = Timer.new()
	t_detect.set_wait_time(2)
	t_detect.set_one_shot(true)
	self.add_child(t_detect)
	t_detect.start()
	yield(t_detect, "timeout")
	if overlaps_body(body):
		print("BIENVENUE A LA FAC DE MEDECINE : PAYEZ 100 ECTS !")
		body.argent-=100
		print("Solde : " + str(body.argent))
		if body.argent <= 0:
			print("VOUS ETES FAUCHES, C'EST PERDU !")
			get_tree().quit()

