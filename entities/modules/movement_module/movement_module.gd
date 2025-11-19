extends Node
## Handles movement, jumping and dash physics.

@export var parent_entity: CharacterBody2D = get_parent()

@export_category("Horizontal movement")
@export var hor_acceleration: float = MovementConsts.DEFAULT_HORIZONTAL_ACCELERATION
@export var max_hor_velocity: float = MovementConsts.DEFAULT_MAX_HORIZONTAL_VELOCITY
@export var hor_deceleration: float = MovementConsts.DEFAULT_FRICTION_ACCELERATION 
@export var dash_target_velocity: float = 1200

@export_category("Vertical movement")
@export var max_jump_height_px: int = 104
@export var min_jump_height_px: int = 72
@export var max_jump_dist_px: int = 200
@export var min_jump_dist_px: int = 144
@export var max_jump_time_ms: int = MovementConsts.DEFAULT_MAX_JUMPING_TIME_MS
@export var coyote_time_ms: int = MovementConsts.DEFAULT_COYOTE_TIME_MS
@export var jump_buffer_time_ms: int = MovementConsts.DEFAULT_JUMPING_BUFFER_TIME_MS


var _gravity_for_max_jump: float
var _gravity_for_min_jump: float
var _jump_initial_velocity: float
var _is_dashing: bool = false

#var _gravity_for_max_jump: float =	\
	#(2.0 * max_jump_height_px * max_hor_velocity * max_hor_velocity) /	\
	#(max_jump_dist_px / 2) * (max_jump_dist_px / 2)
#
#var _gravity_for_min_jump: float =	\
	#(2.0 * min_jump_height_px * max_hor_velocity * max_hor_velocity) /	\
	#(min_jump_dist_px / 2) * (min_jump_dist_px / 2)

@onready var jump_state: StateChart = $StateChart

func _ready() -> void:
	_calc_jumping_curve()

func _physics_process(_delta: float) -> void:
	if (parent_entity.is_on_floor()):
		jump_state.send_event("touchdown")
	else:
		jump_state.send_event("airborne")
		

func apply_horizontal_acceleration(axis_vector_val: float, delta: float) -> void:
	if _is_dashing:
		return
	
	var target_velocity: float = 0.0 if axis_vector_val == 0.0  else max_hor_velocity * axis_vector_val
	var velocity_delta: float = hor_deceleration if axis_vector_val == 0.0 else hor_acceleration
	
	parent_entity.velocity.x = move_toward(parent_entity.velocity.x, target_velocity, velocity_delta * delta)
	
	
func start_jump() -> void:
	jump_state.send_event("jump")

func stop_jump() -> void:
	jump_state.send_event("stop_jump")
	
func start_dash() -> void:
	jump_state.send_event("dash")

func _on_is_jumping_state_physics_processing(delta: float) -> void:
	parent_entity.velocity.y -= _gravity_for_max_jump * delta
	if (parent_entity.velocity.y >= 0.0):
		jump_state.send_event("stop_jump")


func _on_is_falling_state_physics_processing(delta: float) -> void:
	parent_entity.velocity.y -= _gravity_for_min_jump * delta


func _on_is_jumping_state_entered() -> void:
	parent_entity.velocity.y -= _jump_initial_velocity

func _calc_jumping_curve() -> void:
	var max_h: float = max_jump_height_px
	var min_h: float = min_jump_height_px
	var vx: float = max_hor_velocity
	var max_xh: float = max_jump_dist_px / 2.0
	var min_xh: float = min_jump_dist_px / 2.0
	
	print("t: ", max_xh / vx)
	
	_jump_initial_velocity = (2 * max_h * vx) / max_xh
	print (_jump_initial_velocity)
	
	var vx_sqrd: float = vx * vx
	var max_xh_sqrd: float = max_xh * max_xh
	var min_xh_sqrd: float = min_xh * min_xh
	
	_gravity_for_max_jump = (-2 * max_h * vx_sqrd) / max_xh_sqrd
	print (_gravity_for_max_jump)

	_gravity_for_min_jump = (-2 * min_h * vx_sqrd) / min_xh_sqrd
	print (_gravity_for_min_jump)


func _on_is_dashing_state_entered():
	_is_dashing = true
	var axis_x: float = parent_entity.move.value_axis_2d.normalized().x
	
	parent_entity.velocity.x = axis_x * dash_target_velocity
	
	
func _on_is_dashing_state_exited():
	_is_dashing = false
	parent_entity.restore_dash()
