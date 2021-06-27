extends Pickups


const ENERGY = 10


onready var palette_sprite := $SpriteMain/Sprite/PaletteSprite


func _on_WeaponEnergyLarge_collected_by_player(player_obj) -> void:
	if player_obj is Player:
		player_obj.recover_ammo(ENERGY)


func _process(delta: float) -> void:
	palette_sprite.primary_sprite.modulate = GlobalVariables.current_player_primary_color
	palette_sprite.second_sprite.modulate = GlobalVariables.current_player_secondary_color
	palette_sprite.outline_sprite.modulate = GlobalVariables.current_player_outline_color
