extends Node

class_name Cases

enum CasesTypes {DEPART, PRISON, PROPRIETE, AUTRE}
 

var proprio = -1
var type
var prix
var case_goto

func set_depart(gains : int):
	type = CasesTypes.DEPART
	prix = gains

func set_propriete(Prix : int):
	type = CasesTypes.PROPRIETE
	self.prix = -Prix

func set_prison(case_number : int):
	type = CasesTypes.PRISON
	case_goto = case_number

func set_autre():
	type = CasesTypes.AUTRE
	prix = 0
