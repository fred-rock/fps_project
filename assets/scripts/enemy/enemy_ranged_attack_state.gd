class_name EnemyRangedAttackState extends EnemyMovementState

@onready var PLAYER : Player = get_tree().get_first_node_in_group("player")
#var projectile = preload("res://scenes/projectiles/projectile.tscn")
@onready var PROJECTILE_LAUNCHER : ProjectileLauncher = $"../../ProjectileLauncher"

func enter(previous_state : State) -> void:
	# Play animation
	# Fire projectile
	var proj = projectile.instantiate()
	proj.launch()
	print(proj)

func physics_update(delta : float) -> void:
	pass

func attack():
	pass
