class_name CameraEffects extends Camera3D

@export_category("References")
@export var player : PlayerController

@export_category("Effects")
@export var enable_tilt : bool = true
@export var enable_fall_kick : bool = true
@export var enable_damage_kick : bool = true
@export var enable_weapon_kick : bool = true
@export var enable_screen_shake : bool = true
@export var enable_headbob : bool = true

@export_category("Kick & Recoil Settings")
@export_group("Run Tilt")
@export var run_pitch : float = 0.1 # Degrees
@export var run_roll : float = 0.25 # Degrees
@export var max_pitch : float = 1.0 # Degrees
@export var max_roll : float = 2.5 # Degrees
@export_group("Camera Kick")
@export_subgroup("Fall Kick")
@export var fall_time : float = 0.3
@export_subgroup("Damage Kick")
@export var damage_time : float = 0.3
@export_subgroup("Weapon Kick")
@export var weapon_decay : float = 0.5
@export_subgroup("Headbob")
@export_range(0.0, 0.1, 0.001) var bob_pitch : float = 0.05
@export_range(0.0, 0.1, 0.001) var bob_roll : float = 0.025
@export_range(0.0, 0.1, 0.001) var bob_up : float = 0.005
@export_range(0.0, 0.1, 0.001) var bob_frequency : float = 6.0

var _fall_value : float = 0.0
var _fall_timer : float = 0.0

var _damage_pitch : float = 0.0
var _damage_roll : float = 0.0
var _damage_timer : float = 0.0

var _weapon_kick_angles : Vector3 = Vector3.ZERO

var _screen_shake_tween : Tween

var _step_timer : float = 0.0

const MIN_SCREEN_SHAKE : float = 0.05
const MAX_SCREEN_SHAKE : float = 0.5

func _process(delta: float) -> void:
	calculate_view_offset(delta)
	
	if Input.is_action_just_pressed("test"):
		add_screen_shake(5, 2)
	
func calculate_view_offset(delta):
	if not player:
		return
		
	_fall_timer -= delta
	_damage_timer -= delta
		
	var velocity = player.velocity
	
	# Headbob Step Timer and Sin Value
	var speed = Vector2(velocity.x, velocity.z).length()
	if speed > 0.1 and player.is_on_floor():
		_step_timer += delta * (speed / bob_frequency)
		_step_timer = fmod(_step_timer, 1.0)
	else:
		_step_timer = 0.0
	var bob_sin = sin(_step_timer * 2.0 * PI) * 0.5 # 0.5 reduces the magnitude of the sine wave, i.e. less movement
	
	var angles = Vector3.ZERO
	var offset = Vector3.ZERO
	
	# Camera Tilt
	if enable_tilt:
		var forward = global_transform.basis.z
		var right = global_transform.basis.x
		
		var forward_dot = velocity.dot(forward)
		var forward_tilt = clampf(forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
		angles.x += forward_tilt
		
		var right_dot = velocity.dot(right)
		var side_tilt = clampf(right_dot * deg_to_rad(run_roll), deg_to_rad(-max_roll), deg_to_rad(max_roll))
		angles.z -= side_tilt
	
	# Fall Kick
	if enable_fall_kick:
		var fall_ratio = max(0.0, _fall_timer / fall_time)
		var fall_kick_amount = fall_ratio * _fall_value
		angles.x -= fall_kick_amount
		offset.y -= fall_kick_amount
		
	# Damage Kick
	if enable_damage_kick:
		var damage_ratio = max(0.0, _damage_timer / damage_time)
		# damage_ratio = ease(damage_ratio, -2) # If you want to ease over time
		angles.x += damage_ratio * _damage_pitch
		angles.z += damage_ratio * _damage_roll
		
	# Weapon Kick
	if enable_weapon_kick:
		_weapon_kick_angles = _weapon_kick_angles.move_toward(Vector3.ZERO, weapon_decay * delta)
		angles += _weapon_kick_angles
		
	# Headbob
	if enable_headbob:
		var pitch_delta = bob_sin * deg_to_rad(bob_pitch) * speed
		angles.x -= pitch_delta
		
		var roll_delta = bob_sin * deg_to_rad(bob_roll) * speed
		angles.z -= roll_delta
		
		var bob_height = bob_sin * speed * bob_up
		offset.y += bob_height
		
	position = offset
	rotation = angles
	
func add_fall_kick(fall_strength: float):
	_fall_value = deg_to_rad(fall_strength)
	_fall_timer = fall_time
	
func add_damage_kick(pitch: float, roll: float, source: Vector3):
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	var direction = global_position.direction_to(source)
	var forward_dot = direction.dot(forward)
	var right_dot = direction.dot(right)
	_damage_pitch = deg_to_rad(pitch) * forward_dot
	_damage_roll = deg_to_rad(roll) * right_dot
	_damage_timer = damage_time
	
func add_weapon_kick(pitch: float, yaw: float, roll: float):
	_weapon_kick_angles.x += deg_to_rad(pitch)
	_weapon_kick_angles.y += deg_to_rad(randf_range(-yaw, yaw))
	_weapon_kick_angles.z += deg_to_rad(randf_range(-roll, roll))
	
func add_screen_shake(amount: float, seconds: float) -> void:
	if _screen_shake_tween:
		_screen_shake_tween.kill()
		
	_screen_shake_tween = create_tween()
	_screen_shake_tween.tween_method(update_screen_shake.bind(amount), 0.0, 1.0, seconds).set_ease(Tween.EASE_OUT)
	
func update_screen_shake(alpha: float, amount: float) -> void:
	amount = remap(amount, 0.0, 1.0, MIN_SCREEN_SHAKE, MAX_SCREEN_SHAKE)
	var current_shake_amount = amount * (1.0 - alpha)
	h_offset = randf_range(-current_shake_amount, current_shake_amount)
	v_offset = randf_range(-current_shake_amount, current_shake_amount)
