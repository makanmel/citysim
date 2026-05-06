extends Node2D

@onready var ground: TileMapLayer = $GroundTileMapLayer
@onready var tilemap: TileMapLayer = $BuildingTileMapLayer
@onready var economy = $EconomySystem
@onready var tool_manager = $ToolManager
@onready var placement_manager = $PlacementManager
@onready var floating_text_scene: PackedScene = preload("res://FloatingText.tscn")
@onready var citizen_label_scene: PackedScene = preload("res://CitizenLabel.tscn")
@onready var money_label: Label = $CanvasLayer/MoneyLabel
@onready var money_value: Label = $CanvasLayer/MoneyValue
@onready var buildings_label: Label = $CanvasLayer/BuildingsLabel
@onready var buildings_value: Label = $CanvasLayer/BuildingsValue
@onready var citizens_label: Label = $CanvasLayer/CitizensLabel
@onready var citizens_value: Label = $CanvasLayer/CitizensValue

var citizen_labels: Dictionary = {}  # Vector2i -> Node


func _ready() -> void:
	for x in range(-20, 20):
		for y in range(-20, 20):
			# Skip left column (x=0) where menu is
			if x == 0:
				continue
			ground.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	
	economy.income_received.connect(_on_income_received)
	economy.building_citizens_changed.connect(_on_building_citizens_changed)
	economy.buildings_count_changed.connect(_on_buildings_count_changed)
	economy.citizens_count_changed.connect(_on_citizens_count_changed)
	economy.money_changed.connect(_on_money_changed)
	economy.citizens_added_to_building.connect(_on_citizens_added_to_building)
	economy.citizens_removed_from_building.connect(_on_citizens_removed_from_building)
	placement_manager.placed.connect(_on_placed)
	placement_manager.building_removed.connect(_on_building_removed)
	placement_manager.placement_failed.connect(_on_placement_failed)
	
	# Initialize money display
	money_value.text = format_money(economy.get_money())
	
	# Connect to save manager for load completion
	var save_manager: Node = get_node("SaveManager")
	if save_manager.has_signal("game_loaded"):
		save_manager.game_loaded.connect(_on_game_loaded)


func _input(event) -> void:
	if event is InputEventMouseButton and event.pressed:
		var current_tool: int = tool_manager.get_tool()
		
		if current_tool == 0:  # ToolManager.ToolType.NONE
			return
		
		var pos: Vector2i = tilemap.local_to_map(tilemap.get_global_mouse_position())
		placement_manager.place(pos, current_tool, economy)


func _on_timer_timeout() -> void:
	economy.process_income()


func _on_income_received(amount: int) -> void:
	spawn_floating_text("+" + str(amount), get_global_mouse_position(), Color(0.2, 1.0, 0.3))

func _on_money_changed(new_amount: int) -> void:
	money_value.text = format_money(new_amount)

func _on_buildings_count_changed(count: int) -> void:
	buildings_value.text = str(count)

func _on_citizens_count_changed(count: int) -> void:
	citizens_value.text = str(count)

func _on_citizens_added_to_building(pos: Vector2i, amount: int) -> void:
	var world_pos: Vector2 = tilemap.map_to_local(pos)
	world_pos += Vector2(-10, -28)  # Same position as citizen label
	spawn_floating_text("+" + str(amount), world_pos, Color(0.3, 0.3, 1.0))

func _on_citizens_removed_from_building(pos: Vector2i, amount: int) -> void:
	var world_pos: Vector2 = tilemap.map_to_local(pos)
	world_pos += Vector2(-10, -28)  # Same position as citizen label
	spawn_floating_text("-" + str(amount), world_pos, Color(1.0, 0.3, 0.3), 0.5)  # Slower fade rate

func format_money(value: int) -> String:
	if value >= 1_000_000_000:
		return "%.1f B" % (value / 1_000_000_000.0)
	elif value >= 1_000_000:
		return "%.1f M" % (value / 1_000_000.0)
	elif value >= 1_000:
		return "%.1f K" % (value / 1_000.0)
	else:
		return str(value)


func _on_placed(position: Vector2i, tool_type: int) -> void:
	if tool_type == 3:  # ToolManager.ToolType.BULLDOZER
		var refund: int = placement_manager.get_refund(position)
		if refund > 0:
			spawn_floating_text("+" + str(refund), get_global_mouse_position(), Color(0.2, 1.0, 0.3))
	elif tool_type == 1:  # ToolManager.ToolType.RESIDENTIAL
		var price: int = placement_manager.get_price(tool_type)
		spawn_floating_text("-" + str(price), get_global_mouse_position(), Color(1.0, 0.3, 0.3))
		create_citizen_label(position)
	else:
		var price: int = placement_manager.get_price(tool_type)
		spawn_floating_text("-" + str(price), get_global_mouse_position(), Color(1.0, 0.3, 0.3))


func _on_placement_failed(reason: String) -> void:
	print("Placement failed: ", reason)

func _on_building_citizens_changed(pos: Vector2i, count: int) -> void:
	# Only create label for actual building positions, not roads
	if not pos in placement_manager.buildings_positions:
		return
	
	# Create label if it doesn't exist
	if not citizen_labels.has(pos):
		create_citizen_label(pos)
	
	if citizen_labels.has(pos):
		var label: Node = citizen_labels[pos]
		if label and label.has_method("set_count"):
			label.set_count(count)

func _on_building_removed(position: Vector2i) -> void:
	if citizen_labels.has(position):
		var label: Node = citizen_labels[position]
		if label:
			label.queue_free()
		citizen_labels.erase(position)

func _on_game_loaded() -> void:
	# Recreate citizen labels for all loaded buildings
	for pos in placement_manager.buildings_positions:
		if not citizen_labels.has(pos):
			create_citizen_label(pos)
			var count: int = economy.get_citizens_in_building(pos)
			if citizen_labels.has(pos):
				var label: Node = citizen_labels[pos]
				if label and label.has_method("set_count"):
					label.set_count(count)


func spawn_floating_text(text: String, pos: Vector2, color: Color = Color.WHITE, fade_rate: float = 1.5) -> void:
	var ft: Node = floating_text_scene.instantiate()

	ft.text = text
	ft.global_position = pos + Vector2(0, -20)
	ft.color = color
	ft.fade_rate = fade_rate

	add_child(ft)

func create_citizen_label(pos: Vector2i) -> void:
	var label: Node = citizen_label_scene.instantiate()
	var world_pos: Vector2 = tilemap.map_to_local(pos)
	world_pos += Vector2(-10, -28)  # center of tile
	label.global_position = world_pos
	
	if label.has_method("set_count"):
		label.set_count(0)
	
	add_child(label)
	citizen_labels[pos] = label
