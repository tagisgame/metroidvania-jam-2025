class_name AnimationController
extends Node
## Handles the character animations.

@export var target_sprite: AnimatedSprite2D

var _current_frame: int = 0

var _scheduled_animation: StringName = ""
var _frame_to_switch: int = -1
var _scheduled_frame: int = -1

func _ready() -> void:
	assert(target_sprite, "[AnimController] ERROR: No target sprite attached!")
	
	target_sprite.connect("frame_changed", func (): _update_frame())
	target_sprite.connect("animation_finished", func(): _anim_finished())
	
func _process(_delta: float) -> void:
	_change_anim_to_scheduled()

func set_dir(dir: int):
	$AnimationStateChart.set_expression_property("dir", dir)

func set_horizontal_movement(speed: int):
	$AnimationStateChart.set_expression_property("speed", speed)
	
func jump():
	$AnimationStateChart.send_event("jump")

func _on_left_state_entered() -> void:
	target_sprite.flip_h = true


func _on_right_state_entered() -> void:
	target_sprite.flip_h = false


func _on_walking_state_entered() -> void:
	_schedule_animation_change("walking")


func _on_running_state_entered() -> void:
	_schedule_animation_change("running")


func _on_moving_state_exited() -> void:
	_schedule_animation_change("idle", 4, 0)


func _update_frame() -> void:
	_current_frame = target_sprite.frame
	
func _anim_finished() -> void:
	print("Anim Finished")
	$AnimationStateChart.send_event("anim_finished")

func _change_anim_to_scheduled():
	if (_scheduled_animation != ""):
		var debug_msg: String = "Animation '%s' scheduled. " % _scheduled_animation
		
		if (_frame_to_switch == -1 || (_frame_to_switch && _frame_to_switch == _current_frame)):
			debug_msg += "Switching on frame %s, " % _current_frame
			target_sprite.play(_scheduled_animation)
			if (_scheduled_frame >= 0):
				debug_msg += "to frame %s." % _scheduled_frame
				target_sprite.set_frame_and_progress(_scheduled_frame, 0)
			else:
				debug_msg += "to current frame (%s)." % _current_frame
				target_sprite.set_frame_and_progress(_current_frame, 0)
			
			print_debug(debug_msg)
			_scheduled_animation = ""

func _schedule_animation_change(anim_name: StringName, frame_to_switch: int = -1, scheduled_frame: int = -1):
	if (!target_sprite.sprite_frames.has_animation(anim_name)):
		print_debug("%s is not a valid animation name, aborting animation schedule." % anim_name)
		return
	
	print_debug("Scheduling animation change to '%s' on frame %s to frame %s" % [anim_name, frame_to_switch, scheduled_frame])
	_scheduled_animation = anim_name
	_frame_to_switch = frame_to_switch
	_scheduled_frame = scheduled_frame

func _on_slowing_down_state_entered() -> void:
	_schedule_animation_change("slowing_down", 5, 0)


func _on_movement_module_falling_started() -> void:
	$AnimationStateChart.send_event("fall")


func _on_movement_module_jump_started() -> void:
	$AnimationStateChart.send_event("jump")


func _on_movement_module_touchdown() -> void:
	$AnimationStateChart.send_event("touchdown")


func _on_accelerating_upward_state_entered() -> void:
	_schedule_animation_change("jumping_upward")


func _on_landing_stationary_state_entered() -> void:
	_schedule_animation_change("landing_stationary")


func _on_standing_state_entered() -> void:
	_schedule_animation_change("idle")


func _on_sideways_accelerating_upward_state_entered() -> void:
	_schedule_animation_change("jumping")


func _on_landing_sideways_state_entered() -> void:
	_schedule_animation_change("landing_sideways")


func _on_slowing_down_event_received(event: StringName) -> void:
	print(event)
