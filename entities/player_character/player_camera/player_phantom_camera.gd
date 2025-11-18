extends PhantomCamera2D

func _ready() -> void:
	super()
	set_follow_target(get_parent().parent_entity)
	
func process_logic(delta: float) -> void:
	super(delta)
	print("Dead zone w:", dead_zone_width)
	print("Dead zone h:", dead_zone_height)
	print("Target at:", _follow_target_position)
	print("Should follow?", _should_follow)
	print("---------------------------------------------------")
