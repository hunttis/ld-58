extends Node2D

var game_scene_file = preload("res://assets/scenes/game.tscn")
var options_scene_file = preload("res://assets/scenes/menus/options.tscn")
var main_menu_scene_file = preload("res://assets/scenes/menus/main_menu.tscn")

@onready var current_scene = $CurrentScene

func _ready():
	Events.go_to_game.connect(_on_go_to_game)
	Events.go_to_menu.connect(_on_go_to_menu)
	Events.go_to_options.connect(_on_go_to_options)

	# FIX ME
	AudioServer.set_bus_name(0, "Music")
	AudioServer.set_bus_name(1, "Sound")
	_on_go_to_menu()

func _empty_current_scene():
	for child_scene in current_scene.get_children():
		child_scene.queue_free()

func _on_go_to_game():
	_empty_current_scene()
	var game_scene = game_scene_file.instantiate()
	current_scene.add_child(game_scene)

func _on_go_to_menu():
	_empty_current_scene()
	var menu_scene = main_menu_scene_file.instantiate()
	current_scene.add_child(menu_scene)

func _on_go_to_options():
	_empty_current_scene()
	var options_scene = options_scene_file.instantiate()
	current_scene.add_child(options_scene)
