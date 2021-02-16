extends Area2D

func _ready():
	pass 

func _on_Start_body_entered(body):
	if get_node("../..").debut == 0:
		get_node("../..").dep_cases+=1
		get_node("../..").debut+=1
	get_node("../..").coin = 0
	get_node("../..").move()
	var t_detect = Timer.new()
	t_detect.set_wait_time(2)
	t_detect.set_one_shot(true)
	self.add_child(t_detect)
	t_detect.start()
	yield(t_detect, "timeout")
	if overlaps_body(body):
		print("RECEVEZ 200 ECTS")
	
