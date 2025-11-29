extends Control

@onready var hp: int = $"../CombatModule".find_child("CmHealthComponent").health_points

func _ready() -> void:
	$Label.text = "HP: %s" % hp
	
	$"../CombatModule".find_child("CmHealthComponent").entity_gained_health_points.connect(_hp_changed)
	$"../CombatModule".find_child("CmHealthComponent").entity_lost_health_points.connect(_hp_changed)

func _hp_changed(amount: int, new_hp: int):
	hp = new_hp
	$Label.text = "HP: %s" % hp

func _on_dmg_button_pressed() -> void:
	$"../CombatModule".find_child("CmHealthComponent").receive_damage($VBoxContainer/HBoxContainer/DmgAmount.value)


func _on_heal_button_pressed() -> void:
	$"../CombatModule".find_child("CmHealthComponent").heal($VBoxContainer/HBoxContainer2/HealAmount.value)
