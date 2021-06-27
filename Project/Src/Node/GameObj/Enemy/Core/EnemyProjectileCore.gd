# EnemyProjectile
#
# This is kept because it'd be pretty heckin annoying to have to copy
# in everything below for every new EnemyCore object
# that you want to be a projectile...

class_name EnemyProjectile extends EnemyCore


export(int, "Cannot Be Stopped", "Can Be Reflected", "Is Destroyed") var reflectable = 1


onready var bullet_behavior : FJ_BulletBehavior = $BulletBehavior
