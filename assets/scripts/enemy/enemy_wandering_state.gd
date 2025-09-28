class_name EnemyWanderingState extends EnemyMovementState

@onready var PLAYER : Player = get_tree().get_first_node_in_group("player")
@onready var VISION_AREA : Area3D = $"../../VisionArea"

func enter(previous_state : State) -> void:
	VISION_AREA.body_entered.connect(on_body_entered)

func on_body_entered(body : CharacterBody3D) -> void:
	if body is Player:
		transition.emit("EnemyAlertState")

#func _physics_process(delta: float) -> void:
	#var destination = NAVIGATION_AGENT_3D.get_next_path_position()
	#var local_destination = destination - global_position
	#var direction = local_destination.normalized()
	#velocity = direction * 5.0
	#move_and_slide()
#
#func update_target_position(new_position : Vector3) -> void:	
	#NAVIGATION_AGENT_3D.set_target_position(new_position)
