extends Node
## Handles the physics and control logic for 2DCharacter,
## including horizontal movement, jumping, and dashing.

signal jump_started
signal falling_started
signal touchdown
signal dash_started

@export var parent_entity: CharacterBody2D = get_parent()

@export_category("Horizontal movement")
@export var hor_acceleration: float = MovementConsts.DEFAULT_HORIZONTAL_ACCELERATION
@export var max_hor_velocity: float = MovementConsts.DEFAULT_MAX_HORIZONTAL_VELOCITY
@export var hor_deceleration: float = MovementConsts.DEFAULT_FRICTION_ACCELERATION 

@export_category("Vertical movement")
@export var max_jump_height_px: int = 104
@export var min_jump_height_px: int = 72
@export var max_jump_dist_px: int = 200
@export var min_jump_dist_px: int = 144
@export var max_jump_time_ms: int = MovementConsts.DEFAULT_MAX_JUMPING_TIME_MS
@export var coyote_time_ms: int = MovementConsts.DEFAULT_COYOTE_TIME_MS
@export var jump_buffer_time_ms: int = MovementConsts.DEFAULT_JUMPING_BUFFER_TIME_MS
@export var max_jumps: int = 2

@export_category("Animation control")
@export var animation_controller: AnimationController

@export_category("Dash movement")
@export var dash_target_velocity: float = 1200
@export var dash_max: int = 2
@export var current_dash_limit: int = 2
@export var dash_restore_delay: int = 6

var _gravity_for_max_jump: float
var _gravity_for_min_jump: float
var _jump_initial_velocity: float
var _jumps_left: int = 2
var _previous_dir: int = 0
var entity_facing_dir: int = 1 # 1 = right, -1 = left
#var _is_dashing: bool = false

@onready var dash_restore_timer: Timer = $DashResetTimer
@onready var jump_state: StateChart = $StateChart

#var _gravity_for_max_jump: float =	\
	#(2.0 * max_jump_height_px * max_hor_velocity * max_hor_velocity) /	\
	#(max_jump_dist_px / 2) * (max_jump_dist_px / 2)
#
#var _gravity_for_min_jump: float =	\
	#(2.0 * min_jump_height_px * max_hor_velocity * max_hor_velocity) /	\
	#(min_jump_dist_px / 2) * (min_jump_dist_px / 2)


func _ready() -> void:
	_calc_jumping_curve()


func _physics_process(_delta: float) -> void:
	if (parent_entity.is_on_floor()):
		jump_state.send_event("touchdown")
		_jumps_left = max_jumps
	else:
		jump_state.send_event("airborne")


func apply_horizontal_acceleration(axis_vector_val: float, delta: float) -> void:
	var dir: int = 1 if axis_vector_val > 0 else -1 if axis_vector_val < 0 else 0;
	if (animation_controller):
		if (parent_entity.velocity.x == 0):
			animation_controller.set_horizontal_movement(0)
		elif (absf(parent_entity.velocity.x) == max_hor_velocity):
			animation_controller.set_horizontal_movement(2)
		elif (absf(parent_entity.velocity.x) > 0):
			animation_controller.set_horizontal_movement(1)
			
		if (dir && dir != _previous_dir):
			animation_controller.set_dir(dir)
	_previous_dir = dir
	
	var target_velocity: float = 0.0 if axis_vector_val == 0.0 else max_hor_velocity * axis_vector_val
	
	if dir != 0:
		entity_facing_dir = dir
	
	target_velocity = 0.0 if axis_vector_val == 0.0  else max_hor_velocity * axis_vector_val
	var velocity_delta: float = hor_deceleration if axis_vector_val == 0.0 else hor_acceleration
	
	parent_entity.velocity.x = move_toward(parent_entity.velocity.x, target_velocity, velocity_delta * delta)


func start_jump() -> void:
	if _jumps_left > 0:
		_jumps_left -= 1
		jump_started.emit()
		jump_state.send_event("jump")


func stop_jump() -> void:
	jump_state.send_event("stop_jump")


func start_dash() -> void:
	if current_dash_limit > 0:
		current_dash_limit -= 1
		jump_state.send_event("dash")
		dash_started.emit()


func _on_is_jumping_state_physics_processing(delta: float) -> void:
	parent_entity.velocity.y -= _gravity_for_max_jump * delta
	if (parent_entity.velocity.y >= 0.0):
		jump_state.send_event("stop_jump")


func _on_is_falling_state_physics_processing(delta: float) -> void:
		parent_entity.velocity.y -= _gravity_for_min_jump * delta


func _on_is_jumping_state_entered() -> void:
	parent_entity.velocity.y = 0
	parent_entity.velocity.y -= _jump_initial_velocity


func _calc_jumping_curve() -> void:
	var max_h: float = max_jump_height_px
	var min_h: float = min_jump_height_px
	var vx: float = max_hor_velocity
	var max_xh: float = max_jump_dist_px / 2.0
	var min_xh: float = min_jump_dist_px / 2.0
	
	_jump_initial_velocity = (2 * max_h * vx) / max_xh
	
	var vx_sqrd: float = vx * vx
	var max_xh_sqrd: float = max_xh * max_xh
	var min_xh_sqrd: float = min_xh * min_xh
	
	_gravity_for_max_jump = (-2 * max_h * vx_sqrd) / max_xh_sqrd

	_gravity_for_min_jump = (-2 * min_h * vx_sqrd) / min_xh_sqrd


func _on_is_in_air_state_entered() -> void:
	falling_started.emit()


func _on_is_on_ground_state_entered() -> void:
	touchdown.emit()
	print (_gravity_for_min_jump)


func _on_is_dashing_state_entered():
	#_is_dashing = true
	
	parent_entity.velocity.y = 0
	parent_entity.velocity.x = entity_facing_dir * dash_target_velocity
	
	
func _on_is_dashing_state_exited():
	#_is_dashing = false
	
	if $DashResetTimer.is_stopped() and current_dash_limit < dash_max:
		dash_restore_timer.start(dash_restore_delay)
		
		
func _on_dash_reset_timer_timeout():
	current_dash_limit += 1
	print("dash restored, now player has: ", current_dash_limit)
	if current_dash_limit < dash_max:
		dash_restore_timer.start(dash_restore_delay)
		
