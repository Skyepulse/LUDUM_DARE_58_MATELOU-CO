extends Node2D

@onready var hitbox: Area2D = $HitBox
@onready var button_sprite: Sprite2D = $Visual

@export var suspicion_increase_one_shot: float = 10.0

func _on_hit_box_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		return
	return


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		if GameManager.isHandRetracting():
			return
		GameManager.increaseSuspicion(suspicion_increase_one_shot)
		Signals.emit_signal("activate_vignette_effect")
		return
	return
