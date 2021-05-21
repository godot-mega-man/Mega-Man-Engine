extends EnemyCore


func _ready() -> void:
	if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
		$SubObj/MM10_TricastleEyesMiddle.current_hp = 9
		$SubObj/MM10_TricastleEyesTowerLeft.current_hp = 4
		$SubObj/MM10_TricastleEyesTowerRight.current_hp = 4
	if Difficulty.difficulty == Difficulty.DIFF_CASUAL:
		$SubObj/MM10_TricastleEyesMiddle.current_hp = 12
		$SubObj/MM10_TricastleEyesTowerLeft.current_hp = 6
		$SubObj/MM10_TricastleEyesTowerRight.current_hp = 6
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		$SubObj/MM10_TricastleEyesMiddle.current_hp = 40
		$SubObj/MM10_TricastleEyesTowerLeft.current_hp = 12
		$SubObj/MM10_TricastleEyesTowerRight.current_hp = 12


func initiate_battle_process():
	_make_eyes_uninvul()
	$TricastleAttackPattern.start()


func try_begin_raise_flag():
	if not can_raise_flag():
		return
	
	raise_flag_and_collapse()
	destroy_leftover_nodes()


func can_raise_flag() -> bool:
	for enemy in get_tree().get_nodes_in_group("TricastleEyes"):
		if enemy.get_owner() == self and enemy.current_hp > 0:
			return false
	
	return true


func raise_flag_and_collapse():
	$SpriteMain/Anim.play("RaiseFlag")
	yield($SpriteMain/Anim, "animation_finished")
	$SpriteMain/Anim.play("Collapse")
	yield($SpriteMain/Anim, "animation_finished")
	queue_free()


func destroy_leftover_nodes():
	for enemy in get_tree().get_nodes_in_group("TricastlePlatform"):
		enemy.die()
	for enemy in get_tree().get_nodes_in_group("Peat"):
		enemy.die()
	
	$TricastleAttackPattern.queue_free()
	$SubObj/MM10_TricastlePlatformSpawner.queue_free()


func create_explosion():
	level_camera.camera_shaker.shake(3, 50, 2)
	
	var eff = preload("res://Src/Node/GameObj/Effects/LargeExplosion/LargeExplosion.tscn").instance()
	get_parent().add_child(eff)
	eff.global_position = global_position
	eff.position += Vector2(64, 32) * rand_range(-1, 1)
	FJ_AudioManager.sfx_combat_large_explosion_mm3.play()


func create_collapse_effects():
	level_camera.camera_shaker.shake(2.5, 50, 2.5)
	
	for i in 12:
		var eff = preload("res://Src/Node/GameObj/Effects/Explosion/Explosion.tscn").instance()
		get_parent().add_child(eff)
		eff.global_position = $SpriteMain/CollapseEffPos.global_position
		eff.position += Vector2(64, 0) * rand_range(-1, 1)
		
		FJ_AudioManager.sfx_combat_boulder.play()
		yield(get_tree().create_timer(0.15), "timeout")


func _make_eyes_uninvul():
	for enemy in get_tree().get_nodes_in_group("TricastleEyes"):
		if enemy.get_owner() != self:
			return
		
		enemy.can_hit = true
		enemy.can_damage = true
		enemy.eat_player_projectile = true
		enemy.blink()


func _on_MM10_TricastleEyesTowerLeft_slain(target) -> void:
	try_begin_raise_flag()


func _on_MM10_TricastleEyesTowerRight_slain(target) -> void:
	try_begin_raise_flag()


func _on_MM10_TricastleEyesMiddle_slain(target) -> void:
	$SubObj/MM10_TricastleDoor.die()
	try_begin_raise_flag()


func _on_TricastleAttackPattern_turn(tricastle_eyes) -> void:
	print(tricastle_eyes)
