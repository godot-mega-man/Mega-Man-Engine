extends Pickups


const HLTH = 2


func _on_LifeEnergySmall_collected_by_player(player_obj) -> void:
	if player_obj is Player:
		player_obj.heal(HLTH)
