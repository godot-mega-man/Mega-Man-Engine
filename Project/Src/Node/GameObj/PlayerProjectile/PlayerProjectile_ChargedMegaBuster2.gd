extends PlayerProjectile

onready var palette_sprite := $Sprite/PaletteSprite

func _process(delta: float) -> void:
	palette_sprite.primary_sprite.modulate = GlobalVariables.current_player_primary_color
	palette_sprite.second_sprite.modulate = GlobalVariables.current_player_secondary_color
	palette_sprite.outline_sprite.modulate = GlobalVariables.current_player_outline_color
