#DeadEnemyInfo
#Code by: First

#Used in EnemyCore for the purposes: Perma-Death in scene or level.
#This contains the information about the spawn location, enemy id, etc.

extends Resource

class_name DeadEnemyInfo

### Export variables ###

export var file_name : String = ""

export var global_pos : Vector2

#If this is not defined, it's considered as perma_death within level.
export var scene_file_name : String = ""

