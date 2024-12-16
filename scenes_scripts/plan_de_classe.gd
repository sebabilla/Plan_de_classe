extends Control

signal son_a_emettre(son: String)

var table_en_mouvement: Label = null
var table_en_rotation: Label = null
var taille_table: Vector2 = Vector2(128, 96)
var vue_prof: bool = true

func _ready() -> void:
	Globals.nouveau_plan.connect(_afficher_nouveau_plan)
	Globals.maj_nom_classe.connect(_maj_tooltip_capture)
	_maj_tooltip_capture()

# Bouger les tables
func _process(_delta: float) -> void:
	if table_en_mouvement:
		var decalage: Vector2 = table_en_mouvement.size / 2
		var nouveau: Vector2 = get_global_mouse_position() - decalage
		table_en_mouvement.global_position = nouveau
	if table_en_rotation:
		if get_global_mouse_position().distance_to(table_en_rotation.global_position + table_en_rotation.pivot_offset) > taille_table.y:
			table_en_rotation.rotation = table_en_rotation.global_position.angle_to_point(get_global_mouse_position())

func _bouger_table(event: InputEvent, table: Label) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				table_en_mouvement = table
			else:
				_aligner(table_en_mouvement)
				table_en_mouvement = null
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				table_en_rotation = table
			else:
				_acirculer(table_en_rotation)
				table_en_rotation = null

func _aligner(noeud: Control) -> void:
	var x:int = roundi(noeud.position.x)
	var modx: int = x % 16
	x = x - modx if modx < 8 else x + (16 - modx)
	var y: int = roundi(noeud.position.y)
	var mody: int = y % 16
	y = y - mody if mody < 8 else y + (16 - mody)
	noeud.position = Vector2(x, y)
	
func _acirculer(_noeud: Control) -> void:
	var a: int = roundi(table_en_rotation.rotation_degrees)
	var moda: int = a % 10
	a = a - moda if moda < 5 else a + (10 - moda)
	table_en_rotation.rotation_degrees = a


# Afficher les tables
func _afficher_nouveau_plan() -> void:
	for noeud in %PorteTables.get_children():
		noeud.queue_free()
	for eleve in Globals.plan_classe:
		_table_mobile(%PorteTables, Globals.noms_eleves[eleve.z], eleve.x, eleve.y)

func _table_mobile(noeud: Control, texte: String, x: float, y: float) -> void:
	var table: Label = Label.new()
	table.text = texte
	noeud.add_child(table)
	table.global_position = Vector2(x, y)	
	table.gui_input.connect(_bouger_table.bind(table))	
	table.theme_type_variation = "LabelTable"
	table.size = taille_table
	table.pivot_offset = table.size / 2
	table.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	table.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	table.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	table.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_ajouter_table_pressed() -> void:
	var nombre: int = %PorteTablesVierges.get_child_count()
	if nombre >= 50:
		return 
	var x: float = %AjouterTable.global_position.x + %AjouterTable.size.x + 10 + nombre * 4
	var y: float = %AjouterTable.global_position.y + nombre * 6
	_table_mobile(%PorteTablesVierges, " ", x, y)
	son_a_emettre.emit("valider")

func _on_enlever_table_pressed() -> void:
	var nombre: int = %PorteTablesVierges.get_child_count()
	if nombre < 1:
		return
	%PorteTablesVierges.get_child(nombre - 1).queue_free()
	son_a_emettre.emit("annuler")


# Passer de la vue prof à la vue élève	
func _on_retourner_plan_pressed() -> void:
	vue_prof = not vue_prof
	%RetournerPlan.text = tr("O33_VERS_VE") if vue_prof else tr("O33_VERS_VP")
	_maj_tooltip_capture()
	var centre: Vector2 = get_viewport_rect().size / 2
	for noeud in %PorteTables.get_children():
		noeud.global_position = 2 * centre - noeud.global_position
	for noeud in %PorteTablesVierges.get_children():
		noeud.global_position = 2 * centre - noeud.global_position
	son_a_emettre.emit("valider")

# Tracer le mur cadre de la photo
func _on_ajouter_murs_pressed() -> void:
	if %PorteTables.get_child_count() > 0 or %PorteTablesVierges.get_child_count() > 0:
		_definir_rectangle()
	son_a_emettre.emit("valider")
	
func _definir_rectangle() -> void:
	var tous_les_x: Array[float]
	var tous_les_y: Array[float]
	for noeud in %PorteTables.get_children():
		tous_les_x.append(noeud.position.x)
		tous_les_y.append(noeud.position.y)
	for noeud in %PorteTablesVierges.get_children():
		tous_les_x.append(noeud.position.x)
		tous_les_y.append(noeud.position.y)
	var posx: float = tous_les_x.min() - 32
	var largeur: float = tous_les_x.max() - posx + taille_table.x + 32
	var posy: float = tous_les_y.min() - 32
	var longueur: float = tous_les_y.max() - posy + taille_table.y + 32
	%Murs.murs = Rect2(Vector2(posx, posy), Vector2(largeur, longueur))
	%Murs.queue_redraw()

# Capturer le résultat!
func _on_capture_pressed() -> void:
	if %Murs.murs == Rect2(Vector2.ZERO, Vector2.ZERO):
		return
	var vue: String = "_prof" if vue_prof else "_eleve"
	var nom_sauvegarde: String = Globals.CHEMIN_SAUVEGARDE + Globals.nom_classe + vue + ".png"
	var decalage: Vector2 = $ColorRect.global_position - $ColorRect.position
	var capture: Rect2 = Rect2(%Murs.murs.position + decalage, %Murs.murs.size)
	await RenderingServer.frame_post_draw
	var tout_l_ecran: Image = get_viewport().get_texture().get_image()
	tout_l_ecran.get_region(capture).save_png(nom_sauvegarde)
	son_a_emettre.emit("important")
	
func _maj_tooltip_capture() -> void:
	var vue: String = "_prof" if vue_prof else "_eleve"
	var message: String = tr("O35_TOOLTIP") + Globals.nom_classe + vue + ".png."
	%Capture.tooltip_text = message
