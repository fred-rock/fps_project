class_name StateMachine extends Node3D

@export var CURRENT_STATE : State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("State machine contains incompatible child node.")
			
	await owner.ready
	CURRENT_STATE.enter(null)

func _process(delta: float) -> void:
	CURRENT_STATE.update(delta)
	# TODO: Move the debug assignment out of this script, as it creates a dependency with a UI node on the player controller
	#Global.debug.add_property("Current state", CURRENT_STATE.name, 1)
	
func _physics_process(delta: float) -> void:
	CURRENT_STATE.physics_update(delta)
	
func on_child_transition(new_state_name: StringName) -> void:
	var new_state = states.get(new_state_name)
	if new_state != null:
		if new_state != CURRENT_STATE:
			CURRENT_STATE.exit()
			new_state.enter(CURRENT_STATE)
			CURRENT_STATE = new_state
	else:
		push_warning("State does not exist.")
