extends Control

# prépare un tableau de relation vide utilisant les noms des quelques élèves
# fictifs renseignés pour donner un aperçu à l'utilisateur
func _ready() -> void:
	Globals.creer_tableau_relations_initial()
	Globals.creer_scores_individuels_initial()
	Globals.son_a_emettre.connect(_jouer_son)
	_nom_des_onglets()

func _nom_des_onglets() -> void:
	%TabContainer.set_tab_title(0, "O1_CLASSE_ELEVES")
	%TabContainer.set_tab_title(1, "O2_BIN_SOCIO")
	%TabContainer.set_tab_title(2, "O3_PDC")
	%TabContainer.set_tab_title(3, "O4_AIDE_AP")

# quitter!!
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_tab_container_tab_changed(_tab: int) -> void:
	_jouer_son("page")
	
func _jouer_son(son: String) -> void:
	match son:
		"valider":
			$Sons.jouer_bulle()
		"annuler":
			$Sons.jouer_impact()
		"important":
			$Sons.jouer_cloche()
		"page":
			$Sons.jouer_page()
		_:
			return
