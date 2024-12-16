# Solution au problème des colocataires selon l'article d'Irving (1985)

extends Node

var A: Array[Array] = [["B", 0], ["D", 0], ["F", 0], ["C", 0], ["E", 0]]
var B: Array[Array] = [["D", 0], ["E", 0], ["F", 0], ["A", 0], ["C", 0]]
var C: Array[Array] = [["D", 0], ["E", 0], ["F", 0], ["A", 0], ["B", 0]]
var D: Array[Array] = [["F", 0], ["C", 0], ["A", 0], ["E", 0], ["B", 0]]
var E: Array[Array] = [["F", 0], ["C", 0], ["D", 0], ["B", 0], ["A", 0]]
var F: Array[Array] = [["A", 0], ["B", 0], ["D", 0], ["C", 0], ["E", 0]]
var joueurs: Dictionary = {"A": A, "B": B, "C": C, "D": D, "E": E, "F": F}

func SR() -> void:
	initialiser_matrice()
	irving()

	
func irving() -> void:
	if phase1():
		imprimer_joueurs()
		if test_stabilite():
			print("appariement stable après phase 1")
			return
	else:
		print("pas d'appariement possible 1")
		return
	if phase2():
		imprimer_joueurs()
		if test_stabilite():
			print("appariement stable après phase 2")
			return
	else:
		print("pas d'appariement possible")
	

func phase2() -> bool:
	var cycle: Array = trouver_cycle()
	var compteur_securite: int = 0
	while not cycle.is_empty():
		if cycle != ["passer"]:
			for n in range(0, cycle.size(), 2):
				var p: String = cycle[n]
				var q: String = cycle[n + 1]
				supprimer_paire(p, q)
				if liste_vide(p) or liste_vide(q):
					return false
		cycle = trouver_cycle()
		compteur_securite += 1
		if compteur_securite > joueurs.size():
			return false
	return true
	
func trouver_cycle() -> Array:
	var cycle: Array = []
	for joueur in joueurs:
		if joueurs[joueur].size() > 1:
			cycle.append(joueur)
			cycle.append(joueurs[joueur][1][0])
			break
	if cycle.is_empty():
		return cycle
	var debut: String = cycle[0]
	while cycle[0] == debut:
		cycle.append(joueurs[cycle.back()].back()[0])
		if cycle.back() == debut:
			cycle.remove_at(0)
			break
		cycle.append(joueurs[cycle.back()][1][0])
		if cycle.size() > joueurs.size():
			return ["passer"]
	return cycle


func phase1() -> bool:
	var compteur_securite: int = 0
	while (not propositions_toutes_faites()) and (not propositions_toutes_recues()):
		for joueur in joueurs:
			var favori: String = trouver_favori(joueur)
			if  favori != "vide":
				assigner_a(joueur, favori)
				var successeurs: Array = trouver_successeurs(favori, joueur)
				for successeur in successeurs:
					supprimer_paire(favori, successeur)
					if liste_vide(successeur):
						return false
			if propositions_toutes_faites():
				return true
		compteur_securite += 1
		if compteur_securite > joueurs.size():
			return false
	return true

func test_stabilite() -> bool:
	for joueur in joueurs:
		if joueurs[joueur].size() != 1:
			return false
	return true
	
func liste_vide(nom: String) -> bool:
	if joueurs[nom].is_empty():
		return true
	return false

func supprimer_paire(a: String, b: String) -> void:
	for j in joueurs[a]:
		if j[0] == b:
			joueurs[a].remove_at(joueurs[a].find(j))
	for j in joueurs[b]:
		if j[0] == a:
			joueurs[b].remove_at(joueurs[b].find(j))

func trouver_successeurs(liste: String, joueur: String) -> Array:
	var index_joueur: int = -1
	for j in joueurs[liste]:
		index_joueur += 1
		if j[0] == joueur:
			break
	if index_joueur + 1 >= joueurs[liste].size():
		return []
	var successeurs: Array
	for j in joueurs[liste].slice(index_joueur + 1, joueurs[liste].size(), 1, true):
		successeurs.append(j[0])
	return successeurs

func trouver_favori(joueur: String) -> String:
	for j in joueurs[joueur]:
		if j[1] == 0:
			return j[0]
	return "vide"

func assigner_a(p: String, q: String) -> void:
	for j in joueurs[p]:
		if j[0] == q:
			j[1] = -1
	for j in joueurs[q]:
		if j[0] == p:
			j[1] = -2
	
func propositions_toutes_faites() -> bool:
	for joueur in joueurs:
		var p = false
		for j in joueurs[joueur]:
			if j[1] == -1:
				p = true
				break
		if not p:
			return false
	return true

func propositions_toutes_recues() -> bool:
	for joueur in joueurs:
		var p = false
		for j in joueurs[joueur]:
			if j[1] == -2:
				p = true
				break
		if not p:
			return false
	return true

func initialiser_matrice() -> void:
	joueurs.clear()
	var N: int = Globals.nombre_eleves
	for i in range(N):
		var nouveau: Array
		for j in range(N):
			if Globals.noms_eleves[i] != Globals.noms_eleves[j]:
				var valeur: int = Globals.tableau_relations[i * N + j]
				nouveau.append([Globals.noms_eleves[j], valeur])
		if N % 2 != 0:
			nouveau.append(["seul", 0])
		nouveau.shuffle()
		nouveau.sort_custom(func(a, b): return a[1] > b[1])
		joueurs[Globals.noms_eleves[i]] = nouveau
	for joueur in joueurs:
		for j in joueurs[joueur]:
			if j[1] < 0:
				supprimer_paire(joueur, j[0])
			else:
				j[1] = 0	
	if N % 2 != 0:
		var nouveau: Array
		for i in range(N):
			nouveau.append([Globals.noms_eleves[i], 0])
		nouveau.shuffle()
		joueurs["seul"] = nouveau
	

func imprimer_joueurs() -> void:
	for joueur in joueurs:
		print(joueur, " : ", joueurs[joueur])
	print("\n")
