class_name EnemyAlertState extends EnemyMovementState

@export var MINIMUM_RANGED_ATTACK_DISTANCE : float = 2.0
@export var MAXIMUM_RANGED_ATTACK_DISTANCE : float = 7.0
@export var HAS_RANGED_ATTACK : bool = true
@export var HAS_MELEE_ATTACK : bool = false

@onready var PLAYER : Player = get_tree().get_first_node_in_group("player")

func enter(previous_state : State) -> void:
	var distance = ENEMY.global_position.distance_to(PLAYER.global_position)
	if distance > MINIMUM_RANGED_ATTACK_DISTANCE and distance < MAXIMUM_RANGED_ATTACK_DISTANCE and HAS_RANGED_ATTACK:
		print("transition to ranged attack")
		transition.emit(("EnemyRangedAttackState"))
		
	if distance > MAXIMUM_RANGED_ATTACK_DISTANCE:
		transition.emit("EnemyChaseState")
		print("transition to chase state")
		
	if distance < MINIMUM_RANGED_ATTACK_DISTANCE:
		if HAS_MELEE_ATTACK:
			print("transition to melee attack")
		else:
			print("transition to ranged attack (close)")
