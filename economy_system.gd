class_name EconomySystem
extends Node

signal money_changed(new_amount: int)
signal income_received(amount: int)
signal buildings_count_changed(count: int)
signal citizens_count_changed(count: int)
signal building_citizens_changed(pos: Vector2i, count: int)
signal citizens_added_to_building(pos: Vector2i, amount: int)
signal citizens_removed_from_building(pos: Vector2i, amount: int)

const START_MONEY: int = 10000000
const INCOME_PER_BUILDING: int = 10000
const INCOME_PER_CITIZEN: int = 1000
const MAX_CITIZENS_PER_HOUSE: int = 10

var money: int = START_MONEY
var buildings_count: int = 0
var citizens_count: int = 0
var placement_manager: PlacementManager
var citizens_per_building: Dictionary = {}  # Vector2i -> int

func _ready() -> void:
	placement_manager = get_parent().get_node("PlacementManager")

func get_money() -> int:
	return money

func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		return true
	return false

func add_building() -> void:
	buildings_count += 1
	buildings_count_changed.emit(buildings_count)

func add_citizens(amount: int) -> void:
	citizens_count += amount
	citizens_count_changed.emit(citizens_count)

func add_citizens_to_building(pos: Vector2i, amount: int) -> void:
	if not citizens_per_building.has(pos):
		citizens_per_building[pos] = 0
	
	var current: int = citizens_per_building[pos]
	var new_count: int = min(current + amount, MAX_CITIZENS_PER_HOUSE)
	
	var added: int = new_count - current
	citizens_per_building[pos] = new_count
	
	if added > 0:
		citizens_count += added
		citizens_count_changed.emit(citizens_count)
		building_citizens_changed.emit(pos, new_count)
		citizens_added_to_building.emit(pos, added)

func remove_citizens_from_building(pos: Vector2i, amount: int) -> void:
	if citizens_per_building.has(pos):
		var current: int = citizens_per_building[pos]
		var new_count: int = max(0, current - amount)
		
		var removed: int = current - new_count
		citizens_per_building[pos] = new_count
		
		if removed > 0:
			citizens_count -= removed
			citizens_count_changed.emit(citizens_count)
			building_citizens_changed.emit(pos, new_count)
			citizens_removed_from_building.emit(pos, removed)

func get_citizens_in_building(pos: Vector2i) -> int:
	return citizens_per_building.get(pos, 0)

func calculate_income() -> int:
	var buildings_with_road: int = 0
	var citizens_in_roaded_houses: int = 0
	
	if placement_manager:
		for pos in placement_manager.buildings_positions:
			if placement_manager.has_road_nearby(pos):
				buildings_with_road += 1
				citizens_in_roaded_houses += get_citizens_in_building(pos)
	
	return (buildings_with_road * INCOME_PER_BUILDING) + (citizens_in_roaded_houses * INCOME_PER_CITIZEN)

func process_income() -> void:
	if buildings_count > 0:
		var income: int = calculate_income()
		add_money(income)
		income_received.emit(income)
