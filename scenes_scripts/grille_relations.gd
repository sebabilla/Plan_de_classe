extends GridContainer

const COUL_POSITIVES: Array[Color] = [Color.WHITE, Color.PALE_GREEN, Color.LAWN_GREEN, Color.GREEN]
const COUL_NEGATIVES: Array[Color] = [Color.WHITE, Color.ORANGE, Color.RED]

func _ready() -> void:
	Globals.nouveau_tableau_relations.connect(_afficher_nouvelle_grille_relations)
	Globals.maj_nom_classe.connect(_afficher_nom_classe)
	Globals.maj_case_tableau_relations.connect(_maj_case_score)
	_afficher_nouvelle_grille_relations()
	_afficher_nom_classe()
	
func _afficher_nom_classe() -> void:
	$CoinGauche.text = Globals.nom_classe

# affichage d'une nouvelle grille, i.e. crée tous les noeuds labels et buttons
# aucun calcul, tous les calculs devraient être gérés dans globals.gd
func _afficher_nouvelle_grille_relations():
	_tout_nettoyer()
	if Globals.nombre_eleves > 0:
		get_tree().process_frame.connect(_afficher_nouveau_tableau_relations, CONNECT_ONE_SHOT)

func _afficher_nouveau_tableau_relations() -> void:
	$NomsH.columns = Globals.nombre_eleves
	$Affinites.columns = Globals.nombre_eleves
	$PointsH.columns = Globals.nombre_eleves
	for i in range(Globals.nombre_eleves):
		_ajouter_label($NomsH, Globals.noms_eleves[i], HORIZONTAL_ALIGNMENT_CENTER)
		_ajouter_label($NomsV, Globals.noms_eleves[i], HORIZONTAL_ALIGNMENT_RIGHT)
		_ajouter_label($NomsVCopie, Globals.noms_eleves[i], HORIZONTAL_ALIGNMENT_LEFT)
		_ajouter_label($PointsV, str(_points_a_distribuer(i)), HORIZONTAL_ALIGNMENT_CENTER)
		_ajouter_label($PointsH, str(Globals.scores_individuels[i]), HORIZONTAL_ALIGNMENT_CENTER)
	# une ligne par élève avec ses valeurs
	for i in range(Globals.nombre_eleves):
		for j in range(Globals.nombre_eleves):
			if i == j:
				_ajouter_label($Affinites, " ")
			else:
				_ajouter_button_a_grille_relations(i * Globals.nombre_eleves + j)
	_ajuster_les_tailles()
				
func _tout_nettoyer() -> void:
	for portenoeuds in [$NomsH, $NomsV, $NomsVCopie, $Affinites, $PointsV, $PointsH]:
		for noeud in portenoeuds.get_children():
			noeud.queue_free()
		
func _ajuster_les_tailles() -> void:
	if Globals.nombre_eleves <= 1:
		return
	var hauteur: int = $Affinites.get_child(1).size.y
	var largeur: int = 0
	for nom in $NomsH.get_children():
		largeur = nom.size.x if nom.size.x > largeur else largeur
	for portenoeuds in [$NomsH, $NomsV, $NomsVCopie, $Affinites, $PointsV, $PointsH]:
		for noeud in portenoeuds.get_children():
			noeud.custom_minimum_size = Vector2(largeur, hauteur)
				
func _ajouter_label(noeud: Control, texte: String, alignement := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	var nouveau: Label = Label.new()
	nouveau.text = texte
	nouveau.horizontal_alignment = alignement
	noeud.add_child(nouveau)

func _ajouter_button_a_grille_relations(indice: int) -> void:
	var valeur: int = Globals.tableau_relations[indice]
	var couleur: Color = COUL_POSITIVES[valeur] if valeur >= 0 else COUL_NEGATIVES[-valeur]
	var nouveau: Button = Button.new()
	nouveau.text =  str(valeur)
	nouveau.add_theme_color_override("font_color", couleur) 
	nouveau.add_theme_color_override("font_hover_color", couleur)
	nouveau.pressed.connect(_on_button_grille_affinite_pressed.bind(nouveau))  #.tooltip_text))
	$Affinites.add_child(nouveau)
	
func _points_a_distribuer(indice: int) -> int:
	var tous_les_points: Array = range(-Globals.AFFINITE_MIN, Globals.AFFINITE_MAX + 1)
	var score_max: int = tous_les_points.reduce(func(accum, number): return accum + abs(number), 0)
	var score_existant: int = 0
	for i in range(indice * Globals.nombre_eleves, indice * Globals.nombre_eleves + Globals.nombre_eleves):
		score_existant += abs(Globals.tableau_relations[i])
	return score_max - score_existant

# mise à jour de l'affichage quand une valeur a été modifiée
# aucun calcul, tous les calculs devraient être gérés dans globals.gd
func _maj_case_score(indice: int) -> void:
	_maj_une_case(indice)
	_maj_un_score(indice)
	_maj_points_distribues(indice)

func _maj_une_case(indice) -> void:
	var valeur: int = Globals.tableau_relations[indice]
	var couleur: Color = COUL_POSITIVES[valeur] if valeur >= 0 else COUL_NEGATIVES[-valeur]
	var noeud: Button = $Affinites.get_child(indice)
	noeud.text = str(valeur)
	noeud.add_theme_color_override("font_color", couleur)
	noeud.add_theme_color_override("font_hover_color", couleur)
	noeud.add_theme_color_override("font_focus_color", couleur)
		
func _maj_un_score(indice: int) -> void:
	var place = indice % Globals.nombre_eleves
	var noeud: Label = $PointsH.get_child(place)
	noeud.text = str(Globals.scores_individuels[place])
	
func _maj_points_distribues(indice: int) -> void:
	var noeud: Label = $PointsV.get_child(indice / Globals.nombre_eleves)
	var points_actuels = int(noeud.text)
	var point_case: int = Globals.tableau_relations[indice]
	points_actuels = points_actuels + 1 if point_case <= 0 else points_actuels - 1
	noeud.text = str(points_actuels)
	var couleur = COUL_POSITIVES[0] if points_actuels >= 0 else COUL_NEGATIVES[2]
	noeud.add_theme_color_override("font_color", couleur)


# informe Globals de la valeur d'affinité que l'utilisateur veut changer
func _on_button_grille_affinite_pressed(noeud: Button) -> void:
	var indice: int = noeud.get_index()
	Globals.changer_affinite(indice)
