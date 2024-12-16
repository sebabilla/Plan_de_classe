extends Control

func _ready() -> void:
	Globals.maj_question.connect(_afficher_question)
	Globals.maj_nom_classe.connect(_texte_tooltip_sauvegarde)
	_afficher_question()
	_texte_tooltip_sauvegarde()

func _afficher_question() -> void:
	var question: String = "\n" + tr("O16_AFFICHAGE_QUESTION") + Globals.question + "\n\n"
	%Question.text = question


# fonctions des entrees textes et boutons de la colonne de gauche du tableau
# envoient les entrees à Globals qui modifient ou non les valeurs
# ne doivent rien modifier aucune infos par elles-mêmes
func _on_entree_question_text_submitted(new_text: String) -> void:
	var texte_formate: String = new_text.strip_edges().strip_escapes().replace('"', '')
	Globals.question = texte_formate
	%EntreeQuestion.clear()

func _on_entree_classe_text_submitted(new_text: String) -> void:
	var texte_formate_sauvegarde: String = new_text.strip_edges().dedent().strip_escapes().replace(" ", "_").replace('"', '').validate_filename()
	Globals.nom_classe = texte_formate_sauvegarde
	%EntreeClasse.clear()
	
func _on_entree_eleve_text_submitted(new_text: String) -> void:
	var texte_formate: String = new_text.strip_edges().strip_escapes().replace('"', '')
	Globals.ajouter_nom_eleve(texte_formate)
	%EntreeEleve.clear()
	
func _on_enlever_dernier_pressed() -> void:
	Globals.enlever_dernier_eleve()
	
func _on_reset_liste_pressed() -> void:
	Globals.enlever_tous_eleves()

func _on_effacer_contenu_pressed() -> void:
	Globals.vider_les_cases()

# fonctions des boutons/menu en bas au centre, envoient à Globals l'intention
# de l'utilisateur de sauvegarder ou charger un fichier
func _on_sauver_pressed() -> void:
	Globals.sauvegarder_tableau()
	
func _texte_tooltip_sauvegarde() -> void:
	%Sauver.tooltip_text = ""
	var nom_fichier: String = Globals.nom_classe
	var intro: String = tr("O19_TOOLTIP")
	var texte: String = intro + nom_fichier + ".csv."
	%Sauver.tooltip_text = texte
