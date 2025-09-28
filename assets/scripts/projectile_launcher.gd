class_name ProjectileLauncher extends Node3D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 0.5  # Time between shots in seconds
@export var projectile_speed: float = 25.0
@export var muzzle_velocity_variance: float = 2.0  # Random speed variation
@export var spread_angle: float = 0.0  # Cone of fire in degrees (0 = perfectly straight)
@export var auto_fire: bool = false
@export var ammo_count: int = -1  # -1 for infinite ammo
@export var muzzle_flash_duration: float = 0.1

@onready var muzzle_point: Marker3D = $MuzzlePoint
@onready var fire_timer: Timer = $FireTimer
@onready var muzzle_flash: Node3D = $MuzzlePoint/MuzzleFlash  # Optional muzzle flash effect

var can_fire: bool = true
var current_ammo: int
var is_firing: bool = false

signal projectile_fired(projectile: Projectile)
signal ammo_empty
signal ammo_changed(current: int, max: int)

func _ready() -> void:
	# Initialize ammo
	current_ammo = ammo_count
	
	# Set up fire rate timer
	fire_timer.wait_time = fire_rate
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.one_shot = true
	
	# Hide muzzle flash initially
	if muzzle_flash:
		muzzle_flash.visible = false
	
	# Validate required components
	if not projectile_scene:
		push_error("ProjectileLauncher: No projectile scene assigned!")
	if not muzzle_point:
		push_error("ProjectileLauncher: No MuzzlePoint child node found!")

func _process(_delta: float) -> void:
	if auto_fire and is_firing and can_fire:
		fire()

func start_firing() -> void:
	is_firing = true
	if can_fire:
		fire()

func stop_firing() -> void:
	is_firing = false

func fire() -> bool:
	if not can_fire or not projectile_scene:
		return false
	
	# Check ammo
	if ammo_count >= 0 and current_ammo <= 0:
		ammo_empty.emit()
		return false
	
	# Create and configure projectile
	var projectile = projectile_scene.instantiate() as Projectile
	if not projectile:
		push_error("ProjectileLauncher: Projectile scene must have Projectile script!")
		return false
	
	# Add projectile to scene
	get_tree().current_scene.add_child(projectile)
	
	# Set projectile properties
	projectile.global_position = muzzle_point.global_position
	projectile.shooter = get_parent()  # Assume launcher is child of shooter
	
	# Calculate firing direction with spread
	var fire_direction = get_firing_direction()
	var speed_with_variance = projectile_speed + randf_range(-muzzle_velocity_variance, muzzle_velocity_variance)
	
	# Launch the projectile
	projectile.launch(fire_direction, speed_with_variance)
	
	# Update ammo
	if ammo_count >= 0:
		current_ammo -= 1
		ammo_changed.emit(current_ammo, ammo_count)
	
	# Start cooldown
	can_fire = false
	fire_timer.start()
	
	# Show muzzle flash
	show_muzzle_flash()
	
	# Emit signal
	projectile_fired.emit(projectile)
	
	return true

func get_firing_direction() -> Vector3:
	var base_direction = -muzzle_point.global_transform.basis.z  # Forward direction
	
	if spread_angle <= 0:
		return base_direction
	
	# Add random spread within cone
	var spread_rad = deg_to_rad(spread_angle)
	var random_angle = randf() * TAU  # Random angle around the cone
	var random_deviation = randf() * spread_rad  # Random deviation from center
	
	# Create random direction within cone
	var right = muzzle_point.global_transform.basis.x
	var up = muzzle_point.global_transform.basis.y
	
	var offset = (right * cos(random_angle) + up * sin(random_angle)) * sin(random_deviation)
	var spread_direction = (base_direction * cos(random_deviation) + offset).normalized()
	
	return spread_direction

func show_muzzle_flash() -> void:
	if not muzzle_flash:
		return
	
	muzzle_flash.visible = true
	
	# Hide muzzle flash after duration
	var tween = create_tween()
	tween.tween_delay(muzzle_flash_duration)
	tween.tween_callback(func(): muzzle_flash.visible = false)

func reload(amount: int = -1) -> void:
	if ammo_count < 0:
		return  # Infinite ammo, no need to reload
	
	if amount == -1:
		current_ammo = ammo_count  # Full reload
	else:
		current_ammo = min(current_ammo + amount, ammo_count)
	
	ammo_changed.emit(current_ammo, ammo_count)

func set_fire_rate(new_rate: float) -> void:
	fire_rate = new_rate
	fire_timer.wait_time = fire_rate

func has_ammo() -> bool:
	return ammo_count < 0 or current_ammo > 0

func get_ammo_ratio() -> float:
	if ammo_count < 0:
		return 1.0  # Infinite ammo
	return float(current_ammo) / float(ammo_count)

func _on_fire_timer_timeout() -> void:
	can_fire = true

# Optional: Burst fire mode
func fire_burst(burst_count: int, burst_delay: float = 0.1) -> void:
	if not can_fire:
		return
		
	for i in burst_count:
		if fire():
			if i < burst_count - 1:  # Don't wait after last shot
				await get_tree().create_timer(burst_delay).timeout
