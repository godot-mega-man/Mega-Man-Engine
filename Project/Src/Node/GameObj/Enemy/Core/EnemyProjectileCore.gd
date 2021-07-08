# EnemyProjectile


class_name EnemyProjectile extends EnemyCore


export(int, "Cannot Be Stopped", "Can Be Reflected", "Is Destroyed") var reflectable = 1


onready var bullet_behavior : FJ_BulletBehavior = $BulletBehavior
