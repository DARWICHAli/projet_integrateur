extends Node

class_name Cases

enum CasesTypes {DEPART, ALLER_PRISON, PROPRIETE, PRISON, TAXE, COMM, CHANCE, AUTRE}
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

var loyer = [100,200,300,400,500,00]

func set_depart(gains : int):
	type = CasesTypes.DEPART
	prix = gains

func set_propriete(prix, i, sous_type, loyer_tab, prix_m, prix_h):
	type = CasesTypes.PROPRIETE
	self.sous_type = sous_type
	self.prix = prix
	loyer = loyer_tab
	prix_maison = prix_m
	prix_hotel = prix_h

func set_prison():
	type = CasesTypes.PRISON

func set_aller_prison():
	type = CasesTypes.ALLER_PRISON

func set_taxe(i):
	type = CasesTypes.TAXE
	if i == 4:
		self.prix = 200
	else:
		self.prix = 100

func set_comm():
	type = CasesTypes.COMM
	
func set_chance():
	type = CasesTypes.CHANCE

func set_autre():
	type = CasesTypes.AUTRE
	prix = 0
