class_name EnemyChaseState extends EnemyMovementState

@export var MAXIMUM_RANGED_ATTACK_DISTANCE : float = 15.0

@onready var PLAYER : Player = get_tree().get_first_node_in_group("player")

func enter(previous_state : State) -> void:
	print("chasing")
	pass

func update(delta : float) -> void:
	if ENEMY.global_position.distance_to(PLAYER.global_position) <= MAXIMUM_RANGED_ATTACK_DISTANCE:
		transition.emit("EnemyAttackState")

func physics_update(delta: float) -> void:
	ENEMY.update_target_position(PLAYER.global_position)
	
	
#func _physics_process(delta: float) -> void:
	#var destination = NAVIGATION_AGENT_3D.get_next_path_position()
	#var local_destination = destination - global_position
	#var direction = local_destination.normalized()
	#velocity = direction * 5.0
	#move_and_slide()
#
#func update_target_position(new_position : Vector3) -> void:	
	#NAVIGATION_AGENT_3D.set_target_position(new_position)
