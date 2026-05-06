class_name UIController
extends Node

@onready var money_label: Label = get_parent().get_node("CanvasLayer/MoneyLabel")
@onready var residential_button: Button = get_parent().get_node("CanvasLayer/ToolPanel/ResidentialButton")
@onready var road_button: Button = get_parent().get_node("CanvasLayer/ToolPanel/RoadButton")
@onready var bulldozer_button: Button = get_parent().get_node("CanvasLayer/ToolPanel/BulldozerButton")
@onready var save_button: Button = get_parent().get_node("CanvasLayer/ToolPanel/SaveButton")
@onready var load_button: Button = get_parent().get_node("CanvasLayer/ToolPanel/LoadButton")

var economy
var tool_manager
var save_manager

func _ready() -> void:
	economy = get_parent().get_node("EconomySystem")
	tool_manager = get_parent().get_node("ToolManager")
	save_manager = get_parent().get_node("SaveManager")
	
	tool_manager.tool_changed.connect(_on_tool_changed)
	
	residential_button.pressed.connect(_on_residential_pressed)
	road_button.pressed.connect(_on_road_pressed)
	bulldozer_button.pressed.connect(_on_bulldozer_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	
	update_tool_selection()


func _on_tool_changed(tool_type: int) -> void:
	update_tool_selection()

func _on_residential_pressed() -> void:
	tool_manager.set_tool(1)  # ToolManager.ToolType.RESIDENTIAL

func _on_road_pressed() -> void:
	tool_manager.set_tool(2)  # ToolManager.ToolType.ROAD

func _on_bulldozer_pressed() -> void:
	tool_manager.set_tool(3)  # ToolManager.ToolType.BULLDOZER

func _on_save_pressed() -> void:
	save_manager.save_game()

func _on_load_pressed() -> void:
	save_manager.load_game()


func update_tool_selection() -> void:
	var current_tool: int = tool_manager.get_tool()
	
	# Reset all button colors
	reset_button_colors()
	
	# Highlight selected button
	match current_tool:
		1:  # ToolManager.ToolType.RESIDENTIAL
			residential_button.modulate = Color(0.3, 0.8, 1.0)
		2:  # ToolManager.ToolType.ROAD
			road_button.modulate = Color(0.3, 0.8, 1.0)
		3:  # ToolManager.ToolType.BULLDOZER
			bulldozer_button.modulate = Color(1.0, 0.5, 0.3)

func reset_button_colors() -> void:
	residential_button.modulate = Color(1.0, 1.0, 1.0)
	road_button.modulate = Color(1.0, 1.0, 1.0)
	bulldozer_button.modulate = Color(1.0, 1.0, 1.0)

