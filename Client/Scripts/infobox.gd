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

var type_button = 0
#var prop = 0
var ind = 0

var prop_indices = [[1,3],[5,15,25,35],[6,8,9],[11,13,14],[12,27], [16,18,19],[21,23,24],[26,28,29],[31,33,34],[37,39]]
var prop_names = [["Institut Le Bel", "Service des sports"]
				 ,["Arrêt galia", "Arrêt Esplanade", "Arrêt Observatoire", "Arrêt Place de l'étoile"], 
				 ["Atrium", "Faculté de Chimie", "Le Patio"], 
				 ["Faculté de Géographie", "Faculté de Médecine", "Faculté Physique et Ingénierie"], ["Électricité de Strasbourg", "Compagnie des eaux"], ["Bibliothèque BNU", "Observatoire", "Resto U"], ["INSA", "Plateforme de Biologie", "Le Portique"], ["Opéra national", "Parlement Européen", "Stade de la Meinau"], ["Faculté de droit", "Faculté des sciences historiques", "Faculté de pharmacie"]
				 ,["Faculté de Gestion et d'Économie", "UFR Maths info"]]
var prop_loyer = [[[2,10,30,90,160,250], [4,20,60,180,320,450]], 
				  [[25,50,100,200], [25,50,100,200], [25,50,100,200], [25,50,100,200]], 
				  [[6,30,90,270,400,550], [6,30,90,270,400,550], [8,40,100,300,450,600]], 
				  [[10,50,150,450,625,750], [10,50,150,450,625,750], [12,60,180,500,700,900]], 
				  [[0,0,0,0,0,0], [0,0,0,0,0,0]], [[14,70,200,550,750,950], [14,70,200,550,750,950], [16,80,220,600,800,1000]], [[18,90,250,700,875,1050], [18,90,250,700,875,1050],[18,90,250,700,875,1050], [20,100,300,750,925,1100]], [[22,110,330,800,975,1150], [22,110,330,800,975,1150], [24,120,360,850,1025,1200]], [[26,130,390,900,1100,1275], [26,130,390,900,1100,1275], 
				   [28,150,450,1000,1200,1400]], [[35,175,500,1100,1300,1500], [50,200,600,1400,1700,2000]]]

var prop_prix = [[60, 60], [200, 200, 200, 200], [100, 100, 120], 
				 [140, 140, 160], [150, 150], [180, 180, 200], 
				 [220, 220, 240], [260, 260, 280], [300, 300, 320], [350, 400]]
signal sig_stats(infobox,player)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func prop_pressed(color, indice, total, contraste, nb_prop):
	case1.set_normal_texture(color)
	case2.set_normal_texture(color)
	case3.set_normal_texture(color)
	case4.set_normal_texture(color)
	
	get_tree().get_root().get_node("jeu").joueur.prop = nb_prop

	self.ind = indice
	
	for i in range(4):
		if (i > total-1):
			cases[i].hide()
		elif (i == indice):
			cases[i].modulate = Color(1,1,1,1)
		else:
			cases[i].modulate = Color(1,1,1,contraste)
	
	if(get_tree().get_root().get_node("jeu").cases[nb_prop].hypotheque == 1):
		cases[indice].get_node("hyp").show()
	else:
		cases[indice].get_node("hyp").hide()
	
	get_node("../../panelPlayer/ColorRect/money").text = get_tree().get_root().get_node("jeu").joueur.argent[int(name[7])-1]
	case_pressed(indice)
	panel.show()

func _on_prop1_pressed():
	prop_pressed(brun, 0, 2, 0.4, 1)
	

func _on_prop3_pressed():
	prop_pressed(brun, 1, 2, 0.4, 3)

func _on_prop5_pressed():
	prop_pressed(gare, 0, 4, 0.4, 5)

func _on_prop6_pressed():
	print("cyan 6")
	prop_pressed(cyan, 0, 3, 0.2, 6)

func _on_prop8_pressed():
	print("cyan 8")
	prop_pressed(cyan, 1, 3, 0.2, 8)

func _on_prop9_pressed():
	print("cyan 9")
	prop_pressed(cyan, 2, 3, 0.2, 9)

func _on_prop11_pressed():
	prop_pressed(rose, 0, 3, 0.3, 11)

func _on_prop12_pressed():
	prop_pressed(service, 0, 2, 0.3, 12)

func _on_prop13_pressed():
	prop_pressed(rose, 1, 3, 0.3, 13)

func _on_prop14_pressed():
	prop_pressed(rose, 2, 3, 0.3, 14)

func _on_prop15_pressed():
	prop_pressed(gare, 1, 4, 0.4, 15)

func _on_prop16_pressed():
	prop_pressed(orange, 0, 3, 0.4, 16)

func _on_prop18_pressed():
	prop_pressed(orange, 1, 3, 0.4, 18)

func _on_prop19_pressed():
	prop_pressed(orange, 2, 3, 0.4, 19)

func _on_prop21_pressed():
	prop_pressed(rouge, 0, 3, 0.4, 21)

func _on_prop23_pressed():
	prop_pressed(rouge, 1, 3, 0.4, 23)

func _on_prop24_pressed():
	prop_pressed(rouge, 2, 3, 0.4, 24)

func _on_prop25_pressed():
	prop_pressed(gare, 2, 4, 0.4, 25)

func _on_prop26_pressed():
	prop_pressed(jaune, 0, 3, 0.2, 26)

func _on_prop27_pressed():
	prop_pressed(service, 1, 2, 0.3, 27)

func _on_prop28_pressed():
	prop_pressed(jaune, 1, 3, 0.2, 28)

func _on_prop29_pressed():
	prop_pressed(jaune, 2, 3, 0.2, 29)

func _on_prop31_pressed():
	prop_pressed(vert, 0, 3, 0.4, 31)

func _on_prop33_pressed():
	prop_pressed(vert, 1, 3, 0.4, 33)

func _on_prop34_pressed():
	prop_pressed(vert, 2, 3, 0.4, 34)

func _on_prop35_pressed():
	prop_pressed(gare, 3, 4, 0.4, 35)

func _on_prop37_pressed():
	prop_pressed(bleu, 0, 2, 0.4, 37)

func _on_prop39_pressed():
	prop_pressed(bleu, 1, 2, 0.4, 39)

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
	type_button = 1

func _on_hypothequer_pressed():
	change_text_conf("hypothequer/dehypothequer ")
	show_confirmation(1)
	type_button = 2

func _on_construire_pressed():
	change_text_conf("construire sur ")
	show_confirmation(2)
	type_button = 3

func _on_detruire_pressed():
	change_text_conf("detruire un batiment sur\n")
	#get_tree().get_root().get_node("jeu").destruction(3)
	show_confirmation(3)
	type_button = 4

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
	cases[ind].get_node("hyp").hide()
	panel.hide()

func _on_exit2_pressed():
	infos.hide()

func _on_oui_pressed():
	#var case = get_tree().get_root().get_node("jeu").joueur.pos_pion
	#print("PROP : " + str(case))
	var prop = get_tree().get_root().get_node("jeu").joueur.prop
	print("PROP : " + str(prop))
	if type_button == 1:
		get_tree().get_root().get_node("jeu").vendre(prop)
	elif type_button == 2:
		get_tree().get_root().get_node("jeu").hypothequer(prop)
	elif type_button == 3:
		get_tree().get_root().get_node("jeu").construire(prop)
	elif type_button == 4:
		get_tree().get_root().get_node("jeu").destruction(prop)

func _on_non_pressed():
	pass # Replace with function body.
	
func _on_LinkButton_pressed():
	emit_signal("sig_stats",self,$nom_joueur.text)
	

func _on_jailbreak_pressed():
	var id = get_tree().get_root().get_node("jeu").joueur.id+1
	if("infobox"+str(id) == name):
		get_tree().get_root().get_node("jeu").carte_sortie_prison()

func case_pressed(indice):
	var res_col = 0
	var prop = get_tree().get_root().get_node("jeu").joueur.prop
	for col in range(0,len(prop_indices)):
		for i in range(0,len(prop_indices[col])):
			if( prop == prop_indices[col][i]):
				res_col = col
				
	get_node("../../panelPlayer/ColorRect/loyers/nom_propriete").text= prop_names[res_col][indice]
	get_node("../../panelPlayer/ColorRect/loyers/loyer").text = "loyer nu: " +str(prop_loyer[res_col][indice][0])
	get_node("../../panelPlayer/ColorRect/loyers/1maison").text = "avec 1 maison: " + str(prop_loyer[res_col][indice][1])
	get_node("../../panelPlayer/ColorRect/loyers/2maison").text = "avec 2 maison: " + str(prop_loyer[res_col][indice][2])
	get_node("../../panelPlayer/ColorRect/loyers/3maison").text = "avec 3 maison: " + str(prop_loyer[res_col][indice][3])
	get_node("../../panelPlayer/ColorRect/loyers/4maison").text = "avec 4 maison: " + str(prop_loyer[res_col][indice][4])
	get_node("../../panelPlayer/ColorRect/loyers/hotel").text = "avec 1 hotel: " + str(prop_loyer[res_col][indice][5])
	var prix_const = 0
	if(prop < 10):
		prix_const = 50
	elif(prop < 20):
		prix_const = 100
	elif(prop < 30):
		prix_const = 150
	else:
		prix_const = 200
	get_node("../../panelPlayer/ColorRect/loyers/prixparmaison").text = "prix maison: " + str(prix_const)
	get_node("../../panelPlayer/ColorRect/loyers/prixparhotel").text = "prix hotel: " + str(prix_const)
	get_node("../../panelPlayer/ColorRect/loyers/valeur_hypo").text = "Valeur hypothecaire: " + str(prop_prix[res_col][indice])
	
func _on_case_pressed():
	case_pressed(0)


func _on_case2_pressed():
	case_pressed(1)


func _on_case3_pressed():
	case_pressed(2)


func _on_case4_pressed():
	case_pressed(3)
