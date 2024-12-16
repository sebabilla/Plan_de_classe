extends Node

signal maj_question
signal maj_nom_classe
signal nouveau_tableau_relations
signal maj_case_tableau_relations(indice: int)
signal nouveau_plan
signal nouvelle_sauvegarde
signal son_a_emettre(son: String)

const CHEMIN_SAUVEGARDE = "user://"

const AFFINITE_MAX := 3
const AFFINITE_MIN : = 2

var question: String = "Avec qui peux-tu bien travailler?":
	set(chaine):
		question = chaine
		maj_question.emit()
		son_a_emettre.emit("valider")
var nom_classe: String = "Pioupious":
	set(chaine):
		nom_classe = chaine
		maj_nom_classe.emit()
		son_a_emettre.emit("valider")
var noms_eleves: Array = ["Astérix", "Obélix", "Idéfix", "Jules", "Cléopatre"]
var nombre_eleves: int = noms_eleves.size()
var tableau_relations: Array[int]
var scores_individuels: Array[int]
var plan_classe: PackedVector3Array #Vector3(x, y, indice élève)

# Ci-dessous fonctions pour ajouter et enlever des élèves
func ajouter_nom_eleve(nom: String) -> void:
	if nom in noms_eleves:
		return
	noms_eleves.append(nom)
	nombre_eleves = noms_eleves.size()
	agrandir_tableau()
	
func enlever_dernier_eleve() -> void:
	noms_eleves.pop_back()
	nombre_eleves = noms_eleves.size()
	if nombre_eleves >= 0 :
		reduire_tableau()
	
func enlever_tous_eleves() -> void:
	noms_eleves.clear()
	nombre_eleves = 0
	tableau_relations.clear()
	scores_individuels.clear()
	nouveau_tableau_relations.emit()
	son_a_emettre.emit("annuler")
	

# Ci-dessous fonctions pour créer et modifier tableau_relations et scores_individuels
func agrandir_tableau() -> void:
	for i in nombre_eleves - 1:
		tableau_relations.insert(i * nombre_eleves + nombre_eleves - 1, 0)
		tableau_relations.append(0)
	tableau_relations.append(0)
	scores_individuels.append(0)
	nouveau_tableau_relations.emit()
	son_a_emettre.emit("valider")
	
func reduire_tableau() -> void:
	for i in nombre_eleves:
		tableau_relations.pop_at(i * nombre_eleves + nombre_eleves)
		tableau_relations.pop_back()
	tableau_relations.pop_back()
	scores_individuels.pop_back()
	nouveau_tableau_relations.emit()
	son_a_emettre.emit("annuler")

func creer_tableau_relations_initial() -> void:
	tableau_relations.clear()
	tableau_relations.resize(nombre_eleves * nombre_eleves)
	tableau_relations.fill(0)

func creer_scores_individuels_initial() -> void:
	scores_individuels.clear()
	scores_individuels.resize(nombre_eleves)
	scores_individuels.fill(0)

func changer_affinite(indice: int) -> void:
	var a_changer = tableau_relations[indice]
	a_changer += 1
	if a_changer > AFFINITE_MAX:
		a_changer = -AFFINITE_MIN
	tableau_relations[indice] = a_changer
	calculer_score_individuel(indice)
	maj_case_tableau_relations.emit(indice)
	son_a_emettre.emit("valider")

func calculer_score_individuel(indice: int) -> void:
	var place = indice % nombre_eleves
	scores_individuels[place] = 0
	for i in range(place, nombre_eleves * nombre_eleves, nombre_eleves):
		scores_individuels[place] += tableau_relations[i]
		
func vider_les_cases() -> void:
	creer_tableau_relations_initial()
	creer_scores_individuels_initial()
	nouveau_tableau_relations.emit()
	son_a_emettre.emit("annuler")

# ci dessous fonctions pour gérer le plan de classe
func plan_de_classe(plan: PackedVector3Array) -> void:
	plan_classe.clear()
	plan_classe.append_array(plan)
	nouveau_plan.emit()

# Ci dessous fonctions pour sauvegarder ou ouvrir les .csv contenant:
# la question posée, la classe, la liste des élèves et les affinités déclarées
func sauvegarder_tableau() -> void:
	var nom_sauvegarde: String = CHEMIN_SAUVEGARDE + nom_classe + ".csv"
	var fichier := FileAccess.open(nom_sauvegarde, FileAccess.WRITE)
	fichier.store_csv_line([question])
	fichier.store_csv_line([nom_classe])
	fichier.store_csv_line(noms_eleves)
	fichier.store_csv_line(tableau_relations)
	nouvelle_sauvegarde.emit()
	son_a_emettre.emit("important")
		
func ouvrir_tableau(nom_fichier: String) -> void:
	var nom_sauvegarde: String = CHEMIN_SAUVEGARDE + nom_fichier
	var fichier := FileAccess.open(nom_sauvegarde, FileAccess.READ)
	question = fichier.get_csv_line()[0]
	nom_classe = fichier.get_csv_line()[0]
	noms_eleves = Array(fichier.get_csv_line())
	nombre_eleves = noms_eleves.size()
	creer_tableau_relations_initial()
	var ligne_relations = fichier.get_csv_line()
	for i in range(nombre_eleves * nombre_eleves):
		tableau_relations[i] = int(ligne_relations[i])	
	creer_scores_individuels_initial()
	for i in range(nombre_eleves):
		calculer_score_individuel(i)				
	maj_question.emit()
	maj_nom_classe.emit()
	nouveau_tableau_relations.emit()
	son_a_emettre.emit("important")
