extends Node

class_name Cases

enum CasesTypes {DEPART, PRISON, PROPRIETE, AUTRE}
 
var indice

var proprio = -1
var type
var prix
var case_goto


var prix_maison = 100
var prix_hotel = 200
var niveau_case = 0 # 0 = pas construit, 5 = hotel construit

func set_depart(gains : int):
	type = CasesTypes.DEPART
	prix = gains

func set_propriete(Prix : int):
	type = CasesTypes.PROPRIETE
	self.prix = Prix

func set_prison(case_number : int):
	type = CasesTypes.PRISON
	case_goto = case_number

func set_autre():
	type = CasesTypes.AUTRE
	prix = 0
