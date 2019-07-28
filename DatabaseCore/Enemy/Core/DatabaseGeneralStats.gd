extends Node

class_name EnemyDatabaseGeneralStats

enum HealthRegenType {
	INTERVAL = 1,
	CONSTANT = 2,
	NONE = 0
}

export (String) var nickname = "Unnamed"
export (int) var level = 1

export (int, 1, 2147483647) var hit_points_base = 40 #Initial maximum hit points.

export var repel_player_enabled = true #Repel player away when damage is applied
export var repel_power = 300 #Strength to push player away when collided with enemy.
