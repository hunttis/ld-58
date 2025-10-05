extends Node

signal go_to_options
signal go_to_menu
signal go_to_game
signal go_to_instructions
signal point_update(points: int, max: int)

signal sheep_coralled

signal sheep_bleating
signal global_bleat_cooldown_start
signal global_bleat_cooldown_done

signal stamina_change(value: float)
signal dog_move_state_change(value: Global.DOG_MOVE_STATE)

signal toggle_pause
