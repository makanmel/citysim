class_name LocalizationManager
extends Node

enum Language { EN, UK }

var current_language: Language = Language.EN
var translations: Dictionary = {
	Language.EN: {
		"money": "Money",
		"buildings": "Buildings",
		"citizens": "Citizens",
		"residential": "Residential",
		"stone_road": "Stone Road",
		"bulldozer": "Bulldozer",
		"save_game": "Save Game",
		"load_game": "Load Game",
		"residential_tooltip": "Residential building",
		"stone_road_tooltip": "Stone road",
		"bulldozer_tooltip": "Bulldozer",
		"save_tooltip": "Save",
		"load_tooltip": "Load"
	},
	Language.UK: {
		"money": "Гроші",
		"buildings": "Будинки",
		"citizens": "Громадяни",
		"residential": "Житловий",
		"stone_road": "Бруківка",
		"bulldozer": "Бульдозер",
		"save_game": "Зберегти",
		"load_game": "Завантажити",
		"residential_tooltip": "Житловий будинок",
		"stone_road_tooltip": "Бруківка",
		"bulldozer_tooltip": "Бульдозер",
		"save_tooltip": "Зберегти",
		"load_tooltip": "Завантажити"
	}
}

signal language_changed(language: Language)

func get_text(key: String) -> String:
	if translations.has(current_language) and translations[current_language].has(key):
		return translations[current_language][key]
	return key  # Return key as fallback

func set_language(language: Language) -> void:
	current_language = language
	language_changed.emit(language)
