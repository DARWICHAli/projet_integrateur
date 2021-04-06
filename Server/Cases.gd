extends Node

class_name Cases

enum CasesTypes {DEPART, ALLER_PRISON, PROPRIETE, PRISON, AUTRE}
enum Couleur {GARE, BRUN, BLEU_CIEL, VIOLET, ORANGE, ROUGE, JAUNE, VERT, BLEU_FONCE}

var indice
var nom_case

var proprio = -1
var type
var prix

var prix_maison = 100
var prix_hotel = 200
var niveau_case = 0 # 0 = pas construit, 5 = hotel construit

func set_depart(gains : int):
	type = CasesTypes.DEPART
	prix = gains

func set_propriete(prix : int):
	type = CasesTypes.PROPRIETE
	self.prix = prix

func set_prison():
	type = CasesTypes.PRISON

func set_aller_prison():
	type = CasesTypes.ALLER_PRISON

func set_autre():
	type = CasesTypes.AUTRE
	prix = 0
