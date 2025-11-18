extends CharacterBody2D

@export var move:GUIDEAction =\
	 load("res://entities/player_character/mapping_context/move_action.tres")

@export var start_jump: GUIDEAction =\
	load("res://entities/player_character/mapping_context/start_jump.tres")
	
@export var stop_jump: GUIDEAction =\
	load("res://entities/player_character/mapping_context/stop_jump.tres")

@export var mapping_context:GUIDEMappingContext =\
	 load("res://entities/player_character/mapping_context/mapping_context.tres")

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready():
	GUIDE.enable_mapping_context(mapping_context)

func _process(delta:float) -> void:
	
	if (start_jump.is_triggered()):
		$MovementModule.start_jump()
	
	if (stop_jump.is_triggered()):
		$MovementModule.stop_jump()
	
	$MovementModule.apply_horizontal_acceleration(move.value_axis_2d.normalized().x, delta)
	move_and_slide()
