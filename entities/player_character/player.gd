extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


@export var move:GUIDEAction =\
	 load("res://entities/player_character/mapping_context/move_action.tres")

@export var start_jump: GUIDEAction =\
	load("res://entities/player_character/mapping_context/start_jump.tres")
	
@export var stop_jump: GUIDEAction =\
	load("res://entities/player_character/mapping_context/stop_jump.tres")
	
@export var start_dash: GUIDEAction =\
	load("res://entities/player_character/mapping_context/start_dash.tres")

@export var mapping_context:GUIDEMappingContext =\
	 load("res://entities/player_character/mapping_context/mapping_context.tres")

@export var dash_max: int = 2
@export var current_dash_limit: int = 2
@export var dash_restore_delay: int = 6

@onready var dash_restore_timer: Timer = $DashResetTimer


func _ready():
	GUIDE.enable_mapping_context(mapping_context)

func _process(_delta:float) -> void:
	if (start_jump.is_triggered()):
		$MovementModule.start_jump()
	
	if (stop_jump.is_triggered()):
		$MovementModule.stop_jump()
		
	if (start_dash.is_triggered()) and current_dash_limit > 0:
		current_dash_limit -= 1
		print("Dash used! Now player has: ", current_dash_limit)
		$MovementModule.start_dash()
	
func _physics_process(delta: float) -> void:
	$MovementModule.apply_horizontal_acceleration(move.value_axis_2d.normalized().x, delta)
	move_and_slide()
	
func restore_dash():
	if $DashResetTimer.is_stopped() and current_dash_limit < dash_max:
		dash_restore_timer.start(dash_restore_delay)
	
func _on_dash_cooldown_timer_timeout():
	current_dash_limit += 1
	print("dash restored, now player has: ", current_dash_limit)
	if current_dash_limit < dash_max:
		dash_restore_timer.start(dash_restore_delay)
