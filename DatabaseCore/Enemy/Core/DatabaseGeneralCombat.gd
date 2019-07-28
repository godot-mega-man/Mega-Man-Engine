extends Node

class_name EnemyDatabaseGeneralCombat

export (float) var contact_damage = 1 #Deals damage when collided with player.
export var death_immunity = false #When true, enemy cannot die normally.
export var can_hit = true #When true, enemy won't take any damage from any sources.
export var damage_taken_minimum = 0 #Minimum damage taken from player's projectile
export var eat_player_projectile = true #When on, enemy can attempt to destroy the player's bullet.

export var can_damage = true #If false, player can collide with enemy without taking damage.
export var damage_custom_invis_enabled = false #If on, player will have a custom invisibility time after damage is taken.
export var damage_custom_invis_timer = 0.1 #How long the player will be able to take damage again.
