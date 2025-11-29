@icon("res://entities/modules/combat_module/attack_move/attack_move_icon.svg")

class_name AttackMove

extends Resource

enum AttackTypes {
	MELEE,
	RANGED_PROJECTILE,
	RANGED_FIXED
}

@export var attack_name: StringName = ""

@export var attack_type: AttackTypes

@export var base_damage: int

@export var hitbox_animation: Animation

@export var sprite_animation_name: StringName

func on_attack_start(owner, combat_module): pass
func on_active_enter(owner, combat_module): pass
func on_active_process(owner, combat_module): pass
func on_active_exit(owner, combat_module): pass
func on_attack_end(owner, combat_module, was_cancelled: bool): pass

func on_hit_landed(owner, combat_module, target, hit_info): pass
func on_hit_whiffed(owner, combat_module): pass

func on_animation_started(): pass
func on_animation_finished(): pass
