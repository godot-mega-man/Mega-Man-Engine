#Platformer Sprite
#Code by: First

#Platformer Sprite uses predefined animation presets to animate a moving
#KinematicBody2D character.
#To see each of its sprite patterns for using character design(Artist),
#there is an example template image located in-
#res://DEV_ExampleUsages/Ex_LevelCreationTest/MegaMan_Level/PlayerCustomSprite/Reimu_Template.png

#How it work and how to get it work?
#Load a spritesheet (from a template) which is 480 pixels wide and at
#any pixels height. Each sprite cells is 48x48 pixels with a total of 10
#sprites for each row.
#This PlatformerSprite also includes an AnimationPlayer that animates
#sprites through spritesheet by current KinematicBody2D's behavior.
#When done. Assign a path to PlatformerBehavior node from the script
#variables.

extends Sprite

export(NodePath) var path_to_platformer_behavior

#--Child nodes--
onready var character_platformer_animation = $CharacterPlatformerAnimation

#Normal Attack Cooldown. Define how long the animation will come back
#to non-attacking state.
onready var normal_attack_cooldown = $NormalAttackCooldown



#Temp
var is_path_to_platformer_behavior_valid : bool = false
var casted_plat_bhv : PlatformerBehavior #Casted Platformer Behavior. For use in _process().
var is_launching_normal_attack : bool = false

func _ready() -> void:
	if path_to_platformer_behavior != null:
		var plat_bhv_node = get_node(path_to_platformer_behavior)
		if plat_bhv_node is PlatformerBehavior:
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
	
	if casted_plat_bhv.on_floor:
		if is_launching_normal_attack:
			if casted_plat_bhv.walk_left or casted_plat_bhv.walk_right:
				character_platformer_animation.play("Shooting Walk")
			else:
				character_platformer_animation.play("Shooting Idle")
		else:
			if casted_plat_bhv.walk_left or casted_plat_bhv.walk_right:
				character_platformer_animation.play("Walk")
			else:
				character_platformer_animation.play("Idle")
	else:
		if is_launching_normal_attack:
			character_platformer_animation.play("Shooting Jump")
		else:
			character_platformer_animation.play("Jump")

func start_normal_attack_animation():
	normal_attack_cooldown.start()
	is_launching_normal_attack = true

#When normal attack cooldown timer timed out (usually player has launched
#a normal attack a few milliseconds ago), the animation will come back
#to non-attacking state.
func _on_NormalAttackCooldown_timeout() -> void:
	is_launching_normal_attack = false
