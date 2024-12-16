extends Control

signal son_a_emettre(son: String)

const COUL_POSITIVES: Array[Color] = [Color.FLORAL_WHITE, Color.PALE_GREEN, Color.LAWN_GREEN, Color.GREEN]
const COUL_NEGATIVES: Array[Color] = [Color.FLORAL_WHITE, Color.ORANGE, Color.RED]

var etiquette_en_mouvement: Label = null
var fleches: Array #[noeud de depart, noeud d'arrivee, affinite]

@onready var shader_ligne = preload("res://shaders/ligne.gdshader")

func _ready() -> void:
	Globals.nouveau_tableau_relations.connect(_nettoyer_l_onglet)


# gestion du mouvement des étiquettes d'élève par l'utilisateur	
func _process(_delta: float) -> void:
	if etiquette_en_mouvement:
		var decalage: Vector2 = etiquette_en_mouvement.size/2
		var nouveau: Vector2 = get_global_mouse_position() - decalage
		etiquette_en_mouvement.global_position = nouveau
		_maj_lignes()


func _bouger_etiquette(event: InputEvent, etiquette: Label) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				etiquette_en_mouvement = etiquette
			else:
				etiquette_en_mouvement = null


func _nouveau_sociogramme() -> void:
	_placer_eleves()
	# pour calculer la nouvelle matrice de flèches à l'image d'après, sinon,
	# la matrice se formait avec les coordonnés des noeuds effacés???	
	get_tree().process_frame.connect(_placer_relations, CONNECT_ONE_SHOT)

func _placer_eleves() -> void:
	for noeud in %PorteLabels.get_children():
		noeud.queue_free()
		
	var N : int = Globals.nombre_eleves
	if N == 0:
		return
	var coin: Vector2 = get_viewport_rect().size / 3.5
	var lignes: int = floor(sqrt(N))
	var eleves_ranges: Array
	eleves_ranges.resize(N)
	for i in range(N):
		eleves_ranges[i] = [Globals.noms_eleves[i], Globals.scores_individuels[i]]
	eleves_ranges.sort_custom((func(a, b): return a[1] > b[1]))
	var etiquettes_rangees : Array
	etiquettes_rangees.resize(N)
	for i in range(N):
		etiquettes_rangees[i] = eleves_ranges[i][0]
		
	for eleve in Globals.noms_eleves:
		var etiquette: Label = Label.new()
		etiquette.text = eleve
		var indice: int = etiquettes_rangees.find(eleve)
		etiquette.position = Vector2(indice / lignes * 200, indice % lignes * 100) + coin		
		etiquette.theme_type_variation = "LabelEtiquette"
		etiquette.mouse_filter = Control.MOUSE_FILTER_STOP
		etiquette.gui_input.connect(_bouger_etiquette.bind(etiquette))
		%PorteLabels.add_child(etiquette)
		
func _placer_relations() -> void:
	_remplir_fleches()
	_placer_lignes()
	
func _remplir_fleches() -> void:	
	fleches.clear()
	for i in range(Globals.nombre_eleves * Globals.nombre_eleves):
		var valeur: int = Globals.tableau_relations[i]
		if valeur != 0:
			fleches.append([i / Globals.nombre_eleves, i % Globals.nombre_eleves, valeur])

func _placer_lignes() -> void:
	for noeud in %PorteLignes.get_children():
		noeud.queue_free()
	var epaisseur_max : float = log(max(get_viewport_rect().size.x, get_viewport_rect().size.y))
	for fleche in fleches:
		var eti_depart: Label = %PorteLabels.get_child(fleche[0])
		var eti_arrivee: Label = %PorteLabels.get_child(fleche[1])
		var depart: Vector2 = eti_depart.position + eti_depart.size/2
		var arrivee : Vector2 = eti_arrivee.position + eti_arrivee.size/2
		var valeur: int = fleche[2]
		var couleur: Color = COUL_POSITIVES[valeur] if valeur >= 0 else COUL_NEGATIVES[-valeur]
		var epaisseur: float = (epaisseur_max - log(depart.distance_to(arrivee))) * 2 + 0.01
		var noeud = ColorRect.new()
		noeud.color = Color(Color.WHITE)
		noeud.position = depart
		noeud.size.y = epaisseur
		noeud.size.x = depart.distance_to(arrivee)
		noeud.rotation = depart.angle_to_point(arrivee)
		noeud.material = ShaderMaterial.new()
		noeud.material.shader = shader_ligne
		noeud.material.set_shader_parameter("frequency", 300 / epaisseur)
		noeud.material.set_shader_parameter("speed", 5)
		noeud.material.set_shader_parameter("direction", -1)
		noeud.material.set_shader_parameter("color1", couleur)
		noeud.material.set_shader_parameter("color2", Color(0, 0, 0, 0))
		%PorteLignes.add_child(noeud)
	
func _maj_lignes() -> void:
	var epaisseur_max : float = log(max(get_viewport_rect().size.x, get_viewport_rect().size.y))
	for i in range(%PorteLignes.get_child_count()):
		var eti_depart: Label = %PorteLabels.get_child(fleches[i][0])
		var eti_arrivee: Label = %PorteLabels.get_child(fleches[i][1])
		var depart: Vector2 = eti_depart.position + eti_depart.size/2
		var arrivee : Vector2 = eti_arrivee.position + eti_arrivee.size/2
		var epaisseur: float = (epaisseur_max - log(depart.distance_to(arrivee))) * 2 + 0.01
		var noeud = %PorteLignes.get_child(i)
		noeud.position = depart
		noeud.size.y = epaisseur
		noeud.size.x = depart.distance_to(arrivee)
		noeud.rotation = depart.angle_to_point(arrivee)
		noeud.material.set_shader_parameter("frequency", 300 / epaisseur)

				
# fonctions pour répondre à la demande de l'utilisateur d'afficher le sociogramme
# et exporter le résultat ver le plan de classe. 
func _on_tracer_pressed() -> void:
	_nouveau_sociogramme()
	son_a_emettre.emit("valider")

func _on_exporte_vers_plan_pressed() -> void:
	var plan: PackedVector3Array
	for indice in %PorteLabels.get_child_count():
		var place: Vector2 = %PorteLabels.get_child(indice).global_position
		plan.append(Vector3(place.x, place.y, indice))
	Globals.plan_de_classe(plan)
	son_a_emettre.emit("important")
	

# nettoie quand la liste des eleves a changé (et donc probablement le nombre 
# de noeuds à explorer par ou la mise à jour des étiquettes
func _nettoyer_l_onglet() -> void:
	fleches.clear()
	for noeud in %PorteLabels.get_children():
		noeud.queue_free()
	for noeud in %PorteLignes.get_children():
		noeud.queue_free()
	%GroupesNegatifs.text = "\n" + tr("O22_EVITER")
	%GroupesPositifs.text = "\n" + tr("O22_FAVORISER")


func _on_listes_binomes_generer_presse() -> void:
	son_a_emettre.emit("valider")
