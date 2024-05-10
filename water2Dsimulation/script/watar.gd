extends Node2D

var pointer: bool = false
var attrForce: float = 500

func _ready() -> void:
	get_tree().paused = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_reset"):
		get_tree().paused = true
		get_tree().reload_current_scene()
