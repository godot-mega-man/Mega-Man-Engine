# Platformer Sprite
#
# Platformer Sprite uses predefined animation presets to animate a moving
# KinematicBody2D character.


extends Sprite


const MAX_TIP_TOE_FRAME = 7


export(NodePath) var path_to_platformer_behavior

export(bool) var animation_paused = false #For screen transition purposes


onready var character_platformer_animation = $CharacterPlatformerAnimation

# Normal Attack Cooldown. Define how long the animation will come back
# to non-attacking state.
onready var normal_attack_cooldown = $NormalAttackCooldown

onready var palette_sprite := $PaletteSprite as PaletteSprite


var is_path_to_platformer_behavior_valid : bool = false

var casted_plat_bhv : FJ_PlatformBehavior2D #Casted Platformer Behavior. For use in _process().

var is_launching_normal_attack : bool = false

var is_taking_damage : bool = false

var is_sliding : bool = false


func _ready() -> void:
	if path_to_platformer_behavior != null:
		var plat_bhv_node = get_node(path_to_platformer_behavior)
		if plat_bhv_node is FJ_PlatformBehavior2D:
			is_path_to_platformer_behavior_valid = true
			casted_plat_bhv = plat_bhv_node
			return
	
	#If not true from all of the above..
	push_warning(
		str(
			self.name,
			": Path to PlatformerBehavior is null or invalid.",
			" Consider removing it for improved performance."
		)
	)


func _process(delta: float) -> void:
	if not is_path_to_platformer_behavior_valid:
		return
	if casted_plat_bhv == null:
		return
	if animation_paused:
		return
	
	if is_taking_damage:
		if not is_sliding:
			character_platformer_animation.play("Damage")
		else:
			character_platformer_animation.play("Damage Sliding")
	elif casted_plat_bhv.on_floor:
		if is_launching_normal_attack:
			if not is_sliding:
				if casted_plat_bhv.walk_left or casted_plat_bhv.walk_right:
					if casted_plat_bhv.left_right_key_press_time < casted_plat_bhv.MAX_TIP_TOE_FRAME:
						character_platformer_animation.play("Tipping Toe Shooting")
					else:
						character_platformer_animation.play("Shooting Walk")
				else:
					character_platformer_animation.play("Shooting Idle")
			else:
				character_platformer_animation.play("Shooting Sliding")
		else:
			if not is_sliding:
				if casted_plat_bhv.walk_left or casted_plat_bhv.walk_right:
					if casted_plat_bhv.left_right_key_press_time < casted_plat_bhv.MAX_TIP_TOE_FRAME:
						character_platformer_animation.play("Tipping Toe")
					else:
						character_platformer_animation.play("Walk")
				else:
					character_platformer_animation.play("Idle")
			else:
				character_platformer_animation.play("Sliding")
	else:
		if is_launching_normal_attack:
			if casted_plat_bhv.velocity.y < 0:
				character_platformer_animation.play("Shooting Jump Up")
			else:
				character_platformer_animation.play("Shooting Jump Falling")
		else:
			if casted_plat_bhv.velocity.y < 0:
				character_platformer_animation.play("Jump Up")
			else:
				character_platformer_animation.play("Jump Falling")


func start_normal_attack_animation():
	normal_attack_cooldown.start()
	is_launching_normal_attack = true


# When normal attack cooldown timer timed out (usually player has launched
# a normal attack a few milliseconds ago), the animation will come back
# to non-attacking state.
func _on_NormalAttackCooldown_timeout() -> void:
	is_launching_normal_attack = false

