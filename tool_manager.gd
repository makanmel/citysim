class_name ToolManager
extends Node

enum ToolType { NONE, RESIDENTIAL, ROAD, BULLDOZER }

signal tool_changed(tool_type: ToolType)

var current_tool: ToolType = ToolType.NONE
var selected_category: String = ""

func set_tool(tool_type: ToolType) -> void:
	current_tool = tool_type
	tool_changed.emit(tool_type)

func get_tool() -> ToolType:
	return current_tool

func set_category(category: String) -> void:
	selected_category = category
