extends Node

@export var parent_entity: CharacterBody2D = get_parent()

@export_category("Horizontal movement")
@export var hor_acceleration: float = MovementConsts.DEFAULT_HORIZONTAL_ACCELERATION
@export var max_hor_velocity: float = MovementConsts.DEFAULT_MAX_HORIZONTAL_VELOCITY
@export var hor_deceleration: float = MovementConsts.DEFAULT_FRICTION_ACCELERATION

@export_category("Vertical movement")
@export var initial_jump_velocity: float = 600
@export var jump_acceleration: float = MovementConsts.DEFAULT_JUMP_ACCELERATION
@export var grav_acceleration: float = MovementConsts.DEFAULT_GRAVITATIONAL_ACCELERATION
@export var max_vert_velocity: float = MovementConsts.DEFAULT_MAX_VERTICAL_VELOCITY
@export var max_jump_time_ms: int = MovementConsts.DEFAULT_MAX_JUMPING_TIME_MS
@export var coyote_time_ms: int = MovementConsts.DEFAULT_COYOTE_TIME_MS
@export var jump_buffer_time_ms: int = MovementConsts.DEFAULT_JUMPING_BUFFER_TIME_MS

@onready var jump_state: StateChart = $StateChart

func _physics_process(delta: float) -> void:
	
	if (parent_entity.is_on_floor()):
		jump_state.send_event("touchdown")
	else:
		jump_state.send_event("airborne")
		

func apply_horizontal_acceleration(axis_vector_val: float, delta: float) -> void:
	var target_velocity: float = 0.0 if axis_vector_val == 0.0 else max_hor_velocity * axis_vector_val
	var velocity_delta: float = hor_deceleration if axis_vector_val == 0.0 else hor_acceleration
	
	parent_entity.velocity.x = move_toward(parent_entity.velocity.x, target_velocity, velocity_delta * delta)

func start_jump() -> void:
		jump_state.send_event("jump")

func stop_jump() -> void:
	jump_state.send_event("stop_jump")

func _on_is_jumping_state_physics_processing(delta: float) -> void:
	parent_entity.velocity.y = move_toward(parent_entity.velocity.y, -max_vert_velocity, jump_acceleration * delta)


func _on_is_falling_state_physics_processing(delta: float) -> void:
	parent_entity.velocity.y = move_toward(parent_entity.velocity.y, max_vert_velocity, grav_acceleration * delta)


func _on_is_jumping_state_entered() -> void:
	parent_entity.velocity.y -= initial_jump_velocity
