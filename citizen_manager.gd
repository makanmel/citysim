class_name CitizenManager
extends Node

const CITIZENS_PER_SPAWN: int = 1
const SPAWN_INTERVAL: float = 1.0
const SPAWN_CHANCE: float = 0.1  # chance to spawn citizens each interval
const DECREASE_CHANCE: float = 0.08  # chance to decrease citizens each interval

var placement_manager: PlacementManager
var economy: EconomySystem
var spawn_timer: float = 0.0

func _ready() -> void:
	placement_manager = get_parent().get_node("PlacementManager")
	economy = get_parent().get_node("EconomySystem")
	
	placement_manager.building_placed.connect(_on_building_placed)

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= SPAWN_INTERVAL:
		spawn_timer = 0.0
		try_spawn_citizens()

func try_spawn_citizens() -> void:
	for building_pos in placement_manager.buildings_positions:
		# Only spawn citizens if building has road access
		if placement_manager.has_road_nearby(building_pos):
			var random_val: float = randf()
			
			# 10% chance to decrease citizens
			if random_val < DECREASE_CHANCE:
				var current_citizens: int = economy.get_citizens_in_building(building_pos)
				if current_citizens > 0:
					economy.remove_citizens_from_building(building_pos, 1)
			# 30% chance to spawn citizens
			elif random_val < SPAWN_CHANCE + DECREASE_CHANCE:
				economy.add_citizens_to_building(building_pos, CITIZENS_PER_SPAWN)

func _on_building_placed(_position: Vector2i) -> void:
	pass
