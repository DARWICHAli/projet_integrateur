extends "Case.gd"

var taille
var pos_pions = [[-48,-46]]
onready var pos = get_node("Pos")
#class_name allerprison


#============== Routines =================
func _ready():
	taille = get_node("Sprite").texture.get_size()
	pass


#============== Signaux =================
func _on_Goto_prison_body_entered(body):
	body.mettre_case(self)
	if (body.dep_cases <= 1):
		var t_detect = Timer.new()
		t_detect.set_wait_time(1)
		t_detect.set_one_shot(true)
		self.add_child(t_detect)
		t_detect.start()
		yield(t_detect, "timeout")
		if overlaps_body(body):
			print("Envoi requete de fin de dep go prison......")
			get_node("../../../..").fin_dep_go_prison()
			#body.position_case = 10

#============== Fonctions =================
