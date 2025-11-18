extends Camera2D

const CAMERA_DEADZONE: float = 0.12

var can_switch_cameras: bool = false

@export var parent_entity: CharacterBody2D = get_parent()

func _ready() -> void:
	$PhantomCamera2DFollowing.set_follow_target(parent_entity)
