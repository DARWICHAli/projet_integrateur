extends Node

class_name Cases

enum CasesTypes {DEPART, ALLER_PRISON, PROPRIETE, PRISON, TAXE, AUTRE}
enum PropTypes {GARE, BRUN, BLEU_CIEL, VIOLET, ORANGE, ROUGE, JAUNE, VERT, BLEU_FONCE, COMPAGNIE}

var indice
var nom_case

var proprio = -1
var hypotheque = 0
var type
var sous_type = 0
var prix

var prix_maison = 100
var prix_hotel = 200
var niveau_case = 0 # 0 = pas construit, 5 = hotel construit

func set_depart(gains : int):
	type = CasesTypes.DEPART
	prix = gains

func set_propriete(prix : int, i : int, sous_type):
	type = CasesTypes.PROPRIETE
	self.sous_type = sous_type
	self.prix = prix

func set_prison():
	type = CasesTypes.PRISON

func set_aller_prison():
	type = CasesTypes.ALLER_PRISON

func set_taxe(i):
	type = CasesTypes.TAXE
	if i == 2:
		self.prix = 50
	else:
		self.prix = 150

func set_autre():
	type = CasesTypes.AUTRE
<<<<<<< HEAD
=======
	#self.proprio = -2
>>>>>>> origin/snapshot
	prix = 0
