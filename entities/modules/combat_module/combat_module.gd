@tool
@icon("res://entities/modules/combat_module/combat_module_icon.svg")

class_name CombatModule
extends Node2D

@export var attack_moves: Array[AttackMove]

@export_category("Health Component")
@export_group("Health")

## The upper limit of health the Entity can have (including buffs) [br]
## If set to [code]-1[/code] - there is no limit.
@export var health_points_cap: int = -1

## The maximum amount of health points the Entity can have (without buffs) [br]
## Must be lower than [member CombatModule.health_points_cap] if cap is set.
@export var max_health_points: int

## The amount of health points the Entity starts the life with. [br]
## Must be lower or equal than [member CombatModule.max_health_points]. [br][br]
## Defaults to [member CombatModule.max_health_points].
@export var starting_health_points: int = max_health_points

@export_category("Attached Modules")
@export var _animation_controller: AnimationController
@export var _movement_module: MovementModule

@export_category("Damage Hitbox")
@export var hitbox_position: Vector2 = Vector2.ZERO :
	set(val):
		_hitbox_position_changed()
		hitbox_position = val

var _hitbox_dictionary: Dictionary[StringName, DamageHitbox]

var _attack_dictionary: Dictionary[AttackMove.AttackTypes, Dictionary]

var _scheduled_attack: AttackMove

@onready var _parent_entity: CharacterBody2D = get_parent()

func _ready() -> void:
	assert(_parent_entity is CharacterBody2D, "Error: CombatModule must be a child of a valid entity!")
	
	$DamageHitbox.position = hitbox_position
	
	for child_node in get_children():
		if child_node is DamageHitbox:
			_hitbox_dictionary.set(child_node.name, child_node)
			
	assert(!_hitbox_dictionary.is_empty(), "Error: CombatModule must have at least one Damage Hitbox assigned!")
	
	var new_anim_lib: AnimationLibrary = AnimationLibrary.new()
	for attack_move in attack_moves:
		if _attack_dictionary.has(attack_move.attack_type):
			_attack_dictionary[attack_move.attack_type].set(attack_move.attack_name, attack_move)
		else:
			var attacks_of_type: Dictionary
			attacks_of_type.set(attack_move.attack_name, attack_move)
			_attack_dictionary.set(attack_move.attack_type, attacks_of_type)
		
		new_anim_lib.add_animation(attack_move.attack_name, attack_move.hitbox_animation)
	
	$AnimationPlayer.add_animation_library("Combat", new_anim_lib)
	
	if (_attack_dictionary.is_empty()):
		push_warning("Warning: Just FYI, '%s' entity's  CombatModule has no attacks assigned, it still works tho." % _parent_entity.name)

func _process(delta: float) -> void:
	$DamageHitbox.position = hitbox_position + $DamageHitbox.position_offset

## Can be called to request an attackmove of specified type and optionally name. [br]
## If [param name] is not specified, the attack is randomly choses from available of such type.
func request_attack(type: AttackMove.AttackTypes, dir: Vector2i, name: StringName = "") -> void:
	if (!_attack_dictionary.has(type) || _attack_dictionary[type].is_empty()):
		push_warning("'%s' entity's CombatModule has no attacks of type '%s'. But that's fine innit?" % [_parent_entity.name, type])
	
	var attack: AttackMove
	
	if (name != "" && _attack_dictionary[type].has(name)):
		attack = _attack_dictionary[type][name]
	else:
		var randomised_key: StringName = _attack_dictionary[type].keys().pick_random()
		attack = _attack_dictionary[type][randomised_key]
		
	_scheduled_attack = attack
	$StateChart.set_expression_property("attack_requested", true)
	$StateChart.send_event("start_attack")

func _hitbox_position_changed():
	$DamageHitbox.position = hitbox_position

func _start_attack() -> void:
	_scheduled_attack.on_attack_start(_parent_entity, self)
	
	if _animation_controller:
		_animation_controller.request_attack_animation(_scheduled_attack)
		_animation_controller.animation_switched.connect(_activate_attack)
		_animation_controller.animation_finished.connect(_finish_attack)
	else:
		$StateChart.send_event("attack_started")
		
func _activate_attack(anim_name: StringName) -> void:
	if anim_name != _scheduled_attack.sprite_animation_name: return
	
	$AnimationPlayer.play("melee_punch_anim")
	$StateChart.send_event("attack_started")

func _finish_attack() -> void:
	$StateChart.set_expression_property("attack_requested", false)
	$StateChart.send_event("finish_attack")
