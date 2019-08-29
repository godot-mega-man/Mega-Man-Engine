extends EnemyProjectile

onready var palette_sprite := $SpriteMain/Sprite/PaletteSprite as PaletteSprite

var h_flame = preload("res://Entities/Enemy/Obj/MM6_FlameBurstHorizontal.tscn")
var v_flame = preload("res://Entities/Enemy/Obj/MM6_FlameBurstVertical.tscn")

var is_frame_spawned = false

func _on_PlatformBehavior_landed() -> void:
	if is_frame_spawned:
		return
	
	var enemy_flame_obj = v_flame.instance()
	get_parent().add_child(enemy_flame_obj)
	enemy_flame_obj.global_position = global_position
	enemy_flame_obj.get_node("SpriteMain/Sprite/PaletteSprite").primary_sprite.modulate = palette_sprite.primary_sprite.modulate
	enemy_flame_obj.get_node("SpriteMain/Sprite/PaletteSprite").second_sprite.modulate = palette_sprite.second_sprite.modulate
	
	FJ_AudioManager.sfx_combat_flame_burst.play()
	
	queue_free()

func _on_PlatformBehavior_by_wall() -> void:
	if is_frame_spawned:
		return
	
	var enemy_flame_obj = h_flame.instance()
	get_parent().add_child(enemy_flame_obj)
	enemy_flame_obj.global_position = global_position
	enemy_flame_obj.get_node("SpriteMain/Sprite/PaletteSprite").primary_sprite.modulate = palette_sprite.primary_sprite.modulate
	enemy_flame_obj.get_node("SpriteMain/Sprite/PaletteSprite").second_sprite.modulate = palette_sprite.second_sprite.modulate
	
	if bullet_behavior.angle_in_degrees < -90:
		enemy_flame_obj.scale.x = -1
	
	FJ_AudioManager.sfx_combat_flame_burst.play()
	
	queue_free()
