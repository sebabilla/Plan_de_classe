extends MenuButton

var noms_sauvegardes: PackedStringArray = ["liste.csv"]


func _ready() -> void:
	get_popup().id_pressed.connect(_on_popup_pressed)
	_maj_popup()
	Globals.nouvelle_sauvegarde.connect(_maj_popup)

# gère les noms de fichiers affichés dans le menu popup en lisant CHEMIN_SAUVEGARDE
# ne devrait pas modifier d'infos
func _maj_popup() -> void:
	_trouver_sauvegardes()
	_maj_menu_ouvrir()

func _trouver_sauvegardes() -> void:
	var dir = DirAccess.open(Globals.CHEMIN_SAUVEGARDE)
	var fichiers: PackedStringArray = dir.get_files()
	noms_sauvegardes.clear()
	for nom in fichiers:
		if nom.get_extension() == "csv":
			noms_sauvegardes.append(nom)
	if noms_sauvegardes.is_empty():
		noms_sauvegardes.append("pas_de_fichier")

func _maj_menu_ouvrir() -> void:
	get_popup().clear()
	for i in range(noms_sauvegardes.size()):
		get_popup().add_item(noms_sauvegardes[i], i)


# Laisse Globals ouvrir la sauvegarde et la vérifier
func _on_popup_pressed(index: int) -> void:
	if noms_sauvegardes[index].get_extension() == "csv":
		Globals.ouvrir_tableau(noms_sauvegardes[index])

# pour que le popup apparaissent au-dessus du bouton et non sur lui
func _on_pressed() -> void:
	var popup = get_popup()
	popup.position.y = global_position.y - popup.size.y
