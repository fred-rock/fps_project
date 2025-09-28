class_name Enemy extends CharacterBody3D

@export var MINIMUM_RANGED_ATTACK_DISTANCE : float = 5.0
@export var MAXIMUM_RANGED_ATTACK_DISTANCE : float = 15.0
@export var HAS_MELEE_ATTACK : bool = false

@onready var ANIMATIONPLAYER : AnimationPlayer = $AnimationPlayer
@onready var NAVIGATION_AGENT_3D : NavigationAgent3D = $NavigationAgent3D
@onready var VISION_AREA : Area3D = $VisionArea

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("jump"): # testing with spacebar input
		#var random_position := Vector3.ZERO
		#random_position.x = randf_range(-5.0, 5.0)
		#random_position.z = randf_range(-5.0, 5.0)
		#NAVIGATION_AGENT_3D.set_target_position(random_position)

func _physics_process(delta: float) -> void:
	var destination = NAVIGATION_AGENT_3D.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	velocity = direction * 5.0
	move_and_slide()

func update_target_position(new_position : Vector3) -> void:	
	NAVIGATION_AGENT_3D.set_target_position(new_position)
