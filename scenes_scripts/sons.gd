extends Node

@export var son: bool = true

func jouer_bulle() -> void:
	if son:
		$Bulle.play()
	
func jouer_cloche() -> void:
	if son:
		$Cloche.play()
	
func jouer_impact() -> void:
	if son:
		$Impact.play()
	
func jouer_page() -> void:
	if son:
		$Page.play()

func _on_aide_a_propos_couper_son() -> void:
	son = not son
