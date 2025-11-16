extends CharacterBody2D

@export var move:GUIDEAction =\
 load("res://entities/player_character/mapping_context/move_action.tres")
@export var mapping_context:GUIDEMappingContext =\
 load("res://entities/player_character/mapping_context/mapping_context.tres")

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready():
	GUIDE.enable_mapping_context(mapping_context)

func _physics_process(delta:float) -> void:
	
	position += move.value_axis_2d.normalized() * SPEED * delta
