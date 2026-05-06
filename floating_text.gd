extends Node2D

@onready var label = $FloatingLabel

var velocity = Vector2(0, -60)
var text := ""
var color := Color.WHITE
var fade_rate := 1.5

func _ready():
	label.text = text
	label.modulate = color

func _process(delta):
	position += velocity * delta

	label.modulate.a -= fade_rate * delta

	if modulate.a <= 0:
		queue_free()
