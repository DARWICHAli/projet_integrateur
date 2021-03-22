extends "Propriete.gd"

var prixHotel = 0
var prixMaison = 0
var nbMaison = 0
var hotel = false
var couleur
var voisins = []	#de meme couleur

#============== Routines =================
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#============== Fonctions =================
func getPrixMaison():
	return prixMaison

func getPrixHotel():
	return prixHotel

func getNombreMaison():
	return nbMaison

func isHotel():
	return hotel

func checkProprios(joueur):
	for i in voisins:
		if (i.proprio != joueur):
			return false
	return true

func upgrade(joueur):
	if (!checkProprios(joueur)):
		return false
	if (hotel):
		print ("la propriete n'est plus upgradable")
		return false
	else:
		if (nbMaison < 4):
			if (proprio.argent >= prixMaison):
				proprio.argent -= prixMaison
#				[TODO] update prixMaison
				nbMaison += 1
		else:
			if (proprio.argent >= prixHotel):
				proprio.argent -= prixHotel
#				[TODO] update prixHotel
				hotel = true
	return true

func downgrade(joueur):
	if (joueur != self.proprio):
		return false
	if (hotel):
		hotel = false
		proprio.argent += 0.5*prixHotel
	else:
		if (nbMaison > 0):
			proprio.argent += 0.5*prixMaison
#			[TODO] update prixMaison
			nbMaison -= 1
		else:
			print ("la propriete n'est plus downgradable")

