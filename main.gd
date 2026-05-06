extends Node2D

const PRICE: int       = 1000000
const START_MONEY: int = 10000000

var money: int               = START_MONEY
var displayed_money: float   = 0.0
var income_per_building: int = 10000
var buildings_count: int     = 0

@onready var tilemap: TileMapLayer = $BuildingTileMapLayer
@onready var ground: TileMapLayer = $GroundTileMapLayer
@onready var money_label: Label = $CanvasLayer/MoneyLabel
@onready var floating_text_scene: PackedScene = preload("res://FloatingText.tscn")


func _ready():
    for x in range(-20, 20):
        for y in range(-20, 20):
            ground.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))


func _input(event) -> void:
    if event is InputEventMouseButton and event.pressed:
        var pos: Vector2i    = tilemap.local_to_map(tilemap.get_global_mouse_position())
        var cell_source: int = tilemap.get_cell_source_id(pos)

        if cell_source != -1:
            return # cell occupied

        if money >= PRICE:
            tilemap.set_cell(pos, 1, Vector2i(0, 0))
            money -= PRICE
            spawn_floating_text("-" + str(PRICE), get_global_mouse_position())
            buildings_count += 1


func _on_timer_timeout():
    if buildings_count > 0:
        var income = buildings_count * income_per_building
        money += income
        spawn_floating_text("+" + str(income), get_global_mouse_position())


func format_money(value: int) -> String:
    if value >= 1_000_000_000:
        return "%.1f B" % (value / 1_000_000_000.0)
    elif value >= 1_000_000:
        return "%.1f M" % (value / 1_000_000.0)
    elif value >= 1_000:
        return "%.1f K" % (value / 1_000.0)
    else:
        return str(value)


func _process(delta):
    displayed_money = lerp(displayed_money, float(money), 10 * delta)
    money_label.text = "Buildings: %d | Money: %s" % [
    buildings_count,
    format_money(int(displayed_money))
    ]


func spawn_floating_text(text: String, pos: Vector2):
    var ft: Node = floating_text_scene.instantiate()

    ft.text = text
    ft.global_position = pos + Vector2(0, -20)

    if text.begins_with("+"):
        ft.color = Color(0.2, 1.0, 0.3)
    else:
        ft.color = Color(1.0, 0.3, 0.3)

    add_child(ft)
