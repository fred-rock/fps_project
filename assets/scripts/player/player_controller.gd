class_name PlayerController extends CharacterBody3D

@export var debug : bool = false
@export_category("References")
@export var camera : CameraController
@export var camera_effects : CameraEffects
@export var state_chart : StateChart
@export var standing_collision : CollisionShape3D
@export var crouching_collision : CollisionShape3D
@export var crouch_check : ShapeCast3D
@export var interaction_raycast : RayCast3D
@export var step_handler : StepHandlerComponent
@export_category("Movement Settings")
@export_category("Easing")
@export var acceleration : float = 0.2
@export var deceleration : float = 0.5
@export_category("Speed")
@export var default_speed : float = 7.0
@export var sprint_speed : float = 10.0
@export var crouch_speed : float = -5.0
@export_category("Jump Settings")
@export var jump_velocity : float = 5.0
@export var fall_velocity_threshold : float = -5.0

var _input_dir : Vector2 = Vector2.ZERO
var _movement_velocity : Vector3 = Vector3.ZERO
var _sprint_modifier : float = 0.0
var _crouch_modifier : float = 0.0
var _speed : float = 0.0

var current_fall_velocity : float
var previous_velocity : Vector3

func _physics_process(delta: float) -> void:
	previous_velocity = velocity
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var speed_modifier = _sprint_modifier
	_speed = default_speed + speed_modifier
		
	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var current_velocity = Vector2(_movement_velocity.x, _movement_velocity.z)
	var direction = (transform.basis * Vector3(_input_dir.x, 0.0, _input_dir.y)).normalized()
		
	if direction:
		current_velocity = lerp(current_velocity, Vector2(direction.x, direction.z) * _speed, acceleration)
	else: 
		current_velocity = current_velocity.move_toward(Vector2.ZERO, deceleration)
	
	_movement_velocity = Vector3(current_velocity.x, velocity.y, current_velocity.y)
	
	velocity = _movement_velocity
	
	move_and_slide()
	
	if is_on_floor():
		step_handler.handle_step_climbing()

func update_rotation(rotation_input) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)
	
func sprint() -> void:
	_sprint_modifier = sprint_speed
	
func walk() -> void:
	_sprint_modifier = 0.0
	
func stand() -> void:
	_crouch_modifier = 0.0
	standing_collision.disabled = false
	crouching_collision.disabled = true
	
func crouch() -> void:
	_crouch_modifier = crouch_speed
	standing_collision.disabled = true
	crouching_collision.disabled = false
	
func jump() -> void:
	velocity.y += jump_velocity

func check_fall_speed() -> bool:
	if current_fall_velocity < fall_velocity_threshold:
		current_fall_velocity = 0.0
		return true
	else:
		current_fall_velocity = 0.0
		return false

func get_input_direction() -> Vector2:
	return _input_dir
