class_name PickupFragment
extends PickupBase

# ==============================================================================
# VECTOR//BREAK — VECTOR FRAGMENT PICKUP
# Collectible kinetic energy currency used in Hangar Store.
# ==============================================================================

@export var fragment_value: int = 15

func can_collect(_target_node: Node2D) -> bool:
	return true

func apply_pickup(_target_node: Node2D) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("award_currency"):
		gm.award_currency(fragment_value)
	else:
		SaveManager.add_currency(fragment_value)
