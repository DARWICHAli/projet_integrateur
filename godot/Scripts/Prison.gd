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
		print("VOUS ETES EN PRISON HAHAHAHA")

