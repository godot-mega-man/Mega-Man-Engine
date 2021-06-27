extends Pickups


const HLTH = 10


func _on_LifeEnergyLarge_collected_by_player(player_obj) -> void:
	if player_obj is Player:
		player_obj.heal(HLTH)
