class_name EnemyIdleState extends EnemyMovementState

@onready var PLAYER : Player = get_tree().get_first_node_in_group("player")
@onready var VISION_AREA : Area3D = $"../../VisionArea"

func enter(previous_state : State) -> void:
	VISION_AREA.body_entered.connect(on_body_entered)

func on_body_entered(body : CharacterBody3D) -> void:
	if body is Player:
		transition.emit("EnemyAlertState")
