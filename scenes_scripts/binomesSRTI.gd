#Tentative d'extension de la solution du problème des colocataires un peu selon la solution d'Irving
#(2002), un peu à ma sauce... mais... il semble que s'il existe une solution stable,
#l'algorithme le trouve, signifie que dans 99% des cas, il n'y a pas de solution.

extends Node

var A: Array[Array] = [["B", 0, 3], ["D", 0, 2], ["C", 0, 0], ["E", 0, 0]]
var B: Array[Array] = [["D", 0, 3], ["E", 0, 2], ["F", 0, 1], ["A", 0, 0], ["C", 0, 0]]
var C: Array[Array] = [["D", 0, 3], ["E", 0, 2], ["F", 0, 0], ["A", 0, 0], ["B", 0, 0]]
var D: Array[Array] = [["F", 0, 3], ["C", 0, 2], ["A", 0, 0], ["E", 0, 0], ["B", 0, 0]]
var E: Array[Array] = [["F", 0, 3], ["C", 0, 2], ["D", 0, 1], ["B", 0, 0], ["A", 0, 0]]
var F: Array[Array] = [["A", 0, 3], ["B", 0, 2], ["D", 0, 1], ["C", 0, 0], ["E", 0, 0]]
var joueurs: Dictionary = {"A": A, "B": B, "C": C, "D": D, "E": E, "F": F}

func _ready() -> void:
	irving()
	
func irving() -> void:
	if phase1() == "phase2":
		imprimer_joueurs()
	elif phase1() == "fini":
		print("appariement stable après phase 1")
		return
	else:
		print("pas d'appariement possible")
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
		print(cycle, joueurs[cycle.back()])
		cycle.append(joueurs[cycle.back()][1][0])
	return cycle


func phase1() -> String:
	var compteur_securite: int = 0
	var propositions_recues: Array = []
	while (not propositions_toutes_faites()) and (not toutes_listes_vides()):
		for joueur in joueurs:
			imprimer_joueurs()
			var favori: String = trouver_favori(joueur)
			if not favori in propositions_recues and favori != "vide":
				propositions_recues.append(favori)
			if  favori != "vide":
				assigner_a(joueur, favori)
				var successeurs: Array = trouver_successeurs(favori, joueur)
				for successeur in successeurs:
					supprimer_paire(favori, successeur)
					#if liste_vide(successeur):
						#return false
				#var tous_les_apparies: Array = trouver_les_apparies(favori)
				#if tous_les_apparies.size() > 1:
					#for apparie in tous_les_apparies:
						#if apparie == joueur:
							#supprimer_paire(favori, joueur)
						#elif est_apparie(apparie, joueur):
							#supprimer_paire(favori, apparie)
						#supprimer_appariement(apparie, favori)
						#if liste_vide(apparie):
							#return false
			if test_stabilite():
				return "fini"
			if participant_rejete(propositions_recues):
				return "impossible"
		compteur_securite += 1
		if compteur_securite > joueurs.size():
			return "impossible"
	return "phase2"

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
			
func supprimer_appariement(a: String, b: String) -> void:
	for j in joueurs[a]:
		if j[0] == b:
			j[1] = 0
	for j in joueurs[b]:
		if j[0] == a:
			j[1] = 0

func est_apparie(a: String, b: String) -> bool:
	for j in joueurs[b]:
		if j[0] == a:
			return true
	return false	

func trouver_les_apparies(joueur) -> Array:
	var apparies: Array = []
	for j in joueurs[joueur]:
		if j[1] != 0:
			apparies.append(j[0])
	return apparies
	

func trouver_successeurs(liste: String, joueur: String) -> Array:
	var force: int
	var index_successeur: int = 0
	for i in range(joueurs[liste].size() - 1):
		if joueurs[liste][i][0] == joueur:
			force = joueurs[liste][i][2]
			for j in range(i, joueurs[liste].size() - 1):
				if joueurs[liste][j + 1][2] < force:
					index_successeur = j + 1
					break
	if index_successeur == 0:
		return []
	var successeurs: Array
	for j in joueurs[liste].slice(index_successeur, joueurs[liste].size(), 1, true):
		successeurs.append(j[0])
	successeurs.reverse()
	return successeurs

func trouver_favori(joueur: String) -> String:
	if not joueurs[joueur].is_empty():
		return joueurs[joueur][0][0]
	return "vide"

func assigner_a(p: String, q: String) -> void:
	for j in joueurs[p]:
		if j[0] == q:
			j[1] = -1
	for j in joueurs[q]:
		if j[0] == p:
			j[1] = -2

func participant_rejete(liste: Array) -> bool:
	for joueur in joueurs:
		if joueurs[joueur].is_empty() and joueur in liste:
			return true
	return false
	

func toutes_listes_vides() -> bool:
	for joueur in joueurs:
		if not joueurs[joueur].is_empty():
			return false
	return true

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

#func propositions_toutes_recues() -> bool:
	#for joueur in joueurs:
		#var p = false
		#for j in joueurs[joueur]:
			#if j[1] == -2:
				#p = true
				#break
		#if not p:
			#return false
	#return true

func imprimer_joueurs() -> void:
	for joueur in joueurs:
		print(joueur, " : ", joueurs[joueur])
	print("\n")
