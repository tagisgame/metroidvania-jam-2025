@icon("res://entities/modules/combat_module/health_component/cm_health_component_icon.svg")

class_name CM_HealthComponent
extends Node

signal lost_all_health_points
signal entity_gained_health_points(amount: int, new_health_points: int)
signal entity_lost_health_points(amount: int, new_health_points: int)

var health_points: int

@onready var _combat_module: CombatModule = get_parent()
@onready var _hitboxes: Dictionary[StringName, DamageHitbox] = _combat_module._hitbox_dictionary



func _ready() -> void:
	assert(_combat_module && _combat_module is CombatModule, "Error: CM_HealthComponent must be a child of a CombatModule!")
	
	health_points = _combat_module.starting_health_points
	
	_connect_hitbox_signals()

func heal(amount: int, modifier: float = 1) -> void:
	var calculated_heal: int = floori(amount * modifier)
	if _combat_module.health_points_cap != -1:
		health_points = clampi(health_points + calculated_heal, health_points, _combat_module.health_points_cap)
	else:
		health_points += calculated_heal
	
	entity_gained_health_points.emit(calculated_heal, health_points)

func receive_damage(amount: int, modifier: float = 1) -> void:
	var calculated_dmg: int = floori(amount * modifier)
	health_points = clampi(health_points - calculated_dmg, 0, health_points)
	
	entity_lost_health_points.emit(calculated_dmg, health_points)
	
	_check_death()
	
func _on_hitbox_area_entered(area: Area2D):
	pass

func _connect_hitbox_signals():
	for hitbox_key in _hitboxes:
		_hitboxes[hitbox_key].area_entered.connect(_on_hitbox_area_entered)

func _check_death() -> bool:
	if health_points <= 0:
		lost_all_health_points.emit()
		return true
	return false
