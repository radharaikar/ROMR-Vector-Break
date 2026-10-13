class_name PickupNanocell
extends PickupBase

# ==============================================================================
# VECTOR//BREAK — NANOCELL HEALING PICKUP
# Restores 25 HP. Full-health players do NOT waste this pickup.
# ==============================================================================

@export var heal_amount: int = 25

func can_collect(target_node: Node2D) -> bool:
	if "current_health" in target_node and "max_health" in target_node:
		# Do not consume if player is already at full health
		if target_node.current_health >= target_node.max_health:
			return false
	return true

func apply_pickup(target_node: Node2D) -> void:
	if target_node.has_method("heal"):
		var effective_heal: int = heal_amount
		if SaveManager.is_upgrade_unlocked("upgrade_nanocell"):
			effective_heal += 10 # Emergency Nanocell upgrade bonus
		target_node.heal(effective_heal)
