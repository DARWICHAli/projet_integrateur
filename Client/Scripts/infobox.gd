extends Container
onready var panel = get_node("../../panelPlayer")
onready var infos = get_node("../../panelInfos")
onready var case1 = panel.get_node("ColorRect/case")
onready var case2 = panel.get_node("ColorRect/case2")
onready var case3 = panel.get_node("ColorRect/case3")
onready var case4 = panel.get_node("ColorRect/case4")
onready var cases = [case1, case2, case3, case4]


onready var brun = preload("res://GFX/cases_bon_sens/case_brun.png")
onready var bleu = preload("res://GFX/cases_bon_sens/case_bleu.png")
onready var cyan = preload("res://GFX/cases_bon_sens/case_cyan.png")
onready var jaune = preload("res://GFX/cases_bon_sens/case_jaune.png")
onready var orange = preload("res://GFX/cases_bon_sens/case_orange.png")
onready var rose = preload("res://GFX/cases_bon_sens/case_rose.png")
onready var rouge = preload("res://GFX/cases_bon_sens/case_rouge.png")
onready var service = preload("res://GFX/cases_bon_sens/case_service.png")
onready var vert = preload("res://GFX/cases_bon_sens/case_vert.png")
onready var gare = preload("res://GFX/cases_bon_sens/gare.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func prop_pressed(color, indice, total, contraste):
	case1.set_normal_texture(color)
	case2.set_normal_texture(color)
	case3.set_normal_texture(color)
	case4.set_normal_texture(color)
	
	for i in range(4):
		if (i > total-1):
			cases[i].hide()
		elif (i == indice):
			cases[i].modulate = Color(1,1,1,1)
		else:
			cases[i].modulate = Color(1,1,1,contraste)
	
	panel.show()
	pass

func _on_prop1_pressed():
	prop_pressed(brun, 0, 2, 0.4)

func _on_prop3_pressed():
	prop_pressed(brun, 1, 2, 0.4)

func _on_prop5_pressed():
	prop_pressed(gare, 0, 4, 0.4)

func _on_prop6_pressed():
	print("cyan 6")
	prop_pressed(cyan, 0, 3, 0.2)

func _on_prop8_pressed():
	print("cyan 8")
	prop_pressed(cyan, 1, 3, 0.2)

func _on_prop9_pressed():
	print("cyan 9")
	prop_pressed(cyan, 2, 3, 0.2)

func _on_prop11_pressed():
	prop_pressed(rose, 0, 3, 0.3)

func _on_prop12_pressed():
	prop_pressed(service, 0, 2, 0.3)

func _on_prop13_pressed():
	prop_pressed(rose, 1, 3, 0.3)

func _on_prop14_pressed():
	prop_pressed(rose, 2, 3, 0.3)

func _on_prop15_pressed():
	prop_pressed(gare, 1, 4, 0.4)

func _on_prop16_pressed():
	prop_pressed(orange, 0, 3, 0.4)

func _on_prop17_pressed():
	prop_pressed(orange, 1, 3, 0.4)

func _on_prop19_pressed():
	prop_pressed(orange, 2, 3, 0.4)

func _on_prop21_pressed():
	prop_pressed(rouge, 0, 3, 0.4)

func _on_prop23_pressed():
	prop_pressed(rouge, 1, 3, 0.4)

func _on_prop24_pressed():
	prop_pressed(rouge, 2, 3, 0.4)

func _on_prop25_pressed():
	prop_pressed(gare, 2, 4, 0.4)

func _on_prop26_pressed():
	prop_pressed(jaune, 0, 3, 0.2)

func _on_prop27_pressed():
	prop_pressed(service, 1, 2, 0.3)

func _on_prop28_pressed():
	prop_pressed(jaune, 1, 3, 0.2)

func _on_prop29_pressed():
	prop_pressed(jaune, 2, 3, 0.2)

func _on_prop31_pressed():
	prop_pressed(vert, 0, 3, 0.4)

func _on_prop33_pressed():
	prop_pressed(vert, 1, 3, 0.4)

func _on_prop34_pressed():
	prop_pressed(vert, 2, 3, 0.4)

func _on_prop35_pressed():
	prop_pressed(gare, 3, 4, 0.4)

func _on_prop37_pressed():
	prop_pressed(bleu, 0, 2, 0.4)

func _on_prop39_pressed():
	prop_pressed(bleu, 1, 2, 0.4)

func _on_info_joueur_pressed():
#	print("body")
#	var brun = load("res://GFX/cases_bon_sens/case_brun.png")
#	prop_pressed(brun, 0, 3)
	pass

var conf_mode = -1

func change_text_conf(string):
	var label = get_node("../../panelPlayer/ColorRect/confirmation/Label")
	label.set_text("Voulez-vous vraiment " + string + "cette propriete ?")

func show_confirmation(mode):
	var conf = get_node("../../panelPlayer/ColorRect/confirmation")
	
	if (conf_mode == mode and conf.is_visible()):
		conf.hide()
		conf_mode = -1
	elif(conf_mode != mode and conf.is_visible()) :
		conf_mode = mode
	elif(!conf.is_visible()):
		conf.show()
		conf_mode = mode

func _on_vendre_pressed():
	change_text_conf("vendre ")
	show_confirmation(0)
	pass # Replace with function body.

func _on_hypothequer_pressed():
	change_text_conf("hypothequer ")
	show_confirmation(1)
	pass # Replace with function body.

func _on_construire_pressed():
	change_text_conf("construire sur ")
	show_confirmation(2)
	pass # Replace with function body.

func _on_detruire_pressed():
	change_text_conf("detruire un batiment sur\n")
	get_tree().get_root().get_node("jeu").destruction(3)
	show_confirmation(3)
	pass # Replace with function body.

func show_houses(nb):
	var upgrade = get_node("../../panelPlayer/ColorRect/upgrade")
	for i in range(5):
		upgrade.get_child(i).hide()
	
	var i = 0
	var flag = 0
	while (i < 5 and flag < nb):
		var home = upgrade.get_child(i)
		if (!home.is_visible()):
			home.show()
			flag += 1
		i += 1

func _on_exit_pressed():
	panel.hide()

func _on_exit2_pressed():
	infos.hide()

func _on_oui_pressed():
	pass # Replace with function body.

func _on_non_pressed():
	pass # Replace with function body.

func _on_LinkButton_pressed():
	infos.show()
