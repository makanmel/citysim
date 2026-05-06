class_name SaveManager
extends Node

const SAVE_FILE_PATH: String = "user://city_save.json"

signal game_loaded()

var economy: EconomySystem
var placement_manager: PlacementManager
var tool_manager: ToolManager

func _ready() -> void:
	economy = get_parent().get_node("EconomySystem")
	placement_manager = get_parent().get_node("PlacementManager")
	tool_manager = get_parent().get_node("ToolManager")

func save_game() -> void:
	# Convert Vector2i arrays to serializable format
	var buildings_serialized: Array = []
	for pos in placement_manager.buildings_positions:
		buildings_serialized.append({"x": pos.x, "y": pos.y})
	
	var roads_serialized: Array = []
	for pos in placement_manager.roads_positions:
		roads_serialized.append({"x": pos.x, "y": pos.y})
	
	# Serialize citizens per building
	var citizens_serialized: Array = []
	for pos in economy.citizens_per_building:
		citizens_serialized.append({
			"x": pos.x,
			"y": pos.y,
			"count": economy.citizens_per_building[pos]
		})
	
	var save_data: Dictionary = {
		"money": economy.money,
		"buildings_count": economy.buildings_count,
		"citizens_count": economy.citizens_count,
		"buildings_positions": buildings_serialized,
		"roads_positions": roads_serialized,
		"citizens_per_building": citizens_serialized,
		"current_tool": tool_manager.current_tool
	}
	
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Game saved!")

func load_game() -> void:
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_string: String = file.get_as_text()
		file.close()
		
		var json: JSON = JSON.new()
		var parse_result: int = json.parse(json_string)
		
		if parse_result == OK:
			var save_data: Dictionary = json.data
			apply_save_data(save_data)
			print("Game loaded!")
		else:
			print("Failed to parse save file!")
	else:
		print("No save file found!")

func apply_save_data(data: Dictionary) -> void:
	economy.money = data.get("money", economy.START_MONEY)
	economy.buildings_count = data.get("buildings_count", 0)
	economy.citizens_count = data.get("citizens_count", 0)
	
	# Clear and rebuild position arrays
	placement_manager.buildings_positions.clear()
	placement_manager.roads_positions.clear()
	economy.citizens_per_building.clear()
	
	var saved_buildings: Array = data.get("buildings_positions", [])
	var saved_roads: Array = data.get("roads_positions", [])
	var saved_citizens: Array = data.get("citizens_per_building", [])
	
	for pos_dict in saved_buildings:
		placement_manager.buildings_positions.append(Vector2i(pos_dict.x, pos_dict.y))
	
	for pos_dict in saved_roads:
		placement_manager.roads_positions.append(Vector2i(pos_dict.x, pos_dict.y))
	
	for citizen_data in saved_citizens:
		var pos: Vector2i = Vector2i(citizen_data.x, citizen_data.y)
		economy.citizens_per_building[pos] = citizen_data.count
	
	tool_manager.current_tool = data.get("current_tool", tool_manager.ToolType.NONE)
	
	# Rebuild tilemaps
	rebuild_tilemaps()
	
	# Emit signals for citizens per building to update labels
	for pos in economy.citizens_per_building:
		# Only emit for actual building positions
		if pos in placement_manager.buildings_positions:
			var count: int = economy.citizens_per_building[pos]
			economy.building_citizens_changed.emit(pos, count)
	
		economy.money_changed.emit(economy.money)
		economy.buildings_count_changed.emit(economy.buildings_count)
		economy.citizens_count_changed.emit(economy.citizens_count)
		tool_manager.tool_changed.emit(tool_manager.current_tool)
		
		# Notify that game has been loaded
		game_loaded.emit()

func rebuild_tilemaps() -> void:
	# Clear existing tiles
	placement_manager.building_tilemap.clear()
	placement_manager.road_tilemap.clear()
	
	print("Rebuilding ", placement_manager.buildings_positions.size(), " buildings")
	print("Rebuilding ", placement_manager.roads_positions.size(), " roads")
	
	# Rebuild buildings
	for pos in placement_manager.buildings_positions:
		placement_manager.building_tilemap.set_cell(pos, 1, Vector2i(0, 0))
	
	# Rebuild roads
	for pos in placement_manager.roads_positions:
		placement_manager.road_tilemap.set_cell(pos, 1, Vector2i(0, 0))
	
	print("Tilemap rebuild complete")

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)
