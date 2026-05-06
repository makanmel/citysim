class_name PlacementManager
extends Node

signal placed(position: Vector2i, tool_type: int)
signal placement_failed(reason: String)
signal building_placed(position: Vector2i)
signal road_placed(position: Vector2i)
signal building_removed(position: Vector2i)
signal road_removed(position: Vector2i)

const RESIDENTIAL_PRICE: int = 1000000
const ROAD_PRICE: int = 100000
const BULLDOZER_REFUND_RATIO: float = 0.5

@onready var building_tilemap: TileMapLayer = get_parent().get_node("BuildingTileMapLayer")
@onready var road_tilemap: TileMapLayer = get_parent().get_node("RoadTileMapLayer")

var buildings_positions: Array[Vector2i] = []
var roads_positions: Array[Vector2i] = []

func get_tilemap(tool_type: int) -> TileMapLayer:
	match tool_type:
		1:  # ToolManager.ToolType.RESIDENTIAL
			return building_tilemap
		2:  # ToolManager.ToolType.ROAD
			return road_tilemap
		_:
			return building_tilemap

func can_place(pos: Vector2i, tool_type: int, economy) -> bool:
	# Bulldozer doesn't need money check
	if tool_type == 3:  # ToolManager.ToolType.BULLDOZER
		return can_bulldoze(pos)
	
	var tilemap: TileMapLayer = get_tilemap(tool_type)
	
	# Restrict placement to playground area (starting from 130px, which is x>=1 in tiles)
	if pos.x < 1:
		placement_failed.emit("Cannot build in menu area")
		return false
	
	# Check if position is occupied in either tilemap
	var building_source: int = building_tilemap.get_cell_source_id(pos)
	var road_source: int = road_tilemap.get_cell_source_id(pos)
	
	if building_source != -1 or road_source != -1:
		placement_failed.emit("Cell occupied")
		return false
	
	var price: int = get_price(tool_type)
	if economy.get_money() < price:
		placement_failed.emit("Not enough money")
		return false
	
	return true

func can_bulldoze(pos: Vector2i) -> bool:
	var building_source: int = building_tilemap.get_cell_source_id(pos)
	var road_source: int = road_tilemap.get_cell_source_id(pos)
	
	if building_source == -1 and road_source == -1:
		placement_failed.emit("Nothing to bulldoze")
		return false
	
	return true

func place(pos: Vector2i, tool_type: int, economy) -> bool:
	if not can_place(pos, tool_type, economy):
		return false
	
	# Handle bulldozer
	if tool_type == 3:  # ToolManager.ToolType.BULLDOZER
		return bulldoze(pos, economy)
	
	var price: int = get_price(tool_type)
	if not economy.spend_money(price):
		return false
	
	var tilemap: TileMapLayer = get_tilemap(tool_type)
	var atlas_coords: Vector2i = get_atlas_coords(tool_type)
	var source_id: int = get_source_id(tool_type)
	tilemap.set_cell(pos, source_id, atlas_coords)
	
	if tool_type == 1:  # ToolManager.ToolType.RESIDENTIAL
		economy.add_building()
		buildings_positions.append(pos)
		building_placed.emit(pos)
	elif tool_type == 2:  # ToolManager.ToolType.ROAD
		roads_positions.append(pos)
		road_placed.emit(pos)
	
	placed.emit(pos, tool_type)
	return true

func bulldoze(pos: Vector2i, economy) -> bool:
	var building_source: int = building_tilemap.get_cell_source_id(pos)
	var road_source: int = road_tilemap.get_cell_source_id(pos)
	
	if building_source != -1:
		building_tilemap.erase_cell(pos)
		buildings_positions.erase(pos)
		economy.buildings_count -= 1
		economy.buildings_count_changed.emit(economy.buildings_count)
		
		# Remove all citizens from this building
		economy.remove_citizens_from_building(pos, economy.MAX_CITIZENS_PER_HOUSE)
		
		var refund: int = int(RESIDENTIAL_PRICE * BULLDOZER_REFUND_RATIO)
		economy.add_money(refund)
		building_removed.emit(pos)
		placed.emit(pos, 3)
		return true
	
	if road_source != -1:
		road_tilemap.erase_cell(pos)
		roads_positions.erase(pos)
		
		# Check if any buildings lose road access and decrease population
		check_and_decrease_population(economy)
		
		var refund: int = int(ROAD_PRICE * BULLDOZER_REFUND_RATIO)
		economy.add_money(refund)
		road_removed.emit(pos)
		placed.emit(pos, 3)
		return true
	
	return false

func check_and_decrease_population(economy) -> void:
	for building_pos in buildings_positions:
		if not has_road_nearby(building_pos):
			# Building lost road access - mark as not roaded
			# Citizens won't increase anymore, but won't be removed
			pass

func get_price(tool_type: int) -> int:
	match tool_type:
		1:  # ToolManager.ToolType.RESIDENTIAL
			return RESIDENTIAL_PRICE
		2:  # ToolManager.ToolType.ROAD
			return ROAD_PRICE
		_:
			return 0

func get_source_id(tool_type: int) -> int:
	match tool_type:
		1:  # ToolManager.ToolType.RESIDENTIAL
			return 1  # Use single source for now
		2:  # ToolManager.ToolType.ROAD
			return 1
		_:
			return 1

func get_atlas_coords(tool_type: int) -> Vector2i:
	match tool_type:
		1:  # ToolManager.ToolType.RESIDENTIAL
			return Vector2i(0, 0)
		2:  # ToolManager.ToolType.ROAD
			return Vector2i(0, 0)
		_:
			return Vector2i(0, 0)

func get_refund(pos: Vector2i) -> int:
	var building_source: int = building_tilemap.get_cell_source_id(pos)
	var road_source: int = road_tilemap.get_cell_source_id(pos)
	
	if building_source != -1:
		return int(RESIDENTIAL_PRICE * BULLDOZER_REFUND_RATIO)
	
	if road_source != -1:
		return int(ROAD_PRICE * BULLDOZER_REFUND_RATIO)
	
	return 0

func has_road_nearby(pos: Vector2i) -> bool:
	var neighbors: Array[Vector2i] = [
		pos + Vector2i(1, 0),
		pos + Vector2i(-1, 0),
		pos + Vector2i(0, 1),
		pos + Vector2i(0, -1)
	]
	
	for neighbor in neighbors:
		if neighbor in roads_positions:
			return true
	
	return false
