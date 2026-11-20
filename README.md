# CitySim

A small 2D city-builder game built with **Godot 4.6** (GL Compatibility renderer).

Place residential buildings and roads, grow your population, and keep the budget positive as citizens pay into the economy over time.

## Features

- **Build tools** — residential buildings, roads, and a bulldozer for demolishing.
- **Economy** — each build costs money; populated buildings generate periodic income.
- **Citizens** — houses attract residents; per-building citizen counts are shown with floating labels.
- **Placement validation** — tiles must be free and affordable; buildings snap to a tile grid.
- **Localization** — English and Ukrainian, switchable in-game.
- **Save/Load** — persist the city via `save_manager.gd`.
- **UI** — live money / buildings / citizens counters, floating text feedback on income.

## Requirements

- [Godot 4.6+](https://godotengine.org/download) with GL Compatibility renderer support.

## Running

1. Clone the repo.
2. Open `project.godot` in the Godot editor.
3. Press **F5** (or the Play button) — main scene: `Main.tscn`.

## Controls

- Select a tool in the bottom toolbar (house / road / bulldozer).
- Left-click a tile to place or demolish.
- Language button (top bar) toggles EN/UK.

## Project structure

| File | Purpose |
|------|---------|
| `main.gd` | Bootstrap, signal wiring, UI counters |
| `economy_system.gd` | Money, income ticks, citizen accounting |
| `placement_manager.gd` | Tile validation, building/road placement, bulldozer |
| `tool_manager.gd` | Active tool state (`RESIDENTIAL`, `ROAD`, `BULLDOZER`) |
| `citizen_manager.gd` | Citizen spawn/removal per building |
| `save_manager.gd` | Save/load city state |
| `localization_manager.gd` | EN/UK translations |
| `ui_controller.gd` | Toolbar UI |
| `floating_text.gd` | Income popup labels |
| `citizen_label.gd` | Per-building resident count label |
| `assets/` | 64px and 128px tile/tool sprites |

## Notes

- The `addons/GitGodot` plugin is git-ignored; the project runs without it.
