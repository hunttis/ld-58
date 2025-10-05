extends Node2D

var game_scene_file = preload("res://assets/scenes/game.tscn")
var options_scene_file = preload("res://assets/scenes/menus/options.tscn")
var instructions_scene_file = preload("res://assets/scenes/menus/instructions.tscn")
var main_menu_scene_file = preload("res://assets/scenes/menus/main_menu.tscn")
var game_end_scene_file = preload("res://assets/scenes/menus/game_end_screen.tscn")

var current_scene_type: Scenes
var musicOn = 0
var musicOff = -80

enum Scenes {
  Main_Menu,
  Options,
  Game,
  GameEnd,
  Instructions
}

@export var default_scene: Scenes = Scenes.Main_Menu
@onready var current_scene = $CurrentScene
@onready var titleMusic = $"AudioStreamPlayerTitle"
@onready var gameMusic = $"AudioStreamPlayerGame"


func _ready():
  Events.go_to_game.connect(_on_go_to_game)
  Events.go_to_menu.connect(_on_go_to_menu)
  Events.go_to_options.connect(_on_go_to_options)
  Events.go_to_instructions.connect(_on_go_to_instructions)

  match default_scene:
    Scenes.Main_Menu:
      _on_go_to_menu()
    Scenes.Options:
      _on_go_to_options()
    Scenes.Game:
      _on_go_to_game()
    Scenes.Instructions:
      _on_go_to_instructions()

  gameMusic.volume_db = musicOff

func _empty_current_scene():
  for child_scene in current_scene.get_children():
    child_scene.queue_free()

func _on_go_to_game():
  _empty_current_scene()
  var game_scene = game_scene_file.instantiate()
  current_scene.add_child(game_scene)
  current_scene_type = Scenes.GameEnd
  game_scene.level_failed.connect(_on_game_end)
  game_scene.level_complete.connect(_on_game_end)
  update_music()

func _on_game_end():
  _empty_current_scene()
  var game_end_scene = game_end_scene_file.instantiate()
  current_scene.add_child(game_end_scene)
  current_scene_type = Scenes.Game


func _on_go_to_menu():
  _empty_current_scene()
  var menu_scene = main_menu_scene_file.instantiate()
  current_scene.add_child(menu_scene)
  current_scene_type = Scenes.Main_Menu
  update_music()

func _on_go_to_options():
  _empty_current_scene()
  var options_scene = options_scene_file.instantiate()
  current_scene.add_child(options_scene)
  current_scene_type = Scenes.Options
  update_music()

func _on_go_to_instructions():
  _empty_current_scene()
  var instructions_scene = instructions_scene_file.instantiate()
  current_scene.add_child(instructions_scene)
  current_scene_type = Scenes.Instructions
  update_music()
    
func update_music():
    match current_scene_type:
        Scenes.Game:
            titleMusic.volume_db = musicOff
            gameMusic.volume_db = musicOn
        Scenes.Main_Menu:
            titleMusic.volume_db = musicOn
            gameMusic.volume_db = musicOff
        Scenes.Options:
            titleMusic.volume_db = musicOn
            gameMusic.volume_db = musicOff
        _:
            titleMusic.volume_db = musicOn
            gameMusic.volume_db = musicOff
