extends VBoxContainer

signal generer_presse

var binomes_positifs: Array[Array]
var binomes_negatifs: Array[Array]

# Ci-dessous, fonctions pour générer une liste de binomes à favoriser et une 
# liste de binômes à éviter
func _on_generer_binomes_pressed() -> void:
	_generer_binomes()
	_afficher_goupes()
	generer_presse.emit()
	
func _generer_binomes() -> void:
	binomes_positifs.clear()
	binomes_negatifs.clear()
	for i in range(Globals.nombre_eleves - 1):
		for j in range(i + 1, Globals.nombre_eleves):
			var aff1: int = Globals.tableau_relations[i * Globals.nombre_eleves + j]
			var aff2: int = Globals.tableau_relations[j * Globals.nombre_eleves + i]
			if aff1 < 0 or aff2 < 0:
				binomes_negatifs.append([i, aff1, j, aff2])
			elif aff1 > 0 or aff2 > 0:
				binomes_positifs.append([i, aff1, j, aff2])
	binomes_negatifs.sort_custom(func(a, b): return a[1] + a[3] < b[1] + b[3])
	binomes_positifs.sort_custom(func(a, b): return a[1] + a[3] > b[1] + b[3])

# fonctions d'affichage des binomes positifs et négatifs à gauche
func _afficher_goupes() -> void:
	%GroupesPositifs.text = ""
	%GroupesNegatifs.text = ""
	%GroupesPositifs.add_theme_color_override("font_color", Color.PALE_GREEN)
	%GroupesNegatifs.add_theme_color_override("font_color", Color.ORANGE)
	var positif: String = "\n" + tr("O22_FAVORISER") + "\n"
	var negatif: String = "\n" + tr("O22_EVITER") + "\n"
	for binome in binomes_positifs:
		positif += "\n" + Globals.noms_eleves[binome[0]] + " " + str(binome[1]) + " " +Globals.noms_eleves[binome[2]] + " " + str(binome[3])
	for binome in binomes_negatifs:
		negatif += "\n" + Globals.noms_eleves[binome[0]] + " " + str(binome[1]) + " " +Globals.noms_eleves[binome[2]] + " " + str(binome[3])
	%GroupesPositifs.text = positif
	%GroupesNegatifs.text = negatif
