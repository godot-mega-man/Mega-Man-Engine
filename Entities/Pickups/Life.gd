extends Pickups

const HLTH = 28

onready var sprite = $SpriteMain/Sprite
onready var palette_sprite := $SpriteMain/Sprite/PaletteSprite

onready var player = $"/root/Level/Iterable/Player"

func _ready() -> void:
	#Load sprite by current active player.
	pass

func _on_Life_collected_by_player(player_obj) -> void:
	if player_obj is Player:
		FJ_AudioManager.sfx_ui_one_up.play()
		player_obj.heal(HLTH)

func _process(delta: float) -> void:
	palette_sprite.primary_sprite.modulate = GlobalVariables.current_player_primary_color
	palette_sprite.second_sprite.modulate = GlobalVariables.current_player_secondary_color
	palette_sprite.outline_sprite.modulate = GlobalVariables.current_player_outline_color
	
	#Load sprite by current active player.
	if player != null:
		if player.platformer_sprite != null:
			sprite.texture = player.platformer_sprite.texture