extends Node2D

var label: Label

func _ready() -> void:
	label = $Label

func set_count(count: int) -> void:
	if label:
		label.text = str(count)
